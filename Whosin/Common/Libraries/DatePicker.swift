import UIKit

class DatePicker: UIView {
    
    var changeClosure: ((Date)->())?
    var dismissClosure: (()->())?
    
    let dPicker: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .date
        
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() -> Void {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        if let maxDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()) {
            dPicker.maximumDate = maxDate
        }

//        dPicker.maximumDate = Date()
        let pickerHolderView: UIView = {
            let v = UIView()
            v.backgroundColor = .white.withAlphaComponent(0.13)
            v.layer.cornerRadius = 8
            return v
        }()
        
        let doneButton: UIButton = {
            let button = UIButton(type: .custom)
            button.titleLabel?.font = FontBrand.SFboldFont(size: 20)
            button.setTitleColor( .link, for: .normal)
            button.setTitle("Done", for: .normal)
            button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
            return button
        }()
        
        [blurredEffectView, pickerHolderView, dPicker, doneButton].forEach { v in
              v.translatesAutoresizingMaskIntoConstraints = false
          }
        
        addSubview(blurredEffectView)
        pickerHolderView.addSubview(dPicker)
        pickerHolderView.addSubview(doneButton)
        addSubview(pickerHolderView)
        
        NSLayoutConstraint.activate([
            
            blurredEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurredEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurredEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurredEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            pickerHolderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
            pickerHolderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
            pickerHolderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            dPicker.topAnchor.constraint(equalTo: pickerHolderView.topAnchor, constant: 20.0),
            dPicker.leadingAnchor.constraint(equalTo: pickerHolderView.leadingAnchor, constant: 20.0),
            dPicker.trailingAnchor.constraint(equalTo: pickerHolderView.trailingAnchor, constant: -20.0),
            
            doneButton.topAnchor.constraint(equalTo: dPicker.bottomAnchor, constant: 10.0),
            doneButton.centerXAnchor.constraint(equalTo: pickerHolderView.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: pickerHolderView.bottomAnchor, constant: -10.0),
            
        ])
        
        if #available(iOS 14.0, *) {
            dPicker.preferredDatePickerStyle = .inline
        } else {
            // use default
        }

        dPicker.addTarget(self, action: #selector(didChangeDate(_:)), for: .valueChanged)
        
        let t = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        blurredEffectView.addGestureRecognizer(t)
    }
    
    @objc func didTapDone() {
        dismissClosure?()
    }
    
    @objc func tapHandler(_ g: UITapGestureRecognizer) -> Void {
        dismissClosure?()
    }
    
    @objc func didChangeDate(_ sender: UIDatePicker) -> Void {
        changeClosure?(sender.date)
    }
}
