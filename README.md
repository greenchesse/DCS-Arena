# DCS Arena

Web-Based Intramurals Registration and Management System for the Department of Computer Studies (Ateneo de Naga University).

## Project Structure

- `database/` - SQLite schema and seed scripts
- `backend/` - VUE, JS, Python
- `frontend/` - Responsive browser client (HTML/CSS/JS)

## Required Design Patterns Included

- **Singleton**: `DatabaseManager`
- **Facade**: `IntramuralService`
- **Observer**: `ScoreUpdateEvent` with `LeaderboardObserver`, `NotificationObserver`, `BracketObserver`
