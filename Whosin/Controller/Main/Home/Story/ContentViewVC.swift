import UIKit
import Hero

var contentVC = ContentViewVC()

protocol PresentedViewControllerDelegate: AnyObject {
    func presentedViewControllerWillDismiss()
}


class ContentViewVC: ChildViewController {
    
    var pageViewController : UIPageViewController?
    var pages: [VenueDetailModel] = []
    var currentIndex : Int = 0
    weak var delegate: PresentedViewControllerDelegate?
    var isTapInProgress = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func setupUi() {
        contentVC = self
        pageViewController = INIT_CONTROLLER_XIB(PageViewController.self)
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        
        let startingViewController: StoryPerivewVC = viewControllerAtIndex(index: currentIndex) ?? StoryPerivewVC()
        let viewControllers = [startingViewController]
        pageViewController!.setViewControllers(viewControllers , direction: .forward, animated: false, completion: nil)
        pageViewController!.view.frame = view.bounds
        
        addChild(pageViewController!)
        view.addSubview(pageViewController!.view)
        view.sendSubviewToBack(pageViewController!.view)
        pageViewController!.didMove(toParent: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func viewControllerAtIndex(index: Int) -> StoryPerivewVC? {
        if pages.count == 0 || index >= pages.count {
            return nil
        }
        let vc = INIT_CONTROLLER_XIB(StoryPerivewVC.self)
        vc.pageIndex = index
        vc.items = pages
        currentIndex = index
        return vc
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func goNextPage(fowardTo position: Int) {
        if let startingViewController = viewControllerAtIndex(index: position) {
            let viewControllers = [startingViewController]
            pageViewController!.setViewControllers(viewControllers , direction: .forward, animated: true, completion: nil)
        }
    }
    
    func goPreviousPage(backTo position: Int) {
        if let startingViewController = viewControllerAtIndex(index: position) {
            let viewControllers = [startingViewController]
            pageViewController!.setViewControllers(viewControllers , direction: .reverse, animated: true, completion: nil)
        }
    }

    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func closeAction(_ sender: Any) {
        delegate?.presentedViewControllerWillDismiss()
        dismiss(animated: true, completion: nil)
        Hero.shared.finish()
    }
}

// --------------------------------------
// MARK: UIPageViewControllerDataSource
// --------------------------------------


extension ContentViewVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, transitionStyleFor _: UIPageViewController.NavigationOrientation) -> UIPageViewController.TransitionStyle {
        return .scroll
    }
    
}
