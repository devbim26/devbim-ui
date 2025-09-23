<script lang="ts">
	import { getContext, onMount } from 'svelte';

	const i18n = getContext('i18n');

	import { getGroups } from '$lib/apis/groups';
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
	let groups: any[] = [];

	// Типы доступа
	const ACCESS_TYPES = {
		PUBLIC: 'public',
		PRIVATE: 'private',
		GROUPS: 'groups'
	};

	// Определение текущего типа доступа
	const getAccessType = () => {
		if (accessControl === null) return ACCESS_TYPES.PUBLIC;
		if (accessControl && (accessControl.read?.group_ids?.length > 0 || accessControl.write?.group_ids?.length > 0)) {
			return ACCESS_TYPES.GROUPS;
		}
		return ACCESS_TYPES.PRIVATE;
	};

	// Обработка изменения типа доступа
	const handleAccessTypeChange = (value: string) => {
		if (value === ACCESS_TYPES.PUBLIC) {
			accessControl = null;
		} else if (value === ACCESS_TYPES.GROUPS) {
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

	// Инициализация публичного доступа
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

<div class="rounded-lg flex flex-col gap-2">
	<div class="">
		<div class="text-sm font-semibold mb-1">{$i18n.t('Access Type')}</div>
		
		<!-- Радио кнопки для выбора типа доступа -->
		<div class="flex flex-col gap-2 mb-3">
			<label class="flex items-center gap-2 cursor-pointer">
				<input 
					type="radio" 
					name="accessType" 
					value={ACCESS_TYPES.PUBLIC}
					checked={getAccessType() === ACCESS_TYPES.PUBLIC}
					on:change={() => handleAccessTypeChange(ACCESS_TYPES.PUBLIC)}
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
					value={ACCESS_TYPES.PRIVATE}
					checked={getAccessType() === ACCESS_TYPES.PRIVATE}
					on:change={() => handleAccessTypeChange(ACCESS_TYPES.PRIVATE)}
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
					value={ACCESS_TYPES.GROUPS}
					checked={getAccessType() === ACCESS_TYPES.GROUPS}
					on:change={() => handleAccessTypeChange(ACCESS_TYPES.GROUPS)}
					class="w-4 h-4 text-blue-600"
				/>
				<div class="flex flex-col">
					<span class="text-sm font-medium">{$i18n.t('Specific Groups')}</span>
					<span class="text-xs text-gray-500">{$i18n.t('Accessible to selected groups and users')}</span>
				</div>
			</label>
		</div>
	</div>
	
	<!-- Секция управления группами (только для типа "groups") -->
	{#if getAccessType() === ACCESS_TYPES.GROUPS}
		{@const accessGroups = groups.filter((group) =>
			(accessControl?.read?.group_ids ?? []).includes(group.id)
		)}
		<div class="border border-gray-200 dark:border-gray-700 rounded-lg p-3 bg-gray-50 dark:bg-gray-900">
			<div class="flex justify-between items-center mb-2">
				<div class="text-sm font-semibold">
					{$i18n.t('Select Groups')}
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
	{/if}
</div>