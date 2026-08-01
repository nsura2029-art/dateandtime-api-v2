module.exports = {
  root: true,
  env: { node: true, es2024: true, worker: true },
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: 2024,
    sourceType: "module",
  },
  plugins: ["@typescript-eslint"],
  extends: ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  rules: {
    "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
    "@typescript-eslint/no-explicit-any": "warn",
    "no-console": "off", // we use console for structured logging
  },
  ignorePatterns: ["dist/", ".wrangler/", "node_modules/", "migrations/"],
};
