<!-- Headline plus a <PanelRow> of captioned panels, and optional caption/footnote. -->
<template>
  <div class="slidev-layout layout-panels">
    <slot />
  </div>
</template>

<style scoped>
.layout-panels {
  padding: 3.2rem 2rem 3.2rem;
  height: 100%;
  display: flex;
  flex-direction: column;
  gap: 0.55rem;
}
.layout-panels :deep(h1) { margin-bottom: 0.7rem; }
</style>
