//
//  SignInScreenView.swift
//  LoginApp
//
//  Created by Samir Castro on 7/12/22.
//
import Foundation
import SwiftUI
import Combine
import AuthenticationServices
import Combine

struct SignInScreenView: View {
    
    enum Field: Hashable {
        case emailField
        case passwordField
    }
   
    @State var SharedUser = UserDefaults(suiteName: SharedUserDefults.suiteName)
    @State private var email: String = ""
    @State private var Password: String = ""
    @State private var validation: String = ""
    @State private var showPassword = false
    @State private var isEmailValid : Bool   = true
    @State var showSpinner = false
    @State var showDashboard = false
    @State var showAppClipPage = false
    @State var showAppClipURL : URL?
    @State var  model : WebViewModel?
    @FocusState private var focusedField: Field?
    var type : ASAuthorizationAppleIDButton.ButtonType = .default
    var style : ASAuthorizationAppleIDButton.Style? = nil
    @State private var presentAlert = false
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var manager = TaptokDataManager()
    @State private var isValid = true
    @State var managerdata = DataPost()
    @FocusState var isInputActive2: Bool
    public init() {
        UIScrollView.appearance().alwaysBounceVertical = false
    }

    var body: some View {
        if managerdata.formCompleted {
                    Text("Done").font(.headline)
                }
        NavigationView {
            
            ZStack {
                Color("BgColor").edgesIgnoringSafeArea(.all)

                    VStack {
                        VStack{
                            Image("LoginBG")
                                .resizable()
                                .scaledToFill()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 400, height: 200)
                                .overlay(
                                    Image("Primary")
                                        .resizable()
                                        .frame(width: 302, height: 80, alignment: .center)
                                        .scaledToFit()
                                )
                            
                        }.onTapGesture {
                            if (focusedField != nil) {
                                            
                                focusedField = nil

                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Login to your \naccount")
                                .foregroundColor(Color.black)
                                .font(Font.custom("Poppins", size: 17.0))
                                .scaledToFit()
                                .padding(sides: [.left], value: 20)
                            
                            HStack {
                                Image("Iconly-Light-Message")
                                    .foregroundColor(.secondary)
                                TextField("Enter Your Email",
                                          text: $email)
                                .frame(height: 50)
                                .font(Font.custom("Poppins", size: 20.0))
                                .textContentType(.emailAddress)
                                .submitLabel(.return)
                                
                                .focused($focusedField, equals: .emailField)
  
                            }   .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(isValid ? Color.black : Color.red, lineWidth: 1))
                                .padding(.vertical)
                                .padding(sides: [.left , .right], value: 20)
                            
                            HStack {
                                Image("Icon feather-key")
                                    .foregroundColor(.secondary)
                                if showPassword {
                                    TextField("Enter Your Password",
                                              text: $Password)
                                    .font(Font.custom("Poppins", size: 20.0))
                                    .frame(height: 50)
                                    .focused($focusedField, equals: .passwordField)
                                    .textContentType(.password)
                                    .submitLabel(.send)
                               
                                } else {
                                    SecureField("Enter Your Password",
                                                text: $Password)
                                    .focused($focusedField, equals: .passwordField)
                                    .font(Font.custom("Poppins", size: 20.0))
                                    .frame(height: 50)
                                    .textContentType(.password)
                                    .submitLabel(.send)

                                }
                                Button(action: { self.showPassword.toggle()}) {
                                    
                                    Image(systemName: "eye")
                                        .foregroundColor(.secondary)
                                }
                            }   .padding()
                                .frame(maxWidth: .infinity)
                            
                                .background(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(isValid ? Color.black : Color.red, lineWidth: 1))
                                .padding(.vertical)
                                .padding(sides: [.left , .right], value: 20)
                                
                            
                            //Forgot your password?
                            HStack {
                                Spacer()
                                NavigationLink(
                                    destination:
                                    Forgot().navigationBarHidden(true))
                                {
                                    Text("Forgot your password?")
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(Color.black)
                                        .font(Font.custom("Poppins", size: 12.0))
                                        .scaledToFit()
                                        .padding(sides: [.right], value: 20)
                                        
                                    Image("CaretDown")
                                        .foregroundColor(.secondary)
                                        .padding(sides: [.right], value: 20)

                                }
                                .navigationBarHidden(true)
                                .onTapGesture {
                                    if (focusedField != nil) {
                                                    
                                        focusedField = nil

                                    }
                                }
                                
                                
                                
                            }
                         
                            HStack() {
                            Button(action: {
                                if email.isEmpty == true
                                {
                                    validation = "Enter your email"
                                    presentAlert = true
                                } else if !self.isValidEmail(email)
                                {
                                    validation = "Please enter valid email"
                                    presentAlert = true
                                    
                                }
                                else if Password.isEmpty == true
                                {
                                    validation = "Enter password"
                                    presentAlert = true
                                }else{
                                    self.showSpinner.toggle()
                                    self.managerdata.checkDetails(email: self.email , password: self.Password) { response in
                                        self.showSpinner = false
                                       
                                        guard let success = response["success"] else { return  }
                                        
                                        if success as! Bool == true {
                                            let data = response["data"] as! NSDictionary
                                           // print(data)
                                            UserDefaults.standard.set(data, forKey: "Userdata");
                                            let token: NSString = data["token"] as! NSString;
                                            let avatar: NSString = data["avatar"] as! NSString;
                                            let company_logo: NSString = data["company_logo"] as! NSString;
                                            let company_name: NSString = data["company_name"] as! NSString;
                                            let name: NSString = data["name"] as! NSString;
                                            let position: NSString = data["position"] as! NSString;
                                            let role: NSString = data["role"] as! NSString;
                                            UserDefaults.standard.set(avatar, forKey: "avatar");
                                            UserDefaults.standard.set(company_logo, forKey: "company_logo");
                                            UserDefaults.standard.set(company_name, forKey: "company_name");
                                            UserDefaults.standard.set(name, forKey: "name");
                                            UserDefaults.standard.set(position, forKey: "position");
                                            UserDefaults.standard.set(role, forKey: "role");
                                            let UserID: NSInteger = data["user_id"] as? NSInteger ?? 0
                                            UserDefaults.standard.set(token, forKey: "token");
                                            UserDefaults.standard.set(UserID, forKey: "user_id");
                                            SharedUser?.set(token, forKey: SharedUserDefults.Values.token)
                                            SharedUser?.set("YES", forKey: SharedUserDefults.Values.LOGIN)
                                            guard let sharetoken = SharedUser?.string(forKey: SharedUserDefults.Values.token) else {
                                                return
                                            }
                                            guard let LOGIN = SharedUser?.string(forKey: SharedUserDefults.Values.LOGIN) else {
                                                return
                                            }
                                           // print("sharetoken: \(sharetoken)")
                                           // print("LOGIN: \(LOGIN)")
                                            //print(UserDefaults.standard.integer(forKey: "user_id"))
                                            manager.selectedTab = .home
                                            UserDefaults.standard.set("YES", forKey: "LOGIN");
                                            self.showDashboard = true
                                            NotificationCenter.default.post(name: AppConfig.loginRootViewNotification, object: nil,userInfo: nil)
                                    
                                        }else{
                                            guard let message = response["message"] else { return  }
                                            validation = message as! String
                                            presentAlert = true
                                        }
                                    }
                                }
                                
                                
                            }, label: {
                                    Text("                       Sign in                       ")
                                        .font(.custom("Avenir-Heavy", size: 20))
                                        .padding(.top, 10)
                                        .padding(.bottom, 10)
                                        .padding(.leading, 16)
                                        .padding(.trailing, 16)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(8)
                                })
                                .frame(height: 47)
                                .foregroundColor(.white)
                                .background(
                                LinearGradient(
                                gradient: .init(colors: [Color("AccentLightColor"), Color("AccentColor")]),
                                startPoint: .top,
                                endPoint: .bottom))
                                .cornerRadius(8)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                                .padding(sides: [.left , .right], value: 20)
                                .buttonStyle(PlainButtonStyle())
                                
                            }
                            HStack {
                                Spacer()
                                NavigationLink(
                                    destination:
                                    SignuWebView().navigationBarHidden(true))
                                {
                                    Text("don’t have an account?")
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(Color.black)
                                        .font(Font.custom("Poppins", size: 12.0))
                                        .scaledToFit()
                                        .padding(sides: [.right], value: 20)

                                }
                                .navigationBarHidden(true)
                    
                            }
 
                        }        .onSubmit {
                            switch focusedField {
                            case .emailField:
                                focusedField = .passwordField
                            default:
                                validateAllFields()
                            }
                        }
    
                    }
                    .padding()
                    .alert("TaptopDev", isPresented: $presentAlert, actions: {
                          Button("OK") {
                              
                          }
                        }, message: {
                          Text(validation)
                        })
                    
                if model != nil {
                    NavigationLink(destination: ShowAppClipPages().environmentObject(model!).navigationBarHidden(true), isActive: $showAppClipPage) {
                        
                    }
                }
                LoadingView(isLoading: $showSpinner)
                

            }.navigationBarHidden(true)
                .onTapGesture {
                    if (focusedField != nil) {
                                    
                       // focusedField = nil

                    }
                }
            
        }
        .onAppear() {
            showDashboard = false
            NotificationCenter.default.addObserver(forName: AppConfig.URLNotification, object: nil, queue: nil, using: { notification in
                let notificationURL = notification.object as? URL
                            showAppClipPage = true
                showAppClipURL = notificationURL!
                model = WebViewModel(requestURL: showAppClipURL!)
                model?.isAppClip = true
                model?.loadUrl(Method: "GET", contactID: nil)
                
               
            })
        }

    }
    // #  MARK Validition In Email id
    func isValidEmail(_ email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func validateAllFields(){
        if email.isEmpty == true
        {
            validation = "Enter your email"
            presentAlert = true
        } else if !self.isValidEmail(email)
        {
            validation = "Please enter valid email"
            presentAlert = true
            
        }
        else if Password.isEmpty == true
        {
            validation = "Enter password"
            presentAlert = true
        }else{
            self.showSpinner.toggle()
            self.managerdata.checkDetails(email: self.email , password: self.Password) { response in
                self.showSpinner = false
               
                guard let success = response["success"] else { return  }
                
                if success as! Bool == true {
                    let data = response["data"] as! NSDictionary
                    //print(data)
                    UserDefaults.standard.set(data, forKey: "Userdata");
                    UserDefaults.standard.set("YES", forKey: "LOGIN");
                    let token: NSString = data["token"] as! NSString;
                    let avatar: NSString = data["avatar"] as! NSString;
                    let company_logo: NSString = data["company_logo"] as! NSString;
                    let company_name: NSString = data["company_name"] as! NSString;
                    let name: NSString = data["name"] as! NSString;
                    let position: NSString = data["role"] as! NSString;
                    let role: NSString = data["role"] as! NSString;
                   
                    let UserID: NSInteger = data["user_id"] as? NSInteger ?? 0
                    
                    UserDefaults.standard.set(avatar, forKey: "avatar");
                    UserDefaults.standard.set(company_logo, forKey: "company_logo");
                    UserDefaults.standard.set(company_name, forKey: "company_name");
                    UserDefaults.standard.set(name, forKey: "name");
                    UserDefaults.standard.set(position, forKey: "position");
                    UserDefaults.standard.set(role, forKey: "role");
                    
                    UserDefaults.standard.set(token, forKey: "token");
                    UserDefaults.standard.set(UserID, forKey: "user_id");
                    guard let sharedUserDefaults = UserDefaults(suiteName: "group.NT69LV86A5.dev.taptok.Taptok") else {
                        // Error handling
                        return
                    }
                    sharedUserDefaults.set(token, forKey: "token")
                    sharedUserDefaults.set("YES", forKey: "LOGIN");
                    sharedUserDefaults.synchronize()
                   // print(UserDefaults.standard.integer(forKey: "user_id"))
                    self.showDashboard = true
                    NotificationCenter.default.post(name: AppConfig.loginRootViewNotification, object: nil,userInfo: nil)

                }else{
                    guard let message = response["message"] else { return  }
                    validation = message as! String
                    presentAlert = true
                }
                //print(response)
            }
        }
    }
    
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

class DataPost: ObservableObject {
    var didChange = PassthroughSubject<DataPost, Never>()
    @State var SharedUser = UserDefaults(suiteName: SharedUserDefults.suiteName)
    var formCompleted = false {
        didSet {
            didChange.send(self)
        }
    }
    
    func checkDetails(email: String, password: String, completion:@escaping ([String : Any]) -> ()) {
        
        let body: [String: Any] = ["email": email, "password": password]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        
        //  "https://flaskcontact-list-app.herokuapp.com/contacts"
        let url = URL(string: "\(AppConfig.DevURL)/api/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpCookieAcceptPolicy = .never
     
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            let all_cookies =  URLSession.shared.configuration.httpCookieStorage?.cookies
            var cookieArray = [[HTTPCookiePropertyKey: Any]]()
            if let cookies = all_cookies {
                let cookie = HTTPCookie(properties: [
                    .domain: cookies[0].domain,
                    .path: cookies[0].path,
                    .name: "mobile_agent",
                    .value: "TT_APP",
                    .secure: "TRUE",
                    .expires: NSDate(timeIntervalSinceNow: 31556926)
                ])!
                URLSession.shared.configuration.httpCookieStorage?.setCookie(cookie)
                HTTPCookieStorage.shared.setCookie(cookie)
                cookieArray.append(cookie.properties!)
                
            }
          
            
//            guard let cookiesKey = self.SharedUser?.string(forKey: SharedUserDefults.Values.cookiesKey) else {
//                return
//            }
//            print("cookiesKey: \(cookiesKey)")

            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }

            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        
            if let responseJSON = responseJSON as? [String: Any] {
            

                DispatchQueue.main.async(execute: {
  
                        completion(responseJSON)

                })
                
            }
        }
        
        task.resume()
    }
}
struct SignInScreenView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            SignInScreenView().environmentObject(TaptokDataManager()).environment(\.colorScheme, .light)
        }
    }
}
enum Side: Equatable, Hashable {
    case left
    case right
}

extension View {
    func padding(sides: [Side], value: CGFloat = 8) -> some View {
        HStack(spacing: 0) {
            if sides.contains(.left) {
                Spacer().frame(width: value)
            }
            self
            if sides.contains(.right) {
                Spacer().frame(width: value)
            }
        }
    }
}

func createTask(){
    
}

fileprivate extension LinearGradient {
    static let actionButton = LinearGradient(gradient: Gradient(colors: [Color(Color.blue as! CGColor), Color(Color.black as! CGColor)]),startPoint: .topLeading,
                                            endPoint: .bottomTrailing)
}

struct SocialLoginButton: View {
    var image: Image
    var text: Text
    var body: some View {
        HStack {
            image
                .padding(.horizontal)
            Spacer()
            
            text
                .font(.title2)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(50.0)
        .shadow(color: Color.black.opacity(0.08), radius: 60, x: 0.0, y: 16)
    }
}
