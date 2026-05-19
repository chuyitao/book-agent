<template>
  姓：<input type="text" v-model="firstName">
  名：<input type="text" v-model="lastName">
  全名：<span>{{ fullname }}</span>
  <button @click="changeFullName">修改全名</button>
</template>


<script lang="ts" setup name="Person">
  import {computed, ref} from 'vue'

  let firstName=ref('zhang')
  let lastName=ref("san")

  let fullname=computed({
    get(){
      return firstName.value+"-"+lastName.value
    },
    set(val){
      firstName.value=val.split('-')[0]
      lastName.value=val.split('-')[1]
    }
  })


  function changeFullName(){
    fullname.value='jiang-jie'
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