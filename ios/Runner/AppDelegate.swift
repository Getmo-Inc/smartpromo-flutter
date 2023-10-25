import UIKit
import Flutter
import SmartPromo

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // SmartPromo
    observeSmartPromoMethods()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

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