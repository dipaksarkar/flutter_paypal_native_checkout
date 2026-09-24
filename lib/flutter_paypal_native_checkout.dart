import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_native_checkout/models/approval/approval_data.dart';
import 'package:flutter_paypal_native_checkout/models/custom/error_info.dart';
import 'package:flutter_paypal_native_checkout/models/shipping_change/shipping_info.dart';
import 'flutter_paypal_native_checkout_platform_interface.dart';
import 'models/custom/currency_code.dart';
import 'models/custom/environment.dart';
import 'models/custom/purchase_unit.dart';
import 'models/custom/user_action.dart';
import 'models/custom/order_callback.dart';

class FlutterPaypalNativeCheckout {
  static FlutterPaypalNativeCheckout? _instance;
  bool _initiated = false;
  final _methodChannel = const MethodChannel('flutter_paypal_native_checkout');
  List<FPayPalPurchaseUnit> purchaseUnits = [];

  // Default callback does nothing
  FPayPalOrderCallback _callback = FPayPalOrderCallback(
    onCancel: () {},
    onSuccess: (_) {},
    onError: (_) {},
    onShippingChange: (_) {},
  );

  static bool isDebugMode = false;

  FlutterPaypalNativeCheckout();

  Future<String?> getPlatformVersion() {
    return FlutterPaypalNativeCheckoutPlatform.instance.getPlatformVersion();
  }

  void setPayPalOrderCallback({
    required FPayPalOrderCallback callback,
  }) {
    _callback = callback;
  }

  /// Initialize the PayPal Checkout SDK.
  Future<FlutterPaypalNativeCheckout> init({
    // Return URL matching developer portal registration (e.g. appid://paypalpay)
    required String returnUrl,
    // Client ID from PayPal developer dashboard
    required String clientID,
    // Sandbox or live environment
    required FPayPalEnvironment payPalEnvironment,
    // Currency code
    required FPayPalCurrencyCode currencyCode,
    // PayNow or Continue user action
    required FPayPalUserAction action,
    // Whether to automatically capture the payment on client side (default: true)
    bool autoCapture = true,
  }) async {
    _methodChannel.setMethodCallHandler(_handleMethod);
    _initiated = true;

    Map<String, dynamic> data = {
      "returnUrl": returnUrl,
      "clientId": clientID,
      "payPalEnvironment": FPayPalEnvironmentHelper.convertFromEnumToString(
        payPalEnvironment,
      ),
      "currency": FPayPalCurrencyCodeHelper.convertFromEnumToString(
        currencyCode,
      ),
      "userAction": FPayPalUserActionHelper.convertFromEnumToString(
        action,
      ),
      "autoCapture": autoCapture,
    };
    await _methodChannel.invokeMethod<String>(
      'FlutterPaypal#initiate',
      data,
    );
    return instance;
  }

  /// Singleton instance of FlutterPaypalNativeCheckout
  static FlutterPaypalNativeCheckout get instance {
    _instance ??= FlutterPaypalNativeCheckout();
    return _instance!;
  }

  /// Adds an item/purchase unit to be purchased
  void addPurchaseUnit(FPayPalPurchaseUnit pUnit) {
    if (!_initiated) {
      throw Exception(
        "You must initiate package first. Call FlutterPaypalNativeCheckout.instance.init()",
      );
    }
    purchaseUnits.add(pUnit);
  }

  /// Check if more purchase units can be added (max 5)
  bool get canAddMorePurchaseUnit {
    return purchaseUnits.length < 5;
  }

  /// Starts the checkout flow
  Future<void> makeOrder({
    FPayPalUserAction action = FPayPalUserAction.payNow,
  }) async {
    if (!_initiated) {
      throw Exception(
        "You must initiate package first. Call FlutterPaypalNativeCheckout.instance.init()",
      );
    }

    String purchaseUnitsData = FPayPalPurchaseUnit.convertListToJson(
      purchaseUnits,
    );

    Map<String, String> data = {
      "purchaseUnits": purchaseUnitsData,
      "userAction": FPayPalUserActionHelper.convertFromEnumToString(
        action,
      ),
    };

    await _methodChannel.invokeMethod<String>('FlutterPaypal#makeOrder', data);
  }

  // Method call handler from native Android/iOS
  Future<void> _handleMethod(MethodCall call) async {
    if (call.method == 'FlutterPaypal#onSuccess') {
      _onPayPalOrderSuccess(call.arguments.cast<String, dynamic>());
    } else if (call.method == 'FlutterPaypal#onCancel') {
      _onCancelPayPalOrder();
    } else if (call.method == 'FlutterPaypal#onError') {
      _onPayPalOrderError(call.arguments.cast<String, dynamic>());
    } else if (call.method == 'FlutterPaypal#onShippingChange') {
      _onPayPalOrderShippingChange(call.arguments.cast<String, dynamic>());
    }
  }

  void _onPayPalOrderSuccess(Map<String, dynamic> data) {
    String aData = data['approvalData'] ?? "";
    FPayPalApprovalData success = FPayPalApprovalData();

    try {
      success = FPayPalApprovalData.fromJson(
        jsonDecode(aData),
      );
    } catch (e) {
      if (isDebugMode) debugPrint(e.toString());
    }
    _callback.onSuccess(success);
  }

  void _onCancelPayPalOrder() {
    if (_callback.onCancel != null) {
      _callback.onCancel!();
    }
  }

  void _onPayPalOrderError(Map<String, dynamic> data) {
    FPayPalErrorInfo error = FPayPalErrorInfo();
    try {
      error = error.fromJson(data);
    } catch (e) {
      if (isDebugMode) debugPrint(e.toString());
    }

    if (_callback.onError != null) {
      _callback.onError!(error);
    }
  }

  void _onPayPalOrderShippingChange(Map<String, dynamic> data) {
    FPayPalShippingChangeInfo shipping = FPayPalShippingChangeInfo();
    try {
      shipping = FPayPalShippingChangeInfo().fromJson(data);
    } catch (e) {
      if (isDebugMode) debugPrint(e.toString());
    }

    if (_callback.onShippingChange != null) {
      _callback.onShippingChange!(shipping);
    }
  }

  void removeAllPurchaseItems() {
    purchaseUnits = [];
  }
}

/// Backward compatibility alias
typedef FlutterPaypalNative = FlutterPaypalNativeCheckout;
