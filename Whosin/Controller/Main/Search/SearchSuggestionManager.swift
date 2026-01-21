import UIKit
import Alamofire

class SearchSuggestionManager: NSObject {
    
    private weak var searchBar: UISearchBar?
    private weak var parentView: UIView?
    
    private let tableView = UITableView()
    private var filteredSuggestions: [String] = []
    private var currentTask: DataRequest?
    private let loader = UIActivityIndicatorView(style: .medium)
    private var debounceTimer: Timer?
    private var latestSearchKeyword: String = ""
    
    var onSuggestionSelected: ((String) -> Void)?
    
    init(searchBar: UISearchBar, in parentView: UIView) {
        super.init()
        self.searchBar = searchBar
        self.parentView = parentView
        setupTableView()
    }
    
    private func setupTableView() {
        guard let parentView = parentView else { return }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.cornerRadius = 8
        tableView.keyboardDismissMode = .onDrag
        
        loader.hidesWhenStopped = true
        loader.color = .gray
        tableView.backgroundView = loader
        
        parentView.addSubview(tableView)
    }
    
    private func updateDropdownFrame() {
        guard let searchBar = searchBar,
              let parent = parentView,
              let convertedFrame = searchBar.superview?.convert(searchBar.frame, to: parent) else { return }
        
        let height = CGFloat(min(5, max(filteredSuggestions.count, 1))) * 44
        tableView.frame = CGRect(x: convertedFrame.minX,
                                 y: convertedFrame.maxY,
                                 width: convertedFrame.width,
                                 height: height)
    }
    
    private func showDropdown() {
        updateDropdownFrame()
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    public func hideDropdown() {
        currentTask?.cancel()
        debounceTimer?.invalidate()
        filteredSuggestions.removeAll()
        loader.stopAnimating()
        tableView.isHidden = true
    }
    
    public func updateSearchText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        latestSearchKeyword = trimmed
        
        debounceTimer?.invalidate()
        
        guard !trimmed.isEmpty else {
            hideDropdown()
            return
        }
        
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
            self?.performSearch(trimmed)
        }
    }
    
    private func performSearch(_ keyword: String) {
        currentTask?.cancel()
        filteredSuggestions.removeAll()
        loader.startAnimating()
        tableView.backgroundView = loader
        showDropdown()
        
        let currentKeyword = keyword
        currentTask = WhosinServices.requestSearchSuggestion(search: currentKeyword) { [weak self] container, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard self.searchBar?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == currentKeyword else {
                    return
                }
                
                if let data = container?.data, !data.isEmpty {
                    self.loader.stopAnimating()
                    self.filteredSuggestions = data
                    self.showDropdown()
                } else {
                    self.filteredSuggestions = []
                    self.hideDropdown()
                }
            }
        }
    }
    
    public func dismiss() {
        hideDropdown()
    }
}

extension SearchSuggestionManager: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        guard indexPath.row < filteredSuggestions.count else { return cell }
        cell.textLabel?.text = filteredSuggestions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < filteredSuggestions.count else { return }
        let selectedText = filteredSuggestions[indexPath.row]
        searchBar?.text = selectedText
        hideDropdown()
        searchBar?.resignFirstResponder()
        onSuggestionSelected?(selectedText)
    }
}
