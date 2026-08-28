# MoodMate

MoodMate is a minimal social networking iOS app built around daily emotional check-ins. Write a short post, attach a photo or thought, and share it with friends and followers — a low-friction social experience that keeps the focus on authentic daily check-ins without the curated highlight-reel feel.

## Features

- **Authentication** — email/password sign in and sign up via Firebase Auth, with email verification and password reset
- **Home feed** — a scrollable timeline of friends' mood posts, with **For You** (everyone) and **Following** (people you follow) tabs, plus a friends tray and mood picker
- **Create Post** — pick a mood, write a caption, attach a photo, choose post visibility, with local draft saving
- **Discover** — search users, posts, moods, and hashtags; browse topics, trending moods and hashtags, and suggested users to follow
- **Chat** — direct messaging with a conversation list and per-thread message view
- **Profile** — own profile and other users' profiles, edit profile, avatar picker, followers/following lists, post detail view, settings
- **Theming** — light/dark mode support via a central theme manager
- **Deep linking** — custom URL scheme (`moodmate://`) routed through a central app router

## Tech Stack

- **Swift 5** / **SwiftUI**
- **MVVM** architecture (`Views` + `ViewModels`, repository layer for data access)
- **Swift Concurrency** (async/await)
- **Firebase Auth** (via Firebase iOS SDK, added as a Swift Package)
- Mock/local data providers for posts, feed, discover, and chat (no live backend for content yet — see [Current Limitations](#current-limitations))

## Project Structure

```
moodmate/
├── App/                     # App entry point, AppDelegate, Info.plist, GoogleService-Info.plist
├── Core/
│   ├── Components/          # Shared reusable views (avatar, text field, post card, toast)
│   ├── Errors/               # App-wide error types
│   ├── Extensions/           # Color, String, View extensions
│   ├── Models/                # Shared domain models
│   ├── Navigation/            # AppRouter, Route definitions
│   ├── Repositories/           # Post, Follow, Avatar, Profile, UserStore repositories (+ protocols)
│   └── Theme/                  # ThemeColors, ThemeManager
└── Features/
    ├── Authentication/          # Sign in / sign up, Firebase auth manager, session manager
    ├── Chat/                    # Conversation list and thread views
    ├── CreatePost/               # Mood/photo/caption post composer
    ├── Discover/                  # Search, moods, hashtags, trending topics, suggested users
    ├── Home/                       # Feed, tab container, bottom navigation
    └── Profile/                     # Own/other profile, edit profile, follow lists, settings
```

Each feature module follows the same shape: `Models/`, `ViewModels/`, `Views/`, and (where needed) `Components/` and `Services/` or `Repositories/`.

## Requirements

- macOS with **Xcode 26** or newer
- iOS **26.1**+ deployment target (simulator or device)
- Swift 5 toolchain (bundled with Xcode)
- A Firebase project with **Authentication** (Email/Password) enabled
- Internet connection to resolve the Firebase iOS SDK Swift package on first build

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd moodmate
   ```
2. Open the project in Xcode:
   ```bash
   open moodmate.xcodeproj
   ```
3. Let Xcode resolve Swift Package dependencies (`firebase-ios-sdk`) — this happens automatically on first open/build.
4. **Firebase setup**: the project already includes `moodmate/App/GoogleService-Info.plist`. If you're pointing this at your own Firebase project, replace it with your own config file downloaded from the [Firebase console](https://console.firebase.google.com/), and enable the **Email/Password** sign-in provider under Authentication.
5. Select a simulator (or device) and run (`Cmd+R`).

## Current Limitations

- Feed, Discover, and Chat content are backed by local mock data providers, not a live database — posts, likes, and messages do not currently sync across devices or persist to a backend.
- Only email/password authentication is implemented (no Sign in with Apple/Google yet).
- No push notifications, offline caching, or cloud sync yet.
- No automated test target is currently configured in the Xcode project.

## Notes

- `DESIGN-swiftui.md` and `report.md` are working/reference documents (design tokens and an implementation report) and are excluded from version control via `.gitignore` — only this `README.md` is tracked.
- Bundle identifier: `com.lalalala.moodmate`.

## License

This project is intended for educational and portfolio purposes.
