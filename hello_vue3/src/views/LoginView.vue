<template>
  <div class="login-page">
    <div
      class="login-bg"
      :style="{ backgroundImage: `url(${loginCover})` }"
      aria-hidden="true"
    />
    <div class="login-overlay" aria-hidden="true" />
    <el-card class="login-card" shadow="hover">
      <template #header>
        <div class="login-header">
          <div class="login-title">
            <BrandMark small class="login-brand-mark" />
            <span class="login-title-text">万象书心</span>
          </div>
          <div class="login-sub">线上书城 · 欢迎回来</div>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="formModel"
        :rules="rules"
        class="login-form"
        label-width="72px"
        @keyup.enter="handleLogin"
      >
        <el-form-item label="账号" prop="username">
          <el-input
            v-model="formModel.username"
            placeholder="请输入用户名"
            clearable
          />
        </el-form-item>

        <el-form-item label="密码" prop="password">
          <el-input
            v-model="formModel.password"
            type="password"
            show-password
            placeholder="请输入密码"
            clearable
          />
        </el-form-item>

        <el-form-item class="action-item">
          <el-button
            type="primary"
            class="login-btn"
            :loading="submitting"
            @click="handleLogin"
          >
            登 录
          </el-button>
        </el-form-item>
        <div class="switch-link-wrap">
          <span class="switch-link" @click="goRegister">没有账号？去注册</span>
        </div>
        <div class="home-link-wrap">
          <router-link class="home-link" to="/">← 返回书城首页</router-link>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage, type FormInstance, type FormRules } from "element-plus";
import BrandMark from "../components/BrandMark.vue";
import loginCover from "../../img/6C69281ACAB49C01AF6D0C164F03F2AC.jpg";
import { loginApi } from "../api/auth";
import { setToken, setUserName } from "../utils/auth";

const router = useRouter();
const route = useRoute();
const formRef = ref<FormInstance>();
const submitting = ref(false);

const formModel = reactive({
  username: "",
  password: "",
});

const rules: FormRules = {
  username: [{ required: true, message: "请输入账号", trigger: "blur" }],
  password: [{ required: true, message: "请输入密码", trigger: "blur" }],
};

const handleLogin = async () => {
  if (!formRef.value || submitting.value) return;
  await formRef.value.validate();

  submitting.value = true;
  try {
    const res = await loginApi(formModel);
    if (res.code !== 1 || !res.data?.token) {
      ElMessage.error(res.msg || "登录失败");
      return;
    }

    setToken(res.data.token);
    setUserName(res.data.name || res.data.username);
    ElMessage.success("登录成功");
    const redirect =
      typeof route.query.redirect === "string" && route.query.redirect.startsWith("/")
        ? route.query.redirect
        : "/";
    await router.push(redirect);
  } catch (error: any) {
    const serverMsg = error?.response?.data?.msg;
    ElMessage.error(serverMsg || "登录失败，请稍后重试");
  } finally {
    submitting.value = false;
  }
};

const goRegister = () => {
  router.push("/register");
};
</script>

<style scoped>
.login-page {
  --accent-gold: var(--wx-accent-warm);
  --accent-gold-deep: var(--wx-accent-warm-deep);
  --accent-teal: var(--wx-accent);
  --accent-teal-deep: var(--wx-accent-deep);
  --accent-green: var(--wx-accent-green);
  --focus-ring: var(--wx-focus-ring);
  position: relative;
  overflow: hidden;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  padding: 24px clamp(16px, 6vw, 120px);
  background: var(--wx-page-bg);
}

.login-bg {
  position: absolute;
  inset: 0;
  background-size: cover;
  background-position: 72% center;
  background-repeat: no-repeat;
  pointer-events: none;
}

.login-overlay {
  position: absolute;
  inset: 0;
  background: var(--wx-login-overlay);
  pointer-events: none;
}

.login-card {
  position: relative;
  z-index: 1;
  width: min(420px, 100%);
  border-radius: 16px;
  border: 1px solid var(--wx-edge);
  background: var(--wx-glass);
  backdrop-filter: blur(18px) saturate(1.15);
  -webkit-backdrop-filter: blur(18px) saturate(1.15);
  box-shadow:
    0 16px 48px rgba(15, 23, 42, 0.1),
    0 0 0 1px rgba(255, 255, 255, 0.6) inset;
}

.login-card :deep(.el-card__header) {
  padding: 28px 28px 20px;
  border-bottom: 1px solid rgba(13, 148, 136, 0.12);
  background: transparent;
}

.login-card :deep(.el-card__body) {
  padding: 26px 26px 28px;
}

.login-card :deep(.el-card) {
  --el-card-border-color: transparent;
  background: transparent;
}

.login-header {
  text-align: center;
}

.login-title {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 14px;
}

.login-brand-mark {
  color: var(--accent-teal);
}

.login-title-text {
  font-family: "Songti SC", "Noto Serif SC", "STSong", "SimSun", serif;
  font-size: 24px;
  font-weight: 500;
  letter-spacing: 0.2em;
  color: #1e3a2f;
}

.login-sub {
  margin-top: 10px;
  font-size: 14px;
  line-height: 1.5;
  color: #64748b;
  font-weight: 400;
  letter-spacing: 0.04em;
}

.login-form :deep(.el-form-item) {
  margin-bottom: 20px;
}

.login-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #334155;
  padding-right: 12px;
}

.login-form :deep(.el-input__wrapper) {
  min-height: 42px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.9);
  box-shadow: 0 0 0 1px rgba(13, 148, 136, 0.14) inset;
  transition: box-shadow 0.2s ease, background 0.2s ease;
}

.login-form :deep(.el-input__wrapper:hover) {
  box-shadow: 0 0 0 1px rgba(13, 148, 136, 0.28) inset;
}

.login-form :deep(.el-input__wrapper.is-focus) {
  background: #fff;
  box-shadow: 0 0 0 1px var(--accent-teal) inset, 0 0 0 3px var(--focus-ring);
}

.login-form :deep(.el-input__inner) {
  color: #1e293b;
}

.login-form :deep(.el-input__inner::placeholder) {
  color: #94a3b8;
}

.login-form :deep(.el-input .el-input__clear),
.login-form :deep(.el-input .el-input__password) {
  color: var(--accent-teal);
}

.action-item {
  margin-bottom: 0;
  margin-top: 6px;
}

.login-card :deep(.login-btn.el-button--primary) {
  width: 100%;
  height: 42px;
  font-size: 15px;
  font-weight: 500;
  letter-spacing: 0.12em;
  border: none;
  border-radius: 10px;
  --el-button-bg-color: transparent;
  --el-button-border-color: transparent;
  --el-button-hover-bg-color: transparent;
  --el-button-hover-border-color: transparent;
  background: linear-gradient(135deg, var(--accent-gold) 0%, var(--accent-green) 100%);
  box-shadow: 0 4px 16px rgba(202, 138, 4, 0.35);
}

.login-card :deep(.login-btn.el-button--primary:hover),
.login-card :deep(.login-btn.el-button--primary:focus) {
  background: linear-gradient(135deg, var(--accent-gold-deep) 0%, #4d7c0f 100%);
  filter: none;
}

.switch-link-wrap {
  margin-top: 16px;
  text-align: center;
}

.switch-link {
  font-size: 14px;
  color: #64748b;
  cursor: pointer;
  transition: color 0.2s ease;
}

.switch-link:hover {
  color: var(--accent-teal);
}

.home-link-wrap {
  margin-top: 20px;
  text-align: center;
}

.home-link {
  font-size: 13px;
  color: #64748b;
  text-decoration: none;
}

.home-link:hover {
  color: var(--accent-teal-deep);
}

@media (max-width: 640px) {
  .login-page {
    justify-content: center;
    padding: 20px 16px;
  }

  .login-bg {
    background-position: center;
  }

  .login-overlay {
    background: linear-gradient(
      180deg,
      rgba(255, 255, 255, 0.88) 0%,
      rgba(255, 255, 255, 0.78) 55%,
      rgba(255, 255, 255, 0.55) 100%
    );
  }
}
</style>
