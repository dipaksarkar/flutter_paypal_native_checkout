import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_paypal_native_checkout_method_channel.dart';

abstract class FlutterPaypalNativeCheckoutPlatform extends PlatformInterface {
  /// Constructs a FlutterPaypalNativeCheckoutPlatform.
  FlutterPaypalNativeCheckoutPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterPaypalNativeCheckoutPlatform _instance =
      MethodChannelFlutterPaypalNativeCheckout();

  /// The default instance of [FlutterPaypalNativeCheckoutPlatform] to use.
  static FlutterPaypalNativeCheckoutPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterPaypalNativeCheckoutPlatform] when
  /// they register themselves.
  static set instance(FlutterPaypalNativeCheckoutPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
