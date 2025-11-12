Accessible color palettes for Labki / Chameleon
===============================================

Below are a few curated palettes you can use as starting points. Each palette
lists primary, accent, background and text colors. Use the palette that best
matches your project's accessibility and branding needs.

1) Default (current)
- primary: #0b5f9b
- accent:  #e67e22
- background: #f7f8fb
- text: #222631

2) High-contrast (best for accessibility)
- primary: #004a99
- accent:  #cc5500
- background: #ffffff
- text: #0b0c0d

3) Soft / Pastel (friendly look)
- primary: #5b8aff
- accent:  #ff9fb1
- background: #fbfbff
- text: #283044

4) Corporate Blue
- primary: #005b9e
- accent:  #00a2d3
- background: #f4f8fb
- text: #0b2b44

Notes on accessibility
- Check foreground/background contrast (WCAG AA requires 4.5:1 for normal text).
- If you choose a low-contrast palette, increase font weight and sizes for readability.

How to apply a palette
- Edit `config/themes/_local_variables.scss` and replace the color variables with
  the hex codes from your chosen palette. Then touch `config/LocalSettings.php`
  (or touch the `_local_variables.scss` file) to trigger a rebuild.

Preview
- Open `config/themes/previews/palette_preview.html` in a browser to see a quick
  visual preview of each palette.
