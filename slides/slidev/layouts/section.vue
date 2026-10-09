<!-- Section divider. Navy ground, gold kicker. -->
<script setup lang="ts">
defineProps<{ kicker?: string }>()
</script>

<template>
  <div class="slidev-layout layout-section">
    <div class="wrap">
      <div v-if="kicker" class="kicker">{{ kicker }}</div>
      <slot />
    </div>
  </div>
</template>

<style scoped>
.layout-section {
  background: var(--navy);
  height: 100%;
  display: flex;
  align-items: center;
  padding: 2.2rem 4rem;
}
.kicker {
  font-size: 0.78rem;
  font-weight: 800;
  letter-spacing: 0.24em;
  text-transform: uppercase;
  color: var(--gold);
  margin-bottom: 0.9rem;
}
.wrap { max-width: 52rem; }
.wrap :deep(h1) {
  color: var(--cream);
  font-size: 2.5rem;   /* act titles are full claims now, not one-word topics */
  line-height: 1.12;
  margin: 0;
}

/* --muted is tuned for the cream ground and lands at 1.7:1 on navy - invisible.
   Captions on a dark divider need a light tone. */
.layout-section :deep(.caption) {
  color: #C7D0D4;
  max-width: 52rem;
}
.layout-section :deep(.caption.gold) {
  color: var(--cream);
  border-left-color: var(--gold);
}
.layout-section :deep(.caption strong) { color: var(--cream); }
</style>
