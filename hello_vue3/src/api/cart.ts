import request from "../utils/request";
import type { ApiResult } from "./book";

export interface Cart {
  id: number;
  userId: number;
  bookId: number;
  createdAt?: string;
  updatedAt?: string;
}

/** GET /cart/list?pageNum=&pageSize= */
export function fetchCartList(pageNum = 1, pageSize = 10) {
  return request.get<any, ApiResult<Cart[]>>("/cart/list", {
    params: { pageNum, pageSize },
  });
}

/** POST /cart/save?bookId= */
export function saveBookToCart(bookId: number) {
  return request.post<any, ApiResult<null>>("/cart/save", null, {
    params: { bookId },
  });
}

/** DELETE /cart/delete?cartId= */
export function deleteCartById(cartId: number) {
  return request.delete<any, ApiResult<null>>("/cart/delete", {
    params: { cartId },
  });
}
