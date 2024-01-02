//
//  LoginAppApp.swift
//  LoginApp
//
//  Created by Samir Castro on 7/11/22.
//

import SwiftUI
import Combine
import UIKit
import CoreSpotlight
import MobileCoreServices
import UserNotifications


@main
struct LoginAppApp: App {
   
    @StateObject private var manager = TaptokDataManager()
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    let center = UNUserNotificationCenter.current()
    init() {
        //registerForNotification()
    }
    
    func registerForNotification() {
        //For device token and push notifications.
        UIApplication.shared.registerForRemoteNotifications()
        let center : UNUserNotificationCenter = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound , .alert , .badge ], completionHandler: { (granted, error) in
            if ((error != nil)) { UIApplication.shared.registerForRemoteNotifications() }
            else {
                
            }
        })
    }
    var body: some Scene {
        
        WindowGroup {
            if UserDefaults.standard.string(forKey: "LOGIN") == "YES"{
                NavigationView {
                    ZStack {
                        Color("BgColor").edgesIgnoringSafeArea(.all)
                        DashboardContentView().environmentObject(manager).onContinueUserActivity(NSUserActivityTypeBrowsingWeb) {
                            userActivity in
                                handleSpotlight(userActivity)
                        }
                    }.navigationBarHidden(true).onAppear(){
                        UserDefaults.standard.removeObject(forKey: "contact_id")
                    }
                }
            }else{
                ContentView().environmentObject(manager).onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    handleSpotlight(userActivity)
                }.onAppear(){
                   
                    UserDefaults.standard.removeObject(forKey: "contact_id")
                }
            }
        }
    }
    func handleSpotlight(_ userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL
             // let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true)
              
        else {
            return
        }
    
//        manager.showAppClipContain = true
//        manager.appClipUrl = incomingURL
     //   UserDefaults.standard.setValue(incomingURL, forKey: "appClipUrl")
        NotificationCenter.default.post(name: AppConfig.URLNotification, object: incomingURL,userInfo: nil)

       // UIApplication.shared.open(incomingURL)
    }
    
}




// MARK: - Extensions for View
/// Create a shape with specific rounded corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


/// Hide keyboard from anywhere in the app
extension View {
    func hideKeyboard() {
        DispatchQueue.main.async {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Present an alert from anywhere in the app
func presentAlert(title: String, message: String, primaryAction: UIAlertAction, secondaryAction: UIAlertAction? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(primaryAction)
    if let secondary = secondaryAction { alert.addAction(secondary) }
    var root = UIApplication.shared.currentUIWindow()?.rootViewController
    if let presenter = root?.presentedViewController { root = presenter }
    root?.present(alert, animated: true, completion: nil)
}

//// MARK: - Blur background view
struct BackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
// MARK: - Save/Retrieve data from documents folder
extension FileManager {
    /// Save any data to documents folders
    /// - Parameters:
    ///   - data: data to be saved
    ///   - name: data/file name
    func save(data: Data, name: String, completion: ((_ documentURL: URL) -> Void)? = nil) {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsUrl.appendingPathComponent(name)
            do {
                try data.write(to: fileURL, options: .atomic)
                completion?(fileURL)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Delete a document/file with a given file name
    /// - Parameter fileName: file name to be deleted
    func delete(fileName: String) {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsUrl.appendingPathComponent(fileName)
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Loads data from file manager for a given file name
    /// - Parameter fileName: file name
    /// - Returns: returns file data
    func loadData(fileName: String) -> Data? {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsUrl.appendingPathComponent(fileName)
            return try? Data(contentsOf: fileURL)
        }
        return nil
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
       
            let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
            configuration.delegateClass = SceneDelegate.self
            return configuration
    }
    
    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        var window: UIWindow?
        
        private var observer: Any?
        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            if connectionOptions.urlContexts.first != nil {

                //let sendingAppID = urlContext.options.sourceApplication
                //let url = urlContext.url
                //print("source application = \(sendingAppID ?? "Unknown")")
               // print("url = \(url)")

                // Process the URL similarly to the UIApplicationDelegate example.
            }
            if let windowScene = scene as? UIWindowScene {
                let app = UIApplication.shared

                if !(app.delegate is AppDelegate) && app.supportsMultipleScenes {
                    app.requestSceneSessionDestruction(session, options: nil)
                }
                let window = UIWindow(windowScene: windowScene)
                
                if UserDefaults.standard.string(forKey: "LOGIN") == "YES"{
                    window.rootViewController = UIHostingController(rootView:
                                                                        NavigationView {
                        ZStack {
                           
                            Color("BgColor").edgesIgnoringSafeArea(.all)
                            DashboardContentView().environmentObject(TaptokDataManager())
                        }.navigationBarHidden(true).onAppear(){
                            UserDefaults.standard.removeObject(forKey: "contact_id")
                        }
                    })
                } else {
                    window.rootViewController = UIHostingController(rootView: ContentView().environmentObject(TaptokDataManager()).onContinueUserActivity(CSSearchableItemActionType, perform: LoginAppApp().handleSpotlight(_:)).onAppear(){
                        
                        UserDefaults.standard.removeObject(forKey: "contact_id")
                    }
                    )
                }
                
                observer = NotificationCenter.default.addObserver(forName: AppConfig.loginRootViewNotification, object: nil, queue: nil, using: { _ in
                    // create another view on notification and replace
                    window.rootViewController = UIHostingController(rootView:
                                                                        NavigationView {
                        ZStack {
                            Color("BgColor").edgesIgnoringSafeArea(.all)
                            DashboardContentView().environmentObject(TaptokDataManager())
                        }.navigationBarHidden(true).onAppear(){
                            UserDefaults.standard.removeObject(forKey: "contact_id")
                        }
                    })
                })
                
                observer = NotificationCenter.default.addObserver(forName: AppConfig.logoutNotification, object: nil, queue: nil, using: { _ in
                    // create another view on notification and replace
                    window.rootViewController = UIHostingController(rootView: ContentView().environmentObject(TaptokDataManager()).onContinueUserActivity(CSSearchableItemActionType, perform: LoginAppApp().handleSpotlight(_:)).onAppear(){
                        
                        UserDefaults.standard.removeObject(forKey: "contact_id")
                    }
                    )
                })
                self.window = window
                window.makeKeyAndVisible()
            }
        }
        
        
    }
    
}
