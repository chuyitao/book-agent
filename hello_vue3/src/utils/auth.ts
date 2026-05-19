const TOKEN_KEY = 'wanxiang-book-token'
const USER_NAME_KEY = 'wanxiang-book-username'

export const getToken = () => localStorage.getItem(TOKEN_KEY) ?? ''

export const setToken = (token: string) => {
  localStorage.setItem(TOKEN_KEY, token)
}

export const clearToken = () => {
  localStorage.removeItem(TOKEN_KEY)
}

export const getUserName = () => localStorage.getItem(USER_NAME_KEY) ?? ''

export const setUserName = (name: string) => {
  localStorage.setItem(USER_NAME_KEY, name)
}

export const clearUserName = () => {
  localStorage.removeItem(USER_NAME_KEY)
}

export const clearAuthInfo = () => {
  clearToken()
  clearUserName()
}
