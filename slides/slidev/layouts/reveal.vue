<!--
  Setup/reveal pairs (28a->28b, 44->44a). Geometry is deliberately identical to its partner
  slide so that only the VALUES appear to move when you advance.
-->
<script setup lang="ts">
defineProps<{ codeSize?: string }>()
</script>

<template>
  <div class="slidev-layout layout-reveal" :style="{ '--code-size': (codeSize ?? '15') + 'px' }">
    <slot />
  </div>
</template>

<style scoped>
.layout-reveal {
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;   /* NOT centred: a centred pair shifts when the reveal has
                                    one more row, which is exactly what must not move */
  padding: 3.2rem 2rem 3.2rem;
}
.layout-reveal :deep(h1) { font-size: 2rem; margin-bottom: 1.3rem; }
.layout-reveal :deep(.slidev-code),
.layout-reveal :deep(.slidev-code code) {
  font-size: var(--code-size);
}
</style>
