<template>
  <div class="cart-entry">
    <el-badge :value="cartBadgeCount" :hidden="cartBadgeCount === 0" :max="99" class="cart-badge">
      <el-button class="cart-btn" circle plain @click="onCartClick" aria-label="购物车">
        <span class="cart-icon" aria-hidden="true">🛒</span>
      </el-button>
    </el-badge>

    <!-- append-to-body：必须挂到 body，否则在 sticky/flex 头部内 fixed 定位会错位 -->
    <el-drawer
      v-model="drawerVisible"
      title="购物车"
      direction="rtl"
      size="420px"
      append-to-body
      :z-index="3200"
    >
      <div v-loading="loading" class="drawer-body">
        <template v-if="!getToken()">
          <el-empty description="登录后可查看购物车" />
        </template>
        <template v-else-if="!cartRows.length && !loading">
          <el-empty description="购物车还是空的，去挑本书吧" />
        </template>
        <template v-else>
          <div class="cart-toolbar">
            <el-checkbox v-model="checkAll" :indeterminate="isIndeterminate">全选</el-checkbox>
            <el-button
              type="danger"
              size="small"
              plain
              :disabled="!selectedIds.length"
              @click="removeSelected"
            >
              批量删除{{ selectedIds.length ? `（${selectedIds.length}）` : "" }}
            </el-button>
          </div>
          <el-checkbox-group v-model="selectedIds" class="cart-list">
            <li v-for="row in cartRows" :key="row.cart.id" class="cart-row">
              <el-checkbox :label="row.cart.id" class="row-check" @click.stop />
              <div class="row-cover" :style="{ '--tone': row.tone }">
              <img
                v-if="row.coverUrl"
                :src="row.coverUrl"
                :alt="row.title"
                class="row-cover-img"
                loading="lazy"
              />
              <span v-else class="row-initial">{{ row.title.slice(0, 1) }}</span>
            </div>
            <div class="row-main">
              <p class="row-title">{{ row.title }}</p>
              <p class="row-meta">{{ row.author }} · {{ row.priceLine }}</p>
            </div>
              <el-button type="danger" link @click="remove(row.cart.id)">移除</el-button>
            </li>
          </el-checkbox-group>
        </template>
      </div>
      <template #footer>
        <div v-if="getToken() && cartRows.length" class="cart-footer">
          <p class="footer-line">
            <span>共 <strong>{{ cartRows.length }}</strong> 件</span>
            <span v-if="pricedCount < cartRows.length" class="footer-hint">
              · 其中 <strong>{{ cartRows.length - pricedCount }}</strong> 本暂无定价
            </span>
          </p>
          <p class="footer-total">
            <span class="footer-total-label">小计（仅含已标价）</span>
            <span class="footer-total-value">{{ subtotalLine }}</span>
          </p>
        </div>
      </template>
    </el-drawer>
  </div>
</template>

<script lang="ts" setup>
import { computed, nextTick, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import type { Cart } from "../api/cart";
import { deleteCartById, fetchCartList } from "../api/cart";
import { fetchBookById, type Book } from "../api/book";
import { fetchBookPriceByBookId } from "../api/bookPrice";
import { cartBadgeCount, refreshCartBadge } from "../composables/cartBadge";
import { formatYuanPrice } from "../utils/shelfBook";
import { getToken } from "../utils/auth";

const TONES = ["#5c3d2e", "#1e3a5f", "#6b4f3a", "#2d4a3e", "#7c4a3a", "#4a5568", "#3d5c5c", "#8b4513"];

const route = useRoute();
const router = useRouter();

const drawerVisible = ref(false);
const loading = ref(false);
type CartRow = {
  cart: Cart;
  title: string;
  author: string;
  tone: string;
  priceLine: string;
  /** 有定价时为金额（元），否则为 null */
  priceAmount: number | null;
  coverUrl?: string;
};

const cartRows = ref<CartRow[]>([]);
const selectedIds = ref<number[]>([]);

const checkAll = computed({
  get() {
    const total = cartRows.value.length;
    return total > 0 && selectedIds.value.length === total;
  },
  set(checked: boolean) {
    selectedIds.value = checked ? cartRows.value.map((r) => r.cart.id) : [];
  },
});

const isIndeterminate = computed(() => {
  const n = selectedIds.value.length;
  const total = cartRows.value.length;
  return n > 0 && n < total;
});

const pricedCount = computed(() => cartRows.value.filter((r) => r.priceAmount != null).length);

const subtotalLine = computed(() => {
  const sum = cartRows.value.reduce((s, r) => s + (r.priceAmount ?? 0), 0);
  if (pricedCount.value === 0) return "—";
  return formatYuanPrice(sum);
});

const bookCache = ref<Map<number, Book>>(new Map());

async function resolveBook(bookId: number): Promise<Book | null> {
  const cached = bookCache.value.get(bookId);
  if (cached) return cached;
  try {
    const res = await fetchBookById(bookId);
    if (res.code === 1 && res.data) {
      bookCache.value.set(bookId, res.data);
      return res.data;
    }
  } catch {
    /* 忽略单条失败 */
  }
  return null;
}

function onCartClick() {
  if (!getToken()) {
    ElMessage.warning("请先登录");
    void router.push({ path: "/login", query: { redirect: route.fullPath } });
    return;
  }
  drawerVisible.value = true;
}

async function loadDrawer() {
  if (!getToken()) return;
  loading.value = true;
  try {
    const res = await fetchCartList(1, 200);
    if (res.code !== 1 || !Array.isArray(res.data)) {
      cartRows.value = [];
      return;
    }
    const rows: CartRow[] = [];
    for (const cart of res.data) {
      const bid = Number(cart.bookId);
      const book = await resolveBook(bid);
      const title = book?.title ?? `图书 #${bid}`;
      const author = book?.author ?? "—";
      const tone = TONES[Math.abs(bid) % TONES.length] ?? "#5c3d2e";
      let priceLine = "暂无标价";
      let priceAmount: number | null = null;
      if (book?.price != null) {
        const n = Number(book.price);
        if (Number.isFinite(n)) {
          priceAmount = n;
          priceLine = formatYuanPrice(n);
        }
      }
      if (priceAmount == null) {
        try {
          const pr = await fetchBookPriceByBookId(bid);
          if (pr.code === 1 && pr.data?.price != null) {
            const n = Number(pr.data.price);
            if (Number.isFinite(n)) {
              priceAmount = n;
              priceLine = formatYuanPrice(n);
            }
          }
        } catch {
          priceLine = "暂无标价";
        }
      }
      const coverUrl = book?.coverUrl?.trim() || undefined;
      rows.push({ cart, title, author, tone, priceLine, priceAmount, coverUrl });
    }
    cartRows.value = rows;
    selectedIds.value = [];
    await refreshCartBadge();
  } finally {
    loading.value = false;
  }
}

async function confirmInDrawer(message: string, confirmButtonText: string) {
  const hadDrawerOpen = drawerVisible.value;
  if (hadDrawerOpen) {
    drawerVisible.value = false;
    await nextTick();
  }
  try {
    await ElMessageBox.confirm(message, "提示", {
      type: "warning",
      confirmButtonText,
      cancelButtonText: "取消",
    });
    return { confirmed: true, hadDrawerOpen };
  } catch {
    if (hadDrawerOpen) drawerVisible.value = true;
    return { confirmed: false, hadDrawerOpen };
  }
}

async function removeSelected() {
  const ids = [...selectedIds.value];
  if (!ids.length) return;
  const { confirmed, hadDrawerOpen } = await confirmInDrawer(
    `确定移除已选的 ${ids.length} 件商品？`,
    "批量移除",
  );
  if (!confirmed) return;
  try {
    const results = await Promise.allSettled(ids.map((id) => deleteCartById(id)));
    const failed = results.filter(
      (r) => r.status === "rejected" || (r.status === "fulfilled" && r.value.code !== 1),
    );
    const successCount = ids.length - failed.length;
    if (successCount === 0) {
      ElMessage.error("批量删除失败");
      return;
    }
    if (failed.length > 0) {
      ElMessage.warning(`已移除 ${successCount} 件，${failed.length} 件失败`);
    } else {
      ElMessage.success("已批量移除");
    }
    selectedIds.value = [];
    await refreshCartBadge();
    await loadDrawer();
  } catch {
    ElMessage.error("批量删除失败，请稍后重试");
  } finally {
    if (hadDrawerOpen) drawerVisible.value = true;
  }
}

async function remove(cartId: number) {
  const { confirmed, hadDrawerOpen } = await confirmInDrawer("确定从购物车中移除该商品？", "移除");
  if (!confirmed) return;
  try {
    const res = await deleteCartById(cartId);
    if (res.code !== 1) {
      ElMessage.error(res.msg || "移除失败");
      return;
    }
    ElMessage.success("已移除");
    await refreshCartBadge();
    await loadDrawer();
  } catch {
    ElMessage.error("移除失败，请稍后重试");
  } finally {
    if (hadDrawerOpen) drawerVisible.value = true;
  }
}

watch(drawerVisible, (open) => {
  if (open && getToken()) void loadDrawer();
});
</script>

<style scoped>
.cart-entry {
  display: inline-flex;
  align-items: center;
}

.cart-btn {
  --el-button-bg-color: var(--wx-surface);
  --el-button-border-color: var(--wx-edge);
  padding: 8px;
  border-radius: 10px;
}

.cart-icon {
  font-size: 18px;
  line-height: 1;
}

.cart-badge :deep(.el-badge__content) {
  border: none;
}

.drawer-body {
  min-height: 120px;
}

.cart-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
  padding: 0 2px;
}

.cart-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
}

.row-check {
  flex-shrink: 0;
  margin-right: -4px;
}

.row-check :deep(.el-checkbox__label) {
  display: none;
}

.cart-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 12px;
  border: 1px solid var(--wx-edge);
  background: var(--wx-surface);
  color: var(--wx-ink);
}

.row-cover {
  width: 48px;
  height: 60px;
  border-radius: 8px;
  flex-shrink: 0;
  background: linear-gradient(160deg, var(--tone), #1a1010);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.row-cover-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.row-initial {
  font-size: 20px;
  color: rgba(255, 250, 235, 0.9);
  font-family: "Songti SC", "Noto Serif SC", serif;
}

.row-main {
  flex: 1;
  min-width: 0;
}

.row-title {
  margin: 0 0 4px;
  font-size: 15px;
  font-weight: 600;
  line-height: 1.35;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.row-meta {
  margin: 0;
  font-size: 12px;
  color: var(--wx-ink-soft);
  opacity: 0.85;
}

.cart-footer {
  padding: 12px 4px 4px;
  border-top: 1px solid var(--wx-edge);
}

.footer-line {
  margin: 0 0 8px;
  font-size: 13px;
  color: var(--wx-ink-soft);
}

.footer-hint {
  color: var(--wx-accent);
}

.footer-total {
  margin: 0;
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
  font-size: 15px;
}

.footer-total-label {
  color: var(--wx-ink-soft);
  font-size: 13px;
}

.footer-total-value {
  font-weight: 700;
  color: var(--wx-accent-warm);
  font-variant-numeric: tabular-nums;
}
</style>
