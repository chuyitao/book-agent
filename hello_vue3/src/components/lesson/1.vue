<template>
    <div class="person">
    <h2>姓名：{{name}}</h2>
    <h2>年龄：{{age}}</h2>
    <button @click="changeName">修改名字</button>
    <button @click="changeAge">年龄+1</button>
    <button @click="showTel">点我查看联系方式</button>
  </div>

    <h2>游戏列表：</h2>
    <ul>
      <li v-for="g in games" :key="g.id">{{ g.name }}</li>
    </ul>
        <button @click="changeFirstGame">修改第一游戏</button>
</template>


<script lang="ts" setup name="Person">
         
        import {ref} from 'vue'
        import { reactive } from 'vue'


    let games = reactive([
  { id: 'ahsgdyfa01', name: '英雄联盟' },
  { id: 'ahsgdyfa02', name: '王者荣耀' },
  { id: 'ahsgdyfa03', name: '原神' }
])

      function changeFirstGame() {
        games[0].name = '流星蝴蝶剑'
      }






        let name=ref('蒋杰')
        let age=ref(19)
        let tel="123123412321"

        function changeName(){
            name.value="蒋老杰"
        }
        function changeAge(){
            age.value+=1
        }

        function showTel(){
            alert(tel)
        }

</script>

<style>
  .app {
    background-color: #4583ee;
    box-shadow: 0 0 10px;
    border-radius: 10px;
    padding: 20px;
  }
</style>