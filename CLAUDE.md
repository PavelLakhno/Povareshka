# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Povareshka is a UIKit-based iOS recipe app (iPhone only, Swift 6.0) backed by Supabase and Realm. The app is entirely in Russian.

## Build & Run

Open `Povareshka.xcodeproj` in Xcode. There is no Makefile, Fastfile, or Podfile — dependencies are managed via Swift Package Manager (`.xcodeproj` resolves them automatically).

**Required before building:** `Povareshka/SupportingFiles/Config.plist` must exist with three keys: `SUPABASE_URL`, `SUPABASE_KEY`, and `SUPABASE_REDIRECT`. This file is not committed to the repo.

There is no lint tooling or automated test suite configured.

## Architecture

**Coordinator + MVC.** `AppCoordinator` owns the root navigation decision (auth vs. main app) and handles all deep links (`povareshka-supabase://` scheme for password reset and email verification). Feature screens are plain `UIViewController` subclasses — no MVVM or VIPER.

Navigation is tab-based with four tabs: Main (feed), Search, Shopping List, Profile.

## Data Layer

Three distinct layers, each with its own models:

1. **Supabase (remote)** — `DataService` is the high-level query layer; `SupabaseManager` owns the Supabase client singleton and file storage. Supabase models live in `Models/` (e.g. `RecipeSupabase`, `Rating`, `FavoriteRecipe`).

2. **Realm (local cache)** — `StorageManager` owns the Realm singleton. Realm models mirror Supabase ones (e.g. `RecipeModel`, `CategoryRealm`, `TagRealm`). Current schema version is 3; migrations are defined in `StorageManager`.

3. **In-memory managers** — `ShoppingListManager` holds the session shopping list. UI is notified via `NotificationCenter` (`.shoppingListDidChange`, `.userDidLogout`).

## Key Patterns

- **Configuration loading** — `SupabaseConfig` reads from `Config.plist` at runtime. Add new config keys there, not as hardcoded strings.
- **Design tokens** — `AppColors`, `AppStrings`, `AppImages`, `AppError` in `Helpers/Resources/`. Always use these rather than inline literals.
- **Cell/view construction** — `CollectionViewFactory` and `TableViewFactory` build reusable cells. Add new collection/table cells through these factories.
- **Error handling** — `AppError` is a protocol-based hierarchy with cases for auth, data, image, recipe, and review errors. Error messages are in Russian.
- **Concurrency** — Swift 6.0 strict concurrency is active. All UI updates must be on `@MainActor`; async/await is used throughout `DataService` and `SupabaseManager`.
- **Image loading** — Kingfisher handles all remote image loading and caching. Use `KingfisherManager` (the project wrapper) rather than calling Kingfisher directly.

## Authentication Flow

Supabase email/password auth. `AppCoordinator` listens for the `userDidLogout` notification and routes back to the auth screen. Deep links arrive via `SceneDelegate` and are forwarded to `AppCoordinator` for handling (password reset, email verification).
