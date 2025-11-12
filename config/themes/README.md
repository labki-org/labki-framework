Chameleon theme: local variables and customization
=================================================

This directory contains your local Chameleon SCSS variable overrides.

Files
-----
- `_local_variables.scss` — Edit this file to override Chameleon / Bootstrap SCSS variables.

Why use `_local_variables.scss`?
-------------------------------
- Keeps your changes outside the skin packages so updates to Chameleon/Bootstrap won't overwrite them.
- Loaded into Chameleon with the position `afterVariables` so your values override defaults but are still available to style definitions.
- Registered as a cache trigger so editing the file will trigger a stylesheet rebuild.

Recommended variables (examples)
--------------------------------
These are safe, commonly-used variables you can change. They are defined in `_local_variables.scss` as examples — edit as needed.

- `cmln-collapse-point` — Breakpoint at which the skin switches between desktop and mobile layout.
  - Example: `cmln-collapse-point: 1024px;`

- `body-bg` — Page background color.
  - Example: `body-bg: #fafafa;`

- `brand-primary` — Main brand / primary color used by buttons, links, etc.
  - Example: `brand-primary: #006699;`

- `font-family-base` — Base font-family stack.
  - Example: `font-family-base: "Inter", system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;`

- `navbar-padding-y`, `navbar-padding-x` — Header spacing values.
  - Examples: `navbar-padding-y: 0.5rem;`, `navbar-padding-x: 1rem;`

- `container-max-width-lg` — Reduce or grow the max container width on large viewports.
  - Example: `container-max-width-lg: 1120px;`

Adding other SCSS files
-----------------------
If you want to import an entire Bootstrap/Bootswatch theme or additional SCSS files, use `$egChameleonExternalStyleModules` in
`config/LocalSettings.labki.php` and choose a position:

Positions: `beforeFunctions`, `functions`, `afterFunctions`,
`beforeVariables`, `variables`, `afterVariables`,
`beforeMain`, `main`, `afterMain`.

- Put variable overrides in `afterVariables` so they override Chameleon/Bootstrap defaults.
- Put custom styles in `afterMain` so they can override compiled CSS.

Triggering a rebuild (dev workflow)
-----------------------------------
Styles are compiled and cached. To force a rebuild after editing `_local_variables.scss`:

- Option A (fast): touch `LocalSettings.php` (the entrypoint checks LocalSettings mtime):

```bash
# from repo root (host)
touch config/LocalSettings.php
# or inside the container
docker compose exec wiki touch /var/www/html/config/LocalSettings.php
```

- Option B (touch the variables file): we register `_local_variables.scss` as a cache trigger in `LocalSettings.labki.php`, so touching it should also trigger recompilation:

```bash
touch config/themes/_local_variables.scss
```

Note: compilation may take a few seconds on first run.

Layout selection
----------------
Choose a layout by setting `$egChameleonLayoutFile` in `config/LocalSettings.labki.php` to one of the bundled layouts:
- `standard`, `navhead`, `fixedhead`, `stickyhead`, `clean`

Examples are already added to `LocalSettings.labki.php`. You can also allow visitors to change layout via `?uselayout=` by listing layouts in
`$egChameleonAvailableLayoutFiles`.

Further reading
---------------
- Chameleon skin documentation: https://www.mediawiki.org/wiki/Skin:Chameleon
- SCSS variables list (in the Chameleon repo) — use the skin's `resources/styles` folder as a reference.

