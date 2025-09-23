<script lang="ts">
	import { getContext, onMount } from 'svelte';

	const i18n = getContext('i18n');

	import { getGroups } from '$lib/apis/groups';
	import { getAllUsers } from '$lib/apis/users';
	import Tooltip from '$lib/components/common/Tooltip.svelte';
	import Plus from '$lib/components/icons/Plus.svelte';
	import UserCircleSolid from '$lib/components/icons/UserCircleSolid.svelte';
	import XMark from '$lib/components/icons/XMark.svelte';
	import Badge from '$lib/components/common/Badge.svelte';

	export let onChange: Function = () => {};

	export let accessRoles = ['read'];
	export let accessControl: any = {};

	export let allowPublic = true;

	let selectedGroupId = '';
	let selectedUserId = '';
	let groups: any[] = [];
	let users: any[] = [];

	// Функция для определения типа доступа
	const getAccessType = () => {
		if (accessControl === null) return 'public';
		if (accessControl && (accessControl.read?.group_ids?.length > 0 || accessControl.read?.user_ids?.length > 0 || accessControl.write?.group_ids?.length > 0 || accessControl.write?.user_ids?.length > 0)) {
			return 'groups';
		}
		return 'private';
	};

	// Функция для обработки изменения типа доступа
	const handleAccessTypeChange = (value: string) => {
		if (value === 'public') {
			accessControl = null;
		} else if (value === 'groups') {
			accessControl = {
				read: {
					group_ids: accessControl?.read?.group_ids ?? [],
					user_ids: accessControl?.read?.user_ids ?? []
				},
				write: {
					group_ids: accessControl?.write?.group_ids ?? [],
					user_ids: accessControl?.write?.user_ids ?? []
				}
			};
		} else {
			// private
			accessControl = {
				read: {
					group_ids: [],
					user_ids: []
				},
				write: {
					group_ids: [],
					user_ids: []
				}
			};
		}
		onChange(accessControl);
	};

	$: if (!allowPublic && accessControl === null) {
		initPublicAccess();
	}

	const initPublicAccess = () => {
		if (!allowPublic && accessControl === null) {
			accessControl = {
				read: {
					group_ids: [],
					user_ids: []
				},
				write: {
					group_ids: [],
					user_ids: []
				}
			};
			onChange(accessControl);
		}
	};

	onMount(async () => {
		groups = await getGroups(localStorage.token);
		users = await getAllUsers(localStorage.token);

		if (accessControl === null) {
			initPublicAccess();
		} else {
			accessControl = {
				read: {
					group_ids: accessControl?.read?.group_ids ?? [],
					user_ids: accessControl?.read?.user_ids ?? []
				},
				write: {
					group_ids: accessControl?.write?.group_ids ?? [],
					user_ids: accessControl?.write?.user_ids ?? []
				}
			};
		}
	});
</script>

<div class=" rounded-lg flex flex-col gap-2">
	<div class="">
		<div class=" text-sm font-semibold mb-1">{$i18n.t('Visibility')}</div>

		<div class="flex gap-2.5 items-center mb-1">
			<div>
				<div class=" p-2 bg-black/5 dark:bg-white/5 rounded-full">
					{#if accessControl !== null}
						<svg
							xmlns="http://www.w3.org/2000/svg"
							fill="none"
							viewBox="0 0 24 24"
							stroke-width="1.5"
							stroke="currentColor"
							class="w-5 h-5"
						>
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z"
							/>
						</svg>
					{:else}
						<svg
							xmlns="http://www.w3.org/2000/svg"
							fill="none"
							viewBox="0 0 24 24"
							stroke-width="1.5"
							stroke="currentColor"
							class="w-5 h-5"
						>
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								d="M6.115 5.19l.319 1.913A6 6 0 008.11 10.36L9.75 12l-.387.775c-.217.433-.132.956.21 1.298l1.348 1.348c.21.21.329.497.329.795v1.089c0 .426.24.815.622 1.006l.153.076c.433.217.956.132 1.298-.21l.723-.723a8.7 8.7 0 002.288-4.042 1.087 1.087 0 00-.358-1.099l-1.33-1.108c-.251-.21-.582-.299-.905-.245l-1.17.195a1.125 1.125 0 01-.98-.314l-.295-.295a1.125 1.125 0 010-1.591l.13-.132a1.125 1.125 0 011.3-.21l.603.302a.809.809 0 001.086-1.086L14.25 7.5l1.256-.837a4.5 4.5 0 001.528-1.732l.146-.292M6.115 5.19A9 9 0 1017.18 4.64M6.115 5.19A8.965 8.965 0 0112 3c1.929 0 3.716.607 5.18 1.64"
							/>
						</svg>
					{/if}
				</div>
			</div>

			<div>
				<!-- Улучшенный интерфейс выбора типа доступа -->
				<div class="flex flex-col gap-2">
					<label class="flex items-center gap-2 cursor-pointer">
						<input
							type="radio"
							name="accessType"
							value="public"
							checked={getAccessType() === 'public'}
							on:change={() => handleAccessTypeChange('public')}
							class="w-4 h-4 text-blue-600"
						/>
						<div class="flex flex-col">
							<span class="text-sm font-medium">{$i18n.t('Public')}</span>
							<span class="text-xs text-gray-500">{$i18n.t('Accessible to all users')}</span>
						</div>
					</label>
					
					<label class="flex items-center gap-2 cursor-pointer">
						<input
							type="radio"
							name="accessType"
							value="private"
							checked={getAccessType() === 'private'}
							on:change={() => handleAccessTypeChange('private')}
							class="w-4 h-4 text-blue-600"
						/>
						<div class="flex flex-col">
							<span class="text-sm font-medium">{$i18n.t('Private')}</span>
							<span class="text-xs text-gray-500">{$i18n.t('Only the owner can access')}</span>
						</div>
					</label>
					
					<label class="flex items-center gap-2 cursor-pointer">
						<input
							type="radio"
							name="accessType"
							value="groups"
							checked={getAccessType() === 'groups'}
							on:change={() => handleAccessTypeChange('groups')}
							class="w-4 h-4 text-blue-600"
						/>
						<div class="flex flex-col">
							<span class="text-sm font-medium">{$i18n.t('Specific Groups and Users')}</span>
							<span class="text-xs text-gray-500">{$i18n.t('Accessible to selected groups and users')}</span>
						</div>
					</label>
				</div>

			</div>
		</div>
	</div>
	{#if accessControl !== null}
		{@const accessGroups = groups.filter((group) =>
			(accessControl?.read?.group_ids ?? []).includes(group.id)
		)}
		<div>
			<div class="">
				<div class="flex justify-between mb-1.5">
					<div class="text-sm font-semibold">
						{$i18n.t('Groups')}
					</div>
				</div>

				<div class="mb-3">
					<div class="flex w-full gap-2">
						<div class="flex-1">
							<select
								class="w-full px-3 py-2 text-sm border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
								bind:value={selectedGroupId}
								on:change={() => {
									if (selectedGroupId !== '') {
										accessControl.read.group_ids = [
											...(accessControl?.read?.group_ids ?? []),
											selectedGroupId
										];

										selectedGroupId = '';
										onChange(accessControl);
									}
								}}
							>
								<option class="text-gray-700" value="" disabled selected>
									{$i18n.t('Select a group')}
								</option>
								{#each groups.filter((group) => !(accessControl?.read?.group_ids ?? []).includes(group.id)) as group}
									<option class="text-gray-700" value={group.id}>{group.name}</option>
								{/each}
							</select>
						</div>
						<button
							class="px-3 py-2 bg-blue-600 text-white text-sm rounded-lg hover:bg-blue-700 transition-colors"
							type="button"
							on:click={() => {
								if (selectedGroupId !== '') {
									accessControl.read.group_ids = [
										...(accessControl?.read?.group_ids ?? []),
										selectedGroupId
									];
									selectedGroupId = '';
									onChange(accessControl);
								}
							}}
						>
							<Plus className="size-4" />
						</button>
					</div>
				</div>

				{#if accessGroups.length > 0}
					<div class="space-y-2">
						{#each accessGroups as group}
							<div class="flex items-center justify-between p-2 bg-white dark:bg-gray-800 rounded-lg border">
								<div class="flex items-center gap-2">
									<UserCircleSolid className="size-4 text-gray-500" />
									<span class="text-sm font-medium">{group.name}</span>
								</div>
								
								<div class="flex items-center gap-2">
									{#if accessRoles.includes('write')}
										<button
											class="px-2 py-1 text-xs rounded"
											type="button"
											on:click={() => {
												if ((accessControl?.write?.group_ids ?? []).includes(group.id)) {
													accessControl.write.group_ids = (
														accessControl?.write?.group_ids ?? []
													).filter((group_id) => group_id !== group.id);
												} else {
													accessControl.write.group_ids = [
														...(accessControl?.write?.group_ids ?? []),
														group.id
													];
												}
												onChange(accessControl);
											}}
										>
											{#if (accessControl?.write?.group_ids ?? []).includes(group.id)}
												<Badge type={'success'} content={$i18n.t('Write')} />
											{:else}
												<Badge type={'info'} content={$i18n.t('Read')} />
											{/if}
										</button>
									{/if}
									
									<button
										class="p-1 text-gray-500 hover:text-red-500 transition"
										type="button"
										on:click={() => {
											accessControl.read.group_ids = (accessControl?.read?.group_ids ?? []).filter(
												(id) => id !== group.id
											);
											accessControl.write.group_ids = (
												accessControl?.write?.group_ids ?? []
											).filter((id) => id !== group.id);
											onChange(accessControl);
										}}
									>
										<XMark className="size-4" />
									</button>
								</div>
							</div>
						{/each}
					</div>
				{:else}
					<div class="text-center py-4 text-gray-500 text-sm">
						{$i18n.t('No groups selected. Choose groups from the dropdown above.')}
					</div>
				{/if}
			</div>
		</div>

		<!-- Секция пользователей -->
		<div>
			<div class="">
				<div class="flex justify-between mb-1.5">
					<div class="text-sm font-semibold">
						{$i18n.t('Users')}
					</div>
				</div>

				<div class="mb-3">
					<div class="flex w-full gap-2">
						<div class="flex-1">
							<select
								class="w-full px-3 py-2 text-sm border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
								bind:value={selectedUserId}
								on:change={() => {
									if (selectedUserId !== '') {
										accessControl.read.user_ids = [
											...(accessControl?.read?.user_ids ?? []),
											selectedUserId
										];

										selectedUserId = '';
										onChange(accessControl);
									}
								}}
							>
								<option class="text-gray-700" value="" disabled selected>
									{$i18n.t('Select a user')}
								</option>
								{#each users.filter((user) => !(accessControl?.read?.user_ids ?? []).includes(user.id)) as user}
									<option class="text-gray-700" value={user.id}>{user.name || user.email}</option>
								{/each}
							</select>
						</div>
						<button
							class="px-3 py-2 bg-blue-600 text-white text-sm rounded-lg hover:bg-blue-700 transition-colors"
							type="button"
							on:click={() => {
								if (selectedUserId !== '') {
									accessControl.read.user_ids = [
										...(accessControl?.read?.user_ids ?? []),
										selectedUserId
									];
									selectedUserId = '';
									onChange(accessControl);
								}
							}}
						>
							<Plus className="size-4" />
						</button>
					</div>
				</div>

				{@const accessUsers = users.filter((user) =>
					(accessControl?.read?.user_ids ?? []).includes(user.id)
				)}
				{#if accessUsers.length > 0}
					<div class="space-y-2">
						{#each accessUsers as user}
							<div class="flex items-center justify-between p-2 bg-white dark:bg-gray-800 rounded-lg border">
								<div class="flex items-center gap-2">
									<UserCircleSolid className="size-4 text-gray-500" />
									<span class="text-sm font-medium">{user.name || user.email}</span>
								</div>

								<div class="flex items-center gap-2">
									{#if accessRoles.includes('write')}
										<button
											class="px-2 py-1 text-xs rounded"
											type="button"
											on:click={() => {
												if ((accessControl?.write?.user_ids ?? []).includes(user.id)) {
													accessControl.write.user_ids = (
														accessControl?.write?.user_ids ?? []
													).filter((user_id) => user_id !== user.id);
												} else {
													accessControl.write.user_ids = [
														...(accessControl?.write?.user_ids ?? []),
														user.id
													];
												}
												onChange(accessControl);
											}}
										>
											{#if (accessControl?.write?.user_ids ?? []).includes(user.id)}
												<Badge type={'success'} content={$i18n.t('Write')} />
											{:else}
												<Badge type={'info'} content={$i18n.t('Read')} />
											{/if}
										</button>
									{/if}

									<button
										class="p-1 text-gray-500 hover:text-red-500 transition"
										type="button"
										on:click={() => {
											accessControl.read.user_ids = (accessControl?.read?.user_ids ?? []).filter(
												(id) => id !== user.id
											);
											accessControl.write.user_ids = (
												accessControl?.write?.user_ids ?? []
											).filter((id) => id !== user.id);
											onChange(accessControl);
										}}
									>
										<XMark className="size-4" />
									</button>
								</div>
							</div>
						{/each}
					</div>
				{:else}
					<div class="text-center py-4 text-gray-500 text-sm">
						{$i18n.t('No users selected. Choose users from the dropdown above.')}
					</div>
				{/if}
			</div>
		</div>
	{/if}
</div>
