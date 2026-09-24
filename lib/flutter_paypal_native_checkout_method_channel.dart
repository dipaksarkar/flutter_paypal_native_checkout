import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_paypal_native_checkout_platform_interface.dart';

/// An implementation of [FlutterPaypalNativeCheckoutPlatform] that uses method channels.
class MethodChannelFlutterPaypalNativeCheckout extends FlutterPaypalNativeCheckoutPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_paypal_native_checkout');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
