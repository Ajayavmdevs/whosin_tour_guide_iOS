import UIKit

class AvailbleTimeSlotesCell: UICollectionViewCell {

    @IBOutlet weak var _fromText: UITextField!
    @IBOutlet weak var _tillText: UITextField!
    public var timeSlotCallback: ((_ slot: TimeSlot) -> Void)?
    private var fromTime: String?
    private var tillTime: String?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 30 }
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _fromText.delegate = self
        _tillText.delegate = self
        let fromTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFromTime))
        let tillTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTillTime))
        _fromText.addGestureRecognizer(fromTapGesture)
        _fromText.isUserInteractionEnabled = true
        _tillText.addGestureRecognizer(tillTapGesture)
        _tillText.isUserInteractionEnabled = true
    }
    
    @objc func handleFromTime() {
        showTimePicker { selectedTime in
            self._fromText.text = Utils.dateToString(selectedTime, format: "dd/MM/yyyy")
            self.fromTime = Utils.dateToString(selectedTime, format: kFormatDate)
            self.checkAndCallback()
        }
    }
    
    @objc func handleTillTime() {
        showTimePicker { selectedTime in
            self._tillText.text = Utils.dateToString(selectedTime, format: "dd/MM/yyyy")
            self.tillTime = Utils.dateToString(selectedTime, format: kFormatDate)
            self.checkAndCallback()
        }
    }
    
    private func checkAndCallback() {
        if let from = fromTime, let till = tillTime {
            let timeSlot = TimeSlot(fromDate: from, tillDate: till)
            timeSlotCallback?(timeSlot)
        }
    }

    private func showTimePicker(completion: @escaping (Date) -> Void) {
        let alertController = UIAlertController(title: "select_time".localized(), message: nil, preferredStyle: .actionSheet)

        let datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date

        alertController.view.addSubview(datePicker)

        let okAction = UIAlertAction(title: "ok".localized(), style: .default) { _ in
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            completion(datePicker.date)
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.heightAnchor.constraint(equalToConstant: 300).isActive = true

        datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 10).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -10).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -100).isActive = true
        parentViewController?.present(alertController, animated: true, completion: nil)
    }

    

}

extension AvailbleTimeSlotesCell: UITextFieldDelegate {
    
}
