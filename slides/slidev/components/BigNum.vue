<!-- "4 -> 11". A count, not a catalogue. Long class names on purpose: see Card.vue. -->
<script setup lang="ts">
defineProps<{ from?: string; to?: string }>()
</script>

<template>
  <div class="bignum">
    <span class="bignum-from">{{ from }}</span>
    <svg class="bignum-arrow" viewBox="0 0 48 16" aria-hidden="true">
      <path d="M0 8 H38 M32 2 L40 8 L32 14" fill="none" stroke="currentColor" stroke-width="2" />
    </svg>
    <span class="bignum-to">{{ to }}</span>
  </div>
</template>

<style scoped>
.bignum { display: flex; align-items: center; gap: 1.1rem; margin: 0.1rem 0 0.8rem; }
.bignum-from, .bignum-to {
  font-family: 'JetBrains Mono', monospace;
  font-size: 3.2rem;
  font-weight: 800;
  line-height: 1;
}
.bignum-from { color: var(--muted); }
.bignum-to { color: var(--gold); -webkit-text-stroke: 1px var(--navy); }
.bignum-arrow { width: 3rem; color: var(--navy); }
</style>
