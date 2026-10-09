<script setup lang="ts">
// `size` is a px font-size computed by the generator from the widest code line AND the height
// available, so panel code fits its column instead of being clipped. See fitPanels().
defineProps<{ cols?: number | string; size?: string; arrow?: boolean }>()
</script>

<template>
  <div
    class="panel-row"
    :class="{ 'has-arrow': arrow }"
    :style="{ '--cols': String(cols ?? 2), '--code-size': (size ?? '13') + 'px' }"
  >
    <slot />
    <FlowArrow v-if="arrow" />
  </div>
</template>

<style scoped>
.panel-row {
  display: grid;
  grid-template-columns: repeat(var(--cols, 2), minmax(0, 1fr));
  gap: 0.85rem;
  align-items: stretch;
  min-width: 0;
}
/* widen the gutter so the arrow sits between the panels rather than on top of them */
.panel-row.has-arrow {
  position: relative;
  gap: 3.4rem;
}
</style>
