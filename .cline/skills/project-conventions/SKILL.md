---
name: project-conventions
description: Use for any code change in this repository.
---
# Project Conventions
## Stack
- **Frontend**: Flutter / Dart
- **Backend**: Python (FastAPI), SQLite/PostgreSQL
- **Package Managers**: pip (backend), pub (frontend)

## Structure
- `/backend`: API endpoints (`main.py`), DB schemas (`database.py`), forecasting (`forecaster.py`)
- `/Palengke+_frontend/palengkeplus/lib`: Flutter UI (`screens/`, `widgets/`, `services/`)

## Rules
- **Naming**: snake_case for backend/Python, camelCase for Flutter/Dart.
- **Styling**: Consistent with existing UI theme and Flutter widget conventions.
- **Error Handling**: Use HTTP exceptions in backend; handle async failures in UI with `try-catch` blocks and `ScaffoldMessenger`.
- **Commands**:
  - **Dev**: `cd backend; python main.py`
  - **Test**: `cd backend; python -m unittest test_sqa_fixes.py` (Backend); `cd Palengke+_frontend/palengkeplus; flutter test` (Frontend)
- **Constraints**: Always verify changes against regression tests (`test_sqa_fixes.py` and widget tests).
