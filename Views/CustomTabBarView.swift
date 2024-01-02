//
//  CustomTabBarView.swift
// 
//
//  Created by Apps4World on 9/29/21.
//

import SwiftUI

/// Custom tab bar item
enum CustomTabBarItem: Identifiable {
    case home, settings
    var id: Int { hashValue }
    var icon: String {
        self == .home ? "house" : "gearshape"
    }
}

/// Custom bottom tab bar view
struct CustomTabBarView: View {
    
    @EnvironmentObject var manager: TaptokDataManager
    static let height: CGFloat = 160
    private let cameraButtonSize: CGFloat = 70
    
    // MARK: - Main rendering function
    var body: some View {
        VStack(spacing: -35) {
            Button(action: {
                UIImpactFeedbackGenerator().impactOccurred()
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .compactMap({$0 as? UIWindowScene})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first

                if var topController = keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    topController.present(manager.documentCameraViewController(), animated: true, completion: nil)
                }
         
            }, label: {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color("AccentLightColor"), Color.accentColor]), startPoint: .topLeading, endPoint: .bottom).mask(Circle())
                        .frame(width: cameraButtonSize, height: cameraButtonSize, alignment: .center)
                        .foregroundColor(.accentColor)
                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                        .foregroundColor(.white).font(.system(size: 35))
                    Image("ScanIc")
                        .foregroundColor(.white).font(.system(size: 35))
                }
            })
            
            ZStack {
                /// TabBar shape view
                CustomTabBarShape()
                    .frame(height: CustomTabBarView.height - cameraButtonSize)
                    .foregroundColor(Color("TabBarColor"))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, y: -5)
                /// TabBar items
                HStack {
                    Spacer()
                    Button(action: {
                        UIImpactFeedbackGenerator().impactOccurred()

                       
                        NotificationCenter.default.post(name: NSNotification.Name("HomeTapped"), object: nil,userInfo: nil)
                        manager.selectedTab = .home

                    }, label: {
                        Image(systemName: CustomTabBarItem.home.icon + (manager.selectedTab == .home ? ".fill" : ""))
                    })
                    Spacer()
                    Spacer()
                    Button(action: {
                        UIImpactFeedbackGenerator().impactOccurred()
                        NotificationCenter.default.post(name: NSNotification.Name("settingsTapped"), object: nil,userInfo: nil)

                        manager.selectedTab = .settings
                    }, label: {
                        Image(systemName: CustomTabBarItem.settings.icon + (manager.selectedTab == .settings ? ".fill" : ""))
                    })
                    Spacer()
                }
                .font(.system(size: 26)).padding(.bottom)
                .foregroundColor(Color("LightGrayColor"))
            }
        }
    }
}

// MARK: - Preview UI
struct CustomTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBarView()
            .previewLayout(.sizeThatFits)
            .environmentObject(TaptokDataManager())
    }
}

// MARK: - Tab Bar Custom shape
struct CustomTabBarShape: Shape {
    /// Create the path for a given rect
    /// - Parameter rect: rect
    /// - Returns: returns the path
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 40))
        path.addCurve(to: CGPoint(x: 40, y: 0),
                      controlPoint1: CGPoint(x: 0, y: 17.9),
                      controlPoint2: CGPoint(x: 17.9, y: 0))
        
        path.addLine(to: CGPoint(x: 93.8, y: 0))
        path.addLine(to: CGPoint(x: 135, y: 0))
        path.addCurve(to: CGPoint(x: 144, y: 7),
                      controlPoint1: CGPoint(x: 138.4, y: 0),
                      controlPoint2: CGPoint(x: 141.7, y: 2))
        
        path.addLine(to: CGPoint(x: 143.5, y: 5.2))
        path.addCurve(to: CGPoint(x: 230.1, y: 7.1),
                      controlPoint1: CGPoint(x: 187.5-35, y: 55),
                      controlPoint2: CGPoint(x: 187.5+35, y: 55))
        
        path.addLine(to: CGPoint(x: 231, y: 5))
        path.addCurve(to: CGPoint(x: 240, y: 0),
                      controlPoint1: CGPoint(x: 233.3, y: 1.8),
                      controlPoint2: CGPoint(x: 236.5, y: 0))
        
        path.addLine(to: CGPoint(x: 281.3, y: 0))
        path.addLine(to: CGPoint(x: 335, y: 0))
        path.addCurve(to: CGPoint(x: 375, y: 40),
                      controlPoint1: CGPoint(x: 357.1, y: 0),
                      controlPoint2: CGPoint(x: 375, y: 17.9))
        
        path.addLine(to: CGPoint(x: 375, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.close()
        return Path(path.cgPath).scaled(toFit: rect)
    }
}

extension Path {
    func scaled(toFit rect: CGRect) -> Path {
        let scaleW = rect.width/boundingRect.width
        return applying(CGAffineTransform(scaleX: scaleW, y: 1))
    }
}
