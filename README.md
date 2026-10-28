# CYNX KAGE 🛍️

**A Flutter-based e-commerce application built with Firebase.**

CYNX KAGE is a personal project focused on building a modern shopping experience with Flutter. The goal was to create an application that goes beyond UI design by integrating real app functionality such as authentication, product browsing, cart management, checkout, and order tracking.

While developing this project, I focused on building reusable UI components, organizing the code into separate screens and services, and connecting the frontend to Firebase for data management.

## ✨ Features

- **User Authentication** — Sign up and log in using Firebase Authentication.
- **Product Browsing** — Explore products through a dedicated shopping interface.
- **Shopping Cart** — Add products, update quantities, and manage cart items.
- **Wishlist** — Save products for later.
- **Product Details** — View product information and images.
- **Address Management** — Add and manage saved delivery addresses.
- **Checkout** — Review cart items and select a delivery address.
- **Coupon System** — Apply coupons through the app's coupon logic.
- **Order Management** — Place orders and view order history.
- **Theme Support** — Switch between the app's available themes.
- **Reusable UI Components** — Keep the interface organized and easier to maintain.

*Note: Features that are still being developed or tested may not be fully functional in every build.*

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Application programming language |
| Firebase Authentication | User authentication |
| Cloud Firestore | Cloud database for application data |
| Material Design | UI components and layout |

## 📁 Project Structure

The project is organized into separate areas for screens, models, services, and reusable widgets. The exact structure may evolve as the application grows.

```text
lib/
├── models/
├── screens/
├── services/
├── widgets/
├── theme/
├── main.dart
└── firebase_options.dart
```

- `models/` — Data models used throughout the application.
- `screens/` — Main app screens, such as login, product details, cart, and checkout.
- `services/` — Firebase interactions and application services.
- `widgets/` — Reusable UI components.
- `theme/` — Theme configuration and styling.
- `main.dart` — Application entry point.
- `firebase_options.dart` — Firebase configuration generated for the project.

## 🚀 Getting Started

### Prerequisites

Before running the project, make sure you have:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or VS Code
- An Android emulator or a physical Android device
- A Firebase project configured for the application

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/Cyanide07x/cynx_kage.git
```

Replace the repository URL above if your actual GitHub repository uses a different name.

**2. Navigate to the project directory**

```bash
cd cynx_kage
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Configure Firebase**

Configure your own Firebase project for the Flutter application using the [official FlutterFire setup guide](https://firebase.google.com/docs/flutter/setup).

Ensure that Firebase Authentication and Cloud Firestore are configured as required by the application. Do not commit private credentials or sensitive configuration files.

**5. Run the application**

```bash
flutter run
```

### Build an Android APK

To create a release APK, run:

```bash
flutter build apk --release
```

The generated APK will typically be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 🔐 Firebase and Security

CYNX KAGE uses Firebase Authentication and Cloud Firestore for its backend functionality.

If you set up this project using your own Firebase account:

- Configure Firestore security rules before testing with real users.
- Restrict access to user-specific data.
- Never rely solely on frontend validation for sensitive operations.
- Keep API keys, credentials, and other sensitive information out of public repositories where applicable.
- Review Firebase usage limits before deploying or scaling the application.

Firebase services may have usage limits or incur charges depending on the services and configuration used.

## 🧪 Development and Testing

The application is being developed incrementally, with an emphasis on maintaining existing functionality while improving the UI and adding features.

To check for common Flutter issues, run:

```bash
flutter analyze
```

To run the available automated tests, use:

```bash
flutter test
```

## 🗺️ Future Improvements

Potential improvements as the project develops include:

- Product reviews and ratings
- Personalized product recommendations
- An AI-powered shopping assistant
- Improved product discovery and filtering
- Additional checkout and order-management improvements

These are planned enhancements and should not be considered completed features unless they have been implemented.

## 👨‍💻 About the Project

CYNX KAGE is a hands-on project built to explore Flutter development, Firebase integration, application architecture, and the process of developing a complete e-commerce experience.

Rather than focusing only on individual UI screens, the project has helped me understand how different parts of an application—authentication, data storage, cart management, and orders—fit together.

I'm continuing to improve the application, refine the user experience, and learn through practical development.

## 📄 License

This project is currently a personal development project. A license has not been specified yet.

---

**Built with Flutter and Firebase.**
