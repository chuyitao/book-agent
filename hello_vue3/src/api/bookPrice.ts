import request from "../utils/request";
import type { ApiResult } from "./book";

/** 与后端 cn.itcast.entity.BookPrice 一致 */
export interface BookPrice {
  id: number;
  bookId: number;
  price: number;
  createdAt?: string;
  updatedAt?: string;
}

/** GET /book-price/getByBookId?bookId= */
export function fetchBookPriceByBookId(bookId: number) {
  return request.get<any, ApiResult<BookPrice | null>>("/book-price/getByBookId", {
    params: { bookId },
  });
}

/** 并发拉取多本书的定价，失败或 401 时跳过（不影响列表展示） */
export async function fetchPriceMapByBookIds(ids: number[]): Promise<Map<number, number>> {
  const unique = [...new Set(ids.filter((id) => Number.isFinite(id) && id > 0))];
  const map = new Map<number, number>();
  await Promise.all(
    unique.map(async (id) => {
      try {
        const res = await fetchBookPriceByBookId(id);
        if (res.code === 1 && res.data?.price != null) {
          const n = Number(res.data.price);
          if (Number.isFinite(n)) map.set(id, n);
        }
      } catch {
        /* 无定价或未登录等 */
      }
    }),
  );
  return map;
}
