# Synapse

A context-aware productivity engine featuring biometric health integration, notification mediation, and a fluid flow dashboard.

## Features

- **Biometric Flux** — Integrates with Apple HealthKit and Google Health Connect to compute energy levels from heart rate, sleep, and activity data
- **Focus Shield** — Notification mediation layer that toggles Do Not Disturb and filters distractions
- **Flow Dashboard** — Reactive UI with dynamic gradient backgrounds that shift based on your Synapse Score
- **Privacy-First** — All biometric data processed locally. No cloud sync. Full data purge on consent revocation.

## Architecture

```
lib/
├── config/          # Theme, gradients, design tokens
├── models/          # Immutable state models
├── services/        # Biometric sync, notification mediation
├── controllers/     # Riverpod StateNotifier (Synapse Score logic)
├── widgets/         # Dashboard, CustomPainter background
└── utils/           # Privacy manager, local storage
```

## Getting Started

```bash
flutter pub get
flutter run
```

### Environment Setup

Create a `.env` file (not committed) if needed for future cloud features. Currently all data is local-only.

## Building

```bash
# Debug APK
flutter build apk --debug

# Release APK (split per ABI)
flutter build apk --release --split-per-abi

# App Bundle (for Play Store)
flutter build appbundle --release
```

## Permissions

See [ANDROID_PERMISSIONS_GUIDE.md](ANDROID_PERMISSIONS_GUIDE.md) for a complete breakdown of Android permissions and common troubleshooting steps.

## License

MIT — see [LICENSE](LICENSE) for details.
