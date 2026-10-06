// Minifies the tgui.html helpers into tgui/public.
// Uses absolute paths: Bun on Windows throws EEXIST from mkdirSync(recursive)
// on an existing relative '../..' directory, which broke every rebuild.
const fs = require('fs');
const path = require('path');
const { minify } = require('terser');
const CleanCSS = require('clean-css');

const outDir = path.resolve(__dirname, '../../public');
fs.mkdirSync(outDir, { recursive: true });

async function main() {
  const helpers = fs.readFileSync(path.join(__dirname, 'helpers.js'), 'utf8');
  // Same output as the old `terser -f ascii_only,comments=false` CLI call,
  // which neither compressed nor mangled.
  const js = await minify(helpers, {
    compress: false,
    mangle: false,
    format: { ascii_only: true, comments: false },
  });
  fs.writeFileSync(path.join(outDir, 'helpers.min.js'), js.code);

  const css = new CleanCSS().minify(
    fs.readFileSync(path.join(__dirname, 'ntos-error.css'), 'utf8'),
  );
  if (css.errors.length) throw new Error(css.errors.join('\n'));
  fs.writeFileSync(path.join(outDir, 'ntos-error.min.css'), css.styles);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
