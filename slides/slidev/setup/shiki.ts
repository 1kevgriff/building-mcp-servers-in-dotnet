import { defineShikiSetup } from '@slidev/types'

// night-owl is the theme the carbon.now.sh panels used, so the #011627 ground
// the deck was designed around carries over unchanged.
export default defineShikiSetup(() => ({
  themes: {
    dark: 'night-owl',
    light: 'night-owl',
  },
}))
