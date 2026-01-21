import Foundation
import UIKit

extension UITextField {
    
    @IBInspectable var placeholderColor: UIColor {
        get {
            return value(forKeyPath: "_placeholderLabel.textColor") as! UIColor
        }set {
            let iVar = class_getInstanceVariable(UITextField.self, "_placeholderLabel")!
            let placeholderLabel = object_getIvar(self, iVar) as? UILabel
            placeholderLabel?.textColor = newValue
        }
    }
    
    @IBInspectable var localizedText: String {
        set(value) { self.text = (value) }
        get { return kEmptyString }
    }
    
    @IBInspectable var localizedPlaceholderText: String {
        set(value) { self.placeholder = value.localized() }
        get { return kEmptyString }
    }
    
    func addRightImageTextField(imgName: String) {
        rightViewMode = .always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(named: imgName)
        imageView.image = image
        rightView = imageView
    }
    
    func setRightImage(withColor: UIColor = UIColor.black, imgName: String)  {
        let eyeBtn = UIButton.init(type: .system)
        eyeBtn.frame = CGRect(x: -10, y: 0, width: 30, height: 20)
        eyeBtn.tag = 0
        eyeBtn.setImage(UIImage(named: imgName), for: .normal)
        eyeBtn.imageView?.contentMode = .scaleAspectFit
        eyeBtn.tintColor = withColor

        let eyeContainerView: UIView = UIView(frame:
            CGRect(x: -10, y: 0, width: 30, height: 20))
        eyeContainerView.addSubview(eyeBtn)
        rightView = eyeContainerView
        rightViewMode = .always
    }
    
    func setRightEyeButton(withColor: UIColor = UIColor.black)  {
        let eyeBtn = UIButton.init(type: .system)
        eyeBtn.frame = CGRect(x: -10, y: 0, width: 24, height: 15)
        eyeBtn.tag = 0
        eyeBtn.setImage(UIImage(named: "icon_eye"), for: .normal)
        eyeBtn.addTarget(self, action: #selector(actionOnEye), for: .touchUpInside)
        eyeBtn.imageView?.contentMode = .scaleAspectFit
        eyeBtn.tintColor = withColor

        let eyeContainerView: UIView = UIView(frame:
            CGRect(x: -10, y: 0, width: 30, height: 15))
        eyeContainerView.addSubview(eyeBtn)
        rightView = eyeContainerView
        rightViewMode = .always
    }
    
    @objc func actionOnEye(button:UIButton) {
        if !isSecureTextEntry {
            isSecureTextEntry = true
            button.setImage(UIImage.init(named: "eye show.png"), for: .normal)

        } else {
            isSecureTextEntry = false
            button.setImage(UIImage.init(named: "eye hide.png"), for: .normal)
        }
    }
}
