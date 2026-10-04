<script setup lang="ts">
defineProps<{ n?: string; title?: string; accent?: boolean }>()
</script>

<!--
  NOTE: class names here are deliberately long. UnoCSS turns short class names into utilities —
  `class="b"` compiles to `border: 1px solid`, which on an empty div renders as a stray hairline.
-->
<template>
  <div class="card" :class="{ accent }">
    <div v-if="n" class="card-num">{{ n }}</div>
    <div v-if="title" class="card-title">{{ title }}</div>
    <div v-if="$slots.default" class="card-body"><slot /></div>
  </div>
</template>

<style scoped>
.card {
  background: #fff;
  border: 1px solid var(--rule);
  border-radius: 10px;
  padding: 1.1rem 1.15rem 1.25rem;
  display: flex;
  flex-direction: column;
  min-width: 0;
}
.card-num {
  font-family: 'JetBrains Mono', monospace;
  font-size: 1.25rem;
  font-weight: 800;
  color: var(--muted);
  line-height: 1;
  margin-bottom: 0.6rem;
}
.card-title {
  font-size: 1.05rem;
  font-weight: 800;
  line-height: 1.22;
  color: var(--navy);
}
.card-body {
  font-size: 0.86rem;
  line-height: 1.45;
  color: var(--muted);
  margin-top: 0.45rem;
}

.accent { background: var(--navy); border-color: var(--navy); }
.accent .card-num { color: var(--gold); }
.accent .card-title { color: var(--cream); }
.accent .card-body { color: rgba(247, 246, 243, 0.8); }
</style>
