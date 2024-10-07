//
//  TabbarController.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import UIKit

class TabbarController: BaseTabbarController {
    
    let homePage = HomeBaseController()
    let searchPage = SearchFeedController()
    let createPostPage = CreatePostController()
    let inboxPage = InboxListController()
    let profilePage = UIViewController()
    
    var selectedPage: TabbarItem
    
    init(selectedPage: TabbarItem) {
        self.selectedPage = selectedPage
        super.init(nibName: nil, bundle: nil)
        selectedIndex = selectedPage.rawValue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeUI()
    }
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        setupView()
    }
    func initalizeUI(){
        delegate = self
        
        homePage.tabBarItem = setupTabbarItem(.home)
        
        searchPage.tabBarItem = setupTabbarItem(.search)
        
        createPostPage.tabBarItem = setupTabbarItem(.create)
        
        inboxPage.tabBarItem = setupTabbarItem(.inbox)
        
        profilePage.tabBarItem = setupTabbarItem(.profile)
        
        let tabBarList = [homePage, searchPage, createPostPage, inboxPage, profilePage]
        viewControllers = tabBarList.map{ UINavigationController(rootViewController: $0) }
    }
    func setupView(){
        //guard let tabbarItem = TabbarItem(rawValue: selectedIndex) else{ return }
        //changeTabbarStyle(tabbarItem)
        changeTabbarStyle(selectedPage)
        
        tabBar.applyShadow()
    }
    func setupTabbarItem(_ item_result: TabbarItem)-> UITabBarItem{
        let item = item_result.result
                
        let normalImage = UIImage(named: item.image)
        let selectedImage = UIImage(named: item.selectedImage)
        
        let customTab = UITabBarItem(title: item.name, image:  normalImage?.withRenderingMode(item.renderMode_normal), selectedImage: selectedImage?.withRenderingMode(item.renderMode_selected))
        customTab.setTitleTextAttributes([NSAttributedString.Key.font: item.font], for: .normal)
        customTab.setTitleTextAttributes([NSAttributedString.Key.font: item.font], for: .selected)
        customTab.imageInsets = item.imageInset
        customTab.tag = item_result.rawValue
        return customTab
    }
}

extension TabbarController: UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let tabBarItem = TabbarItem(rawValue: viewController.tabBarItem.tag) else{ return }
        changeTabbarStyle(tabBarItem)
    }
    fileprivate func changeTabbarStyle(_ tabBarItem: TabbarItem){
        let BackgroundColor: UIColor
        let TintColor: UIColor
        let UnselectedTintColor: UIColor
        
        switch tabBarItem{
            case .home,.create:
                BackgroundColor = .black
                TintColor = .PrimaryColor
                UnselectedTintColor = .ButtonTextColor
                break
            case .search,.inbox,.profile:
                BackgroundColor = .ButtonTextColor
                TintColor = .PrimaryDarkColor_Only
                UnselectedTintColor = .TextTeritaryColor
                break
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
            self?.tabBar.backgroundColor = BackgroundColor
            self?.tabBar.tintColor = TintColor
            self?.tabBar.unselectedItemTintColor = UnselectedTintColor
        }, completion: nil)
    }
}

enum TabbarItem:Int, CaseIterable{
    case home = 0
    case search = 1
    case create = 2
    case inbox = 3
    case profile = 4
    
    var result: TabbarValues{
        switch self {
        case .home: return TabbarValues(name: "Home", image: "home", selectedImage: "home")
        case .search: return TabbarValues(name: "Search", image: "search", selectedImage: "search")
        case .create: return TabbarValues(name: nil, image: "create", selectedImage: "create",renderMode_normal: .alwaysOriginal,renderMode_selected: .alwaysOriginal,imageInset: .zero/*UIEdgeInsets(top: -25, left: -6, bottom: 0, right: -6)*/)
        case .inbox: return TabbarValues(name: "Inbox", image: "inbox", selectedImage: "inbox")
        case .profile: return TabbarValues(name: "Me", image: "profile", selectedImage: "profile_selected",renderMode_normal: .alwaysOriginal,renderMode_selected: .alwaysOriginal)
        }
    }
}

struct TabbarValues{
    let name: String?
    let image: String
    let selectedImage: String
    let font: UIFont = .customFont(style: .semiBold, size: 12)
    var renderMode_normal: UIImage.RenderingMode = .alwaysTemplate
    var renderMode_selected: UIImage.RenderingMode = .alwaysTemplate
    var imageInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}
