import UIKit
import WebKit

class PlanDetailsVC: ChildViewController {

    @IBOutlet weak var _discriptionText: UILabel!
    @IBOutlet weak var _subTitle: UILabel!
    @IBOutlet weak var _discountText: UILabel!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _bottomViewTitle: UILabel!
    @IBOutlet private weak var _priceLabel: UILabel!
    @IBOutlet private weak var _timeLabel: UILabel!
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
//    @IBOutlet private weak var _webView: WKWebView!
    private var _url: String = kEmptyString
    var membershipDetail: MembershipPackageModel? = APPSETTING.membershipPackage?.first
    private let kCellIdentifier = String(String(describing: FeaturesTableCell.self))

    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
        _requestDetail()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        hideNavigationBar()
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "Somthing wrong..!",
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: nil,
            delegate: self)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: FeaturesTableCell.self, kCellHeightKey: FeaturesTableCell.height]]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        _titleLabel.text = membershipDetail?.title
        _bottomViewTitle.text = membershipDetail?.title
        _subTitle.text = membershipDetail?.subTitle
        _discountText.text = membershipDetail?.discountText
        _priceLabel.text = "D\(membershipDetail?.actualPrice ?? 0)"
        _timeLabel.text = "/ \(membershipDetail?.time ?? kEmptyString)"
        _discriptionText.text = membershipDetail?.descriptions
        guard let feature = membershipDetail?.feature else { return }
        feature.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: FeaturesTableCell.self,
                kCellHeightKey: FeaturesTableCell.height
            ])
        })
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestDetail() {
        guard let id = membershipDetail?.id else { return }
        showHUD()
        WhosinServices.membershipDetail(id: id) { [weak self]container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else {  return }
            self.membershipDetail = data
            _loadData()
        }
    }

    
    private func _openEditProfile() {
        confirmAlert(message: "Please complete your profile for purchase subscription.", okHandler: { [weak self] action in
            let vc = INIT_CONTROLLER_XIB(EditProfileVC.self)
            self?.navigationController?.pushViewController(vc, animated: true)
        }) { [weak self] action in
            self?.dismiss(animated: true)
        }
        
    }
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleBackEvent(_ sender: UIButton) {
        if self.presentingViewController != nil {
            dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func _handleBuyNowEvent(_ sender: UIButton) {
        if APPSESSION.userDetail?.requiredFields() == true || APPSESSION.userDetail?.isEmailVerified == 0 {
            _openEditProfile()
        } else {
            let vc = INIT_CONTROLLER_XIB(SubscriptionPurchaseVC.self)
            vc.membershipDetail = membershipDetail
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func _handleTermsEvent(_ sender: UIButton) {
        guard let termsAndCondition = membershipDetail?.termsAndCondition else { return }
        let vc = INIT_CONTROLLER_XIB(DeclaimerBottomSheet.self)
        vc.disclaimerTitle = "terms_condition".localized()
        vc.disclaimerdescriptions = Utils.convertHTMLToPlainText(from: termsAndCondition) ?? kEmptyString
        presentAsPanModal(controller: vc)
    }
}

extension PlanDetailsVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? FeaturesTableCell, let object = cellDict?[kCellObjectDataKey] as? CommonSettingsModel else { return}
        cell.setup(object.icon, title: object.feature)
    }
}

extension PlanDetailsVC: openSuccessDelegate {
    func openpurchaseSuccessDialogue() {
        let vc = INIT_CONTROLLER_XIB(PurchasePlanPopUpVC.self)
        vc.subscription = membershipDetail
        let navController = NavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .overFullScreen
        self.present(navController, animated: true)
    }
    
}

