# Weather APP (Weather-APP-Manoj)

A simple Flutter weather app that fetches forecast data from the Open-Meteo API and shows:

- Current / daily summary (max / min temperatures)
- Hourly temperatures in a horizontally scrollable list starting from current time
- 7-day forecast (max/min temps, sunrise/sunset, UV index)
- Air quality (placeholder) and additional daily information

The app uses a gradient background and a compact, card-based UI suitable for mobile screens.

## Features

- Fetches weather data (hourly + daily) from Open-Meteo using `dio`.
- Displays hourly temperatures (starts from the current hour).
- 7-day forecast with day name and daily max temperature.
- Sunrise / Sunset and UV index display (when available from API).
- Bottom navigation bar : Location, Add, Menu.
- Intro screen with a Get Start button.
- Small provider-based location state (optional) to share longitude/latitude across pages.

## Project structure (important files)

- `lib/main.dart` — App entry and theme setup (ScreenUtilInit, global white text theme).
- `lib/pages/home_page.dart` — Main home UI: summary + hourly list + bottom navigation.
- `lib/pages/menu_page.dart` — Menu page: coordinates, 7-day forecast, air quality card, sunrise/UV cards.
- `lib/pages/intro_page.dart` — Intro/start screen with Get Start button.
- `lib/pages/add_page.dart` — Page to enter longitude/latitude (wires into Provider).
- `lib/services/weather_service.dart` — Network layer using Dio (fetches hourly and daily forecasts).
- `lib/models/hourly_weather.dart` — Hourly model and daily summary parsing.
- `lib/models/daily_forecast.dart` — 7-day daily arrays parsing (max/min/sunrise/sunset/uv).
- `lib/providers/location_provider.dart` — (optional) provider that holds the current latitude/longitude used across pages.

## Dependencies

- Flutter (see `pubspec.yaml` for SDK constraints)
- dio — HTTP client
- intl — date/time formatting
- provider — state management (used for sharing location in the app)
- flutter_screenutil — responsive sizing

These are listed in `pubspec.yaml` and should be fetched with `flutter pub get`.


## Run the app (Windows PowerShell)

0. Clone the repository (first time only):

```powershell
git clone https://github.com/roshankarki9000/Weather-APP-Manoj.git
cd Weather-APP-Manoj
```

1. Get packages:

```powershell
flutter pub get
```


2. Run on a connected device or emulator:

```powershell
flutter run
```

