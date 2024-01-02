//
//  AppConfig.swift
//  PDFScanner
//
//  Created by Apps4World on 10/1/21.
//

import SwiftUI
import Foundation

/// Generic configurations for the app
class AppConfig {
   // \(AppConfig.DevURL)
//    static let DevURL = "https://app.tt.social"
//    static let Host = "app.tt.social"
    
    static let DevURL = "https://app.taptok.dev"
    static let Host = "app.taptok.dev"
    static var tokenmessage = ""
    static let MyPhysicalProducts: URL = URL(string: "\(DevURL)/physical-products")!
    static let MyAudience: URL = URL(string: "\(DevURL)/my-audience")!
    static let VirtualCards: URL = URL(string: "\(DevURL)/virtual-cards")!
    static let MiniPages: URL = URL(string: "\(DevURL)/mini-pages")!
    static let AccountSetting: URL = URL(string: "\(DevURL)/settings")!
    static let Helpcenter: URL = URL(string: "https://support.tt.social/support/home")!
    static let RedirecttoOpenContact: URL = URL(string: "\(DevURL)/my-audience/contact/")!
    static let TeamMembers: URL = URL(string: "\(DevURL)/organization/members")!
    static let OrganizationSettings: URL = URL(string: "\(DevURL)/organization/settings")!
    static let ChatURL: URL = URL(string: "https://bcrw.apple.com/urn:biz:339e8614-cc61-446b-9fd5-b8b77939b994")!
    static let emailSupport = "support@tt.social"
    static let loginRootViewNotification = NSNotification.Name("loginRootViewNotification") // declare notification
    static let logoutNotification = NSNotification.Name("logoutNotification") // declare notification
    static let URLNotification = NSNotification.Name("URLNotification") // declare notification
    static func removeAllUserDefaults() {
        UserDefaults.standard.removeObject(forKey:"LOGIN")
        UserDefaults.standard.removeObject(forKey:"token")
        UserDefaults.standard.removeObject(forKey:"user_id")
        UserDefaults.standard.removeObject(forKey:"avatar")
        UserDefaults.standard.removeObject(forKey:"company_logo")
        UserDefaults.standard.removeObject(forKey:"company_name")
        UserDefaults.standard.removeObject(forKey:"name")
        UserDefaults.standard.removeObject(forKey:"position")
        UserDefaults.standard.removeObject(forKey:"role")
        guard let sharedUserDefaults = UserDefaults(suiteName: "dev.taptok.TaptokMigration") else {
            // Error handling
            return
        }
        sharedUserDefaults.removeObject(forKey:"LOGIN")
        sharedUserDefaults.removeObject(forKey:"token")
    }
   
}


