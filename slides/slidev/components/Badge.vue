<!-- Failure-mode badge, top right. The motif from slide 11, recalled where the mode bites. -->
<template>
  <div class="badge"><slot /></div>
</template>

<style scoped>
.badge {
  position: absolute;
  top: 1.5rem;
  right: 1.9rem;
  background: var(--navy);
  color: var(--gold);
  font-size: 0.6rem;
  font-weight: 800;
  letter-spacing: 0.18em;
  padding: 0.3rem 0.62rem;
  border-radius: 4px;
  z-index: 5;
}
</style>
