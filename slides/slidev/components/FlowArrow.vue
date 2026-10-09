<!--
  The gold arrow between two panels.
  NOT called "Arrow": Slidev ships a built-in <Arrow> and a same-named local component is
  silently IGNORED, which is how this ended up rendering in the wrong place.
-->
<template>
  <div class="flow-arrow" aria-hidden="true">
    <svg viewBox="0 0 64 16">
      <path d="M0 8 H52 M46 2 L54 8 L46 14" fill="none" stroke="currentColor" stroke-width="2.5" />
    </svg>
  </div>
</template>

<style scoped>
.flow-arrow {
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  color: var(--gold);
  z-index: 3;
  pointer-events: none;
}
svg { width: 2.6rem; display: block; }
</style>
