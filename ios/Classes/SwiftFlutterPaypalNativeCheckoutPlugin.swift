import Flutter
import UIKit
import PayPalCheckout

public class SwiftFlutterPaypalNativeCheckoutPlugin: NSObject, FlutterPlugin {
    private static let METHOD_CHANNEL_NAME = "flutter_paypal_native_checkout"

    static var channel: FlutterMethodChannel?
    static var paypalCallBackHelper: PayPalCallBackHelper?

    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        paypalCallBackHelper = PayPalCallBackHelper(flutterChannel: channel!)
        let instance = SwiftFlutterPaypalNativeCheckoutPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "FlutterPaypal#initiate":
            initiatePackage(call, result)
            result("successfully initiated")
            break
        case "FlutterPaypal#makeOrder":
            makeOrder(call, result)
            result("makeOrder")
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func initiatePackage(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        let clientID = args["clientId"] as! String
        let payPalEnvironmentStr = args["payPalEnvironment"] as! String
        let currencyStr = args["currency"] as! String
        let userActionStr = args["userAction"] as! String
        let autoCapture = args["autoCapture"] as? Bool ?? true

        let payPalEnvironment = Environment.init(rawValueString: payPalEnvironmentStr)
        let currency = CurrencyCode.withLabel(rawValue: currencyStr)
        let userAction = UserAction.init(rawValueString: userActionStr)

        SwiftFlutterPaypalNativeCheckoutPlugin.paypalCallBackHelper?.autoCapture = autoCapture

        Checkout.set(config: CheckoutConfig(
                clientID: clientID,
                onApprove: { approval in
                    try! SwiftFlutterPaypalNativeCheckoutPlugin
                            .paypalCallBackHelper?
                            .onApprove(approval)
                },
                onShippingChange: { shippingChange, shippingAction in
                    try! SwiftFlutterPaypalNativeCheckoutPlugin
                            .paypalCallBackHelper?
                            .onShippingChange(shippingChange)
                },
                onCancel: SwiftFlutterPaypalNativeCheckoutPlugin
                        .paypalCallBackHelper?
                        .onCancel,
                onError: SwiftFlutterPaypalNativeCheckoutPlugin
                        .paypalCallBackHelper?
                        .onError,
                environment: payPalEnvironment
        ))
    }

    func makeOrder(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid arguments",
                    details: nil
            ))
            return
        }
        let purchaseUnitsStr = args["purchaseUnits"] as! String

        let listCustomUnit = try! JSONDecoder().decode([CustomUnit].self, from: purchaseUnitsStr.data(using: .utf8)!)
        var purchaseUnits: [PurchaseUnit] = []
        for customUnit in listCustomUnit {
            let amount = PayPalCheckout.PurchaseUnit.Amount(
                    currencyCode: CurrencyCode.withLabel(rawValue: customUnit.currency),
                    value: customUnit.price
            )

            let purchaseUnit = PayPalCheckout.PurchaseUnit(
                    amount: amount,
                    referenceId: customUnit.referenceId
            )

            purchaseUnits.append(purchaseUnit)
        }
        Checkout.start(
                createOrder: { createOrderAction in
                    let order = OrderRequest(
                            intent: .capture,
                            purchaseUnits: purchaseUnits
                    )
                    createOrderAction.create(order: order)
                }
        )
    }
}
