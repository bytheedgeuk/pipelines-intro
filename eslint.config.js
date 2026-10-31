import js from "@eslint/js";

export default [
  { ignores: ["dist/", ".vercel/", ".wrangler/"] },
  js.configs.recommended,
];
