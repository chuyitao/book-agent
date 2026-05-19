import { ref } from "vue";
import { fetchCartList } from "../api/cart";
import { getToken } from "../utils/auth";

/** 购物车角标数量（与后端列表条数同步，用于头部展示） */
export const cartBadgeCount = ref(0);

export async function refreshCartBadge(): Promise<void> {
  if (!getToken()) {
    cartBadgeCount.value = 0;
    return;
  }
  try {
    const res = await fetchCartList(1, 200);
    if (res.code === 1 && Array.isArray(res.data)) {
      cartBadgeCount.value = res.data.length;
    }
  } catch {
    cartBadgeCount.value = 0;
  }
}
