<template>
  <div class="timer-container">
    <div class="timer-box">
      <div class="time-text">{{ elapsed.toFixed(1) }}s / {{ duration }}s</div>

      <!-- 输入总时长 -->
      <div class="input-group">
        <span>总时长（秒）：</span>
        <input
          v-model.number="duration"
          type="number"
          min="1"
          class="duration-input"
          @input="handleInputChange"
        />
      </div>

      <el-progress
        :percentage="parseFloat(Math.min((elapsed / duration) * 100, 100).toFixed(1))"
        color="#FB7299"
      />

      <div class="btn-group">
        <button class="btn btn-start" @click="start">开始</button>
        <button class="btn btn-pause" @click="stop">暂停</button>
        <button class="btn btn-reset" @click="reset">重置</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onBeforeUnmount } from 'vue'

const duration = ref(10) // 变成响应式
const elapsed = ref(0)
let timer: number | null = null

// 开始
function start() {
  if (timer) return
  timer = window.setInterval(() => {
    elapsed.value += 0.1
    if (elapsed.value >= duration.value) {
      elapsed.value = duration.value
      clearInterval(timer)
      timer = null
    }
  }, 100)
}

// 暂停
function stop() {
  if (timer) clearInterval(timer)
  timer = null
}

// 重置
function reset() {
  if (timer) clearInterval(timer)
  timer = null
  elapsed.value = 0
}


function handleInputChange() {
  if (timer) {
    reset()
    start()
  }
}

onBeforeUnmount(() => reset())
</script>

<style scoped>
.timer-container {
  width: 100%;
  padding: 60px 0;
  display: flex;
  justify-content: center;
  align-items: center;
  background: #f4f4f5;
}

.timer-box {
  width: 420px;
  padding: 36px 40px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.06);
  border: 1px solid rgba(251, 114, 153, 0.15);
}

.time-text {
  font-size: 20px;
  font-weight: 600;
  color: #222;
  text-align: center;
  margin-bottom: 20px;
  letter-spacing: 1px;
}

/* 输入框样式 */
.input-group {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
  font-size: 15px;
  color: #555;
}
.duration-input {
  width: 100px;
  padding: 6px 10px;
  border: 1px solid #fb7299;
  border-radius: 6px;
  text-align: center;
  font-size: 15px;
  margin-left: 8px;
  outline: none;
}
.duration-input:focus {
  box-shadow: 0 0 0 2px rgba(251, 114, 153, 0.2);
}

.btn-group {
  margin-top: 26px;
  display: flex;
  gap: 16px;
  justify-content: center;
}

.btn {
  flex: 1;
  max-width: 110px;
  padding: 12px 0;
  border: none;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.25s ease;
}

.btn-start {
  background: #fb7299;
  color: #fff;
}
.btn-start:hover {
  background: #f1678c;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(251, 114, 153, 0.3);
}

.btn-pause {
  background: #f9f0f4;
  color: #fb7299;
  border: 1px solid #fb7299;
}
.btn-pause:hover {
  background: #fce4ec;
  transform: translateY(-2px);
}

.btn-reset {
  background: #fff0f6;
  color: #e05679;
  border: 1px solid #e05679;
}
.btn-reset:hover {
  background: #ffe0ef;
  transform: translateY(-2px);
}
</style>