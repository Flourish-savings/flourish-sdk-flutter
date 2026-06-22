# flourish_flutter_sdk_example

Demonstrates how to use the flourish_flutter_sdk plugin.

## Setup

A `.env` file is required (it's declared as an asset, so the build fails
without it). Create one from the template:

```bash
cp .env.template .env
```

Then fill in your partner credentials (used by `staging`; they can stay empty
when running with a static dev token — see below):

```
PARTNER_ID=<your_partner_id>
PARTNER_SECRET=<your_partner_secret>
```

## Running

By default the example targets **staging** with the normal authentication
flow — this is what integrators get:

```bash
flutter run -d "iPhone 16"
```

### Local development against a local web app

The environment and token are controlled with compile-time `--dart-define`
flags, so no source changes are needed.

| Flag | Default | Purpose |
|------|---------|---------|
| `FLOURISH_DEV` | `false` | `true` switches the example to `Environment.development` (local web app over HTTP). |
| `FLOURISH_DEV_HOST` | `localhost:5173` | Host (`host:port`) of the local web app. |
| `FLOURISH_DEV_TOKEN` | _(empty)_ | When set, skips the auth backend and loads the web app with this static token. |

**Local web app + static token** (no backend round-trip):

```bash
flutter run -d "iPhone 16" \
  --dart-define=FLOURISH_DEV=true \
  --dart-define=FLOURISH_DEV_TOKEN=local_dev_token
```

**Local web app + real authentication** (omit the token):

```bash
flutter run -d "iPhone 16" --dart-define=FLOURISH_DEV=true
```

**Custom host/port:**

```bash
flutter run -d "iPhone 16" \
  --dart-define=FLOURISH_DEV=true \
  --dart-define=FLOURISH_DEV_HOST=localhost:3001 \
  --dart-define=FLOURISH_DEV_TOKEN=local_dev_token
```

Notes:
- `--dart-define` is **compile-time** — relaunch `flutter run` after changing a
  flag (hot reload won't pick it up).
- The static-token bypass only works in **debug** builds; a release build
  always runs the normal auth flow.
- **iOS simulator** reaches your machine at `localhost`. **Android emulator**
  uses `10.0.2.2` instead and additionally needs cleartext HTTP enabled in its
  manifest.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
