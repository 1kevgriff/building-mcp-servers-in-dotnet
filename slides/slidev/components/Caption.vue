<script setup lang="ts">
defineProps<{ gold?: boolean }>()
</script>

<template>
  <div class="caption" :class="{ gold }"><slot /></div>
</template>

<style scoped>
.caption {
  margin-top: 0.75rem;
  font-size: 1rem;          /* several captions ARE the takeaway; 0.86rem vanished in a room */
  color: var(--muted);
  line-height: 1.45;
}
.caption.gold {
  color: var(--navy);
  font-weight: 800;
  font-size: 1.08rem;
  border-left: 4px solid var(--gold);
  padding-left: 0.8rem;
}
.caption :deep(code) {
  background: rgba(22, 48, 63, 0.07);
  padding: 0.08em 0.34em;
  border-radius: 4px;
}
</style>
