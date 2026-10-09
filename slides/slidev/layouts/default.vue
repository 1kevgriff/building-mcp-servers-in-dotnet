<!--
  Headline pinned to the top, content centred in the space that's left, so a short table or a
  single row of cards doesn't sit in the top third with half the slide empty.
-->
<script setup lang="ts">
defineProps<{ codeSize?: string }>()
</script>

<template>
  <div class="slidev-layout layout-default" :style="{ '--code-size': (codeSize ?? '13.8') + 'px' }">
    <slot />
  </div>
</template>

<style scoped>
.layout-default {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 3.2rem 3rem 3.2rem;
}
/* Content is top-anchored at the same Y on every slide, so the deck has a steady horizon
   line instead of each slide centring its own block at a different height. */
.layout-default :deep(h1) { flex: none; }
.layout-default :deep(.slidev-code),
.layout-default :deep(.slidev-code code) {
  font-size: var(--code-size);
}
</style>
