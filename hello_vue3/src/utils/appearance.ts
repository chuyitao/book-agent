const THEME_KEY = "wx-theme";

export type ThemeMode = "light" | "dark";

export function getSavedTheme(): ThemeMode | null {
  try {
    const v = localStorage.getItem(THEME_KEY);
    return v === "dark" || v === "light" ? v : null;
  } catch {
    return null;
  }
}

export function resolveInitialTheme(): ThemeMode {
  const saved = getSavedTheme();
  if (saved) return saved;
  if (typeof window !== "undefined" && window.matchMedia("(prefers-color-scheme: dark)").matches) {
    return "dark";
  }
  return "light";
}

export function applyTheme(mode: ThemeMode) {
  const html = document.documentElement;
  const dark = mode === "dark";
  html.dataset.theme = mode;
  html.classList.toggle("dark", dark);
  try {
    localStorage.setItem(THEME_KEY, mode);
  } catch {
    /* ignore */
  }
}

/** 在 createApp 之前调用，避免主题闪烁 */
export function initAppearance() {
  applyTheme(resolveInitialTheme());
}

export function isFullscreenActive() {
  return Boolean(document.fullscreenElement);
}
