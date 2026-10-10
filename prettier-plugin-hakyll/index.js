"use strict";

// Hakyll template-aware HTML formatter.
//
// Wraps prettier: protects $...$ template tags before formatting,
// then restores them after.
//
// Tags in HTML attributes get a text placeholder (HAKYLL_ATTR_xxxx)
// since you can't embed HTML elements in attribute values.
// Tags in content get <span> placeholders to preserve inline flow.
//
// Usage: node prettier-plugin-hakyll/index.js [--check] file [file...]
//        node prettier-plugin-hakyll/index.js --stdin   (stdin -> stdout, for editors)

const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

function toBase64(str) {
  return Buffer.from(str).toString("base64");
}

function fromBase64(str) {
  return Buffer.from(str, "base64").toString("utf8");
}

function protect(text) {
  // First pass: protect tags inside HTML attributes with text placeholders.
  // Rewrite every tag within each attrib="..." value, so adjacent tags
  // like "$siteRoot$$url$" are all kept.
  let result = text.replace(/(=\s*")([^"]*)(")/g, (_match, open, value, close) => {
    const protectedValue = value.replace(
      /\$[a-zA-Z_][a-zA-Z0-9_./() ]*\$/g,
      (tag) => `HAKYLL_ATTR_${toBase64(tag)}_RTTA`,
    );
    return `${open}${protectedValue}${close}`;
  });

  // Second pass: protect remaining tags (in content) with <span> placeholders
  result = result.replace(
    /\$[a-zA-Z_][a-zA-Z0-9_./"() ]*\$/g,
    (match) => `<span data-hakyll="${toBase64(match)}"></span>`,
  );

  return result;
}

function restore(text) {
  // Restore attribute placeholders
  let result = text.replace(
    /HAKYLL_ATTR_([A-Za-z0-9+/=]+)_RTTA/g,
    (_match, encoded) => fromBase64(encoded),
  );

  // Restore content placeholders (handle prettier reformatting whitespace)
  result = result.replace(
    /<span data-hakyll="([A-Za-z0-9+/=]+)">\s*<\/span\s*>/g,
    (_match, encoded) => fromBase64(encoded),
  );

  // Fix prettier splitting closing ">" onto the next line
  // e.g. '<span class="foo"\n  >' → '<span class="foo">'
  // and '</time\n  >' → '</time>'
  result = result.replace(/(<\/?[\w-]+(?:\s+[^>]*?)?)\s*\n\s*>/g, "$1>");

  // Fix Hakyll block tags that ended up on the same line
  // e.g. "  $endif$ $if(posts)$" → "$endif$\n  $if(posts)$"
  // Preserve the leading indentation for the second tag
  result = result.replace(
    /^(\s*)\$(endif|endfor)\$\s+\$(if|for)\(/gm,
    "$1$$$2$$\n$1$$$3(",
  );

  // Fix closing HTML tags split across lines before Hakyll tags
  // e.g. "</span\n  >$endif$" → "</span>\n  $endif$"
  result = result.replace(
    /<\/(\w+)\s*\n(\s*)>\$(endif|endfor|else|sep)\$/g,
    "</$1>\n$2$$$3$$",
  );

  return result;
}

function formatText(text) {
  const formatted = execFileSync("prettier", ["--parser", "html"], {
    input: protect(text),
    encoding: "utf8",
    stdio: ["pipe", "pipe", "pipe"],
    // run from the repo root so .prettierrc is found
    cwd: path.join(__dirname, ".."),
  });
  return restore(formatted);
}

function formatFile(filePath, check) {
  try {
    const original = fs.readFileSync(filePath, "utf8");
    const restored = formatText(original);

    if (restored === original) return;

    if (check) {
      console.log(`needs formatting: ${filePath}`);
      process.exitCode = 1;
    } else {
      fs.writeFileSync(filePath, restored);
      console.log(`formatted: ${filePath}`);
    }
  } catch (e) {
    console.error(`error formatting ${filePath}: ${e.stderr || e.message}`);
    process.exitCode = 1;
  }
}

function formatStdin() {
  try {
    process.stdout.write(formatText(fs.readFileSync(0, "utf8")));
  } catch (e) {
    process.stderr.write(String(e.stderr || e.message));
    process.exit(1);
  }
}

// CLI
const args = process.argv.slice(2);

if (args.includes("--stdin")) {
  formatStdin();
} else {
  const check = args.includes("--check");
  const files = args.filter((a) => a !== "--check");

  if (files.length === 0) {
    console.error(
      "Usage: node prettier-plugin-hakyll/index.js [--check] file... | --stdin",
    );
    process.exit(1);
  }

  for (const f of files) {
    formatFile(f, check);
  }
}
