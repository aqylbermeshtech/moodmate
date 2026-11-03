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
- **Clean Architecture** — Domain (entities, use cases, repository protocols), Data (repository/service implementations), Presentation (SwiftUI views + view models), with a composition-root DI container
- **Swift Concurrency** (async/await) + **Combine** (store observation)
- **Firebase Auth** (via Firebase iOS SDK, added as a Swift Package) — isolated behind `AuthServiceProtocol`; the rest of the app only ever sees the domain `AuthUser`
- Interest-based onboarding: new accounts pick their core interests before reaching the app, and those picks live on the profile
- On-device local stores for posts and profiles, persisted to JSON in the app's documents directory (no live backend for content yet — see [Current Limitations](#current-limitations))

## Project Structure

```
moodmate/
├── App/                     # Composition root: entry point, AppDelegate, AppSessionManager,
│   └── DI/                  #   DIContainer — the only place that knows concrete types
├── Domain/                  # Pure Swift (Foundation only — no SwiftUI/UIKit/Firebase)
│   ├── Entities/            # PostModel, UserProfile, AppUser, AuthUser, Visibility, Interest,
│   │                        #   chat and discover models
│   ├── Errors/              # AppError
│   ├── Repositories/        # All repository/service protocols (the domain's contracts)
│   └── UseCases/            # One file per feature: Auth, Feed, CreatePost, Profile,
│                            #   Discover, Chat, Onboarding
├── Data/                    # Implementations of the domain's contracts
│   ├── Repositories/        # Post, Profile, Follow, Avatar, UserStore, Friends
│   ├── Services/            # FirebaseAuthService, DiscoverService, DraftManager
│   ├── Mappers/             # Firebase User → AuthUser
│   └── Session/             # CurrentUserProvider (replaces the old static currentUserId())
├── Core/                    # Presentation infrastructure
│   ├── Components/          # Shared reusable views (avatar, text field, post card, toast)
│   ├── Extensions/          # Color, String, View extensions
│   ├── Navigation/          # AppRouter, Route definitions
│   ├── Theme/               # ThemeColors, ThemeManager
│   └── Utilities/           # ImageCompressor (UIImage → JPEG Data)
└── Features/                # Presentation layer: Views + ViewModels per feature
    ├── Authentication/      # Sign in / sign up
    ├── Chat/                # Conversation list and thread views
    ├── CreatePost/          # Mood/photo/caption post composer
    ├── Discover/            # Search, moods, hashtags, trending topics, suggested users
    ├── Home/                # Feed, tab container, bottom navigation
    ├── Onboarding/          # Interest picker + onboarding gate
    └── Profile/             # Own/other profile, edit profile, follow lists, settings
```

**Dependency rule:** Presentation → Domain ← Data. View models depend on use-case
protocols (never on repositories or Firebase directly); repositories implement domain
protocols; `DIContainer` wires the graph and view models default their dependencies to
`DIContainer.shared.<useCase>` so tests can inject fakes through the same initializers.

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

- Feed, Discover, and Chat content is backed by on-device local stores, not a live database — posts and likes persist only on the device that created them, and do not sync across devices.
- The app ships with no seeded content or accounts: a fresh install starts empty, and the feed, profile grid, and Discover fill in only as the signed-in user creates posts.
- Interests are captured at onboarding and shown on the profile, but nothing consumes them yet — ranking, recommendations, and the planned AI features still need to be built on top of them.
- The follow graph is one-directional and local: `isFollowing` records only who the signed-in user follows, so follower lists for other accounts stay empty until a backend stores both directions.
- Messaging is not implemented — the inbox lists the accounts you follow, but message history and sending are stubs pending a message store.
- Only email/password authentication is implemented (no Sign in with Apple/Google yet).
- No push notifications, offline caching, or cloud sync yet.
- No automated test target is currently configured in the Xcode project.

## Notes

- `DESIGN-swiftui.md` and `report.md` are working/reference documents (design tokens and an implementation report) and are excluded from version control via `.gitignore` — only this `README.md` is tracked.
- Bundle identifier: `com.lalalala.moodmate`.

## License

This project is intended for educational and portfolio purposes.
