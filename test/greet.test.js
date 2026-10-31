import assert from "node:assert/strict";
import { test } from "node:test";

import { greet } from "../src/greet.js";

test("greet includes the name", () => {
  assert.equal(greet("world"), "Hello, world!");
});
