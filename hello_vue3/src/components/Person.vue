<template>
  <div class="person">

  </div>
</template>

<script lang="ts" setup name="Person">
  import {ref,watch,watchEffect} from 'vue'
  import {type PersonInter,type Persons} from "@/types"

  let person:PersonInter={id:'e98219e12',name:'张三',age:18}

 let persons = ref<Persons>([
  {id:'e98219e12',name:'张三',age:18},
   {id:'e98219e13',name:'李四',age:19},
    {id:'e98219e14',name:'王五',age:20}
  ])


</script>

<style scoped>
</style>