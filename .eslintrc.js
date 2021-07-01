module.exports = {
    "env": {
      "browser": true,
      "es2021": true
    },
    "extends": "eslint:recommended",
    "globals": {
        "$": "readonly",
        "JQuery": "readonly",
        "echarts": "readonly",
        "require": "readonly",
        "global": "readonly",
    },
    "parserOptions": {
      "ecmaVersion": 12,
      "sourceType": "module"
    },
    "rules": {
    }
};
