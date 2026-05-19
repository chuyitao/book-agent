import { computed, onMounted, ref } from "vue";
import {
  applyTheme,
  isFullscreenActive,
  type ThemeMode,
} from "../utils/appearance";

function readThemeFromDom(): ThemeMode {
  if (typeof document === "undefined") return "light";
  return document.documentElement.dataset.theme === "dark" ? "dark" : "light";
}

const theme = ref<ThemeMode>(readThemeFromDom());
const fullscreen = ref(false);
let listenersBound = false;

function bindGlobalListeners() {
  if (listenersBound || typeof document === "undefined") return;
  listenersBound = true;
  document.addEventListener("fullscreenchange", syncFullscreen);
}

function syncFullscreen() {
  fullscreen.value = isFullscreenActive();
}

export function useAppearance() {
  const isDark = computed(() => theme.value === "dark");

  onMounted(() => {
    theme.value = readThemeFromDom();
    syncFullscreen();
    bindGlobalListeners();
  });

  const toggleTheme = () => {
    const next: ThemeMode = theme.value === "dark" ? "light" : "dark";
    theme.value = next;
    applyTheme(next);
  };

  const toggleFullscreen = async () => {
    try {
      if (!document.fullscreenElement) {
        await document.documentElement.requestFullscreen();
      } else {
        await document.exitFullscreen();
      }
    } catch {
      /* 浏览器可能禁止全屏 */
    } finally {
      syncFullscreen();
    }
  };

  return {
    theme,
    isDark,
    fullscreen,
    toggleTheme,
    toggleFullscreen,
  };
}
