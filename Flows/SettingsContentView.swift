//
//  SettingsContentView.swift
//  PDFScanner
//
//  Created by Apps4World on 10/1/21.
//

import SwiftUI
import StoreKit
import MessageUI
//import PurchaseKit

/// Main settings view
struct SettingsContentView: View {
    
    @EnvironmentObject var manager: TaptokDataManager
    @State private var showLoadingView: Bool = false
    @State private var showPhysicalPage = false
    @State private var showHelpcenter = false
    @State private var showAccountSettings = false
    @State private var showMyAudiencePage = false
    @State private var showOrganizationSettingsPage = false
    @State private var showTeamMembersPage = false
    @State private var showVirtualCardPage = false
    @State private var showMiniPages = false
    @State private var isAlert = false
    @State private var joke: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var userProfile = ""
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack() {
                /// Header view
                ///
                ///
                HeaderTitleView
                
                /// Settings items
                ScrollView(.vertical, showsIndicators: false, content: {
                    if UserDefaults.standard.object(forKey: "role") == nil{
                        
                    }else {
                        VStack{
                            Header()
                            
                            ProfileText()
                        }.overlay(HeaderImage())
                        Spacer(minLength: 30)
                        
                    }
                    VStack {
                       
                        CustomHeader(title: "Solutions")
                        SolutionsView
                        if UserDefaults.standard.object(forKey: "role") == nil{
                            
                        }else {
                            let defaults = UserDefaults.standard
                            let role = defaults.string(forKey: "role")!
                            let company_name = defaults.string(forKey: "company_name")!
                            if (role == "Admin") ||  (role == "Super-Admin"){
                                let company_logo = defaults.string(forKey: "company_logo")!
                                companyHeader(title: "Organization: \(company_name)",icon: company_logo)
                                OrganizationView
                            }
                            CustomHeader(title: "Help & Support")
                            PrivacySupportView
                            CustomHeader(title: "Manage Account")
                            SignoutView
                        }
                       
                        
                    }.padding([.leading, .trailing])
                    Spacer(minLength: CustomTabBarView.height)
                })
            }.alert(isPresented: $isAlert) { () -> Alert in
                Alert(title: Text("Are you sure you want to logout?"), message: Text(""), primaryButton: .default(Text("YES"), action: {
                    showLoadingView = true
                    Task {
                        let (data, _) = try await URLSession.shared.data(from: URL(string:"\(AppConfig.DevURL)/logout")!)
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                        //print(responseJSON as Any)
                        AppConfig.removeAllUserDefaults()
                        NotificationCenter.default.post(name: AppConfig.logoutNotification, object: nil,userInfo: nil)

                    }
                    
                    
                }), secondaryButton: .default(Text("NO")))
            }
            /// Show loading view
            LoadingView(isLoading: $showLoadingView)
            
            //WebviewShow
        }
        
    }
    struct HeaderBackgroundSliders: View {
        @AppStorage("rValue") var rValue = 17.0
        @AppStorage("gValue") var gValue = 37.0
        @AppStorage("bValue") var bValue = 74.0
        
        var body: some View {
            Section(header: Text("Header Background Color")) {
                HStack {
                    VStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 100)
                            .foregroundColor(Color(red: rValue, green: gValue, blue: bValue, opacity: 1.0))
                    }
                }
            }
        }
    }
    struct ProfileText: View {
        @AppStorage("name") var name = ""
        @AppStorage("subtitle") var company_name = ""
       
        var body: some View {
            VStack(spacing: 15) {
                VStack(spacing: 8) {
                    
                    let defaults = UserDefaults.standard
                    let company_name = defaults.string(forKey: "company_name")!
                    let name = defaults.string(forKey: "name")!
                    let position = defaults.string(forKey: "position")!
                    Text(name.capitalized)
                        .foregroundColor(Color(red:17.0/255.0, green:37.0/255.0, blue:74.0/255.0))
                        .font(Font.custom("Poppins-Medium", size: 22.0))
                    Text(position)
                        .font(Font.custom("Poppins-Medium", size: 16.0))
                        .foregroundColor(Color(red:17.0/255.0, green:37.0/255.0, blue:74.0/255.0))
                        .frame(maxWidth: .infinity)
                        .textCase(.uppercase)
                    Text(company_name)
                        
                        .font(Font.custom("Poppins-Medium", size: 14.0))
                        .foregroundColor(Color(red:17.0/255.0, green:37.0/255.0, blue:74.0/255.0))
                        .frame(maxWidth: .infinity)
                        .textCase(.uppercase)
                    
                }.padding(.top, 80)
                
            }
        }
    }
    
    /// Header title view
    private var HeaderTitleView: some View {
        HStack {
            Text("Manage").bold().font(.largeTitle)
                .foregroundColor(Color("ExtraDarkGrayColor"))
            Spacer()
        }.padding(.top).padding([.leading, .trailing])
    }
    
    private var WebviewShow: some View {
        Button(action: {  }) {
            Group {
                Spacer().frame(width: 0, height: 36.0, alignment: .topLeading)
                HStack {
                    Image("iconBack")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                        .padding(.leading, 30.0)
                }
                
            }
            
        }
        
        
    }
    
    /// Create custom header view
    private func CustomHeader(title: String) -> some View {
        HStack {
            Text(title).font(.system(size: 18, weight: .medium))
            Spacer()
        }.foregroundColor(Color("LightGrayColor"))
    }
    
    /// Create custom header view
    private func companyHeader(title: String ,icon: String) -> some View {
    
        HStack() {
            
            AsyncImage(url: URL(string: "\(AppConfig.DevURL)\(icon)")) { image in
                image.resizable()
                    .frame(width: 30, height: 30, alignment: .center)
                    
               
            } placeholder: {
                Image(icon).resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                    
            }
            Image(icon).resizable().aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30, alignment: .center)
                
                
            Text(title).font(.system(size: 18, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .position(x: 105 ,y: 15)
            //Spacer()
            
        }.foregroundColor(Color("LightGrayColor"))
    }
    
    /// Custom settings item
    private func SettingsItem(title: String, icon: String, action: @escaping() -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            action()
        }, label: {
            HStack {
                Image(icon).resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22, alignment: .center)
                Text(title).font(.system(size: 18))
                Spacer()
                Image(systemName: "chevron.right")
            }.foregroundColor(Color("ExtraDarkGrayColor")).padding()
        })
    }
    
    
    private func SettingsCustome(title: String, icon: String, action: @escaping() -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            action()
        }, label: {
            HStack {
                Image(systemName: icon).resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22, alignment: .center)
                Text(title).font(.system(size: 18))
                Spacer()
                Image(systemName: "chevron.right")
            }.foregroundColor(Color("ExtraDarkGrayColor")).padding()
        })
    }
    
    
    private var OrganizationView: some View {
        VStack {
            
            Group{
    
                
                SettingsItem(title: "Team Members", icon: "TeamMembers") {
                    showTeamMembersPage = true
                }
                Divider()
                SettingsItem(title: "Organization Settings", icon: "organization-structure") {
                    showOrganizationSettingsPage = true
                }
            }
            
            
            Group{
                //let vc = UIHostingController(rootView: MiniPages())
                NavigationLink(
                    destination: TeamMembers().environmentObject(manager).navigationBarHidden(true), isActive: $showTeamMembersPage) {
                        
                    }
                    .navigationBarHidden(true)
                NavigationLink(
                    destination: OrganizationSettings().environmentObject(manager).navigationBarHidden(true), isActive: $showOrganizationSettingsPage) {
                        
                    }
                    .navigationBarHidden(true)
               
            }
        }.padding([.top, .bottom], 5).background(
            Color("LightColor").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        ).padding(.bottom, 40)
        
    }
    
    
    private var SolutionsView: some View {
        VStack {
            
            SettingsItem(title: "My Physical Products", icon: "Products") {
                showPhysicalPage = true
                
                
            }
            
            Divider()
            SettingsItem(title: "My Audience", icon: "audience") {
                showMyAudiencePage = true
            }
            
            // Mini Pages
            Divider()
            SettingsItem(title: "Virtual Cards", icon: "IdentificationCard") {
                showVirtualCardPage = true
                
            }
            
            Divider()
            SettingsItem(title: "Mini Pages", icon: "Component") {
                showMiniPages = true
            }
           
            
            
            Group{
                //let vc = UIHostingController(rootView: MiniPages())
                NavigationLink(
                    destination: MyPhysicalProducts().environmentObject(manager).navigationBarHidden(true), isActive: $showPhysicalPage) {
                        
                    }
                    .navigationBarHidden(true)
                NavigationLink(
                    destination: MyAudience().environmentObject(manager).navigationBarHidden(true), isActive: $showMyAudiencePage) {
                        
                    }
                    .navigationBarHidden(true)
                NavigationLink(
                    destination: VirtualCards().environmentObject(manager).navigationBarHidden(true), isActive: $showVirtualCardPage) {
                        
                    }
                    .navigationBarHidden(true)
                
                
                NavigationLink(
                    destination: MiniPages().environmentObject(manager).navigationBarHidden(true), isActive: $showMiniPages) {

                    }
                    .navigationBarHidden(true)
                

                
                
            }
        }.padding([.top, .bottom], 5).background(
            Color("LightColor").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        ).padding(.bottom, 40)
        
    }
    private var InAppPurchasesPromoBannerView: some View {
        ZStack {
            ZStack {
                
                /// Decorative image
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "doc.text").font(.system(size: 120))
                            .foregroundColor(.white).opacity(0.1)
                            .offset(y: 15).rotationEffect(.degrees(-20))
                    }
                }
            }.frame(height: 110).cornerRadius(15).padding(.bottom, 5)
        }
    }
    
    
    
    
    
    // MARK: - Support & Privacy
    private var PrivacySupportView: some View {
        VStack {
            SettingsItem(title: "Helpcenter", icon: "headset") {
                showHelpcenter = true
            }
            Divider()
            SettingsItem(title: "Chat", icon: "ChatDots") {
                
                UIApplication.shared.open(AppConfig.ChatURL, options: [:], completionHandler: nil)
            }
            Divider()
            
            SettingsItem(title: "Call", icon: "Icon feather-phone-call") {
                
                let ContactNo_STR : String = ("+1 (888) 337-0949").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "")
                if let url = URL(string: "tel://\(ContactNo_STR)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
//            Divider()
//            SettingsCustome(title: "Email", icon: "envelope.badge") {
//                EmailPresenter.shared.present()
//
//            }
            Group{
                //let vc = UIHostingController(rootView: MiniPages())
                NavigationLink(
                    destination: Helpcenter().environmentObject(manager).navigationBarHidden(true), isActive: $showHelpcenter) {
                        
                    }
                    .navigationBarHidden(true)
                
                
            }
            
            
        }.padding([.top, .bottom], 5).background(
            Color("LightColor").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        ).padding(.bottom, 40)
    }
    
    
    // MARK: - SignOut
    private var SignoutView: some View {
        VStack {
            
            SettingsItem(title: "Account Setting", icon: "Settingic") {
                showAccountSettings = true
                
            }
            Divider()
            SettingsItem(title: "Logout", icon: "SignOut") {
                //EmailPresenter.shared.present()
                self.isAlert = true
              
            }
            Group{
                //let vc = UIHostingController(rootView: MiniPages())
                NavigationLink(
                    destination: AccountSettings().environmentObject(manager).navigationBarHidden(true), isActive: $showAccountSettings) {
                        
                    }
                    .navigationBarHidden(true)
                
                
            }
            
        }.padding([.top, .bottom], 5).background(
            Color("LightColor").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        )
        // AccountSettings
    }
    //Sign out
}
struct Joke: Codable {
    let value: String
}
// MARK: - Preview UI
struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContentView()
            .environmentObject(TaptokDataManager())
    }
}
private extension HorizontalAlignment {
    struct SFViewAlignment: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[HorizontalAlignment.leading]
        }
    }
    static let sfView = HorizontalAlignment(SFViewAlignment.self)
}


// MARK: - Mail presenter for SwiftUI
class EmailPresenter: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailPresenter()
    private override init() { }
    
    func present() {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: "Email Simulator", message: "Email is not supported on the simulator. This will work on a physical device only.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            EmailPresenter.getRootViewController()?.present(alert, animated: true, completion: nil)
            return
        }
        let picker = MFMailComposeViewController()
        picker.setToRecipients([AppConfig.emailSupport])
        picker.mailComposeDelegate = self
        EmailPresenter.getRootViewController()?.present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        EmailPresenter.getRootViewController()?.dismiss(animated: true, completion: nil)
    }
    
    static func getRootViewController() -> UIViewController? {
        //UIApplication.shared.windows.first?.rootViewController
        UIApplication.shared.currentUIWindow()?.rootViewController
    }
}
public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
        
    }
}
