//
//  HomeBaseController.swift
//  iOS Journey
//
//  Created by MacBook on 28/09/24.
//

import UIKit

class HomeBaseController: BaseController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    
    private var pageViewController: UIPageViewController!
    
    private lazy var orderedViewControllers: [UIViewController] = {
        return [HomeController(), HomeController(), HomeController()]
    }()
        
    lazy private var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["For You", "Following", "Discover"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        return sc
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        setupPageViewController()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupUI() {
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        segmentedControl.setup()
    }
    
    func setupScrollViewListener() {
        // Get the scrollView from the UIPageViewController
        for subview in pageViewController.view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let firstController = orderedViewControllers.first{
            pageViewController.setViewControllers([firstController], direction: .forward, animated: true, completion: nil)
        }
                
        //pageViewController.view.frame = view.bounds
        pageViewController.view.backgroundColor = .clear//.PrimaryColor
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.makeEdgeConstraints(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor)
        
        pageViewController.didMove(toParent: self)
        
        setupScrollViewListener()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //pageViewController.view.frame = view.bounds
        pageViewController.view.clipsToBounds = true
    }
}
extension HomeBaseController{
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let currentViewController = pageViewController.viewControllers?.first
        let currentIndex = orderedViewControllers.firstIndex(of: currentViewController!) ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        pageViewController.setViewControllers([orderedViewControllers[index]], direction: direction, animated: true, completion: nil)
        
        sender.moveUnderline()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return orderedViewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers.firstIndex(of: viewController), index < orderedViewControllers.count - 1 else {
            return nil
        }
        return orderedViewControllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first, let index = orderedViewControllers.firstIndex(of: visibleViewController) {
            segmentedControl.selectedSegmentIndex = index
            segmentedControl.moveUnderline()
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.x
        let scrollWidth = scrollView.frame.width
        segmentedControl.moveUnderlineX_dynamic(scrollOffset: scrollOffset, scrollWidth: scrollWidth)
        
    }
}
