<script setup lang="ts">
import { useCounterStore } from '../stores/counter'
const counter = useCounterStore()
</script>
<template>
  <section>
    <h2>Home</h2>
    <p>Counter: {{ counter.count }}</p>
    <button @click="counter.inc()">+1</button>
  </section>
</template>
