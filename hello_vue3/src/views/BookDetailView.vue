<template>
  <div class="book-detail">
    <header class="detail-header">
      <router-link to="/" class="back-link">← 返回书城</router-link>
      <span class="header-brand">万象书心</span>
      <div class="header-actions">
        <AppearanceToolbar compact />
        <CartEntry />
        <template v-if="isLoggedIn">
          <span class="user-greet">{{ userName }}</span>
        </template>
        <el-button v-else type="primary" size="small" class="login-mini" @click="goLogin">登录</el-button>
      </div>
    </header>

    <main class="detail-main" v-loading="loading">
      <template v-if="!loading && !book">
        <el-empty description="未找到该图书" />
        <div class="back-wrap">
          <router-link to="/">
            <el-button>返回首页</el-button>
          </router-link>
        </div>
      </template>

      <template v-else-if="book">
        <div class="detail-hero">
          <div class="cover-wrap">
            <img v-if="book.coverUrl" :src="book.coverUrl" :alt="book.title" class="cover-img" />
            <div v-else class="cover-fallback" :style="{ '--tone': coverTone }">
              <span class="cover-initial">{{ book.title.slice(0, 1) }}</span>
            </div>
          </div>
          <div class="detail-intro">
            <p class="type-pill">{{ typeLabel }}</p>
            <h1 class="detail-title">{{ book.title }}</h1>
            <p class="detail-author">{{ book.author }}</p>
            <p class="price-line">{{ priceText }}</p>
            <div class="action-row">
              <el-button type="primary" size="large" :loading="adding" @click="addToCart">
                加入购物车
              </el-button>
              <router-link to="/">
                <el-button size="large">继续逛店</el-button>
              </router-link>
            </div>
          </div>
        </div>

        <section class="block summary-block">
          <h2 class="block-title">内容简介</h2>
          <p class="summary-text">
            {{ book.summary?.trim() || "本书暂无简介，敬请期待编辑部补充。" }}
          </p>
        </section>

        <section class="block comments-block">
          <h2 class="block-title">读者评论</h2>
          <el-alert
            type="info"
            :closable="false"
            show-icon
            title="评论功能开发中"
            description="后续将支持查看与发表评论；当前为界面预留区，接口由你接入后即可对接。"
            class="comment-alert"
          />
          <ul class="comment-skeleton" aria-hidden="true">
            <li v-for="n in 3" :key="n" class="sk-row">
              <div class="sk-avatar" />
              <div class="sk-lines">
                <div class="sk-line sk-line--short" />
                <div class="sk-line" />
              </div>
            </li>
          </ul>
          <p class="comment-hint">以上为占位样式，不影响后续接口联调。</p>
        </section>
      </template>
    </main>
  </div>
</template>

<script lang="ts" setup>
import { computed, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import AppearanceToolbar from "../components/AppearanceToolbar.vue";
import CartEntry from "../components/CartEntry.vue";
import { fetchBookById, BOOK_TYPE_LABELS, type Book } from "../api/book";
import { fetchBookPriceByBookId } from "../api/bookPrice";
import { saveBookToCart } from "../api/cart";
import { refreshCartBadge } from "../composables/cartBadge";
import { formatYuanPrice } from "../utils/shelfBook";
import { getToken, getUserName } from "../utils/auth";

const TONES = ["#5c3d2e", "#1e3a5f", "#6b4f3a", "#2d4a3e", "#7c4a3a", "#4a5568", "#3d5c5c", "#8b4513"];

const route = useRoute();
const router = useRouter();

const loading = ref(true);
const book = ref<Book | null>(null);
const adding = ref(false);

const bookId = computed(() => {
  const raw = route.params.id;
  const n = Number(Array.isArray(raw) ? raw[0] : raw);
  return Number.isFinite(n) && n > 0 ? n : NaN;
});

const isLoggedIn = computed(() => Boolean(getToken()));
const userName = computed(() => getUserName() || "书友");

const typeLabel = computed(() => {
  const b = book.value;
  if (b?.type == null) return "图书";
  return BOOK_TYPE_LABELS[b.type] ?? "图书";
});

const coverTone = computed(() => {
  const id = bookId.value;
  if (!Number.isFinite(id)) return TONES[0];
  return TONES[Math.abs(id) % TONES.length] ?? TONES[0];
});

const priceText = computed(() => {
  const p = book.value?.price;
  const n = p != null ? Number(p) : NaN;
  if (Number.isFinite(n)) return formatYuanPrice(n);
  return "暂无标价";
});

async function loadBook() {
  if (!Number.isFinite(bookId.value)) {
    book.value = null;
    loading.value = false;
    return;
  }
  loading.value = true;
  try {
    const res = await fetchBookById(bookId.value);
    if (res.code === 1 && res.data) {
      let data = res.data;
      const pn = data.price != null ? Number(data.price) : NaN;
      if (!Number.isFinite(pn)) {
        try {
          const pr = await fetchBookPriceByBookId(bookId.value);
          if (pr.code === 1 && pr.data?.price != null) {
            const n = Number(pr.data.price);
            if (Number.isFinite(n)) data = { ...data, price: n };
          }
        } catch {
          /* 无定价或网络错误时仍展示详情 */
        }
      }
      book.value = data;
    } else {
      book.value = null;
      if (res.msg) ElMessage.warning(res.msg);
    }
  } catch {
    book.value = null;
    ElMessage.error("加载图书失败");
  } finally {
    loading.value = false;
  }
}

watch(
  () => route.params.id,
  () => {
    void loadBook();
  },
  { immediate: true },
);

function goLogin() {
  void router.push({ path: "/login", query: { redirect: route.fullPath } });
}

async function addToCart() {
  if (!Number.isFinite(bookId.value)) return;
  if (!getToken()) {
    ElMessage.warning("请先登录");
    void router.push({ path: "/login", query: { redirect: route.fullPath } });
    return;
  }
  const title = book.value?.title?.trim() || "该图书";
  try {
    await ElMessageBox.confirm(`确定将《${title}》加入购物车？`, "提示", {
      type: "info",
      confirmButtonText: "加入",
      cancelButtonText: "取消",
    });
  } catch {
    return;
  }
  adding.value = true;
  try {
    const res = await saveBookToCart(bookId.value);
    if (res.code !== 1) {
      ElMessage.error(res.msg || "加入购物车失败");
      return;
    }
    ElMessage.success("已加入购物车");
    await refreshCartBadge();
  } catch {
    ElMessage.error("加入购物车失败，请稍后重试");
  } finally {
    adding.value = false;
  }
}
</script>

<style scoped>
.book-detail {
  --ink: var(--wx-ink);
  --ink-soft: var(--wx-ink-soft);
  --paper: var(--wx-page-bg);
  --paper-deep: var(--wx-paper-deep);
  --accent: var(--wx-accent);
  --accent-hover: var(--wx-accent-deep);
  --accent-warm: var(--wx-accent-warm);
  --edge: var(--wx-edge);
  min-height: 100vh;
  background: var(--wx-page-bg);
  color: var(--ink);
}

.detail-header {
  position: sticky;
  top: 0;
  z-index: 40;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 14px 24px;
  background: var(--wx-surface-muted);
  backdrop-filter: blur(12px) saturate(1.1);
  -webkit-backdrop-filter: blur(12px) saturate(1.1);
  border-bottom: 1px solid var(--edge);
  max-width: 1120px;
  margin: 0 auto;
}

.back-link {
  font-size: 14px;
  color: var(--ink-soft);
  text-decoration: none;
  white-space: nowrap;
}

.back-link:hover {
  color: var(--accent);
}

.header-brand {
  font-family: "Songti SC", "Noto Serif SC", serif;
  font-size: 16px;
  letter-spacing: 0.2em;
  color: var(--ink);
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-greet {
  font-size: 13px;
  color: var(--ink-soft);
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.login-mini {
  border-radius: 999px;
}

.detail-main {
  max-width: 920px;
  margin: 0 auto;
  padding: 32px 24px 64px;
}

.back-wrap {
  text-align: center;
  margin-top: 24px;
}

.detail-hero {
  display: grid;
  grid-template-columns: minmax(200px, 280px) 1fr;
  gap: 32px;
  align-items: start;
  margin-bottom: 40px;
}

@media (max-width: 720px) {
  .detail-hero {
    grid-template-columns: 1fr;
  }
}

.cover-wrap {
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid var(--edge);
  box-shadow: var(--wx-shadow-sm);
  background: var(--wx-surface);
}

.cover-img {
  display: block;
  width: 100%;
  height: auto;
}

.cover-fallback {
  aspect-ratio: 3 / 4;
  background: linear-gradient(160deg, var(--tone), #1a1010);
  display: flex;
  align-items: center;
  justify-content: center;
}

.cover-initial {
  font-size: 72px;
  color: rgba(255, 250, 235, 0.9);
  font-family: "Songti SC", "Noto Serif SC", serif;
  font-weight: 600;
}

.type-pill {
  display: inline-block;
  margin: 0 0 12px;
  font-size: 12px;
  padding: 4px 12px;
  border-radius: 999px;
  background: rgba(13, 148, 136, 0.1);
  color: var(--accent-hover);
}

.detail-title {
  margin: 0 0 10px;
  font-family: "Songti SC", "Noto Serif SC", serif;
  font-size: clamp(24px, 4vw, 32px);
  font-weight: 700;
  line-height: 1.35;
  letter-spacing: 0.04em;
}

.detail-author {
  margin: 0 0 16px;
  font-size: 15px;
  color: var(--ink-soft);
}

.price-line {
  margin: 0 0 24px;
  font-size: 18px;
  font-weight: 700;
  color: var(--accent-warm);
}

.action-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.block {
  margin-bottom: 40px;
  padding: 24px;
  border-radius: 16px;
  border: 1px solid var(--edge);
  background: var(--wx-surface);
  box-shadow: var(--wx-shadow-sm);
}

.block-title {
  margin: 0 0 16px;
  font-size: 18px;
  font-family: "Songti SC", "Noto Serif SC", serif;
  letter-spacing: 0.08em;
}

.summary-text {
  margin: 0;
  font-size: 15px;
  line-height: 1.85;
  color: var(--ink-soft);
}

.comment-alert {
  margin-bottom: 20px;
}

.comment-skeleton {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
  opacity: 0.45;
}

.sk-row {
  display: flex;
  gap: 12px;
}

.sk-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--paper-deep);
  flex-shrink: 0;
}

.sk-lines {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-top: 4px;
}

.sk-line {
  height: 10px;
  border-radius: 6px;
  background: var(--paper-deep);
}

.sk-line--short {
  width: 40%;
}

.comment-hint {
  margin: 16px 0 0;
  font-size: 12px;
  color: var(--ink-soft);
  opacity: 0.75;
}
</style>
