import axios, { type InternalAxiosRequestConfig } from "axios";
import { ElMessage } from "element-plus";
import router from "../router";
import { clearAuthInfo, getToken } from "./auth";

const request = axios.create({
  // 开发环境走 Vite 代理（/api -> localhost:8099），与页面同源，不触发 CORS
  baseURL: import.meta.env.DEV ? "/api" : "http://localhost:8099",
  timeout: 10000,
});

/** 绝对不能带 token（避免旧 token 干扰登录/注册） */
const AUTH_STRIP_TOKEN_PATHS = new Set(["/login", "/login/sign"]);

/** 未登录也可访问；若本地有 token 则照常带上，避免后端鉴权被拒 */
const AUTH_OPTIONAL_TOKEN_PATHS = new Set([
  "/chat/stream",
  "/book/list",
  "/book/getById",
  "/book/test",
  "/book-price/getByBookId",
]);

function requestPath(config: InternalAxiosRequestConfig): string {
  return (config.url ?? "").split("?")[0] ?? "";
}

request.interceptors.request.use((config) => {
  const path = requestPath(config);

  if (AUTH_STRIP_TOKEN_PATHS.has(path)) {
    config.headers?.delete("token");
    return config;
  }

  if (AUTH_OPTIONAL_TOKEN_PATHS.has(path)) {
    const token = getToken();
    if (token) config.headers.set("token", token);
    else config.headers?.delete("token");
    return config;
  }

  const token = getToken();
  if (!token) {
    ElMessage.warning("请先登录");
    void router.push("/login");
    return Promise.reject(new Error("未登录"));
  }
  config.headers.set("token", token);
  return config;
});

request.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error?.response?.status === 401) {
      const path = error.config ? requestPath(error.config) : "";
      const skipGlobalLogout =
        AUTH_OPTIONAL_TOKEN_PATHS.has(path) ||
        AUTH_STRIP_TOKEN_PATHS.has(path);

      if (skipGlobalLogout) {
        // 由业务页面自行提示，避免与组件内 ElMessage 重复
      } else {
        clearAuthInfo();
        ElMessage.error("登录已过期，请重新登录");
        router.push("/login");
      }
    }
    return Promise.reject(error);
  },
);

export default request;
