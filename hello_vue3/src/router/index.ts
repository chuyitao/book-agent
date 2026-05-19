import { createRouter, createWebHistory } from 'vue-router'
import MainLayout from '../layouts/MainLayout.vue'
import LoginView from '../views/LoginView.vue'
import RegisterView from '../views/RegisterView.vue'
import BookDetailView from '../views/BookDetailView.vue'
import { getToken } from '../utils/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: MainLayout
    },
    {
      path: '/login',
      name: 'login',
      component: LoginView
    },
    {
      path: '/register',
      name: 'register',
      component: RegisterView
    },
    {
      path: '/book/:id',
      name: 'book-detail',
      component: BookDetailView
    },
    {
      path: '/books',
      name: 'books',
      component: () => import('../views/BooksCatalogView.vue')
    }
  ]
})

router.beforeEach((to) => {
  const token = getToken()
  if ((to.path === '/login' || to.path === '/register') && token) return '/'
  return true
})

export default router
