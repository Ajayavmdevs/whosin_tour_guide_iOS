import UIKit

class TimeDailogView: UIView {
    
    var openLabel: UILabel = UILabel()
    var closeLabel: UILabel = UILabel()
    var _timeDetail : [TimingModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self.setupView()
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public func setupView() {
        let width = (self.superview?.bounds.width ?? 300) / 3
        openLabel.frame = CGRect(x: width, y: 8, width: width, height: 30)
        openLabel.textAlignment = NSTextAlignment.center
        openLabel.text = "opening".localized()
        openLabel.textColor = UIColor.green
        openLabel.font = FontBrand.SFregularFont(size: 16)
        self.addSubview(openLabel)
        
        closeLabel.frame = CGRect(x: width * 2, y: 8, width: width, height: 30)
        closeLabel.textAlignment = NSTextAlignment.center
        closeLabel.text = "closing".localized()
        closeLabel.textColor = .red
        closeLabel.font = FontBrand.SFregularFont(size: 16)
        self.addSubview(closeLabel)
        
        var yPosition = 40
        _timeDetail.forEach({ model in
            
            let dayLabel: UILabel = UILabel()
            dayLabel.frame = CGRect(x: 16, y: yPosition, width: Int(width) - 16, height: 30)
            dayLabel.textAlignment = NSTextAlignment.left
            dayLabel.text = model.day.prefix(1).capitalized + model.day.dropFirst() //model.day
            dayLabel.textColor = ColorBrand.white
            dayLabel.font = FontBrand.SFregularFont(size: 16)
            self.addSubview(dayLabel)
            
            let startTimeLabel: UILabel = UILabel()
            startTimeLabel.frame = CGRect(x: width, y: CGFloat(yPosition), width: width, height: 30)
            startTimeLabel.textAlignment = NSTextAlignment.center
            startTimeLabel.text = "\(model.`openingTime`)"
            startTimeLabel.textColor = UIColor.secondaryLabel
            startTimeLabel.font = FontBrand.SFregularFont(size: 16)
            self.addSubview(startTimeLabel)
            
            let endTimeLabel: UILabel = UILabel()
            endTimeLabel.frame = CGRect(x: width * 2, y: CGFloat(yPosition), width: width, height: 30)
            endTimeLabel.textAlignment = NSTextAlignment.center
            endTimeLabel.text = "\(model.closingTime)"
            endTimeLabel.textColor = UIColor.secondaryLabel
            endTimeLabel.font = FontBrand.SFregularFont(size: 16)
            self.addSubview(endTimeLabel)
            
            yPosition += 30
        })
                
    }
}
