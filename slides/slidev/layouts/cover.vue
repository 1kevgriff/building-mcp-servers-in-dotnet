<!-- Split panel, headshot right. Title, about and thanks slides share it. -->
<script setup lang="ts">
defineProps<{ variant?: string; image?: string; kicker?: string; qr?: string }>()
</script>

<template>
  <div class="slidev-layout layout-cover" :class="`v-${variant ?? 'title'}`">
    <div class="left">
      <div v-if="kicker" class="kicker">{{ kicker }}</div>
      <slot />
      <img v-if="qr" :src="qr" class="cover-qr" alt="QR code linking to the repository" />
    </div>
    <div class="right" :style="image ? { backgroundImage: `url(${image})` } : undefined" />
  </div>
</template>

<style scoped>
.layout-cover {
  height: 100%;
  display: grid;
  grid-template-columns: 1.45fr 1fr;
  gap: 2.4rem;
  padding: 0;
  align-items: stretch;
}
.left {
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 2.4rem 0 2.4rem 3.2rem;
}
.right {
  background-size: cover;
  background-position: center top;
  background-color: var(--navy);
}
.kicker {
  font-size: 0.72rem;
  font-weight: 800;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: var(--muted);
  margin-bottom: 1rem;
}
.left :deep(h1) { font-size: 3rem; margin-bottom: 1.2rem; }
.left :deep(ul) { list-style: none; padding: 0; }
.left :deep(li) {
  font-size: 1.05rem;
  color: var(--navy);
  margin: 0.32rem 0;
  padding-left: 0.95rem;
  position: relative;
}
.cover-qr {
  width: 6.4rem;
  height: 6.4rem;
  margin-top: 1.1rem;
}

.left :deep(li)::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0.62em;
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: var(--gold);
}

/* the title slide gets the navy ground; bio and thanks stay on cream */
.v-title { background: var(--navy); }
.v-title .left :deep(h1) { color: var(--cream); }
.v-title .kicker { color: var(--gold); }
.v-title .left :deep(li) { color: rgba(247, 246, 243, 0.86); }
</style>
