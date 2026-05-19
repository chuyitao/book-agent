<template>
  <span
    class="brand-mark"
    :class="{ 'brand-mark--sm': small }"
    aria-hidden="true"
  >
    <svg
      class="brand-mark__svg"
      viewBox="0 0 32 40"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <rect
        x="4.5"
        y="3.5"
        width="23"
        height="33"
        rx="2"
        stroke="currentColor"
        stroke-width="0.9"
        stroke-linejoin="round"
      />
      <path
        d="M8.5 12h9.5M8.5 17h13.5M8.5 22h7.5"
        stroke="currentColor"
        stroke-width="0.85"
        stroke-linecap="round"
      />
    </svg>
  </span>
</template>

<script setup lang="ts">
defineProps<{
  /** 登录卡片等较小场景 */
  small?: boolean
}>()
</script>

<style scoped>
.brand-mark {
  display: inline-flex;
  color: var(--wx-accent, #0d9488);
  flex-shrink: 0;
}

.brand-mark__svg {
  display: block;
  width: 34px;
  height: 42px;
}

.brand-mark--sm .brand-mark__svg {
  width: 26px;
  height: 33px;
}
</style>
