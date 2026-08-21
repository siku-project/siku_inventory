/**
 * Item artwork is declared, not guessed: a definition names its file and the
 * interface looks it up here. The glob is eager and resolved at build time,
 * so every shipped file goes through the asset pipeline and keeps working
 * once hashed in production — a path built by string concatenation would only
 * have worked while the dev server was serving the sources.
 */
const FILES = import.meta.glob('../assets/images/items/*.{png,webp,jpg,jpeg,svg}', {
  eager: true,
  import: 'default',
  query: '?url',
}) as Record<string, string>

const BY_FILE: Record<string, string> = {}

for (const [path, url] of Object.entries(FILES)) {
  const file = path.split('/').pop()

  if (file) {
    BY_FILE[file] = url
  }
}

/**
 * The artwork a definition asked for, when that file was shipped.
 * @param file The file name declared on the item, such as `bread.png`.
 */
export const itemImage = (file: string | undefined): string | undefined =>
  file ? BY_FILE[file] : undefined
