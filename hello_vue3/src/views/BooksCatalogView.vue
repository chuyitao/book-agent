<template>
  <div class="books-catalog">
    <header class="catalog-header">
      <router-link to="/" class="back-link">← 返回首页</router-link>
      <span class="header-title">全部图书</span>
      <div class="header-actions">
        <AppearanceToolbar compact />
        <CartEntry />
        <template v-if="isLoggedIn">
          <span class="user-greet">{{ userName }}</span>
        </template>
        <el-button v-else type="primary" size="small" class="login-mini" @click="goLogin">登录</el-button>
      </div>
    </header>

    <main class="catalog-main" v-loading="loading">
      <p class="catalog-meta">共 {{ total }} 本，每页 {{ pageSize }} 本，分页浏览更省流量</p>

      <div v-if="!loading && books.length === 0" class="empty-wrap">
        <el-empty description="暂无图书数据" />
      </div>

      <div v-else class="book-grid">
        <router-link
          v-for="book in books"
          :key="book.id"
          :to="{ name: 'book-detail', params: { id: String(book.id) } }"
          class="book-card book-card--clickable"
          :aria-label="`${book.title}，作者 ${book.author}，查看详情`"
        >
          <div class="book-cover" :style="{ '--tone': book.tone }">
            <img
              v-if="book.coverUrl"
              :src="book.coverUrl"
              :alt="book.title"
              class="book-cover-img"
              loading="lazy"
            />
            <span v-else class="book-cover-initial">{{ book.title.slice(0, 1) }}</span>
          </div>
          <div class="book-body">
            <span class="book-tag">{{ book.tag }}</span>
            <h3 class="book-title">{{ book.title }}</h3>
            <p class="book-author">{{ book.author }}</p>
            <p class="book-price">{{ book.priceText }}</p>
          </div>
        </router-link>
      </div>

      <div v-if="total > 0" class="pager-wrap">
        <el-pagination
          v-model:current-page="pageNum"
          :page-size="pageSize"
          :total="Number(total)"
          :pager-count="7"
          layout="total, prev, pager, next, jumper"
          background
          :hide-on-single-page="false"
        />
      </div>
    </main>
  </div>
</template>

<script lang="ts" setup>
import { computed, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import AppearanceToolbar from "../components/AppearanceToolbar.vue";
import CartEntry from "../components/CartEntry.vue";
import { fetchBookList, normalizeBookListPayload } from "../api/book";
import { mapBookRecordsToShelfBooks, type ShelfBook } from "../utils/shelfBook";
import { getToken, getUserName } from "../utils/auth";

const route = useRoute();
const router = useRouter();

const pageSize = 12;
const pageNum = ref(1);
const total = ref(0);
const books = ref<ShelfBook[]>([]);
const loading = ref(true);

const isLoggedIn = computed(() => Boolean(getToken()));
const userName = computed(() => getUserName() || "书友");

function goLogin() {
  void router.push({ path: "/login", query: { redirect: route.fullPath } });
}

async function loadPage() {
  loading.value = true;
  try {
    const res = await fetchBookList(pageNum.value, pageSize);
    if (res.code != 1) {
      books.value = [];
      total.value = 0;
      if (res.msg) ElMessage.warning(res.msg);
      return;
    }
    const { records, total: t } = normalizeBookListPayload(res.data);
    books.value = await mapBookRecordsToShelfBooks(records);
    total.value = Math.max(0, Math.floor(Number(t) || 0));
  } catch {
    books.value = [];
    total.value = 0;
    ElMessage.error("加载失败，请稍后重试");
  } finally {
    loading.value = false;
  }
}

watch(
  pageNum,
  () => {
    void loadPage();
    window.scrollTo({ top: 0, behavior: "smooth" });
  },
  { immediate: true },
);
</script>

<style scoped>
.books-catalog {
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

.catalog-header {
  position: sticky;
  top: 0;
  z-index: 40;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 12px 20px;
  background: var(--wx-surface-muted);
  border-bottom: 1px solid var(--edge);
  max-width: 1200px;
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

.header-title {
  font-family: "Songti SC", "Noto Serif SC", serif;
  font-size: 17px;
  letter-spacing: 0.12em;
  font-weight: 600;
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

.catalog-main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 16px 20px 40px;
}

.catalog-meta {
  margin: 0 0 14px;
  font-size: 13px;
  color: var(--ink-soft);
}

.empty-wrap {
  padding: 48px 0;
}

.book-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px 16px;
  margin-bottom: 24px;
}

.book-card {
  display: block;
  text-decoration: none;
  color: inherit;
  background: var(--wx-surface);
  border-radius: 14px;
  overflow: hidden;
  border: 1px solid var(--edge);
  box-shadow: var(--wx-shadow-sm);
  transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
}

.book-card--clickable {
  cursor: pointer;
}

.book-card--clickable:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 3px;
}

.book-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 28px rgba(13, 148, 136, 0.1);
  border-color: rgba(13, 148, 136, 0.28);
}

.book-cover {
  aspect-ratio: 3 / 4;
  background: linear-gradient(160deg, var(--tone), #1a1010);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.book-cover-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.book-cover-initial {
  font-family: "Songti SC", "Noto Serif SC", serif;
  font-size: 40px;
  color: rgba(255, 250, 235, 0.88);
  font-weight: 600;
}

.book-body {
  padding: 10px 12px 12px;
}

.book-tag {
  display: inline-block;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 999px;
  background: rgba(13, 148, 136, 0.1);
  color: var(--accent-hover);
  margin-bottom: 6px;
}

.book-title {
  margin: 0 0 4px;
  font-size: 14px;
  font-weight: 600;
  line-height: 1.35;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.book-author {
  margin: 0 0 6px;
  font-size: 12px;
  color: var(--ink-soft);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.book-price {
  margin: 0;
  font-size: 14px;
  font-weight: 700;
  color: var(--accent-warm);
}

.pager-wrap {
  display: flex;
  justify-content: center;
  padding: 8px 0 0;
}

.pager-wrap :deep(.el-pagination) {
  flex-wrap: wrap;
  justify-content: center;
}

@media (max-width: 960px) {
  .book-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 640px) {
  .book-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
  }

  .catalog-main {
    padding: 12px 14px 32px;
  }
}
</style>
