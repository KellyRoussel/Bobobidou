# BoboBidou

A Flutter health-tracking app that helps you find correlations between what you eat and when you feel pain. Log your meals, record pain episodes, and let the app analyze patterns to identify potential food triggers.

## Features

- **Meal logging** — Track meals with detailed ingredient lists
- **Pain tracking** — Record pain episodes with timestamps
- **AI food recognition** 📸 — Snap a photo of your plate and let AI detect the ingredients automatically
- **Correlation analysis** 📊 — Visualize which ingredients appear most frequently before pain episodes (48h lookback window)
- **Timeline view** — See your meals and pain events on a unified timeline
- **Google OAuth** — Secure authentication via Google
- **Bilingual** — Full English and French support

## Architecture

The app follows a clean **Provider-based** architecture:

| Layer | Location | Role |
|-------|----------|------|
| UI | `lib/pages/` | Screens and widgets |
| State | `lib/providers/` | `ChangeNotifier` providers for meals, pain, analysis, auth, theme, locale |
| Services | `lib/services/` | Database (SQLite), Google OAuth, AI food recognition |
| Models | `lib/models/` | `Meal`, `PainEvent`, `Ingredient`, `User` |
| Localization | `lib/l10n/` + `assets/lang/` | Runtime JSON-based translations (EN/FR) |

Data is stored locally using **SQLite**. The AI ingredient recognition and authentication flow go through a backend API.

## Getting Started

### Prerequisites

- Flutter SDK `>=3.6.0`
- A running instance of the backend API (see [backend configuration](#backend-configuration))

### Installation

```bash
# Clone the repo
git clone https://github.com/KellyRoussel/Bobobidou.git
cd Bobobidou

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Backend Configuration

The app communicates with a backend ([bobobidou_backend](https://github.com/KellyRoussel/bobobidou_backend)) for authentication and AI food recognition. Its URL is read from `BACKEND_URL` in `assets/.env` (not committed): copy `assets/.env.example` to `assets/.env`, it points to the production backend. Change it to use your own instance.

## Useful Commands

```bash
flutter run                # Run the app
flutter test               # Run tests
flutter analyze            # Static analysis

# Regenerate assets
flutter pub run flutter_launcher_icons:main    # App icons
flutter pub run flutter_native_splash:create   # Splash screen
```

## Tech Stack

Flutter | Provider | SQLite | fl_chart | OpenAI (via backend) | Google OAuth

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

🚧 License TBD
