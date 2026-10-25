---
name: debug-systematically
description: Use when something errors, a test fails, or behavior is unexpected.
---
# Debug Systematically
1. Reproduce first; get the exact error/stack trace.
2. Form 1-3 hypotheses ranked by likelihood.
3. Verify with logs or a minimal check before changing code.
4. Fix the root cause, not the symptom. No blind retry loops.
5. Re-run the failing case to confirm, then run the wider suite.
