import request from "../utils/request";

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginData {
  id: number;
  username: string;
  name: string;
  token: string;
}

export interface RegisterRequest {
  username: string;
  name: string;
  password: string;
  phone?: string;
  email?: string;
}

interface ApiResponse<T> {
  code: number;
  msg: string;
  data: T;
}

export const loginApi = (payload: LoginRequest) => {
  return request.post<any, ApiResponse<LoginData | null>>("/login", payload);
};

/** 后端 LoginController：GET /login/sign，表单字段以查询参数绑定 UserRegisterDTO */
export const registerApi = (payload: RegisterRequest) => {
  return request.get<any, ApiResponse<null>>("/login/sign", { params: payload });
};
