import { createApp } from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import 'element-plus/theme-chalk/dark/css-vars.css'
import './styles/theme.css'
import { initAppearance } from './utils/appearance'
import App from './App.vue'
import router from './router'

initAppearance()

const app = createApp(App)

app.use(ElementPlus)
app.use(router)
app.mount('#app')