import UIKit

class EventHighlightsCell: UITableViewCell {
    
    @IBOutlet weak var _chattextView: UIView!
    @IBOutlet private weak var _msgTextField: LeftSpaceTextField!
    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: HighlightsCell.self)
    private var event: EventModel?
    private var users: [UserDetailModel] = []
    private var highLightsList: HighlightsListModel?
    private let chatRepository = ChatRepository()
    private var _msgList: [MessageModel] = []

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMsgNotification(_:)), name: kMessageNotification, object: nil)
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    @objc func handleNewMsgNotification(_ notification: Notification) {
        if let chatId = notification.userInfo?["chatId"] as? String {
            guard let _event = event else { return }
            if chatId == _event.id {
                getChatMessage()
            }
        }
    }
    
    private func setupUi() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openChat(_:)))
            _chattextView.addGestureRecognizer(tap)
        
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: nil,
            emptyDataDescription: nil,
            delegate: self)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: HighlightsCell.self, kCellHeightKey: HighlightsCell.height]]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _msgList.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: HighlightsCell.self,
                kCellHeightKey: HighlightsCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    private func getChatMessage() {
        guard let chatId = event?.id else { return }
        chatRepository.getChatMessages(chatId: chatId) { [weak self] container  in
            guard let self = self else { return }
            guard let data = container else { return }
            self._msgList.removeAll()
            data.forEach { o in
                let tmp = o.detached()
                self._msgList.append(tmp)
            }
            if self._tableView.contentOffset.y <= 10 {
                self._tableView.reloadData()
            }
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: EventModel, userModel: [UserDetailModel] = []) {
        users = userModel
        event = model
        getChatMessage()
    }
    
    func _openChat(_ chatModel: ChatModel, chatType: ChatType = .user) {
        let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
        vc.chatModel = chatModel
        vc.chatType = chatType
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openChat(_ g: UITapGestureRecognizer) -> Void {
        if !Utils.isDateExpired(dateString: event?.eventTime, format: kStanderdDate) {
            parentBaseController?.feedbackGenerator?.impactOccurred()
            if let _event = event {
                let _tmpChatModel = ChatModel(_event: _event)
                _openChat(_tmpChatModel, chatType: .event)
            }
        }
      }
    
    @IBAction private func _handleViewAllEvent(_ sender: UIButton) {
        if !Utils.isDateExpired(dateString: event?.eventTime, format: kStanderdDate) {
            parentBaseController?.feedbackGenerator?.impactOccurred()
            if let _event = event {
                let _tmpChatModel = ChatModel(_event: _event)
                _openChat(_tmpChatModel, chatType: .event)
            }
        }
    }
    
    @IBAction private func _handleSendHighlightsEvent(_ sender: UIButton) {
        if !Utils.isDateExpired(dateString: event?.eventTime, format: kStanderdDate) {
            parentBaseController?.feedbackGenerator?.impactOccurred()
            if let _event = event {
                let _tmpChatModel = ChatModel(_event: _event)
                _openChat(_tmpChatModel, chatType: .event)
            }
        }
    }
}

extension EventHighlightsCell: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? HighlightsCell {
            guard let object = cellDict?[kCellObjectDataKey] as? MessageModel else { return }
            cell.setupMessageData(object)
        }
    }
    
}
