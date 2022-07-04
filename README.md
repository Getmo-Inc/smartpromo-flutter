# SmartPromoSampleFlutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Android

minSdkVersion 21

### Gradle
SmartPromo pode ser adicionado no seu projeto `Android` utilizando o `Gradle`, para isto adicione o repositório do `jitpack.io` ao seu arquivo `build.gradle` a nível de `projeto`, dentro de `allprojects` e `repositories`:
```
allprojects {
    repositories {
        ...
        maven { url 'https://jitpack.io' }
    }
}
```

Agora adicione a dependência abaixo ao arquivo `build.gradle` a nível de `módulo`:

    implementation 'org.bitbucket.getmo:android-smartpromo:1.9'
    
Para finalizar, você precisa adicionar a compatibilidade com o Java 8 no `build.gradle` no seu modulo:

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

## iOS

IPHONEOS_DEPLOYMENT_TARGET = 11.0;
cd ios
pod init
pod 'SmartPromo', '1.9'
pod install

import Flutter
import SmartPromo

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Observe Flutter Functions
        observeMethods()


// MARK: - SmartPromo
extension AppDelegate {
    
    private func observeMethods() {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }
        let channel = FlutterMethodChannel(name: "br.com.getmo.smartpromo", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { [weak self] call, _ -> Void in
            
            guard let self = self else { return }
            guard let config = call.arguments as? [String: Any] else { return }
            
            switch call.method {
            case "go":
                self.go(controller: controller, config: config)
            case "scan":
                self.scan(controller: controller, config: config)
            default:
                break
            }
        }
    }
    
    private func go(controller: UIViewController, config: [String: Any]) {
        let smartPromo = smartPromo(config: config)
        smartPromo?.setConsumer(consumer(fromDict: config["consumer"] as? [String: Any]))
        smartPromo?.go(controller)
    }
    
    private func scan(controller: UIViewController, config: [String: Any]) {
        guard let consumerID = config["consumerID"] as? String else { return }
        let smartPromo = smartPromo(config: config)
        smartPromo?.scan(withConsumerID: consumerID, above: controller)
    }
    
    private func smartPromo(config: [String: Any]) -> SmartPromo? {
        guard let campaign = config["campaign"] as? String else { return nil }
        guard let key = config["key"] as? String else { return nil }
        guard let secret = config["secret"] as? String else { return nil }
        
        let smartPromo = SmartPromo(campaign)
        smartPromo?.setupAccessKey(key, andSecretKey: secret)
        
        if let color = color(fromHex: config["color"] as? String) {
            smartPromo?.setColor(color)
        }
        
        return smartPromo
    }
    
    private func consumer(fromDict dict: [String: Any]?) -> FSPConsumer? {
        guard let dict = dict else { return nil }

        let consumer = FSPConsumer()
        consumer.cpf = dict["cpf"] as? String
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


## Flutter
import 'package:flutter/services.dart';
static const smartPromo = MethodChannel('br.com.getmo.smartpromo');

 Map _config() {
    return {
      "campaign": "E3F3BBEABC8344FB",
      "key": "QXS7TR2M3KQF2A9G",
      "secret":
          "gRXdR9aV4QxpXBarMq6G9rsz25MwkdryKU2mShYJkaPstguV7QnN6YPJ8CUytL97",
      "color": "#18AC4F"
    };
  }

  Map _consumer() {
    return {
      "cpf": "23365159037",
      "name": "Consumer Name",
      "email": "mail@mail.com",
      "phone": "51999999999",
      "birthday": "2000-12-31",
      "gender": "NB", // M, F, NB, NI
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

  void _go() {
    var config = _config();
    config["consumer"] = _consumer();
    smartPromo.invokeMethod('go', config);
  }

  void _scan() {
    var config = _config();
    config["consumerID"] = "23365159037";
    smartPromo.invokeMethod('scan', config);
  }