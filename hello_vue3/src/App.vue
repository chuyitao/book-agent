<template>
  <router-view />
  <AppearanceToolbar v-if="showAppearanceToolbar" class="app-appearance" />
  <AiChatFab v-if="showAiChat" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import AppearanceToolbar from './components/AppearanceToolbar.vue'
import AiChatFab from './components/AiChatFab.vue'

const route = useRoute()
const showAiChat = computed(
  () => route.path !== '/login' && route.path !== '/register',
)

/** 登录/注册页使用固定角标；其余页面顶栏内嵌 */
const showAppearanceToolbar = computed(
  () => route.path === '/login' || route.path === '/register',
)
</script>

<style>
.app-appearance {
  position: fixed;
  top: 16px;
  right: 16px;
  z-index: 100;
}
</style>