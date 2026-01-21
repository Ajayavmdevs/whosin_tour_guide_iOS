import UIKit
import Alamofire

class UpdatePreferencesVC: ChildViewController {
    
    @IBOutlet weak var _cuisineCollectionView: UICollectionView!
    @IBOutlet weak var _featureCollectionView: UICollectionView!
    @IBOutlet weak var _musicCollectionView: UICollectionView!
    @IBOutlet weak var _cuisineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var _featureHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var _musicHeightConstraint: NSLayoutConstraint!
    
    private var selectedCuisine : [String] = []
    private var selectedMusic : [String] = []
    private var selectedFeature : [String] = []
    private var params:[String:Any] = [:]

    private var cuisine : [CommonSettingsModel] = APPSETTING.cuisine
    private var music : [CommonSettingsModel] = APPSETTING.music
    private var feature : [CommonSettingsModel] = APPSETTING.feature
    
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _requestGetPreferences()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = _cuisineCollectionView.collectionViewLayout.collectionViewContentSize.height
        _cuisineHeightConstraint.constant = height
        
        let heightA = _featureCollectionView.collectionViewLayout.collectionViewContentSize.height
        _featureHeightConstraint.constant = heightA
        
        let heightB = _musicCollectionView.collectionViewLayout.collectionViewContentSize.height
        _musicHeightConstraint.constant = heightB
        
        _featureCollectionView.reloadData()
        _musicCollectionView.reloadData()
        _cuisineCollectionView.reloadData()

        self.view.layoutIfNeeded()
    }
    
    override func setupUi() {
        hideNavigationBar()
        
        setupCollectionView(_cuisineCollectionView)
        setupCollectionView(_featureCollectionView)
        setupCollectionView(_musicCollectionView)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupCollectionView(_ collectionView: UICollectionView){
        let musicTagsFlowLayout = TagsFlowLayout(alignment: .center)
        collectionView.collectionViewLayout = musicTagsFlowLayout
        collectionView.register(UINib(nibName: "TagViewCell", bundle: nil), forCellWithReuseIdentifier: "TagViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestUpdateProfile() {
        params["cuisine"] = selectedCuisine
        params["feature"] = selectedFeature
        params["music"] = selectedMusic
        showHUD()
        APPSESSION.updatePrefrences(param: params) { [weak self] isSuccess, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard isSuccess else { return }
            self.showToast("Update Prefrences!")
            DISPATCH_ASYNC_MAIN_AFTER(0.6) {
                self.dismiss(animated: true)
            }
        }
    }
    
    private func _requestGetPreferences() {
        WhosinServices.getUserPreferences { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.selectedMusic = data.music
            self.selectedFeature = data.features
            self.selectedCuisine = data.cuisine
            self.setupUi()
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    @IBAction func _handleUpdateEvent(_ sender: UIButton) {
        _requestUpdateProfile()
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
}


// ------------------------------
// MARK: TagListViewDelegate
// ------------------------------

extension UpdatePreferencesVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView ==  _musicCollectionView {
            return music.count
        }else if collectionView == _featureCollectionView {
            return feature.count
        } else {
            return cuisine.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagViewCell", for: indexPath) as! TagViewCell
        if collectionView ==  _musicCollectionView {
            let isSelected = selectedMusic.contains(music[indexPath.row].id)
            cell.setupData(music[indexPath.row], isSelected: isSelected)
            return cell
        }else if collectionView == _featureCollectionView {
            let isSelected = selectedFeature.contains(feature[indexPath.row].id)
            cell.setupData(feature[indexPath.row], isSelected: isSelected)
            return cell
        } else {
            let isSelected = selectedCuisine.contains(cuisine[indexPath.row].id)
            cell.setupData(cuisine[indexPath.row] , isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        if collectionView ==  _musicCollectionView {
            if let selectedIndex = selectedMusic.firstIndex(of: music[index].id) {
                selectedMusic.remove(at: selectedIndex)
            } else {
                if let selectedMusicItem = music.first(where: { $0.title == music[index].title }) {
                    selectedMusic.append(selectedMusicItem.id)
                }
            }
            _musicCollectionView.reloadData()
        }else if collectionView == _featureCollectionView {
            if let selectedIndex = selectedFeature.firstIndex(of: feature[index].id) {
                selectedFeature.remove(at: selectedIndex)
            } else {
                if let selectedFeatureItem = feature.first(where: { $0.title == feature[index].title }) {
                    selectedFeature.append(selectedFeatureItem.id)
                }
            }
            _featureCollectionView.reloadData()
        } else {
            if let selectedIndex = selectedCuisine.firstIndex(of: cuisine[index].id) {
                selectedCuisine.remove(at: selectedIndex)
            } else {
                if let selectedCuisineItem = cuisine.first(where: { $0.title == cuisine[index].title }) {
                    selectedCuisine.append(selectedCuisineItem.id)
                }
            }
            _cuisineCollectionView.reloadData()
        }
    }

}
