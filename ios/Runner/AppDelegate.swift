import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let paymentChannel = FlutterMethodChannel(name: "com.fadyfawzy/paymentMethod",
                                                binaryMessenger: controller.binaryMessenger)
      
      paymentChannel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          // Note: this method invoked on the UI thread.
          // Handle payment.
          guard call.method == "getPaymentMethod" else {
              result(FlutterMethodNotImplemented)
              return
          }
          self.recivePayment(result: result, call: call)
      })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func recivePayment(result: @escaping FlutterResult, call: FlutterMethodCall){
        let provider = OPPPaymentProvider(mode: OPPProviderMode.test)
        let checkoutSettings = OPPCheckoutSettings()
        // Set available payment brands for your shop
        checkoutSettings.paymentBrands = ["VISA",  "DIRECTDEBIT_SEPA", "MASTER"]
        // Set shopper result URL
        checkoutSettings.shopperResultURL = "com.fadyfawzy.hyperpay_example.payments://result"
        
        let args = call.arguments as? Dictionary<String, Any>
        let checkoutId = (args?["checkoutId"] as? String)!
        
        let checkoutProvider = OPPCheckoutProvider(paymentProvider: provider, checkoutID: checkoutId , settings: checkoutSettings)
        
        checkoutProvider?.presentCheckout(forSubmittingTransactionCompletionHandler: { (transaction, error) in
            guard let transaction = transaction else {
                // Handle invalid transaction,
                result(FlutterError(code: "UNAVAILABLE ELSE",
                                    message: "Payemt info unavailable",
                                    details: nil))
                return
            }
            if transaction.type == .synchronous {
                // If a transaction is synchronous, just request the payment status
                // You can use transaction.resourcePath or just checkout ID to do it
                result(transaction.resourcePath)
                
            } else if transaction.type == .asynchronous {
                // The SDK opens transaction.redirectUrl in a browser
                // See 'Asynchronous Payments' guide for more details
                result(transaction.redirectURL?.absoluteString)
                
            } else {
                // Executed in case of failure of the transaction for any reason
                result(FlutterError(code: "UNAVAILABLE Else",
                                    message: error.debugDescription,
                                    details: nil))
            }
        }, cancelHandler: {
            // Executed if the shopper closes the payment page prematurely
            result(FlutterError(code: "UNAVAILABLE Error",
                                message: "Executed if the shopper closes the payment page prematurely",
                                details: nil))
            
        })
    }
}
