package com.fadyfawzy.hyperpay_example

import com.oppwa.mobile.connect.checkout.dialog.CheckoutActivity
import com.oppwa.mobile.connect.checkout.meta.CheckoutSettings
import com.oppwa.mobile.connect.provider.Connect
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.fadyfawzy/paymentMethod"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            // This method is invoked on the main thread.
            // TODO
        }
    }

    fun receivePayment(call: MethodCall){
        val paymentBrands = hashSetOf("VISA", "MASTER", "DIRECTDEBIT_SEPA")

        val checkoutSetting = CheckoutSettings(call.arguments("checkoutId"), paymentBrands, Connect.ProviderMode.TEST)

        // Set shopper result URL
        checkoutSetting.setShopperResultUrl("om.fadyfawzy.hyperpay_example.payments://result")

        val intent = checkoutSetting.createCheckoutActivityIntent(this)

        startActivityForResult(intent, CheckoutActivity.REQUEST_CODE_CHECKOUT)
    }
}
