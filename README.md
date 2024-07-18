# SmartPromo Flutter

O SmartPromo é uma SDK para envio de notas em campanhas promocionais, compatível com Android API 21+ e iOS 11+

## Instalação

### Android

Primeiramente confirme que seu projeto Android esteja configurado para `minSdkVersion 21` ou superior.

#### Gradle
SmartPromo pode ser adicionado no seu projeto `Android` utilizando o `Gradle`, para isto adicione a dependência abaixo ao arquivo `build.gradle` a nível de `módulo`:

    implementation 'br.com.getmo:smartpromo:2.6.3'

Verifique se está usando a versão 1.9 ou superior do Google Material Design:
    
    implementation com.google.android.material:material:1.9.0
    
Você também precisa adicionar a compatibilidade com o Java 8 no `build.gradle` no seu módulo:

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }


#### Kotlin

Agora no arquivo `MainActivity.kt` vamos adicionar a camada de abstração do Android. Aqui é um código pronto que você só precisa colar dentro da classe:
##### Imports
```
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
```

##### Código
```
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

```

### iOS

Primeiramente confirme que seu projeto iOS esteja configurado para `IPHONEOS_DEPLOYMENT_TARGET = 11.0;` ou superior.

#### Cocoapods

Caso seu projeto ainda não esteja utilizando o `Cocoapods`, precisaremos inicializar ele: 
```
cd ios
pod init
```

Adicione a SDK no arquivo `Podfile`:
```
pod 'SmartPromo', '2.6.1'
```

E rode o comando de instalação:
```
pod install
```

#### Swift

Confira se o seu projeto tem declarada a permissão de câmera (NSCameraUsageDescription) no arquivo info.plist a chave NSCameraUsageDescription.

Agora no arquivo `AppDelegate.swift` vamos adicionar a camada de abstração do iOS.
Primeiro vamos importar a SDK:
```
import SmartPromo
```

Então chamar a função que iremos criar em seguida na função `didFinishLaunchingWithOptions`: 
```
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // SmartPromo
        observeSmartPromoMethods()
```

Aqui é um código pronto que você só precisa colar dentro do arquivo:

```
// MARK: - SmartPromo
extension AppDelegate {
    
    private func observeSmartPromoMethods() {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }
        let channel = FlutterMethodChannel(name: "br.com.getmo.smartpromo", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { [weak self] call, _ -> Void in
            
            guard let self = self else { return }
            guard let config = call.arguments as? [String: Any] else { return }
            
            switch call.method {
            case "go":
                self.go(controller: controller, config: config)
            case "goMulti":
                self.goMulti(controller: controller, config: config)
            case "scan":
                self.scan(controller: controller, config: config)
            default:
                break
            }
        }
    }
    
    private func go(controller: UIViewController, config: [String: Any]) {
        guard let campaign = config["campaign"] as? String else { return }
        let smartPromo = smartPromo(config: config)
        smartPromo?.setConsumer(consumer(fromDict: config["consumer"] as? [String: Any]))
        smartPromo?.go(campaign, above: controller)
    }

    private func goMulti(controller: UIViewController, config: [String: Any]) {
        guard let headnote = config["headnote"] as? String else { return }
        guard let title = config["title"] as? String else { return }
        guard let message = config["message"] as? String else { return }
        
        let smartPromo = smartPromo(config: config)
        smartPromo?.setConsumer(consumer(fromDict: config["consumer"] as? [String: Any]))
        smartPromo?.goMulti(withHeadnote: headnote, title: title, message: message)
    }
    
    private func scan(controller: UIViewController, config: [String: Any]) {
        guard let campaign = config["campaign"] as? String else { return }
        guard let consumerID = config["consumerID"] as? String else { return }
        let smartPromo = smartPromo(config: config)
        smartPromo?.scan(campaign, consumerID: consumerID, above: controller)
    }
    
    private func smartPromo(config: [String: Any]) -> SmartPromo? {
       guard let key = config["key"] as? String else { return nil }
       guard let secret = config["secret"] as? String else { return nil }
       
       let smartPromo = SmartPromo()
       smartPromo.setupAccessKey(key, andSecretKey: secret)
       smartPromo.setMetadata(config["metadata"] as? String)
       
       if let color = color(fromHex: config["color"] as? String) {
           smartPromo.setColor(color)
       }
       
       return smartPromo
    }
    
    private func consumer(fromDict dict: [String: Any]?) -> FSPConsumer? {
        guard let dict = dict else { return nil }

        let consumer = FSPConsumer()
        consumer.cpf = dict["consumerID"] as? String
        consumer.name = dict["name"] as? String
        consumer.email = dict["email"] as? String
        consumer.phone = dict["phone"] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        consumer.birthday = dateFormatter.date(from: dict["birthday"] as? String ?? "")
        
        switch dict["gender"] as? String {
        case "M":
            consumer.gender = FSPGenderTypeMale
        case "F":
            consumer.gender = FSPGenderTypeFamale
        case "NB":
            consumer.gender = FSPGenderTypeNotBinary
        default:
            consumer.gender = FSPGenderTypeNotInformed
        }
        
        consumer.address = address(fromDict: dict["address"] as? [String: String] )
        return consumer
    }
    
    private func address(fromDict dict: [String: String]?) -> FSPAddress? {
        guard let dict = dict else { return nil }
        
        let address = FSPAddress()
        address.streetName = dict["streetName"]
        address.streetNumber = dict["streetNumber"]
        address.complement = dict["complement"]
        address.neighborhood = dict["neighborhood"]
        address.city = dict["city"]
        address.state = dict["state"]
        address.zipCode = dict["zipCode"]
        return address
    }
    
    private func color(fromHex color: String?) -> UIColor? {
        guard let color = color else { return nil }
        var cString = color.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
```

### Utilização no Flutter

A parte final é utilizar a camada de abstração criada no seu projeto Flutter.
#### Precisamos importar a classe de serviços e inicializá-la:
```
import 'package:flutter/services.dart';

MethodChannel _smartPromo() {
    return MethodChannel('br.com.getmo.smartpromo');
}

```

#### Passando um consumidor
O SmartPromo gerencia o cadastro do consumidor por você, mas caso queira otimizar a experiência de uso, você pode informar para o SmartPromo o consumidor que está utilizando o aplicativo, através da configuração:
```
Map _createConsumer() {
    return {
      "consumerID": "{consumerID}",
      "name": "Consumer Name",
      "email": "mail@mail.com",
      "phone": "51999999999",
      "birthday": "2000-12-31",
      "gender": "NI", // M, F, NB, NI
      "address": {
        "streetName": "Rua A",
        "streetNumber": "100",
        "complement": "Apto 200",
        "neighborhood": "Partenon",
        "city": "Porto Alegre",
        "state": "RS",
        "zipCode": "91530060",
      }
    };
}
```

#### Iniciando a SDK no modo campanha única:
```
  Map _createConfig() {
    return {
      "campaign": "{campaignID}",
      "key": "{accessKey}",
      "secret": "{secretKey}",
      "color": "#18AC4F",
      "metadata": "Qualquer coisa como String" // opcional
    };
  }

  void _go() {
    var config = _createConfig();
    config["consumer"] = _createConsumer();
    _smartPromo().invokeMethod('go', config);
  }
 ```

#### Iniciando a SDK no modo de múltiplas campanhas:
```
  Map _createConfig() {
    return {
      "headnote": "{Headnote}",
      "title": "{Title}",
      "message": "{Message}",
      "key": "{accessKey}",
      "secret": "{secretKey}",
      "color": "#18AC4F",
      "metadata": "Qualquer coisa como String" // opcional
    };
  }

  void _goMulti() {
    var config = _createConfig();
    config["consumer"] = _createConsumer();
    _smartPromo().invokeMethod('goMulti', config);
  }
 ```
 
 ##### Iniciando a SDK no modo Scanner de notas:
```
  Map _createConfig() {
    return {
      "campaign": "{campaignID}",
      "key": "{accessKey}",
      "secret": "{secretKey}",
      "color": "#18AC4F",
      "metadata": "Qualquer coisa como String" // opcional
    };
  }

  void _scan() {
    var config = _createConfig();
    config["consumerID"] = "{consumerID}";
    _smartPromo().invokeMethod('scan', config);
  }
 ```
 
    
 > __campaignID__, __accessKey__, e __secretKey__ serão fornecidos pelo time da __Getmo__ para serem configurados no seu projeto.
