# GitHub Explorer

A Flutter application that allows users to search and explore GitHub profiles and their public repositories.

Built as a Flutter machine test with a focus on clean architecture, state management, API handling, reusable components, and a polished user experience.

---

## Features

### GitHub Profile Search

- Search GitHub users by username
- Fetch profile information from the GitHub REST API
- Display:
  - Profile avatar
  - Name
  - Username
  - Bio
  - Followers
  - Following
  - Public repositories
- Loading, success, and error states
- Handles user-not-found and network errors

### Repository Explorer

- View public repositories for a selected GitHub user
- Display:
  - Repository name
  - Description
  - Stars
  - Programming language
  - Last updated date
- Sort repositories by:
  - Stars
  - Recently updated

### Recent Searches

- Stores the last 5 searched usernames locally
- Prevents duplicate entries
- Tap a recent search to search again instantly
- Recent searches persist between app launches

---

## Tech Stack

- **Flutter / Dart**
- **BLoC** — State management
- **Dio** — HTTP networking
- **GetIt** — Dependency injection
- **Hive CE** — Local persistence
- **Equatable** — Value equality

---

## Architecture

The project follows a feature-first architecture with separation of responsibilities.

```text
lib/
│
├── core/
│   ├── di/
│   │   └── injection.dart
│   │
│   ├── network/
│   │   └── dio_client.dart
│   │
│   └── widgets/
│       ├── app_loader.dart
│       ├── empty_state.dart
│       └── error_view.dart
│
├── features/
│   └── github/
│       │
│       ├── data/
│       │   ├── local/
│       │   │   └── recent_search_storage.dart
│       │   │
│       │   ├── models/
│       │   │   ├── github_repo_model.dart
│       │   │   └── github_user_model.dart
│       │   │
│       │   ├── github_api.dart
│       │   └── github_repository.dart
│       │
│       └── presentation/
│           ├── bloc/
│           │   ├── github_bloc.dart
│           │   ├── github_event.dart
│           │   └── github_state.dart
│           │
│           ├── pages/
│           │   ├── search_page.dart
│           │   └── repositories_page.dart
│           │
│           └── widgets/
│               ├── profile_card.dart
│               ├── repository_card.dart
│               └── recent_searches.dart
│
└── main.dart