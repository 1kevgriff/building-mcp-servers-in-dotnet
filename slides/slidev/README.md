# Slidev deck — Building MCP Servers in .NET

The presentable deck. It uses the same theme, fonts and tooling as the Modern .NET Configuration deck.

```bash
npm install
npm run dev        # present at http://localhost:3030 (press `p` for presenter mode)
npm run verify     # build + prove no slide clips its content
```

## slides.md is hand-written

The configuration deck generates `slides.md` from a slide-by-slide `OUTLINE.md`. This deck doesn't, yet: the outline here is still ten rough sections, so `slides.md` is the source and you edit it directly. Each slide's speaker notes say which outline section and which `src/demoNN` folder it belongs to.

## Editing

| You want to change | Edit |
| --- | --- |
| what a slide says, or the speaker notes | `slides.md` |
| how a layout looks | `layouts/*.vue`, `components/*.vue`, `styles/index.css` |
| code highlighting | `setup/shiki.ts` (night-owl) |

## Layouts

`code` (full-bleed) · `cover` (title/bio/thanks) · `section` (divider) · `statement` (headline-only) · `panels` (captioned comparison) · `roadmap` · `reveal` (setup/reveal pairs) · `blank` (holding screen) · `default` (headline + table or cards).

Components: `Caption`, `Cards`/`Card`, `PanelRow`/`Panel`, `FlowArrow`, `BigNum`, `Badge`.

## The overflow gate

`slidev build` succeeding proves very little. It will happily compile a slide whose code block runs off the bottom of the screen, because panels set `overflow: hidden` and clip in silence.

```bash
npm run check      # renders every slide and fails if anything overflows, clips, or drops below 3:1 contrast
npm run verify     # build + check, the one command to run before you present
```

The slide count comes from Slidev's own parser, so new slides are always checked.

## Fonts are self-hosted

`public/fonts/` holds Source Sans 3, Manrope and JetBrains Mono, declared in `styles/fonts.css`, with the Slidev font provider set to `none`. The deck must not depend on conference wifi.

## Export

```bash
npm run export          # PDF
npm run export:png      # one PNG per slide
npm run export:pptx     # PowerPoint, native shapes and selectable text
```

Needs `playwright-chromium` (already a dev dependency). All three pass `--wait 6000 --wait-until networkidle`; with a shorter wait, exports can capture the "Loading slide…" placeholder and still produce a valid-looking file. Always check the output, not the exit code.

## Presenting from another device

```bash
npm run dev:tailscale   # serves on your Tailscale address only, port 3031
```

Remote control needs a password: one is generated and printed on start, or set `SLIDEV_REMOTE_PASSWORD` (in `.env.local`, which is ignored).

## Known gaps

- **Feedback QR.** The configuration deck ends with a session feedback QR code. Add one for TechBash once you have the link: drop the SVG in `public/` and add a slide before "Let's keep talking."
- **Content.** Most slides are section dividers carrying the outline's bullets as speaker notes. The tool loop, the three primitives, the `dotnet new` code, and the recipe have on-screen content.
