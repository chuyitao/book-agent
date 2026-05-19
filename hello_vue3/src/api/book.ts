import request from "../utils/request";

/** 与后端 cn.itcast.entity.Book 字段一致 */
export interface Book {
  id: number;
  title: string;
  author: string;
  type?: number;
  coverUrl?: string;
  summary?: string;
  createdAt?: string;
  updatedAt?: string;
  /** 后端从 book_price 合并的售价（元），无则省略 */
  price?: number | string;
}

export interface ApiResult<T> {
  code: number;
  msg: string;
  data: T;
}

/** 与 MyBatis-Plus `Page<Book>` 序列化字段一致（不同版本下列表字段名可能略有差异） */
export interface BookPage {
  records?: Book[];
  recordList?: Book[];
  list?: Book[];
  rows?: Book[];
  total?: number;
  size?: number;
  current?: number;
  pages?: number;
}

function toFiniteNumber(v: unknown): number | undefined {
  if (typeof v === "number" && Number.isFinite(v)) return v
  if (typeof v === "string" && v.trim() !== "") {
    const n = Number(v)
    if (Number.isFinite(n)) return n
  }
  if (typeof v === "bigint") return Number(v)
  return undefined
}

/**
 * 兼容后端返回：
 * - MyBatis-Plus Page：`{ records, total }` 或 `recordList` / `list` 等
 * - 显式 VO：`BookListPageVO`
 * - 旧接口：`data` 直接为 `Book[]`
 */
export function normalizeBookListPayload(data: unknown): { records: Book[]; total: number } {
  if (data == null) return { records: [], total: 0 }
  if (Array.isArray(data)) {
    const records = data as Book[]
    return { records, total: records.length }
  }
  if (typeof data === "object") {
    const obj = data as Record<string, unknown>
    const raw =
      obj.records ?? obj.recordList ?? obj.list ?? obj.rows ?? obj.content
    if (Array.isArray(raw)) {
      const records = raw as Book[]
      const totalRaw =
        obj.total ??
        obj.Total ??
        obj.TOTAL ??
        obj.totalCount ??
        obj.totalElements ??
        obj.totalRow ??
        obj.rowTotal
      let total = records.length
      const tn = toFiniteNumber(totalRaw)
      if (tn != null && tn >= 0) total = tn
      if (total < records.length) total = records.length
      return { records, total }
    }
  }
  return { records: [], total: 0 }
}

/** 与后端 Book.type 注释一致 */
export const BOOK_TYPE_LABELS: Record<number, string> = {
  1: "科幻",
  2: "文学",
  3: "小说",
  4: "童话",
  5: "古典",
  6: "推理",
  7: "散文",
  8: "传记",
  9: "社科",
};

/** GET /book/list?pageNum=&pageSize=（data 为 Page 或旧版数组，请用 normalizeBookListPayload 解析） */
export function fetchBookList(pageNum = 1, pageSize = 10) {
  return request.get<any, ApiResult<BookPage | Book[]>>("/book/list", {
    params: { pageNum, pageSize },
  });
}

/** GET /book/getById?getByid= （与后端 @RequestParam 名称一致） */
export function fetchBookById(getByid: number) {
  return request.get<any, ApiResult<Book>>("/book/getById", {
    params: { getByid },
  });
}
