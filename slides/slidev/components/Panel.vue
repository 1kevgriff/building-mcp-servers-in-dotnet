<script setup lang="ts">
defineProps<{ caption?: string; dark?: boolean }>()
</script>

<!-- Long class names on purpose: short ones collide with UnoCSS utilities. See Card.vue. -->
<template>
  <div class="panel" :class="{ dark }">
    <div v-if="caption" class="panel-cap">{{ caption }}</div>
    <div class="panel-body"><slot /></div>
    <div v-if="$slots.note" class="panel-note"><slot name="note" /></div>
  </div>
</template>

<style scoped>
.panel { display: flex; flex-direction: column; min-width: 0; }
.panel-cap {
  font-size: 0.64rem;
  font-weight: 800;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: var(--muted);
  margin-bottom: 0.38rem;
}
.dark .panel-cap { color: #A9825F; }
.panel-body { flex: 1; min-width: 0; }
.panel-body :deep(.slidev-code) { margin: 0; height: 100%; overflow: hidden; }
.panel-body :deep(p) { margin: 0; }
.panel-note {
  margin-top: 0.45rem;
  font-size: 0.74rem;
  font-style: italic;
  color: var(--muted);
}
.dark .panel-note { font-style: normal; font-weight: 800; color: var(--navy); }
</style>
