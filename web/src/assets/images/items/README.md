# Item artwork

One file per item kind. **The file name is the item `name`**, nothing else to wire.

```
shared/items.lua          web/src/assets/images/items/
Items['bread'] = { … }  →  bread.png
Items['bank_card'] = {…} →  bank_card.png
```

Accepted extensions: `.png`, `.webp`, `.jpg`, `.jpeg`, `.svg`. Prefer `.png` or
`.webp` for real artwork; the files shipped here are thin-line placeholders.

The resolver lives in `src/utils/itemImage.ts`. It reads this folder through
`import.meta.glob`, so every file goes through the build pipeline and keeps
working once hashed in production — do not build image paths by hand.

An item with no file here is not an error: the slot falls back to a typed
placeholder (a different glyph for a weapon than for a plain item) carrying the
first letter of the label.

Square artwork reads best; the slot fits it inside its own box without cropping.
