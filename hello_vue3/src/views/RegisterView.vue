<template>
  <div class="register-page">
    <div
      class="register-bg"
      :style="{ backgroundImage: `url(${loginCover})` }"
      aria-hidden="true"
    />
    <div class="register-overlay" aria-hidden="true" />
    <el-card class="register-card" shadow="hover">
      <template #header>
        <div class="register-header">
          <div class="register-title">
            <BrandMark small class="register-brand-mark" />
            <span class="register-title-text">万象书心</span>
          </div>
          <div class="register-sub">加入书城会员 · 填写基本信息</div>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="formModel"
        :rules="rules"
        class="register-form"
        label-width="80px"
      >
        <el-form-item label="用户名" prop="username">
          <el-input v-model="formModel.username" placeholder="3-20 位" clearable />
        </el-form-item>

        <el-form-item label="真实姓名" prop="name">
          <el-input v-model="formModel.name" placeholder="请输入真实姓名" clearable />
        </el-form-item>

        <el-form-item label="密码" prop="password">
          <el-input
            v-model="formModel.password"
            type="password"
            show-password
            placeholder="6-20 位"
            clearable
          />
        </el-form-item>

        <el-form-item label="手机号">
          <el-input v-model="formModel.phone" placeholder="选填" clearable />
        </el-form-item>

        <el-form-item label="邮箱">
          <el-input v-model="formModel.email" placeholder="选填" clearable />
        </el-form-item>

        <el-form-item class="action-item">
          <el-button
            class="submit-btn"
            type="primary"
            :loading="submitting"
            @click="handleRegister"
          >
            注 册
          </el-button>
        </el-form-item>

        <div class="switch-link-wrap">
          <span class="switch-link" @click="goLogin">已有账号？返回登录</span>
        </div>
        <div class="home-link-wrap">
          <router-link class="home-link" to="/">← 返回书城首页</router-link>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, type FormInstance, type FormRules } from "element-plus";
import BrandMark from "../components/BrandMark.vue";
import loginCover from "../../img/6C69281ACAB49C01AF6D0C164F03F2AC.jpg";
import { registerApi } from "../api/auth";

const router = useRouter();
const formRef = ref<FormInstance>();
const submitting = ref(false);

const formModel = reactive({
  username: "",
  name: "",
  password: "",
  phone: "",
  email: "",
});

const rules: FormRules = {
  username: [
    { required: true, message: "请输入用户名", trigger: "blur" },
    { min: 3, max: 20, message: "用户名长度须在 3-20 位之间", trigger: "blur" },
  ],
  name: [{ required: true, message: "请输入真实姓名", trigger: "blur" }],
  password: [
    { required: true, message: "请输入密码", trigger: "blur" },
    { min: 6, max: 20, message: "密码长度须在 6-20 位之间", trigger: "blur" },
  ],
};

const handleRegister = async () => {
  if (!formRef.value || submitting.value) return;
  await formRef.value.validate();

  submitting.value = true;
  try {
    const res = await registerApi(formModel);
    if (res.code !== 1) {
      ElMessage.error(res.msg || "注册失败");
      return;
    }
    ElMessage.success("注册成功，请登录");
    router.push("/login");
  } catch (error: unknown) {
    const err = error as { response?: { data?: { msg?: string } } };
    ElMessage.error(err?.response?.data?.msg || "注册失败，请稍后重试");
  } finally {
    submitting.value = false;
  }
};

const goLogin = () => {
  router.push("/login");
};
</script>

<style scoped>
.register-page {
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

.register-bg {
  position: absolute;
  inset: 0;
  background-size: cover;
  background-position: 72% center;
  background-repeat: no-repeat;
  pointer-events: none;
}

.register-overlay {
  position: absolute;
  inset: 0;
  background: var(--wx-login-overlay);
  pointer-events: none;
}

.register-card {
  position: relative;
  z-index: 1;
  width: min(440px, 100%);
  border-radius: 16px;
  border: 1px solid var(--wx-edge);
  background: var(--wx-glass);
  backdrop-filter: blur(18px) saturate(1.15);
  -webkit-backdrop-filter: blur(18px) saturate(1.15);
  box-shadow:
    0 16px 48px rgba(15, 23, 42, 0.1),
    0 0 0 1px rgba(255, 255, 255, 0.6) inset;
}

.register-card :deep(.el-card__header) {
  padding: 28px 28px 20px;
  border-bottom: 1px solid var(--wx-edge);
  background: transparent;
}

.register-card :deep(.el-card__body) {
  padding: 26px 26px 28px;
}

.register-card :deep(.el-card) {
  --el-card-border-color: transparent;
  background: transparent;
}

.register-header {
  text-align: center;
}

.register-title {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 14px;
}

.register-brand-mark {
  color: var(--accent-teal);
}

.register-title-text {
  font-family: "Songti SC", "Noto Serif SC", "STSong", "SimSun", serif;
  font-size: 24px;
  font-weight: 500;
  letter-spacing: 0.2em;
  color: var(--wx-ink);
}

.register-sub {
  margin-top: 10px;
  font-size: 14px;
  line-height: 1.5;
  color: #64748b;
  font-weight: 400;
  letter-spacing: 0.04em;
}

.register-form :deep(.el-form-item) {
  margin-bottom: 18px;
}

.register-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #334155;
  padding-right: 12px;
}

.register-form :deep(.el-input__wrapper) {
  min-height: 42px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.9);
  box-shadow: 0 0 0 1px var(--wx-edge) inset;
  transition: box-shadow 0.2s ease, background 0.2s ease;
}

.register-form :deep(.el-input__wrapper:hover) {
  box-shadow: 0 0 0 1px rgba(13, 148, 136, 0.28) inset;
}

.register-form :deep(.el-input__wrapper.is-focus) {
  background: var(--wx-surface);
  box-shadow: 0 0 0 1px var(--accent-teal) inset, 0 0 0 3px var(--focus-ring);
}

.register-form :deep(.el-input__inner) {
  color: #1e293b;
}

.register-form :deep(.el-input__inner::placeholder) {
  color: #94a3b8;
}

.register-form :deep(.el-input .el-input__clear),
.register-form :deep(.el-input .el-input__password) {
  color: var(--accent-teal);
}

.action-item {
  margin-bottom: 0;
  margin-top: 8px;
}

.register-card :deep(.register-btn.el-button--primary) {
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

.register-card :deep(.register-btn.el-button--primary:hover),
.register-card :deep(.register-btn.el-button--primary:focus) {
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
  .register-page {
    justify-content: center;
    padding: 20px 16px;
  }

  .register-bg {
    background-position: center;
  }

  .register-overlay {
    background: linear-gradient(
      180deg,
      rgba(255, 255, 255, 0.88) 0%,
      rgba(255, 255, 255, 0.78) 55%,
      rgba(255, 255, 255, 0.55) 100%
    );
  }
}

html[data-theme="dark"] .register-overlay {
  background: linear-gradient(
    180deg,
    rgba(15, 23, 42, 0.88) 0%,
    rgba(15, 23, 42, 0.78) 55%,
    rgba(15, 23, 42, 0.55) 100%
  );
}

html[data-theme="dark"] .register-form :deep(.el-form-item__label) {
  color: var(--wx-ink-soft);
}

html[data-theme="dark"] .register-form :deep(.el-input__inner) {
  color: var(--wx-ink);
}

</style>
