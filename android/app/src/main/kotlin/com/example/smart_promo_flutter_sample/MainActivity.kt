package com.example.smart_promo_flutter_sample

import android.graphics.Color
import androidx.annotation.NonNull
import br.com.getmo.smartpromo.SmartPromo
import br.com.getmo.smartpromo.models.FSPAddress
import br.com.getmo.smartpromo.models.FSPConsumer
import br.com.getmo.smartpromo.models.FSPGenre
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.lang.Exception

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "br.com.getmo.smartpromo"
        ).setMethodCallHandler { call, _ ->

            (call.arguments as? Map<String, Any>)?.let { config ->
                when (call.method) {
                    "go" -> go(config)
                    "goMulti" -> goMulti(config)
                    "scan" -> scan(config)
                }
            }
        }
    }

    private fun go(config: Map<String, Any>) {
        val campaign = config["campaign"] as? String ?: return
        val smartPromo = smartPromo(config)
        smartPromo?.setConsumer(consumer(config["consumer"] as? Map<String, Any>))
        smartPromo?.go(campaign, this)
    }

    private fun goMulti(config: Map<String, Any>) {
        val headnote = config["headnote"] as? String ?: return
        val title = config["title"] as? String ?: return
        val message = config["message"] as? String ?: return

        val smartPromo = smartPromo(config)
        smartPromo?.setConsumer(consumer(config["consumer"] as? Map<String, Any>))
        smartPromo?.goMulti(headnote, title, message, this)
    }

    private fun scan(config: Map<String, Any>) {
        val campaign = config["campaign"] as? String ?: return
        (config["consumerID"] as? String)?.let { consumerID ->
            val smartPromo = smartPromo(config)
            smartPromo?.scan(campaign, consumerID, this)
        }
    }

    private fun smartPromo(config: Map<String, Any>): SmartPromo? {
        val key = config["key"] as? String
        val secret = config["secret"] as? String

        if (key == null || secret == null) {
            return null
        }

        val smartPromo = SmartPromo()
        smartPromo.setupAccessKeyAndSecretKey(key, secret)
        smartPromo.setMetadata(config["metadata"] as? String)

        (config["color"] as? String)?.let {
            smartPromo.setColor(Color.parseColor(it))
        }

        return smartPromo
    }

    private fun consumer(dict: Map<String, Any>?): FSPConsumer? {
        if (dict == null) return null

        val consumer = FSPConsumer()
        consumer.cpf = dict["cpf"] as? String
        consumer.name = dict["name"] as? String
        consumer.email = dict["email"] as? String
        consumer.phone = dict["phone"] as? String
        try {
            consumer.bdate = SimpleDateFormat("yyyy-MM-dd")
                .parse(dict["birthday"] as? String ?: "")
        } catch (e: Exception) {}

        when (dict["gender"] as? String) {
            "M" -> consumer.genre = FSPGenre.MALE
            "F" -> consumer.genre = FSPGenre.FEMALE
            "NB" -> consumer.genre = FSPGenre.NOT_BINARY
            else -> consumer.genre = FSPGenre.NOT_INFORMED
        }

        consumer.address = address(dict["address"] as? Map<String, String>)
        return consumer
    }

    private fun address(dict: Map<String, String>?): FSPAddress? {
        if (dict == null) return null

        val address = FSPAddress()
        address.streetName = dict["streetName"]
        address.streetNumber = dict["streetNumber"]
        address.complement = dict["complement"]
        address.neighborhood = dict["neighborhood"]
        address.city = dict["city"]
        address.state = dict["state"]
        address.zipCode = dict["zipCode"]
        return address
    }
}