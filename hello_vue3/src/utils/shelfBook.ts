import { BOOK_TYPE_LABELS, type Book } from "../api/book";
import { fetchPriceMapByBookIds } from "../api/bookPrice";

const TONE_PALETTE = [
  "#5c3d2e",
  "#1e3a5f",
  "#6b4f3a",
  "#2d4a3e",
  "#7c4a3a",
  "#4a5568",
  "#3d5c5c",
  "#8b4513",
];

export interface ShelfBook {
  id: number;
  title: string;
  author: string;
  tag: string;
  tone: string;
  priceText: string;
  /** 与详情页一致；有则卡片封面用图片，否则用首字渐变占位 */
  coverUrl?: string;
}

export function formatYuanPrice(n: number | null | undefined): string {
  if (n == null || !Number.isFinite(Number(n))) return "暂无标价";
  return `¥${Number(n).toFixed(2)}`;
}

/**
 * @param priceYuan 可选覆盖；否则使用 `b.price`（列表/详情接口已由后端合并定价）
 */
export function mapToShelfBook(b: Book, priceYuan?: number | null): ShelfBook {
  const id = Number(b.id);
  const tone = TONE_PALETTE[Math.abs(id) % TONE_PALETTE.length] ?? "#5c3d2e";
  const tag: string = (b.type != null ? BOOK_TYPE_LABELS[b.type] : undefined) ?? "图书";
  const fromBook = b.price != null ? Number(b.price) : NaN;
  const merged =
    priceYuan != null && Number.isFinite(Number(priceYuan))
      ? Number(priceYuan)
      : Number.isFinite(fromBook)
        ? fromBook
        : null;
  const hasPrice = merged != null && Number.isFinite(merged);
  return {
    id,
    title: b.title ?? "",
    author: b.author ?? "",
    tag,
    tone,
    priceText: hasPrice ? formatYuanPrice(merged) : "暂无标价",
    coverUrl: b.coverUrl?.trim() || undefined,
  };
}

/** 列表未带 `price` 时并发请求 `/book-price/getByBookId` 补全卡片与首页展示 */
export async function mapBookRecordsToShelfBooks(records: Book[]): Promise<ShelfBook[]> {
  const idsNeedingPrice = records
    .filter((b) => {
      const n = b.price != null ? Number(b.price) : NaN;
      return !Number.isFinite(n);
    })
    .map((b) => Number(b.id));
  const priceMap =
    idsNeedingPrice.length > 0 ? await fetchPriceMapByBookIds(idsNeedingPrice) : new Map<number, number>();
  return records.map((b) => mapToShelfBook(b, priceMap.get(Number(b.id))));
}
