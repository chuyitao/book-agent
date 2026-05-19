<template>
  <div class="appearance-toolbar" :class="{ 'appearance-toolbar--compact': compact }" role="group" aria-label="显示设置">
    <button
      type="button"
      class="appearance-btn"
      :title="theme === 'dark' ? '切换浅色模式' : '切换黑夜模式'"
      :aria-label="theme === 'dark' ? '切换浅色模式' : '切换黑夜模式'"
      @click="toggleTheme"
    >
      <svg v-if="theme === 'dark'" class="appearance-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <circle cx="12" cy="12" r="4" stroke="currentColor" stroke-width="1.5" />
        <path
          d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
        />
      </svg>
      <svg v-else class="appearance-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path
          d="M21 14.5A7.5 7.5 0 0110.5 4 6.5 6.5 0 0014.5 21 7.5 7.5 0 0121 14.5z"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linejoin="round"
        />
      </svg>
    </button>
    <button
      type="button"
      class="appearance-btn"
      :title="fullscreen ? '退出全屏' : '全屏显示'"
      :aria-label="fullscreen ? '退出全屏' : '全屏显示'"
      @click="toggleFullscreen"
    >
      <svg v-if="fullscreen" class="appearance-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path
          d="M9 4H4v5M15 4h5v5M9 20H4v-5M15 20h5v-5"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
      </svg>
      <svg v-else class="appearance-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path
          d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
      </svg>
    </button>
  </div>
</template>

<script setup lang="ts">
import { useAppearance } from "../composables/useAppearance";

defineProps<{
  /** 嵌入顶栏时使用较小尺寸 */
  compact?: boolean;
}>();

const { theme, fullscreen, toggleTheme, toggleFullscreen } = useAppearance();
</script>

<style scoped>
.appearance-toolbar {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px;
  border-radius: 999px;
  background: var(--wx-surface-muted);
  border: 1px solid var(--wx-edge);
  box-shadow: var(--wx-shadow-sm);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
}

.appearance-toolbar--compact {
  padding: 2px;
  gap: 2px;
}

.appearance-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  padding: 0;
  border: none;
  border-radius: 50%;
  cursor: pointer;
  color: var(--wx-ink-soft);
  background: transparent;
  transition:
    color 0.2s ease,
    background 0.2s ease,
    transform 0.15s ease;
}

.appearance-toolbar--compact .appearance-btn {
  width: 32px;
  height: 32px;
}

.appearance-btn:hover {
  color: var(--wx-accent);
  background: rgba(13, 148, 136, 0.1);
}

.appearance-btn:active {
  transform: scale(0.94);
}

.appearance-icon {
  width: 18px;
  height: 18px;
  display: block;
}

html[data-theme="dark"] .appearance-btn:hover {
  background: rgba(45, 212, 191, 0.12);
}
</style>
