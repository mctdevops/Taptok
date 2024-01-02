//
//  Utility.swift
//  Spexal
//
//  Created by Pavan on 11/06/22.
//


import Foundation
import UIKit


private var startGradientColorAssociatedKey : UIColor = .black
private var endGradientColorAssociatedKey : UIColor = .black
private var observationGradientView: NSKeyValueObservation?

struct CurrentDevice {
    
    // iDevice detection code
    static let IS_IPAD               = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE             = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_RETINA             = UIScreen.main.scale >= 2.0
    
    static let SCREEN_WIDTH          = Int(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT         = Int(UIScreen.main.bounds.size.height)
    static let SCREEN_MAX_LENGTH     = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let SCREEN_MIN_LENGTH     = Int( min(SCREEN_WIDTH, SCREEN_HEIGHT) )
    
    static let IS_IPHONE_6_OR_HIGHER = IS_IPHONE && SCREEN_MAX_LENGTH  > 568
    static let IS_IPHONE_6           = IS_IPHONE && SCREEN_MAX_LENGTH == 667
    static let IS_IPHONE_6P          = IS_IPHONE && SCREEN_MAX_LENGTH == 736
    static let IS_IPHONE_X           = IS_IPHONE && SCREEN_MAX_LENGTH == 812
    static let IS_IPHONE_X_OR_HIGHER = IS_IPHONE && SCREEN_MAX_LENGTH  > 812
    static let IS_IPHONE_X_OR_LOWER  = IS_IPHONE && SCREEN_MAX_LENGTH  < 812
    
    static let IS_IPHONE_4_OR_LESS   = IS_IPHONE && SCREEN_MAX_LENGTH  < 568
    static let IS_IPHONE_5_OR_LESS   = IS_IPHONE && SCREEN_MAX_LENGTH <= 568
    
    // MARK: - Singletons
    static var ScreenWidth: CGFloat {
        struct Singleton {
            static let width = UIScreen.main.bounds.size.width
        }
        return Singleton.width
    }
    
    static var ScreenHeight: CGFloat {
        struct Singleton {
            static let height = UIScreen.main.bounds.size.height
        }
        return Singleton.height
    }
}


let BackgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
let appTheam = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

func hexStringToUIColor (hex:String) -> UIColor {
    
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
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

extension UITextField {
    func setRightView(image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20)) // set your Own size
        iconView.image = image
        
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        iconContainerView.addSubview(iconView)
        rightView = iconContainerView
        rightViewMode = .always
        iconView.contentMode = .scaleAspectFit
        
        self.tintColor = .lightGray
    }
    
    func setLeftView(image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20)) // set your Own size
        iconView.image = image
        
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
        iconView.contentMode = .scaleAspectFit
        
        self.tintColor = .lightGray
    }
    
    func setRightViewDropdown(image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 5, y: 0, width: 10, height: 10)) // set your Own size
        iconView.image = image
        
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        iconContainerView.addSubview(iconView)
        rightView = iconContainerView
        rightViewMode = .always
        iconView.contentMode = .scaleAspectFit
        
        self.tintColor = .lightGray
    }
    
    
    @IBInspectable var doneAccessory: Bool{
           get{
               return self.doneAccessory
           }
           set (hasDone) {
               if hasDone{
                   addDoneButtonOnKeyboard()
               }
           }
       }

       func addDoneButtonOnKeyboard()
       {
           let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
           doneToolbar.barStyle = .default

           let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
           let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

           let items = [flexSpace, done]
           doneToolbar.items = items
           doneToolbar.sizeToFit()

           self.inputAccessoryView = doneToolbar
       }

       @objc func doneButtonAction()
       {
           self.resignFirstResponder()
       }
    
    
}

extension UITextField{
func setCharacterSpacing(_ spacing: CGFloat){
    let attributedStr = NSMutableAttributedString(string: self.text ?? "")
    attributedStr.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSMakeRange(0, attributedStr.length))
    self.attributedText = attributedStr
 }
}

extension NSDictionary {
    func GotValue(key : String)-> NSString {
        if self[key] != nil {
            if((self["\(key)"] as? NSObject) != nil && (key .isEmpty) == false) {
                
                let obj_value = self["\(key)"] as? NSObject
                
                let str = NSString(format:"%@", obj_value!)
                
                if str == "<null>" || str == "undefined" {
                    return ""
                }
                return str
            }
        }
        return ""
    }
}

extension UINavigationController {
    func pop(animated: Bool) {
        _ = self.popViewController(animated: animated)
    }
    
    func popToRoot(animated: Bool) {
        _ = self.popToRootViewController(animated: animated)
    }
}
class Toast {
    
    static func show(message: String, controller: UIViewController) {
        
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = #colorLiteral(red: 0.3534786999, green: 0.3337596655, blue: 0.3043811321, alpha: 1)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 25;
        toastContainer.clipsToBounds  =  true
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font.withSize(10.0)
        toastLabel.text = message
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        controller.view.addSubview(toastContainer)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
        toastContainer.addConstraints([a1, a2, a3, a4])
        
        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1, constant: 65)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1, constant: -65)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1, constant: -95)
        controller.view.addConstraints([c1, c2, c3])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}

func shwoAlertControllerInViewController(vc: UIViewController, withTitle title: String?, andMessage message: String?, withButtons button: [String], completion:((_ index: Int) -> Void)!) -> Void
{
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    for index in 0 ..< button.count  {

        let action = UIAlertAction(title: button[index], style: .default, handler: { (alert: UIAlertAction!) in

            if completion != nil {
                completion(index)
            }
        })
        alertController.addAction(action)
    }
    vc.present(alertController, animated: true, completion: nil)
}



extension UIView {

    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue

            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }


    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
               shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
               shadowOpacity: Float = 0.3,
               shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
      @IBInspectable
      var borderWidth: CGFloat {
          get {
              return layer.borderWidth
          }
          set {
              layer.borderWidth = newValue
          }
      }
      
      @IBInspectable
      var borderColor: UIColor? {
          get {
              if let color = layer.borderColor {
                  return UIColor(cgColor: color)
              }
              return nil
          }
          set {
              if let color = newValue {
                  layer.borderColor = color.cgColor
              } else {
                  layer.borderColor = nil
              }
          }
      }
}



private let dateFormatter: DateFormatter = {
    let aDateFormatter = DateFormatter()
    
    aDateFormatter.timeZone = TimeZone(identifier: "UTC")
    aDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    return aDateFormatter
}()

func UTC_DF() -> DateFormatter {
    let dateFormatter = DateFormatter()
    if let time = NSTimeZone(name: "UTC") {
        dateFormatter.timeZone = time as TimeZone
    }
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

    return dateFormatter
}

func Show_DF() -> DateFormatter {

    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "hh:mm aa"

    return dateFormatter
}

func utcToLocal(date: Date) -> Date? {
    return date.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
}

extension UIView {


@IBInspectable var startGradientColor: UIColor {
    get {
        if let color = objc_getAssociatedObject(self, &startGradientColorAssociatedKey) as? UIColor {
            return color
        } else {
            return .black
        }
    } set {
        objc_setAssociatedObject(self, &startGradientColorAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN)
    }
}

@IBInspectable var endGradientColor: UIColor {
    get {
        if let color = objc_getAssociatedObject(self, &endGradientColorAssociatedKey) as? UIColor {
            return color
        } else {
            return .black
        }
    } set {
        objc_setAssociatedObject(self, &endGradientColorAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN)
    }
}


@IBInspectable
var isTopToBottomGradient: Bool {
    get {
        return self.isTopToBottomGradient
    }
    set {
        DispatchQueue.main.async {
            if newValue {
                self.setGradientBackground(colorLeft: self.startGradientColor, colorRight: self.endGradientColor)
                
            } else {
                self.setGradientBackground(colorLeft: self.startGradientColor, colorRight: self.endGradientColor)
            }
        }
    }
}


func setGradientBackground(colorLeft: UIColor, colorRight: UIColor) {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [colorLeft.cgColor, colorRight.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
    
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    gradientLayer.locations = [0, 1]
    gradientLayer.frame = bounds
    
    
    observationGradientView = self.observe(\.bounds, options: .new) { [weak gradientLayer] view, change in
        if let value =  change.newValue {
            gradientLayer?.frame = value
        }
    }
    
    layer.insertSublayer(gradientLayer, at: 0)
}
}


class TriangleView : UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()

        context.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.60)
        context.fillPath()
    }
}

class PentagonView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        let size = self.bounds.size
        let h = size.height //* 0.85      // adjust the multiplier to taste

        // calculate the 5 points of the pentagon
        let p1 = CGPoint(x: 10, y: 0)//self.bounds.origin
        let p2 = CGPoint(x: size.width - 20, y:p1.y)
        let p3 = CGPoint(x:0, y: h)
        let p4 = CGPoint(x:size.width, y:size.height)
       // let p5 = CGPoint(x:p1.x, y:h)

        // create the path
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.addLine(to: p4)
     //   path.addLine(to: p5)
        path.close()

        // fill the path
        UIColor.black.set()
        path.fill()
    }
}

extension UIImageView {
    func setImageFromUrl(ImageURL :String) {
       URLSession.shared.dataTask( with: NSURL(string:ImageURL)! as URL, completionHandler: {
          (data, response, error) -> Void in
          DispatchQueue.main.async {
             if let data = data {
                self.image = UIImage(data: data)
             }
          }
       }).resume()
    }
}
