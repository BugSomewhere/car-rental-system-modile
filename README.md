# Car Rental Mobile

Flutter mobile client for the Car Rental System. The initial scope is the user module: registration OTP, login/logout with cookie session, password reset, profile, and password change. The session cookie remains available while the app is open.

## Run

1. Start the backend at port `6789`.
2. Run `flutter pub get`.
3. Run `flutter run`.

The default backend URL is `http://10.0.2.2:6789` on Android emulator and `http://127.0.0.1:6789` on iOS simulator. For a physical device, provide the backend LAN URL through `ApiClient.create(baseUrl: ...)`.

The API scope and request mappings are documented in [docs/MOBILE-USER-API.md](docs/MOBILE-USER-API.md).
