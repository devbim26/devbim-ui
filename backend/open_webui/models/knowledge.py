import json
import logging
import time
from typing import Optional
import uuid

from open_webui.internal.db import Base, get_db
from open_webui.env import SRC_LOG_LEVELS

from open_webui.models.files import FileMetadataResponse
from open_webui.models.groups import Groups
from open_webui.models.users import Users, UserResponse


from pydantic import BaseModel, ConfigDict
from sqlalchemy import BigInteger, Column, String, Text, JSON

from open_webui.utils.access_control import has_access

log = logging.getLogger(__name__)
log.setLevel(SRC_LOG_LEVELS["MODELS"])

####################
# Knowledge DB Schema
####################


class Knowledge(Base):
    __tablename__ = "knowledge"

    id = Column(Text, unique=True, primary_key=True)
    user_id = Column(Text)

    name = Column(Text)
    description = Column(Text)

    data = Column(JSON, nullable=True)
    meta = Column(JSON, nullable=True)

    access_control = Column(JSON, nullable=True)  # Controls data access levels.
    # Defines access control rules for this entry.
    # - `None`: Public access, available to all users with the "user" role.
    # - `{}`: Private access, restricted exclusively to the owner.
    # - Custom permissions: Specific access control for reading and writing;
    #   Can specify group or user-level restrictions:
    #   {
    #      "read": {
    #          "group_ids": ["group_id1", "group_id2"],
    #          "user_ids":  ["user_id1", "user_id2"]
    #      },
    #      "write": {
    #          "group_ids": ["group_id1", "group_id2"],
    #          "user_ids":  ["user_id1", "user_id2"]
    #      }
    #   }

    created_at = Column(BigInteger)
    updated_at = Column(BigInteger)


class KnowledgeModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str

    name: str
    description: str

    data: Optional[dict] = None
    meta: Optional[dict] = None

    access_control: Optional[dict] = None

    created_at: int  # timestamp in epoch
    updated_at: int  # timestamp in epoch


####################
# Forms
####################


class KnowledgeUserModel(KnowledgeModel):
    user: Optional[UserResponse] = None


class KnowledgeResponse(KnowledgeModel):
    files: Optional[list[FileMetadataResponse | dict]] = None


class KnowledgeUserResponse(KnowledgeUserModel):
    files: Optional[list[FileMetadataResponse | dict]] = None


class KnowledgeForm(BaseModel):
    name: str
    description: str
    data: Optional[dict] = None
    access_control: Optional[dict] = None


class KnowledgeTable:
    def insert_new_knowledge(
        self, user_id: str, form_data: KnowledgeForm
    ) -> Optional[KnowledgeModel]:
        with get_db() as db:
            knowledge = KnowledgeModel(
                **{
                    **form_data.model_dump(),
                    "id": str(uuid.uuid4()),
                    "user_id": user_id,
                    "created_at": int(time.time()),
                    "updated_at": int(time.time()),
                }
            )

            try:
                result = Knowledge(**knowledge.model_dump())
                db.add(result)
                db.commit()
                db.refresh(result)
                if result:
                    return KnowledgeModel.model_validate(result)
                else:
                    return None
            except Exception:
                return None

    def get_knowledge_bases(self) -> list[KnowledgeUserModel]:
        with get_db() as db:
            all_knowledge = (
                db.query(Knowledge).order_by(Knowledge.updated_at.desc()).all()
            )

            user_ids = list(set(knowledge.user_id for knowledge in all_knowledge))

            users = Users.get_users_by_user_ids(user_ids) if user_ids else []
            users_dict = {user.id: user for user in users}

            knowledge_bases = []
            for knowledge in all_knowledge:
                user = users_dict.get(knowledge.user_id)
                knowledge_bases.append(
                    KnowledgeUserModel.model_validate(
                        {
                            **KnowledgeModel.model_validate(knowledge).model_dump(),
                            "user": user.model_dump() if user else None,
                        }
                    )
                )
            return knowledge_bases

    def check_access_by_user_id(self, id, user_id, permission="write") -> bool:
        """
        Проверить доступ пользователя к конкретной базе знаний.
        
        Args:
            id: ID базы знаний
            user_id: ID пользователя
            permission: "read" или "write" - уровень доступа
            
        Returns:
            True если пользователь имеет указанный уровень доступа
        """
        knowledge = self.get_knowledge_by_id(id)
        if not knowledge:
            return False
        if knowledge.user_id == user_id:
            return True
        
        user_group_ids = {group.id for group in Groups.get_groups_by_member_id(user_id)}
        
        # Для чтения проверяем read или write доступ (write включает read)
        if permission == "read":
            return has_access(user_id, "read", knowledge.access_control, user_group_ids) or \
                   has_access(user_id, "write", knowledge.access_control, user_group_ids)
        else:
            # Для записи проверяем только write доступ
            return has_access(user_id, "write", knowledge.access_control, user_group_ids)

    def get_knowledge_bases_by_user_id(
        self, user_id: str, permission: str = "write"
    ) -> list[KnowledgeUserModel]:
        """
        Получить базы знаний, доступные пользователю с указанным уровнем доступа.
        
        Args:
            user_id: ID пользователя
            permission: "read" или "write" - уровень доступа
            
        Returns:
            Список баз знаний, доступных пользователю
        """
        knowledge_bases = self.get_knowledge_bases()
        user_group_ids = {group.id for group in Groups.get_groups_by_member_id(user_id)}
        
        log.info(f"get_knowledge_bases_by_user_id: user_id={user_id}, permission={permission}")
        log.info(f"Total knowledge bases: {len(knowledge_bases)}")
        log.info(f"User group IDs: {user_group_ids}")
        
        # Для чтения включаем:
        # 1. Собственные знания
        # 2. Публичные знания
        # 3. Знания с read доступом через группы/пользователей
        # 4. Знания с write доступом (write включает read)
        if permission == "read":
            accessible_knowledge = []
            for knowledge_base in knowledge_bases:
                is_owner = knowledge_base.user_id == user_id
                is_public = knowledge_base.access_control is None
                has_read_access = has_access(user_id, "read", knowledge_base.access_control, user_group_ids)
                has_write_access = has_access(user_id, "write", knowledge_base.access_control, user_group_ids)
                
                log.info(f"Knowledge {knowledge_base.id}: owner={is_owner}, public={is_public}, read={has_read_access}, write={has_write_access}")
                
                if is_owner or is_public or has_read_access or has_write_access:
                    accessible_knowledge.append(knowledge_base)
            
            log.info(f"Accessible knowledge bases for read: {len(accessible_knowledge)}")
            return accessible_knowledge
        else:
            # Для write доступа - только собственные или с write разрешением
            accessible_knowledge = []
            for knowledge_base in knowledge_bases:
                is_owner = knowledge_base.user_id == user_id
                has_write_access = has_access(user_id, "write", knowledge_base.access_control, user_group_ids)
                
                log.info(f"Knowledge {knowledge_base.id}: owner={is_owner}, write={has_write_access}")
                
                if is_owner or has_write_access:
                    accessible_knowledge.append(knowledge_base)
            
            log.info(f"Accessible knowledge bases for write: {len(accessible_knowledge)}")
            return accessible_knowledge

    def get_public_knowledge_bases(self) -> list[KnowledgeUserModel]:
        """Получить все публичные базы знаний (access_control = None)"""
        knowledge_bases = self.get_knowledge_bases()
        return [
            knowledge_base
            for knowledge_base in knowledge_bases
            if knowledge_base.access_control is None
        ]

    def get_knowledge_by_id(self, id: str) -> Optional[KnowledgeModel]:
        try:
            with get_db() as db:
                knowledge = db.query(Knowledge).filter_by(id=id).first()
                return KnowledgeModel.model_validate(knowledge) if knowledge else None
        except Exception:
            return None

    def update_knowledge_by_id(
        self, id: str, form_data: KnowledgeForm, overwrite: bool = False
    ) -> Optional[KnowledgeModel]:
        try:
            with get_db() as db:
                knowledge = self.get_knowledge_by_id(id=id)
                db.query(Knowledge).filter_by(id=id).update(
                    {
                        **form_data.model_dump(),
                        "updated_at": int(time.time()),
                    }
                )
                db.commit()
                return self.get_knowledge_by_id(id=id)
        except Exception as e:
            log.exception(e)
            return None

    def update_knowledge_data_by_id(
        self, id: str, data: dict
    ) -> Optional[KnowledgeModel]:
        try:
            with get_db() as db:
                knowledge = self.get_knowledge_by_id(id=id)
                db.query(Knowledge).filter_by(id=id).update(
                    {
                        "data": data,
                        "updated_at": int(time.time()),
                    }
                )
                db.commit()
                return self.get_knowledge_by_id(id=id)
        except Exception as e:
            log.exception(e)
            return None

    def delete_knowledge_by_id(self, id: str) -> bool:
        try:
            with get_db() as db:
                db.query(Knowledge).filter_by(id=id).delete()
                db.commit()
                return True
        except Exception:
            return False

    def delete_all_knowledge(self) -> bool:
        with get_db() as db:
            try:
                db.query(Knowledge).delete()
                db.commit()

                return True
            except Exception:
                return False


Knowledges = KnowledgeTable()
