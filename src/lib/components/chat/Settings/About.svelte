<script lang="ts">
	import { getContext } from 'svelte';
	import { config } from '$lib/stores';
	import { APP_NAME, WEBUI_VERSION } from '$lib/constants';

	const i18n = getContext('i18n');
</script>

<div class="flex flex-col h-full">
	<div class="flex-1 space-y-4">
		<div class="flex flex-col items-center justify-center py-8">
			<div class="text-2xl font-bold text-gray-800 dark:text-gray-200 mb-2">
				{$i18n.t('About')} {APP_NAME}
			</div>
			<div class="text-sm text-gray-600 dark:text-gray-400 mb-6">
				{$i18n.t('Version')}: {WEBUI_VERSION}
			</div>
			
			<div class="w-24 h-24 mb-6">
				<svg
					xmlns="http://www.w3.org/2000/svg"
					viewBox="0 0 24 24"
					fill="currentColor"
					class="w-full h-full text-blue-500 dark:text-blue-400"
				>
					<path
						d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"
					/>
				</svg>
			</div>
		</div>

		<div class="space-y-4">
			<div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
				<h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 mb-2">
					{$i18n.t('Open WebUI')}
				</h3>
				<p class="text-sm text-gray-600 dark:text-gray-400">
					{$i18n.t('A user-friendly WebUI for LLMs (Formerly Ollama WebUI)')}
				</p>
			</div>

			<div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
				<h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 mb-2">
					{$i18n.t('Documentation')}
				</h3>
				<a
					href="https://docs.DevBIM.com"
					target="_blank"
					rel="noopener noreferrer"
					class="text-blue-600 dark:text-blue-400 hover:underline text-sm"
				>
					{$i18n.t('Visit Documentation')}
				</a>
			</div>

			<div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
				<h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 mb-2">
					{$i18n.t('GitHub')}
				</h3>
				<a
					href="https://github.com/DevBIM"
					target="_blank"
					rel="noopener noreferrer"
					class="text-blue-600 dark:text-blue-400 hover:underline text-sm"
				>
					{$i18n.t('View on GitHub')}
				</a>
			</div>

			<div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
				<h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 mb-2">
					{$i18n.t('License')}
				</h3>
				<p class="text-sm text-gray-600 dark:text-gray-400">
					{$i18n.t('Open WebUI is licensed under the MIT License')}
				</p>
			</div>

			{#if $config?.license_metadata}
				<div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
					<h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 mb-2">
						{$i18n.t('License Information')}
					</h3>
					<p class="text-sm text-gray-600 dark:text-gray-400">
						{$i18n.t('Licensed to')}: {$config.license_metadata.organization}
					</p>
					{#if $config.license_metadata.seats}
						<p class="text-sm text-gray-600 dark:text-gray-400">
							{$i18n.t('Seats')}: {$config.license_metadata.seats}
						</p>
					{/if}
				</div>
			{/if}
		</div>
	</div>
</div>
