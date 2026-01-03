# The Last King (Vị Vua Cuối Cùng)

A historical strategy card game built with **Flutter**, inspired by *Reigns*. Guide your dynasty through turbulent times by making binary choices that affect the balance of your kingdom.

## 🌟 Features

- **Swipe Mechanic**: Tinder-like card swiping (Left/Right) to make decisions (`flutter_card_swiper`).
- **Resource Management**: Balance four key pillars of the kingdom:
  - 💰 **Money** (Tiền)
  - 👥 **People** (Dân)
  - 🛡️ **Army** (Quân)
  - 🔯 **Religion** (Đạo)
- **Dynamic visual effects**: Confetti blasts on resource changes (`confetti`).
- **Persistent High Scores**: Track your longest reign using local storage (`shared_preferences`).
- **Monetization**:
  - **Banner Ads**: Always visible at the bottom of the screen.
  - **Interstitial Ads**: Randomly triggered after 2-9 swipes.

## 🏗️ Architecture

The project follows a clean architecture pattern utilizing **Riverpod** for state management.

### File Structure
```
lib/
├── data/
│   └── scenarios_data.dart       # Hardcoded content (Questions/Events)
├── models/
│   └── scenario.dart             # Data models (Scenario, Choice, Effect)
├── providers/
│   └── game_provider.dart        # Game Logic & State Management (Riverpod)
├── screens/
│   └── game_screen.dart          # Main UI: Card Stack, Stats, and Ads
├── services/
│   └── shared_preference_service.dart # Local Storage Abstraction
├── utils/
│   └── ad_helper.dart            # AdMob Unit IDs & Test Mode Configuration
├── widgets/
│   ├── resource_bar.dart         # Animated Stat Bar
│   └── scenario_card.dart        # Swipeable Card UI
└── main.dart                     # App Entry & dependency overrides
```

### State Management (`GameNotifier`)
The `GameProvider` manages the `GameState`, which includes:
- **Resources**: Values clamped between 0 and 100.
- **Game Over Logic**: Checks if any resource hits 0.
- **Swipe Tracking**: Counts swipes to determine when to show Interstitial Ads.
- **High Score**: Auto-updates when the current reign exceeds the stored record.

## 🎮 Game Logic

1.  **Core Loop**:
    - Player reads a scenario.
    - Swiping **Left** or **Right** triggers different effects on resources.
    - If any resource depletes to 0, the game ends (Dynasty Falls).
2.  **Ads Logic**:
    - **Banner**: Loaded immediately on start.
    - **Interstitial**: A threshold is randomized between 2 and 9 swipes. When the user swipes enough times to hit this threshold, a full-screen ad is shown, and the counter resets with a new random threshold.
3.  **Storage**:
    - "Years Reigned" (Score) is saved to `SharedPreferences` only if it beats the previous high score.

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: `flutter_riverpod`
- **UI Components**: `flutter_card_swiper`, `confetti`
- **Ads**: `google_mobile_ads`
- **Fonts**: `google_fonts`

## 🚀 Getting Started

1.  **Prerequisites**: Flutter SDK installed.
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    - **iOS Simulator**: `flutter run -d <device_id>`
    - **Android Emulator**: `flutter run -d <emulator_id>`

> **Note**: AdMob IDs are configured for **Test Mode** in `lib/utils/ad_helper.dart`.
