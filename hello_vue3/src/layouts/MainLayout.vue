<template>
  <div class="bookstore">
    <header class="site-header">
      <div class="header-inner">
        <router-link to="/" class="brand">
          <BrandMark />
          <span class="brand-rule" aria-hidden="true" />
          <span class="brand-text">
            <span class="brand-name">万象书心</span>
            <span class="brand-tag">线上书城</span>
          </span>
        </router-link>

        <nav class="nav" aria-label="主导航">
          <a href="#featured" class="nav-link" @click.prevent="scrollTo('featured')">精选</a>
          <a href="#new-arrivals" class="nav-link" @click.prevent="scrollTo('new-arrivals')">新书上架</a>
          <a href="#categories" class="nav-link" @click.prevent="scrollTo('categories')">分类浏览</a>
        </nav>

        <div class="header-tools">
          <el-input
            v-model="searchKeyword"
            class="search-input"
            placeholder="书名、作者、ISBN…"
            clearable
            @keyup.enter="onSearch"
          >
            <template #prefix>
              <span class="search-prefix" aria-hidden="true">搜</span>
            </template>
          </el-input>
          <AppearanceToolbar compact />
          <CartEntry />
          <template v-if="isLoggedIn">
            <span class="user-greet">你好，{{ userName }}</span>
            <el-button class="ghost-btn" @click="handleLogout">退出</el-button>
          </template>
          <el-button v-else type="primary" class="login-entry" @click="goLogin">登录</el-button>
        </div>
      </div>
    </header>

    <section class="hero">
      <div
        class="hero-bg"
        :style="{ backgroundImage: `url(${coverImg})` }"
        aria-hidden="true"
      />
      <div class="hero-overlay" aria-hidden="true" />
      <div class="hero-content">
        <p class="hero-eyebrow">纸墨之间 · 自有天地</p>
        <h1 class="hero-title">在万象书心，遇见下一本好书</h1>
        <p class="hero-desc">
          文学、社科、生活美学与童书绘本，为你精选可读可藏之本；下单与会员权益等功能将陆续开放。
        </p>
        <div class="hero-cta">
          <el-button type="primary" size="large" class="cta-primary" @click="scrollTo('featured')">
            逛逛精选
          </el-button>
          <el-button v-if="!isLoggedIn" size="large" class="cta-secondary" @click="goLogin">
            登录享更多
          </el-button>
        </div>
      </div>
    </section>

    <main class="main">
      <section id="featured" class="section">
        <div class="section-head">
          <h2 class="section-title">店主编选</h2>
          <p class="section-sub">本周值得一读的纸质温度</p>
        </div>
        <div class="book-grid">
          <router-link
            v-for="book in featuredBooks"
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
        <div class="section-more">
          <router-link :to="{ name: 'books' }" class="more-link">查看更多</router-link>
        </div>
      </section>

      <section id="new-arrivals" class="section section--alt">
        <div class="section-head">
          <h2 class="section-title">新书上架</h2>
          <p class="section-sub">刚到店的新面孔</p>
        </div>
        <div class="book-grid book-grid--compact">
          <router-link
            v-for="book in newBooks"
            :key="book.id"
            :to="{ name: 'book-detail', params: { id: String(book.id) } }"
            class="book-card book-card--compact book-card--clickable"
            :aria-label="`${book.title}，作者 ${book.author}，查看详情`"
          >
            <div class="book-cover book-cover--sm" :style="{ '--tone': book.tone }">
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
              <h3 class="book-title">{{ book.title }}</h3>
              <p class="book-author">{{ book.author }}</p>
              <p class="book-price">{{ book.priceText }}</p>
            </div>
          </router-link>
        </div>
      </section>

      <section id="categories" class="section">
        <div class="section-head">
          <h2 class="section-title">分类浏览</h2>
          <p class="section-sub">按心情选一条阅读路线</p>
        </div>
        <div class="category-strip">
          <button
            v-for="c in categories"
            :key="c"
            type="button"
            class="category-chip"
            @click="onCategoryTap(c)"
          >
            {{ c }}
          </button>
        </div>
      </section>
    </main>

    <footer class="site-footer">
      <p class="footer-line">© {{ year }} 万象书心 · 线上书城 · 阅无边界</p>
      <p class="footer-fine">建议用干净的书签夹住今日读到的那一页。</p>
    </footer>
  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import AppearanceToolbar from '../components/AppearanceToolbar.vue'
import BrandMark from '../components/BrandMark.vue'
import coverImg from '../../img/6C69281ACAB49C01AF6D0C164F03F2AC.jpg'
import CartEntry from '../components/CartEntry.vue'
import { clearAuthInfo, getToken, getUserName } from '../utils/auth'
import { fetchBookList, normalizeBookListPayload } from '../api/book'
import { mapBookRecordsToShelfBooks, type ShelfBook } from '../utils/shelfBook'
import { refreshCartBadge } from '../composables/cartBadge'

const router = useRouter()
const searchKeyword = ref('')
const year = new Date().getFullYear()

const isLoggedIn = computed(() => Boolean(getToken()))
const userName = computed(() => getUserName() || '书友')

const categories = ['文学小说', '人文社科', '艺术设计', '生活美学', '童书绘本', '经管励志']

const featuredBooks = ref<ShelfBook[]>([])
const newBooks = ref<ShelfBook[]>([])

async function loadBooks() {
  try {
    const res = await fetchBookList(1, 8)
    if (res.code != 1) {
      ElMessage.warning(res.msg || '书库暂时无法加载')
      return
    }
    const { records } = normalizeBookListPayload(res.data)
    const rows = await mapBookRecordsToShelfBooks(records)
    featuredBooks.value = rows.slice(0, 4)
    const rest = rows.slice(4, 8)
    newBooks.value = rest.length ? rest : []
  } catch {
    ElMessage.error('书库加载失败，请稍后重试')
  }
}

onMounted(() => {
  void loadBooks()
  if (getToken()) void refreshCartBadge()
})

const scrollTo = (id: string) => {
  document.getElementById(id)?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

const onSearch = () => {
  const q = searchKeyword.value.trim()
  if (!q) {
    ElMessage.info('请输入想找的书名或关键词')
    return
  }
  ElMessage.success(`已记录关键词「${q}」，书目检索即将接入后端`)
}

const onCategoryTap = (name: string) => {
  ElMessage.info(`「${name}」分类列表开发中`)
}

const goLogin = () => {
  router.push('/login')
}

const handleLogout = () => {
  clearAuthInfo()
  void refreshCartBadge()
  ElMessage.success('已退出登录')
  router.push('/login')
}
</script>

<style scoped>
.bookstore {
  --ink: var(--wx-ink);
  --ink-soft: var(--wx-ink-soft);
  --paper: var(--wx-page-bg);
  --paper-deep: var(--wx-paper-deep);
  --accent: var(--wx-accent);
  --accent-hover: var(--wx-accent-deep);
  --accent-warm: var(--wx-accent-warm);
  --edge: var(--wx-edge);
  min-height: 100vh;
  background: var(--paper);
  color: var(--ink);
}

.site-header {
  position: sticky;
  top: 0;
  z-index: 50;
  background: var(--wx-surface-muted);
  backdrop-filter: blur(12px) saturate(1.1);
  -webkit-backdrop-filter: blur(12px) saturate(1.1);
  border-bottom: 1px solid var(--edge);
}

.header-inner {
  max-width: 1120px;
  margin: 0 auto;
  padding: 14px 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.brand {
  display: flex;
  align-items: center;
  gap: 0;
  text-decoration: none;
  color: inherit;
  transition: opacity 0.2s ease;
}

.brand:hover {
  opacity: 0.88;
}

.brand-rule {
  width: 1px;
  height: 30px;
  margin: 0 14px 0 12px;
  align-self: center;
  background: linear-gradient(
    180deg,
    transparent 0%,
    rgba(13, 148, 136, 0.2) 20%,
    rgba(13, 148, 136, 0.2) 80%,
    transparent 100%
  );
}

.brand-text {
  display: flex;
  flex-direction: column;
  gap: 5px;
  padding-top: 1px;
}

.brand-name {
  font-family: "Songti SC", "Noto Serif SC", "STSong", "SimSun", serif;
  font-size: 18px;
  font-weight: 500;
  letter-spacing: 0.22em;
  line-height: 1.2;
  color: var(--ink);
}

.brand-tag {
  font-size: 10px;
  font-weight: 400;
  color: var(--ink-soft);
  letter-spacing: 0.42em;
  opacity: 0.85;
}

.nav {
  display: flex;
  gap: 8px 20px;
  flex: 1;
  justify-content: center;
  flex-wrap: wrap;
}

.nav-link {
  font-size: 14px;
  color: var(--ink-soft);
  text-decoration: none;
  transition: color 0.2s;
}

.nav-link:hover {
  color: var(--accent);
}

.header-tools {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.search-input {
  width: 220px;
}

.search-input :deep(.el-input__wrapper) {
  border-radius: 999px;
  background: var(--wx-surface);
  box-shadow: 0 0 0 1px var(--edge) inset;
}

.search-prefix {
  font-size: 14px;
  opacity: 0.5;
}

.user-greet {
  font-size: 13px;
  color: var(--ink-soft);
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.ghost-btn {
  --el-button-border-color: var(--edge);
  --el-button-text-color: var(--ink-soft);
}

.login-entry,
.cta-primary {
  border-radius: 999px;
}

.cta-secondary {
  border-radius: 999px;
  --el-button-bg-color: transparent;
  --el-button-text-color: var(--accent);
  --el-button-border-color: var(--accent);
  --el-button-hover-bg-color: rgba(13, 148, 136, 0.08);
  --el-button-hover-text-color: var(--accent-deep);
  --el-button-hover-border-color: var(--accent);
}

.hero {
  position: relative;
  padding: 72px 24px 88px;
  overflow: hidden;
}

.hero-bg {
  position: absolute;
  inset: 0;
  background-size: cover;
  background-position: center 30%;
  background-repeat: no-repeat;
  pointer-events: none;
}

.hero-overlay {
  position: absolute;
  inset: 0;
  background: var(--wx-hero-overlay);
  pointer-events: none;
}

.hero-content {
  position: relative;
  max-width: 720px;
  margin: 0 auto;
  text-align: center;
}

.hero-eyebrow {
  margin: 0 0 12px;
  font-size: 13px;
  letter-spacing: 0.35em;
  color: var(--accent-warm);
  text-transform: uppercase;
}

.hero-title {
  margin: 0 0 16px;
  font-family: "Songti SC", "Noto Serif SC", "STSong", serif;
  font-size: clamp(26px, 5vw, 38px);
  font-weight: 700;
  line-height: 1.35;
  letter-spacing: 0.06em;
}

.hero-desc {
  margin: 0 0 28px;
  font-size: 15px;
  line-height: 1.75;
  color: var(--ink-soft);
  max-width: 560px;
  margin-left: auto;
  margin-right: auto;
}

.hero-cta {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  justify-content: center;
}

.main {
  max-width: 1120px;
  margin: 0 auto;
  padding: 0 24px 48px;
  background: var(--wx-page-bg);
}

.section {
  padding: 32px 0;
}

.section--alt {
  margin: 0 -24px;
  padding: 32px 24px;
  background: var(--wx-page-bg);
  border-radius: 16px;
  border: 1px solid var(--edge);
  box-shadow: none;
}

.section-head {
  text-align: center;
  margin-bottom: 24px;
}

.section-title {
  margin: 0 0 8px;
  font-family: "Songti SC", "Noto Serif SC", "STSong", serif;
  font-size: 24px;
  font-weight: 700;
  letter-spacing: 0.08em;
}

.section-sub {
  margin: 0;
  font-size: 14px;
  color: var(--ink-soft);
}

.section-more {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}

.more-link {
  font-size: 14px;
  font-weight: 500;
  color: var(--accent);
  text-decoration: none;
  letter-spacing: 0.06em;
}

.more-link:hover {
  text-decoration: underline;
}

.book-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.book-grid--compact {
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
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

.book-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 16px 40px rgba(13, 148, 136, 0.12);
  border-color: rgba(13, 148, 136, 0.28);
}

.book-card--clickable {
  cursor: pointer;
}

.book-card--clickable:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 3px;
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

.book-cover--sm {
  aspect-ratio: 3 / 3.6;
}

.book-cover-initial {
  font-family: "Songti SC", "Noto Serif SC", serif;
  font-size: 52px;
  color: rgba(255, 250, 235, 0.88);
  font-weight: 600;
}

.book-card--compact .book-cover-initial {
  font-size: 40px;
}

.book-body {
  padding: 10px 12px 14px;
}

.book-tag {
  display: inline-block;
  font-size: 11px;
  padding: 2px 8px;
  border-radius: 999px;
  background: rgba(13, 148, 136, 0.1);
  color: var(--accent-deep);
  margin-bottom: 8px;
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
  font-size: 15px;
  font-weight: 700;
  color: var(--accent-warm);
}

.currency {
  font-size: 13px;
  margin-right: 2px;
}

.category-strip {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  justify-content: center;
}

.category-chip {
  cursor: pointer;
  font-size: 14px;
  padding: 10px 20px;
  border-radius: 999px;
  border: 1px solid var(--edge);
  background: var(--wx-surface);
  color: var(--ink-soft);
  transition: border-color 0.2s, color 0.2s, background 0.2s;
}

.category-chip:hover {
  border-color: var(--accent);
  color: var(--accent-deep);
  background: rgba(13, 148, 136, 0.08);
}

.site-footer {
  padding: 32px 24px 40px;
  text-align: center;
  border-top: 1px solid var(--edge);
  background: var(--wx-page-bg);
}

.footer-line {
  margin: 0 0 8px;
  font-size: 13px;
  color: var(--ink-soft);
}

.footer-fine {
  margin: 0;
  font-size: 12px;
  color: var(--ink-soft);
  opacity: 0.75;
}

@media (max-width: 960px) {
  .book-grid,
  .book-grid--compact {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 640px) {
  .book-grid,
  .book-grid--compact {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
  }
}

@media (max-width: 768px) {
  .search-input {
    width: 100%;
    order: 10;
  }

  .header-inner {
    justify-content: center;
  }

  .nav {
    order: 11;
    width: 100%;
    justify-content: center;
  }
}
</style>
