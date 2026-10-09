<!-- Narrow navy panel left, numbered lines right. -->
<script setup lang="ts">
defineProps<{ panelTitle?: string }>()
</script>

<template>
  <div class="slidev-layout layout-roadmap">
    <aside class="panel"><span>{{ panelTitle }}</span></aside>
    <div class="items"><slot /></div>
  </div>
</template>

<style scoped>
.layout-roadmap {
  height: 100%;
  display: grid;
  grid-template-columns: 13rem 1fr;
  gap: 3rem;
  padding: 0;
  align-items: stretch;
}
.panel {
  background: var(--navy);
  display: flex;
  align-items: flex-end;
  padding: 2.4rem 1.6rem;
}
.panel span {
  color: var(--cream);
  font-size: 1.35rem;
  font-weight: 800;
  line-height: 1.2;
}
.items {
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 2.4rem 3rem 2.4rem 0;
}
.items :deep(ol) { list-style: none; padding: 0; counter-reset: rm; }
.items :deep(li) {
  counter-increment: rm;
  font-size: 1.28rem;
  font-weight: 600;
  margin: 0.72rem 0;
  padding-left: 3.1rem;
  position: relative;
}
.items :deep(li)::before {
  content: '0' counter(rm);
  position: absolute;
  left: 0;
  font-family: 'JetBrains Mono', monospace;
  font-weight: 800;
  font-size: 1.05rem;
  color: var(--gold);
}
</style>
