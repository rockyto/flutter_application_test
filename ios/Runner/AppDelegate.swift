import UIKit
import Flutter
import ConsentimientoExpreso

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  var controller : FlutterViewController?
  let viewToPush = CEWebView()
  var fResult : FlutterResult?
  var uuidTrx = ""
  var uuidClient = ""

  override func application( _ application: UIApplication, 
                             didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool {

    guard let flutterViewController  = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    let flutterChannel = FlutterMethodChannel.init(name: "test_activity", binaryMessenger: flutterViewController as! FlutterBinaryMessenger);
    flutterChannel.setMethodCallHandler { (flutterMethodCall, flutterResult) in

    self.fResult = flutterResult

    if flutterMethodCall.method == "startNewActivity" {
      UIView.animate(withDuration: 0.5, animations: {
        self.window?.rootViewController = nil
        self.uuidTrx = UUID().uuidString
        self.uuidClient = UIDevice.current.identifierForVendor!.uuidString
        self.viewToPush.isWebViewLaunched = false
   self.viewToPush.uuidTrx = self.uuidTrx // se asigna un uuid dinámico para la transacción
    self.viewToPush.uuidClient = self.uuidClient // el id de cliente debe ser único por dispositivo por lo que utilizar el uuid del dispositivo.

    self.viewToPush.url = "https://xxxxxx.xxx/" //Este valor será provisto por Dicio
    self.viewToPush.environment = .prod // Relacionado al ambiente .qa .dev o .prod
    self.viewToPush.idLender = "XXXXXXXXXXXXX" // El APIKey del otorgante es un valor constante y será provisto por Dicio
    self.viewToPush.delegate = self // Asigna el delegado para el retorno de información

        let navigationController = UINavigationController(rootViewController: flutterViewController)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window.rootViewController = navigationController
        navigationController.isNavigationBarHidden = true
        navigationController.pushViewController(self.viewToPush, animated: false)

        })

    }; if flutterMethodCall.method == "getInfoDocs" {//Obtenemos los datos de los documentos obtenidos durante el flujo completo.

        if self.uuidTrx == "" || self.uuidClient == "" {
          self.fResult!("Se requiere iniciar el webview antes de consultar los datos")
          } else {
            self.viewToPush.uuidTrx = self.uuidTrx
            self.viewToPush.uuidClient = self.uuidClient
            self.viewToPush.idLender = "xxxxxxxxxxxxxxxxxxxx"
            self.viewToPush.delegate = self
            self.viewToPush.getDocuments()
            }
    }; if flutterMethodCall.method == "getInfoData" {//Obtenemos los datos de los pasos realizados durante el flujo completo.
            if self.uuidTrx == "" || self.uuidClient == "" {
              self.fResult!("Se requiere iniciar el webview antes de consultar los datos")
              } else {
                self.viewToPush.uuidTrx = self.uuidTrx
                self.viewToPush.uuidClient = self.uuidClient
                self.viewToPush.idLender = "xxxxxxxxxxxxxxxxxxxx"
                self.viewToPush.delegate = self
                self.viewToPush.getData()
                }
                }
                }


      GeneratedPluginRegistrant.register(with: self)
                return super.application(application, didFinishLaunchingWithOptions: launchOptions)
                }

        @objc func removeWebViewController() { //esta función es llamada desde el hilo principal
        self.viewToPush.removeFromParent()
        self.viewToPush.isFlutter = true
        }
 }


 extension AppDelegate: CEDelegate {//Métodos delegados que nos van a devolver la información obtenida desde el webview.

 func ceStatus(isFinished: Bool, step: String) {
  if isFinished {
    self.performSelector(onMainThread: #selector(self.removeWebViewController), with: nil, waitUntilDone: false)
    }
    self.fResult!(step)
}

 func ceGetData(data: String) {
  self.fResult!(data)
  }
 func ceFiles(data: String) {
  self.fResult!(data)
  }
  }

