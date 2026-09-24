# Native PayPal Checkout Integration for Flutter

[![pub package](https://img.shields.io/pub/v/flutter_paypal_native_checkout.svg)](https://pub.dev/packages/flutter_paypal_native_checkout)

A Flutter plugin providing 100% native PayPal Mobile Checkout SDK support for Android and iOS without WebViews. Supports both **client-side auto-capture** and **secure server-side manual capture** workflows.

| Platform | Android | iOS |
| -------- | ------- | --- |
| **Support** | SDK 21+ | iOS 13.0+ |

- [PayPal Native iOS Checkout SDK](https://developer.paypal.com/limited-release/paypal-mobile-checkout/initialize-sdk/)
- [PayPal Native Android Checkout SDK](https://developer.paypal.com/limited-release/paypal-mobile-checkout/initialize-sdk/)

---

## Installation

Add `flutter_paypal_native_checkout` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_paypal_native_checkout: ^1.0.3
```

---

## Android Configuration

### 1. Permissions
Add the internet permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
</manifest>
```

### 2. Gradle Setup
In `android/app/build.gradle`:

```groovy
android {
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    defaultConfig {
        minSdkVersion 21
    }
}
```

In `android/gradle.properties`:
```properties
android.useAndroidX=true
android.enableJetifier=true
```

### 3. PayPal Developer Return URL
- Select your app from **My Apps & Credentials** on the PayPal Developer Dashboard.
- Set your Return URL (e.g., `com.yourcompany.app://paypalpay`).
- Ensure **Log in with PayPal**, **Full Name**, and **Email** are enabled under Advanced Options.

---

## iOS Configuration

Minimum iOS deployment target is **iOS 13.0**.

In `ios/Podfile`:
```ruby
platform :ios, '13.0'
```

In `ios/Runner/Info.plist`, configure your URL Schemes for PayPal redirect handling:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.yourcompany.app</string>
        </array>
    </dict>
</array>
```

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_paypal_native_checkout/flutter_paypal_native.dart';
import 'package:flutter_paypal_native_checkout/models/custom/currency_code.dart';
import 'package:flutter_paypal_native_checkout/models/custom/environment.dart';
import 'package:flutter_paypal_native_checkout/models/custom/order_callback.dart';
import 'package:flutter_paypal_native_checkout/models/custom/purchase_unit.dart';
import 'package:flutter_paypal_native_checkout/models/custom/user_action.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _paypal = FlutterPaypalNative.instance;

  @override
  void initState() {
    super.initState();
    initPayPal();
  }

  void initPayPal() async {
    // Register callbacks
    _paypal.setPayPalOrderCallback(
      callback: PayPalOrderCallback(
        onCancel: () {
          debugPrint('PayPal checkout cancelled');
        },
        onSuccess: (data) {
          debugPrint('Order Approved: ${data.orderId}, Payer: ${data.payerId}');
          // Send orderId to your backend for server-side capture if autoCapture: false
        },
        onError: (data) {
          debugPrint('PayPal checkout error: ${data.reason}');
        },
        onShippingChange: (data) {
          debugPrint('Shipping address changed: ${data.shippingChangeAddress?.city}');
        },
      ),
    );

    // Initialize SDK with client-id & returnUrl
    // Set autoCapture: false if your backend captures the PayPal order
    await _paypal.init(
      initProvider: InitProvider(
        clientId: 'YOUR_PAYPAL_CLIENT_ID',
        environment: FPayPalEnvironment.sandbox,
        returnUrl: 'com.yourcompany.app://paypalpay',
        currencyCode: FPayPalCurrencyCode.usd,
        userAction: FPayPalUserAction.payNow,
        autoCapture: false, // Set false for backend capture
      ),
    );
  }

  void startPayment() {
    _paypal.makeOrder(
      action: FPayPalUserAction.payNow,
      purchaseUnits: [
        FPayPalPurchaseUnit(
          amount: 19.99,
          referenceId: 'order_123',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('PayPal Native Checkout')),
        body: Center(
          child: ElevatedButton(
            onPressed: startPayment,
            child: const Text('Checkout with PayPal'),
          ),
        ),
      ),
    );
  }
}
```

---

## Server-Side Capture vs Client-Side Capture

- **Server-Side Capture (`autoCapture: false`)**: The native SDK approves the PayPal order token and triggers `onSuccess`. Your backend then calls `POST /v2/checkout/orders/{order_id}/capture` to complete the transaction and verify status before fulfilling the service/goods.
- **Client-Side Capture (`autoCapture: true`)**: The native SDK automatically captures the order immediately upon approval before returning `onSuccess`.

---

## License
MIT License
