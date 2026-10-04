<script setup lang="ts">
defineProps<{ cols?: number | string }>()
</script>

<template>
  <div class="cards" :style="{ '--cols': String(cols ?? 3) }">
    <slot />
  </div>
</template>

<style scoped>
.cards {
  display: grid;
  grid-template-columns: repeat(var(--cols, 3), minmax(0, 1fr));
  gap: 0.85rem;
  margin-top: 0.4rem;
}
</style>
