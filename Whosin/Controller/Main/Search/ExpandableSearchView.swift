import UIKit
import Alamofire

class ExpandableSearchView: UIView {

    var ondidChange: ((String) -> Void)?
    var onSearchPressed: ((String) -> Void)?
    var onHeightChanged: ((CGFloat) -> Void)?


    private let containerView = UIView()
    private let searchField = UITextField()
    private let tableView = UITableView()
    private var suggestions: [String] = []

    private var debounceTimer: Timer?
    private var currentTask: DataRequest?
    private var tableHeightConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear

        containerView.backgroundColor = ColorBrand.brandBottomSheetColor
        containerView.layer.cornerRadius = 18
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        searchField.backgroundColor = ColorBrand.brandBottomSheetColor
        tableView.backgroundColor = ColorBrand.brandBottomSheetColor
        tableView.backgroundView?.backgroundColor = ColorBrand.brandBottomSheetColor
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        containerView.layer.borderWidth = 1
        addSubview(containerView)

        searchField.placeholder = "where_do_you_want_to_go".localized()
        searchField.font = FontBrand.SFregularFont(size: 14)
        searchField.backgroundColor = ColorBrand.brandBottomSheetColor
        searchField.textColor = .white
        searchField.clearButtonMode = .always
        searchField.returnKeyType = .search
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        searchField.addTarget(self, action: #selector(textDidChange), for: .editingDidBegin)
        searchField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 30))
        searchField.leftViewMode = .always
        searchField.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SuggestionCell.self, forCellReuseIdentifier: "SuggestionCell")
        tableView.backgroundColor = ColorBrand.brandBottomSheetColor
        tableView.separatorStyle = .none
        tableView.rowHeight = 36
        tableView.isScrollEnabled = false
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundView = nil
        tableView.backgroundColor = ColorBrand.brandBottomSheetColor
        containerView.addSubview(searchField)
        containerView.addSubview(tableView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            searchField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            searchField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            searchField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            searchField.heightAnchor.constraint(equalToConstant: 30),

            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 6),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint.isActive = true

    }

    @objc private func textDidChange() {
        debounceTimer?.invalidate()
        ondidChange?(searchField.text ?? "")

        guard let text = searchField.text, !text.isEmpty else {
            suggestions.removeAll()
            reloadSuggestions()
            return
        }

        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            self?.performSearch(text)
        }
    }

    private func performSearch(_ keyword: String) {
        currentTask?.cancel()
        let currentKeyword = keyword
        self.suggestions = SEARCHSUGGESTION.get(for: currentKeyword)
        if !self.suggestions.isEmpty {
            self.reloadSuggestions()
        }

        currentTask = WhosinServices.requestSearchSuggestion(search: currentKeyword) { [weak self] container, error in
            guard let self = self else { return }
            if container == nil { return }
            DispatchQueue.main.async {
                guard self.searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == currentKeyword else { return }
                if let tmp = container?.data, !tmp.isEmpty {
                    SEARCHSUGGESTION.save(tmp, for: currentKeyword)
                    self.suggestions = tmp
                    self.reloadSuggestions()
                } else {
                    self.reloadSuggestions()
                }
            }
        }
    }

    private func reloadSuggestions() {
        tableView.reloadData()
        let visible = !suggestions.isEmpty
        tableView.isHidden = !visible
        let tableHeight = visible ? CGFloat(min(suggestions.count, 8)) * 36 : 0
        tableHeightConstraint.constant = tableHeight
        self.onHeightChanged?(tableHeight + 36)
        UIView.animate(withDuration: 0.05) {
            self.layoutIfNeeded()
        }
    }
    
    func set(_ text: String) {
        searchField.text = text
    }

    func clear() {
        searchField.text = ""
        suggestions.removeAll()
        reloadSuggestions()
        searchField.resignFirstResponder()
    }

    func resignSearch() {
        searchField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension ExpandableSearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return false
        }
        currentTask?.cancel()
        onSearchPressed?(text)
        textField.resignFirstResponder()
        self.suggestions = []
        self.reloadSuggestions()
        tableView.isHidden = true
        return true
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ExpandableSearchView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < suggestions.count else {
                return UITableViewCell() // return an empty cell if out of range
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath) as! SuggestionCell
        cell.configure(with: suggestions[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < suggestions.count else {
            return
        }
        let selected = suggestions[indexPath.row]
        searchField.text = selected
        onSearchPressed?(selected)
        searchField.resignFirstResponder()
        self.suggestions = []
        self.reloadSuggestions()
        tableView.isHidden = true
    }
}

class SuggestionCell: UITableViewCell {
    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = ColorBrand.brandBottomSheetColor
        contentView.backgroundColor = ColorBrand.brandBottomSheetColor
        selectionStyle = .none
        layer.cornerRadius = 24
        layer.masksToBounds = true

        label.font = FontBrand.SFregularFont(size: 14)
        label.textColor = ColorBrand.white
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        label.text = text
    }
}

