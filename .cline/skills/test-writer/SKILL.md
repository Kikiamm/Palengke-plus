---
name: test-writer
description: Use when asked to add, fix, or improve unit/integration tests, or after implementing new logic that has no tests.
---
# Test Writer
1. Detect the existing test framework and conventions from the repo (pytest/jest/vitest/etc.). Match them.
2. Cover: happy path, edge cases (empty, null, zero, boundary), invalid input, and one regression case per known bug.
3. Test behavior, not implementation. No mocking of the unit under test.
4. Name tests as `should_<behavior>_when_<condition>`.
5. Run the tests and fix failures before reporting done. Show the command and result.
