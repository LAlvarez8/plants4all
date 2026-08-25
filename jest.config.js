const { jestConfig } = require("@salesforce/sfdx-lwc-jest/config");

module.exports = {
  ...jestConfig,
  moduleNameMapper: {
    ...jestConfig.moduleNameMapper,
    "^lightning/actions$":
      "<rootDir>/force-app/main/default/test/jest-mocks/lightning/actions"
  },
  modulePathIgnorePatterns: ["<rootDir>/.localdevserver"]
};
