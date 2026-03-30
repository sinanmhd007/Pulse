# Pulse 

Pulse is a premium Flutter application demonstrating the integration of real-time Data streams (News + Cryptocurrency) with a Robust Clean Architecture setup.

## Features 
- **Firebase Authentication**: Email/Password and Google Sign-In.
- **News Tracker**: Pulls live top headlines caching for offline functionality.
- **Crypto Tracker**: Live tracking of top 100 cryptocurrencies by market cap using CoinGecko.
- **Clean Architecture & BLoC**: Industry standard scalable structure.
- **Beautiful UI**: Modern aesthetics featuring `flutter_spinkit` and responsive designs.
- **Offline Support**: Gracefully handles network loss and enables local data caching.

## Screenshots 
*Add screenshots here*

## Tech Stack 
- **Flutter** & **Dart**
- **BLoC** (State Management)
- **GetIt** (Dependency Injection)
- **Firebase** (Auth)
- **dartz** (Functional Error Handling)
- **dio** & **internet_connection_checker**
- **shared_preferences** (Local Storage)
- **cached_network_image**

## Architecture Diagram 
```text
lib/
 ┣ core/              # Shared utilities, errors, network info, theme, DI
 ┣ features/          # Application features
 ┃ ┣ auth/            # Authentication feature
 ┃ ┃ ┣ data/          # Data sources & repositories implementation
 ┃ ┃ ┣ domain/        # Entities, UseCases, Repositories interface
 ┃ ┃ ┗ presentation/  # UI, BLoC, Events, States
 ┃ ┣ news/            # News feature
 ┃ ┗ crypto/          # Crypto feature
 ┗ main.dart          # Entry point
```

## Getting Started 
1. Clone the repository.
   ```bash
   git clone https://github.com/sinanmhd007/Pulse.git
   ```
2. Install dependencies.
   ```bash
   flutter pub get
   ```
3. Configure **Firebase**. Ensure `firebase_options.dart` is added via the FlutterFire CLI.
   ```bash
   flutterfire configure
   ```
4. Run the app.
   ```bash
   flutter run
   ```

## Development
Pulse uses the `dev` branch for active feature development and `main` for stable releases.
