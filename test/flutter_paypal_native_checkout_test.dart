import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_paypal_native_checkout/flutter_paypal_native_checkout.dart';
import 'package:flutter_paypal_native_checkout/flutter_paypal_native_checkout_platform_interface.dart';
import 'package:flutter_paypal_native_checkout/flutter_paypal_native_checkout_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPaypalNativeCheckoutPlatform
    with MockPlatformInterfaceMixin
    implements FlutterPaypalNativeCheckoutPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final FlutterPaypalNativeCheckoutPlatform initialPlatform =
      FlutterPaypalNativeCheckoutPlatform.instance;

  test('$MethodChannelFlutterPaypalNativeCheckout is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPaypalNativeCheckout>());
  });

  test('getPlatformVersion', () async {
    FlutterPaypalNativeCheckout flutterPaypalNativePlugin = FlutterPaypalNativeCheckout();
    MockFlutterPaypalNativeCheckoutPlatform fakePlatform =
        MockFlutterPaypalNativeCheckoutPlatform();
    FlutterPaypalNativeCheckoutPlatform.instance = fakePlatform;
    expect(await flutterPaypalNativePlugin.getPlatformVersion(), '42');
  });
}
