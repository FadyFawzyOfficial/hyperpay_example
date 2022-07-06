package com.fadyfawzy.hyperpay_example

import android.content.Intent
import com.oppwa.mobile.connect.checkout.dialog.CheckoutActivity
import com.oppwa.mobile.connect.checkout.meta.CheckoutSettings
import com.oppwa.mobile.connect.exception.PaymentError
import com.oppwa.mobile.connect.provider.Connect
import com.oppwa.mobile.connect.provider.Transaction
import com.oppwa.mobile.connect.provider.TransactionType
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.fadyfawzy/paymentMethod"
    private lateinit var _result: MethodChannel.Result
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            // This method is invoked on the main thread.
            // TODO
            if (call.method.equals("getPaymentMethod")) {
                _result = result
                receivePayment(call)
            } else result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when (resultCode) {
            CheckoutActivity.RESULT_OK -> {
                // transaction completed
                val transaction: Transaction =
                    data!!.getParcelableExtra(CheckoutActivity.CHECKOUT_RESULT_TRANSACTION)!!

                // resource path if needed
                val resourcePath =
                    data.getStringExtra(CheckoutActivity.CHECKOUT_RESULT_RESOURCE_PATH)

                if (transaction.transactionType == TransactionType.SYNC) {
                    /* check the result of synchronous transaction */
                    _result.success(transaction.alipaySignedOrderInfo)
                } else {
                    /* wait for the asynchronous transaction callback in the onNewIntent() */
                    _result.success(transaction.redirectUrl)
                }
            }

            CheckoutActivity.RESULT_CANCELED -> {
                /* shopper cancelled the checkout process */
                _result.error("UNAVAILABLE", "shopper canceled the checkout process", null)
            }

            CheckoutActivity.RESULT_ERROR -> {
                /* error occurred */
                _result.error("UNAVAILABLE", CheckoutActivity.CHECKOUT_RESULT_ERROR, null)
                val error: PaymentError =
                    data!!.getParcelableExtra(CheckoutActivity.CHECKOUT_RESULT_ERROR)!!
            }
        }
    }

    private fun receivePayment(call: MethodCall) {
        val paymentBrands = hashSetOf("VISA", "MASTER", "DIRECTDEBIT_SEPA")

        val checkoutSetting = CheckoutSettings(
            call.argument("checkoutId")!!,
            paymentBrands,
            Connect.ProviderMode.TEST
        )

        // Set shopper result URL
        checkoutSetting.shopperResultUrl = "com.fadyfawzy.hyperpay.payments://result"

        val intent = checkoutSetting.createCheckoutActivityIntent(this)

        startActivityForResult(intent, CheckoutActivity.REQUEST_CODE_CHECKOUT)
    }
}
