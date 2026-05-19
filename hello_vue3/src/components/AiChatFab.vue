<template>
  <div class="ai-chat-root" aria-live="polite">
    <Transition name="ai-fade">
      <div
        v-show="open"
        class="ai-chat-backdrop"
        aria-hidden="true"
        @click="close"
      />
    </Transition>

    <Transition name="ai-pop">
      <aside
        v-show="open"
        class="ai-chat-panel"
        role="dialog"
        aria-modal="true"
        aria-label="书心 AI 助手"
        @click.stop
      >
        <header class="ai-chat-head">
          <span class="ai-chat-head-title">
            <span class="ai-chat-head-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path
                  d="M12 3l1.4 3.2L17 7l-3.2 1.4L12 12l-1.8-3.6L7 7l3.6-1.4L12 3z"
                  stroke="currentColor"
                  stroke-width="1.1"
                  stroke-linejoin="round"
                />
                <path
                  d="M8 16.5c2 2.5 6 2.5 8 0"
                  stroke="currentColor"
                  stroke-width="1.1"
                  stroke-linecap="round"
                />
              </svg>
            </span>
            书心助手
          </span>
          <button type="button" class="ai-chat-close" aria-label="关闭" @click="close">
            ×
          </button>
        </header>
        <div ref="listRef" class="ai-chat-messages">
          <div
            v-for="m in messages"
            :key="m.id"
            class="ai-chat-row"
            :class="m.role === 'user' ? 'ai-chat-row--user' : 'ai-chat-row--bot'"
          >
            <template v-if="m.role === 'user'">
              <div class="ai-chat-bubble">{{ m.text }}</div>
            </template>
            <div v-else class="ai-chat-bot-block">
              <div class="ai-chat-bubble">{{ m.text }}</div>
              <div v-if="m.books?.length" class="ai-chat-book-grid">
                <article
                  v-for="book in m.books"
                  :key="book.id"
                  class="ai-book-card"
                  :class="{ 'ai-book-card--selected': getQty(m.id, book.id) > 0 }"
                >
                  <router-link
                    :to="{ name: 'book-detail', params: { id: String(book.id) } }"
                    class="ai-book-card-link"
                    :aria-label="`${book.title}，作者 ${book.author}，查看详情`"
                    @click.stop
                  >
                  <div class="ai-book-cover" :style="{ '--tone': book.tone }">
                    <img
                      v-if="book.coverUrl"
                      :src="book.coverUrl"
                      :alt="book.title"
                      class="ai-book-cover-img"
                      loading="lazy"
                    />
                    <span v-else class="ai-book-cover-initial">{{ book.title.slice(0, 1) }}</span>
                  </div>
                  <div class="ai-book-body">
                    <span class="ai-book-tag">{{ book.tag }}</span>
                    <h3 class="ai-book-title">{{ book.title }}</h3>
                    <p class="ai-book-author">{{ book.author }}</p>
                    <p class="ai-book-price">{{ book.priceText }}</p>
                  </div>
                  </router-link>
                  <div
                    class="ai-book-qty"
                    role="group"
                    :aria-label="`${book.title} 数量`"
                    @click.stop
                  >
                    <button
                      v-if="getQty(m.id, book.id) > 0"
                      type="button"
                      class="qty-btn qty-btn--minus"
                      aria-label="减少数量"
                      @click="changeQty(m.id, book.id, -1)"
                    >
                      −
                    </button>
                    <span v-if="getQty(m.id, book.id) > 0" class="qty-num">{{ getQty(m.id, book.id) }}</span>
                    <button
                      type="button"
                      class="qty-btn qty-btn--plus"
                      :aria-label="getQty(m.id, book.id) > 0 ? '增加数量' : '加入 1 本'"
                      @click="changeQty(m.id, book.id, 1)"
                    >
                      +
                    </button>
                  </div>
                </article>
                <div class="ai-book-batch" @click.stop>
                  <el-button
                    type="primary"
                    class="ai-book-batch-btn"
                    :loading="isBatchAdding(m.id)"
                    :disabled="getBatchTotalCount(m.id, m.books) < 1"
                    @click="addAllBooksToCart(m.id, m.books)"
                  >
                    一键加入{{ batchAddHint(m.id, m.books) }}
                  </el-button>
                </div>
              </div>
            </div>
          </div>
          <div v-if="thinking" class="ai-chat-row ai-chat-row--bot">
            <div class="ai-chat-bubble ai-chat-bubble--typing">正在想好怎么回您…</div>
          </div>
        </div>
        <footer class="ai-chat-foot">
          <el-input
            v-model="draft"
            type="textarea"
            :autosize="{ minRows: 1, maxRows: 4 }"
            resize="none"
            placeholder="问问找书、分类或阅读建议…"
            @keydown.enter.exact.prevent="send"
          />
          <el-button type="primary" class="ai-chat-send" :disabled="!draft.trim() || thinking" @click="send">
            发送
          </el-button>
        </footer>
      </aside>
    </Transition>

    <button
      type="button"
      class="ai-fab"
      :class="{ 'ai-fab--active': open }"
      aria-label="打开 AI 助手"
      :aria-expanded="open"
      @click="toggle"
    >
      <svg class="ai-fab__icon" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path
          d="M12 2.5l1.2 2.8L16.5 6l-2.8 1.2L12 10l-1.6-2.8L7.5 6l2.8-1.2L12 2.5z"
          stroke="currentColor"
          stroke-width="1.2"
          stroke-linejoin="round"
        />
        <path
          d="M4.5 14.5c1.3 3.4 4.5 5.8 7.5 5.8s6.2-2.4 7.5-5.8"
          stroke="currentColor"
          stroke-width="1.2"
          stroke-linecap="round"
        />
        <circle cx="9" cy="12" r="0.9" fill="currentColor" />
        <circle cx="15" cy="12" r="0.9" fill="currentColor" />
      </svg>
    </button>
  </div>
</template>

<script setup lang="ts">
import { nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { chatStreamApi, type ChatEventPayload } from '../api/chat'
import type { Book } from '../api/book'
import { fetchBookPriceByBookId } from '../api/bookPrice'
import { saveBookToCart } from '../api/cart'
import { refreshCartBadge } from '../composables/cartBadge'
import { getToken } from '../utils/auth'
import { mapToShelfBook, type ShelfBook } from '../utils/shelfBook'

type Role = 'user' | 'assistant'

interface ChatMessage {
  id: string
  role: Role
  text: string
  books?: ShelfBook[]
}

/** 后端 eventType=2：eventData 为 Map，键 book_{id}，值为 Book 实体（Jackson 序列化） */
function parseToolEventToBooks(data: unknown): Book[] {
  let raw: unknown = data
  if (typeof data === 'string') {
    try {
      raw = JSON.parse(data) as unknown
    } catch {
      return []
    }
  }
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return []
  const obj = raw as Record<string, unknown>
  const books: Book[] = []
  for (const v of Object.values(obj)) {
    if (!v || typeof v !== 'object' || Array.isArray(v)) continue
    const o = v as Record<string, unknown>
    if (!('title' in o) && !('id' in o)) continue
    const id = o.id != null ? Number(o.id) : NaN
    books.push({
      id: Number.isFinite(id) ? id : 0,
      title: String(o.title ?? ''),
      author: String(o.author ?? ''),
      type: o.type != null ? Number(o.type) : undefined,
      coverUrl: o.coverUrl != null ? String(o.coverUrl) : undefined,
      summary: o.summary != null ? String(o.summary) : undefined,
      price: o.price as number | string | undefined,
    })
  }
  return books
}

/** 与购物车一致：`Book` 无 `price` 时再请求 `/book-price/getByBookId` */
async function extractBooksFromToolEvent(data: unknown): Promise<ShelfBook[]> {
  const books = parseToolEventToBooks(data)
  const shelf: ShelfBook[] = []
  for (const b of books) {
    let priceYuan: number | null | undefined
    const fromBook = b.price != null ? Number(b.price) : NaN
    if (Number.isFinite(fromBook)) {
      priceYuan = fromBook
    } else if (b.id > 0) {
      try {
        const pr = await fetchBookPriceByBookId(b.id)
        if (pr.code === 1 && pr.data?.price != null) {
          const n = Number(pr.data.price)
          if (Number.isFinite(n)) priceYuan = n
        }
      } catch {
        /* 单条失败忽略，与购物车一致 */
      }
    }
    shelf.push(mapToShelfBook(b, priceYuan))
  }
  return shelf.filter((s) => s.id > 0 && s.title)
}

const SESSION_STORAGE_KEY = 'wx-chat-session-id'
const MAX_BOOK_QTY = 99

const route = useRoute()
const router = useRouter()

const open = ref(false)
const draft = ref('')
const thinking = ref(false)
const listRef = ref<HTMLElement | null>(null)
const sessionId = ref('')

const messages = ref<ChatMessage[]>([
  {
    id: 'welcome',
    role: 'assistant',
    text: '您好，我是你的阅读助手书心。',
  },
])

let idCounter = 0
const nextId = () => `m-${++idCounter}-${Date.now()}`

const qtyByKey = ref<Record<string, number>>({})
const batchAddingMsgId = ref<string | null>(null)

function bookQtyKey(msgId: string, bookId: number) {
  return `${msgId}-${bookId}`
}

function getQty(msgId: string, bookId: number) {
  return qtyByKey.value[bookQtyKey(msgId, bookId)] ?? 0
}

function changeQty(msgId: string, bookId: number, delta: number) {
  const key = bookQtyKey(msgId, bookId)
  const next = Math.min(MAX_BOOK_QTY, Math.max(0, (qtyByKey.value[key] ?? 0) + delta))
  if (next === 0) {
    const { [key]: _, ...rest } = qtyByKey.value
    qtyByKey.value = rest
  } else {
    qtyByKey.value = { ...qtyByKey.value, [key]: next }
  }
}

function isBatchAdding(msgId: string) {
  return batchAddingMsgId.value === msgId
}

type BatchCartItem = { bookId: number; qty: number; title: string }

function getBatchItems(msgId: string, books: ShelfBook[]): BatchCartItem[] {
  const items: BatchCartItem[] = []
  for (const book of books) {
    const qty = getQty(msgId, book.id)
    if (qty > 0) {
      items.push({ bookId: book.id, qty, title: book.title.trim() || '该图书' })
    }
  }
  return items
}

function getBatchTotalCount(msgId: string, books: ShelfBook[]) {
  return getBatchItems(msgId, books).reduce((sum, item) => sum + item.qty, 0)
}

function batchAddHint(msgId: string, books: ShelfBook[]) {
  const total = getBatchTotalCount(msgId, books)
  if (total < 1) return ''
  const kinds = getBatchItems(msgId, books).length
  return kinds > 1 ? `（${kinds} 种 · 共 ${total} 本）` : total > 1 ? `（${total} 本）` : ''
}

function clearMsgQty(msgId: string, books: ShelfBook[]) {
  const next = { ...qtyByKey.value }
  for (const book of books) {
    delete next[bookQtyKey(msgId, book.id)]
  }
  qtyByKey.value = next
}

/** 聊天面板 z-index 高于 MessageBox 默认层，须先收起否则确定要点两次且会误关面板 */
async function confirmInChatPanel(message: string, confirmButtonText: string) {
  const hadOpen = open.value
  if (hadOpen) {
    open.value = false
    await nextTick()
  }
  try {
    await ElMessageBox.confirm(message, '提示', {
      type: 'info',
      confirmButtonText,
      cancelButtonText: '取消',
    })
    return { confirmed: true, hadOpen }
  } catch {
    if (hadOpen) open.value = true
    return { confirmed: false, hadOpen }
  }
}

async function addAllBooksToCart(msgId: string, books: ShelfBook[]) {
  const items = getBatchItems(msgId, books)
  if (!items.length) {
    ElMessage.warning('请先点击 + 选择要加入的图书')
    return
  }
  if (!getToken()) {
    ElMessage.warning('请先登录')
    void router.push({ path: '/login', query: { redirect: route.fullPath } })
    return
  }
  const total = items.reduce((sum, item) => sum + item.qty, 0)
  const confirmMsg =
    items.length === 1
      ? `确定将《${items[0].title}》${items[0].qty > 1 ? `（共 ${items[0].qty} 本）` : ''}加入购物车？`
      : `确定将 ${items.length} 种图书共 ${total} 本加入购物车？`
  const { confirmed, hadOpen } = await confirmInChatPanel(confirmMsg, '加入')
  if (!confirmed) return

  batchAddingMsgId.value = msgId
  try {
    let added = 0
    for (const item of items) {
      for (let i = 0; i < item.qty; i++) {
        const res = await saveBookToCart(item.bookId)
        if (res.code !== 1) {
          ElMessage.error(res.msg || `《${item.title}》加入失败`)
          if (added > 0) {
            clearMsgQty(msgId, books)
            await refreshCartBadge()
          }
          return
        }
        added++
      }
    }
    ElMessage.success(total > 1 ? `已加入购物车 ×${total}` : '已加入购物车')
    clearMsgQty(msgId, books)
    await refreshCartBadge()
  } catch {
    ElMessage.error('加入购物车失败，请稍后重试')
  } finally {
    batchAddingMsgId.value = null
    if (hadOpen) open.value = true
  }
}

const scrollBottom = async () => {
  await nextTick()
  const el = listRef.value
  if (el) el.scrollTop = el.scrollHeight
}

watch(messages, () => void scrollBottom(), { deep: true })
watch(thinking, () => void scrollBottom())

const fallbackReply =
  '暂时无法连接对话服务，请确认后端已启动（默认 http://localhost:8099），并检查 POST /chat/stream。'

function ensureSessionId() {
  if (sessionId.value) return
  try {
    let s = sessionStorage.getItem(SESSION_STORAGE_KEY)
    if (!s) {
      s = crypto.randomUUID()
      sessionStorage.setItem(SESSION_STORAGE_KEY, s)
    }
    sessionId.value = s
  } catch {
    sessionId.value = `sess-${Date.now()}`
  }
}

let streamController: AbortController | null = null

const close = () => {
  open.value = false
}

const toggle = () => {
  open.value = !open.value
}

const send = async () => {
  const text = draft.value.trim()
  if (!text || thinking.value) return

  ensureSessionId()
  messages.value.push({ id: nextId(), role: 'user', text })
  draft.value = ''
  thinking.value = true
  await scrollBottom()

  streamController?.abort()
  streamController = new AbortController()

  try {
    await chatStreamApi(
      { question: text, sessionId: sessionId.value },
      (evt: ChatEventPayload) => {
        if (evt.eventType === 3) return
        if (evt.eventType === 2) {
          void (async () => {
            const shelf = await extractBooksFromToolEvent(evt.eventData)
            if (!shelf.length) {
              void scrollBottom()
              return
            }
            if (thinking.value) {
              thinking.value = false
              messages.value.push({ id: nextId(), role: 'assistant', text: '', books: shelf })
            } else {
              const last = messages.value[messages.value.length - 1]
              if (last?.role === 'assistant') {
                last.books = shelf
              } else {
                messages.value.push({ id: nextId(), role: 'assistant', text: '', books: shelf })
              }
            }
            void scrollBottom()
          })()
          return
        }
        if (evt.eventType !== 1) return
        const chunk = evt.eventData == null ? '' : String(evt.eventData)
        if (thinking.value) {
          thinking.value = false
          messages.value.push({ id: nextId(), role: 'assistant', text: chunk })
        } else {
          const last = messages.value[messages.value.length - 1]
          if (last?.role === 'assistant') last.text += chunk
        }
        void scrollBottom()
      },
      { signal: streamController.signal },
    )
  } catch (err: unknown) {
    if (err instanceof DOMException && err.name === 'AbortError') {
      thinking.value = false
      return
    }
    const status =
      err && typeof err === 'object' && 'status' in err
        ? (err as { status?: number }).status
        : undefined
    const tip =
      status === 401
        ? '对话接口需要有效登录，请先登录后再试。'
        : err instanceof Error && err.message
          ? err.message.length > 120
            ? '对话请求失败'
            : err.message
          : '对话请求失败'
    ElMessage.error(tip)
    const last = messages.value[messages.value.length - 1]
    if (last?.role === 'user') {
      messages.value.push({ id: nextId(), role: 'assistant', text: fallbackReply })
    } else if (last?.role === 'assistant' && !last.text) {
      last.text = fallbackReply
    }
  } finally {
    thinking.value = false
    streamController = null
    await scrollBottom()
  }
}

const onKeydown = (e: KeyboardEvent) => {
  if (e.key === 'Escape' && open.value) {
    e.preventDefault()
    close()
  }
}

onMounted(() => {
  ensureSessionId()
  window.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  streamController?.abort()
  window.removeEventListener('keydown', onKeydown)
})
</script>

<style scoped>
.ai-chat-root {
  --ai-ink: var(--wx-ink);
  --ai-paper: var(--wx-paper);
  --ai-surface: var(--wx-surface-muted);
  --ai-accent: var(--wx-accent);
  --ai-accent-deep: var(--wx-accent-deep);
  --ai-warm: var(--wx-accent-warm);
  --ai-green: var(--wx-accent-green);
  --ai-edge: var(--wx-edge);
  --ai-focus: var(--wx-focus-ring);
}

.ai-chat-backdrop {
  position: fixed;
  inset: 0;
  z-index: 2990;
  background: rgba(15, 23, 42, 0.18);
  backdrop-filter: blur(2px);
}

.ai-fade-enter-active,
.ai-fade-leave-active {
  transition: opacity 0.22s ease;
}

.ai-fade-enter-from,
.ai-fade-leave-to {
  opacity: 0;
}

.ai-chat-panel {
  position: fixed;
  z-index: 2991;
  right: 24px;
  bottom: 88px;
  width: min(440px, calc(100vw - 32px));
  height: min(760px, calc(100vh - 72px));
  max-height: min(760px, calc(100vh - 72px));
  display: flex;
  flex-direction: column;
  background: var(--ai-surface);
  backdrop-filter: blur(16px) saturate(1.1);
  -webkit-backdrop-filter: blur(16px) saturate(1.1);
  border: 1px solid rgba(255, 255, 255, 0.7);
  border-radius: 16px;
  box-shadow:
    0 20px 56px rgba(15, 23, 42, 0.14),
    0 0 0 1px rgba(255, 255, 255, 0.55) inset;
  overflow: hidden;
}

.ai-pop-enter-active,
.ai-pop-leave-active {
  transition:
    opacity 0.2s ease,
    transform 0.22s ease;
}

.ai-pop-enter-from,
.ai-pop-leave-to {
  opacity: 0;
  transform: translateY(12px) scale(0.98);
}

.ai-chat-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-shrink: 0;
  padding: 14px 16px;
  border-bottom: 1px solid var(--ai-edge);
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.95), rgba(240, 253, 244, 0.85));
}

.ai-chat-head-title {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
  font-weight: 600;
  color: var(--ai-ink);
  letter-spacing: 0.06em;
}

.ai-chat-head-icon {
  display: flex;
  color: var(--ai-accent);
}

.ai-chat-head-icon svg {
  width: 22px;
  height: 22px;
}

.ai-chat-close {
  border: none;
  background: transparent;
  font-size: 22px;
  line-height: 1;
  color: #78716c;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 6px;
  transition: background 0.15s, color 0.15s;
}

.ai-chat-close:hover {
  background: var(--ai-focus);
  color: var(--ai-accent-deep);
}

.ai-chat-messages {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  background: linear-gradient(180deg, rgba(240, 253, 244, 0.35), rgba(255, 255, 255, 0.2));
}

.ai-chat-row {
  display: flex;
}

.ai-chat-row--user {
  justify-content: flex-end;
}

.ai-chat-row--bot {
  justify-content: flex-start;
}

.ai-chat-bot-block {
  max-width: 100%;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 10px;
}

.ai-chat-book-grid {
  width: 100%;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
}

.ai-book-batch {
  grid-column: 1 / -1;
  margin-top: 2px;
}

.ai-book-batch-btn {
  width: 100%;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 0.04em;
  background: linear-gradient(135deg, var(--ai-accent) 0%, #14b8a6 100%);
  border: none;
}

.ai-book-batch-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, var(--ai-accent-deep) 0%, #0d9488 100%);
}

.ai-book-card {
  position: relative;
  display: flex;
  flex-direction: column;
  color: inherit;
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid var(--ai-edge);
  box-shadow: 0 4px 14px rgba(15, 23, 42, 0.06);
  transition: transform 0.18s, box-shadow 0.18s, border-color 0.18s;
}

.ai-book-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 22px rgba(13, 148, 136, 0.12);
  border-color: rgba(13, 148, 136, 0.28);
}

.ai-book-card--selected {
  border-color: rgba(13, 148, 136, 0.45);
  box-shadow: 0 6px 18px rgba(13, 148, 136, 0.14);
}

.ai-book-card-link {
  display: block;
  text-decoration: none;
  color: inherit;
  flex: 1;
  min-height: 0;
}

.ai-book-card-link:hover .ai-book-title {
  color: var(--ai-accent-deep);
}

.ai-book-cover {
  aspect-ratio: 3 / 4;
  background: linear-gradient(160deg, var(--tone), #1a1010);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.ai-book-cover-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.ai-book-cover-initial {
  font-family: 'Songti SC', 'Noto Serif SC', serif;
  font-size: 28px;
  color: rgba(255, 250, 235, 0.88);
  font-weight: 600;
}

.ai-book-body {
  padding: 8px 36px 10px 10px;
}

.ai-book-tag {
  display: inline-block;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 999px;
  background: rgba(13, 148, 136, 0.1);
  color: var(--ai-accent-deep);
  margin-bottom: 4px;
}

.ai-book-title {
  margin: 0 0 4px;
  font-size: 13px;
  font-weight: 600;
  line-height: 1.35;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.ai-book-author {
  margin: 0 0 4px;
  font-size: 11px;
  color: #64748b;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.ai-book-price {
  margin: 0;
  font-size: 13px;
  font-weight: 700;
  color: var(--ai-warm);
}

.ai-book-qty {
  position: absolute;
  right: 6px;
  bottom: 6px;
  z-index: 2;
  display: inline-flex;
  align-items: center;
  gap: 2px;
  padding: 2px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.96);
  box-shadow: 0 2px 10px rgba(15, 23, 42, 0.1);
}

.qty-btn {
  width: 24px;
  height: 24px;
  padding: 0;
  border: none;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  line-height: 1;
  cursor: pointer;
  transition: background 0.15s, transform 0.12s;
}

.qty-btn--plus {
  background: linear-gradient(135deg, var(--ai-accent) 0%, #14b8a6 100%);
  color: #f0fdfa;
  box-shadow: 0 2px 8px rgba(13, 148, 136, 0.35);
}

.qty-btn--plus:hover {
  transform: scale(1.06);
}

.qty-btn--minus {
  background: var(--wx-surface);
  color: var(--ai-ink);
  box-shadow: 0 0 0 1px var(--ai-edge) inset;
}

.qty-btn--minus:hover {
  background: var(--ai-focus);
}

.qty-num {
  min-width: 16px;
  text-align: center;
  font-size: 12px;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
  color: var(--ai-ink);
}

.ai-chat-bubble {
  max-width: 88%;
  padding: 10px 12px;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.55;
  white-space: pre-wrap;
  word-break: break-word;
}

.ai-chat-row--bot .ai-chat-bubble {
  background: var(--wx-surface);
  border: 1px solid var(--ai-edge);
  color: var(--ai-ink);
  border-bottom-left-radius: 4px;
  box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
}

.ai-chat-row--user .ai-chat-bubble {
  background: linear-gradient(135deg, var(--ai-accent) 0%, #14b8a6 100%);
  color: #f0fdfa;
  border-bottom-right-radius: 4px;
  box-shadow: 0 4px 12px rgba(13, 148, 136, 0.25);
}

.ai-chat-bubble--typing {
  opacity: 0.85;
  font-style: italic;
}

.ai-chat-foot {
  flex-shrink: 0;
  padding: 12px 14px 14px;
  border-top: 1px solid var(--ai-edge);
  display: flex;
  gap: 10px;
  align-items: flex-end;
  background: rgba(255, 255, 255, 0.95);
}

.ai-chat-foot :deep(.el-textarea__inner) {
  border-radius: 10px;
  font-size: 14px;
  background: rgba(255, 255, 255, 0.95);
  box-shadow: 0 0 0 1px var(--ai-edge) inset;
  transition: box-shadow 0.2s ease;
}

.ai-chat-foot :deep(.el-textarea__inner:focus) {
  box-shadow: 0 0 0 1px var(--ai-accent) inset, 0 0 0 3px var(--ai-focus);
}

.ai-chat-send {
  flex-shrink: 0;
  height: 40px;
  border: none;
  border-radius: 10px;
  --el-button-bg-color: transparent;
  --el-button-border-color: transparent;
  --el-button-hover-bg-color: transparent;
  --el-button-hover-border-color: transparent;
  background: linear-gradient(135deg, var(--ai-warm) 0%, var(--ai-green) 100%);
  box-shadow: 0 4px 14px rgba(202, 138, 4, 0.3);
}

.ai-chat-send:hover {
  background: linear-gradient(135deg, #a16207 0%, #4d7c0f 100%);
}

.ai-fab {
  position: fixed;
  z-index: 2992;
  right: 22px;
  bottom: 22px;
  width: 56px;
  height: 56px;
  border: none;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(145deg, var(--ai-warm), var(--ai-accent));
  color: #f0fdfa;
  box-shadow:
    0 6px 22px rgba(13, 148, 136, 0.35),
    0 2px 6px rgba(15, 23, 42, 0.1);
  transition:
    transform 0.18s ease,
    box-shadow 0.18s ease;
}

.ai-fab:hover {
  transform: scale(1.05);
  box-shadow:
    0 8px 28px rgba(13, 148, 136, 0.4),
    0 2px 8px rgba(15, 23, 42, 0.12);
}

.ai-fab--active {
  background: linear-gradient(145deg, var(--ai-accent-deep), #115e59);
}

.ai-fab__icon {
  width: 28px;
  height: 28px;
}

@media (max-width: 480px) {
  .ai-chat-panel {
    right: 12px;
    bottom: 80px;
    width: calc(100vw - 24px);
    height: min(680px, calc(100vh - 64px));
    max-height: min(680px, calc(100vh - 64px));
  }

  .ai-fab {
    right: 16px;
    bottom: 16px;
  }
}
</style>
