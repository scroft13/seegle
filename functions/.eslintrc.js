module.exports = {
  root: true,
  env: {
    node: true, // 👈 fixes 'module' and '__dirname' errors
  },
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: "./tsconfig.json",
    tsconfigRootDir: __dirname,
    sourceType: "module",
  },
  plugins: ["@typescript-eslint"],
  extends: ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  rules: {
    "require-jsdoc": "off",
    "object-curly-spacing": ["error", "always"],
  },
};
