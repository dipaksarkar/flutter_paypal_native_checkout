## 2.0.0

- Full rebranding and refactor: Renamed all classes, method channels, Android package namespace (`com.nitrofit28.flutter_paypal_native_checkout`), and iOS plugin identifiers to `flutter_paypal_native_checkout` / `FlutterPaypalNativeCheckout`.
- Added backward compatibility typedef alias `FlutterPaypalNative = FlutterPaypalNativeCheckout`.

## 1.0.3

- Fixed iOS generated Swift header imports in `FlutterPaypalNativePlugin.m` to reference `flutter_paypal_native_checkout-Swift.h`.

## 1.0.2

- Renamed iOS Podspec to `flutter_paypal_native_checkout.podspec` to resolve CocoaPods dependency resolution failure on iOS.

## 1.0.1

- Fixed Android build failure with AGP 8+ by removing `package` attribute from `AndroidManifest.xml` and declaring `namespace` in `build.gradle`.

## 1.0.0

- Initial release of `flutter_paypal_native_checkout`.
- Added `autoCapture` configuration flag to support secure server-side capture (`POST /v2/checkout/orders/{id}/capture`).
- Full support for 100% native PayPal Mobile Checkout SDK on Android & iOS without WebViews.
- Null-safety and robust callback handlers for order approvals, cancellations, shipping changes, and errors.
