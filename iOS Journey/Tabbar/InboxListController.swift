//
//  InboxListController.swift
//  iOS Journey
//
//  Created by MacBook on 04/10/24.
//

import UIKit

final class InboxListController: BaseController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(InboxListCollectionCell.self, forCellWithReuseIdentifier: InboxListCollectionCell.resuseIdentifier)
        collectionView.isUserInteractionEnabled = true
        return collectionView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        initalizeUI()
        
        let value = [1, 2, 3, 4]//, 5, 6, 7, 8, 9]
        
        let result = value
            .lazy
            .filter{ value in
                value % 2 != 0
            }
            .map{ value in
                value * value
            }
            .prefix(2)
            .map{ $0 }
        
        print("result : \(result)")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.setColor(backgroundColor: .BackgroundColor)
    }
    
    
    private func addViews(){
        view.addSubview(collectionView)
        collectionView.makeEdgeConstraints(toView: view, isSafeArea: false)
        collectionView.contentInset = .init(top: 12, left: 0, bottom: 12, right: 0)
    }
    private func initalizeUI(){
        setupView()
        setupTheme()
        setupLang()
        setupFont()
        setupDelegate()
        setupAction()
    }
    private func setupView(){
        addViews()
    }
    private func setupConstrainats(){
        
    }
    private func setupTheme(){
    }
    private func setupLang(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else{ return }
            navigationItem.title = "Message"
        }
    }
    private func setupFont(){
        
    }
    private func setupDelegate(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    private func setupAction(){
    }
}
extension InboxListController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InboxListCollectionCell.resuseIdentifier, for: indexPath) as? InboxListCollectionCell else{ return UICollectionViewCell() }
        cell.setupConfigure()
        print("user inter : ",cell.isUserInteractionEnabled)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            debugPrint("did select called")
            self?.navigateTOChatPage()
        }
    }
    
    private func navigateTOChatPage(){
        let chatPage = ChatViewController(userId: "2")
        tabBarController?.hidesBottomBarWhenPushed = true
        tabBarController?.navigationController?.pushToController(chatPage)
//        tabBarController?.selectedViewController?.navigationController?.pushViewController(chatPage, animated: true)
//        navigationController?.pushViewController(chatPage, animated: true)
    }
}


class InboxListCollectionCell: BaseCollectionCell{
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(style: .semiBold, size: 15)
        label.textColor = .PrimaryDarkColor
        label.numberOfLines = 1
        return label
    }()
    
    private var descLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(style: .regular, size: 13)
        label.textColor = .PrimaryDarkColor
        label.numberOfLines = 2
        return label
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(style: .regular, size: 12)
        label.textColor = .PrimaryDarkColor
        label.numberOfLines = 1
        return label
    }()
    
    private var chatCountLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(style: .regular, size: 12)
        label.textColor = .TextTeritaryColor
        label.numberOfLines = 2
        return label
    }()
    
    private var logoIcon: UIImageView = {
        let imageView = UIImageView(cornerRadius: 0, mode: .scaleAspectFill)
        return imageView
    }()
    
    override func initalizeUI() {
        super.initalizeUI()
        
        setupUI()
    }
    private func setupUI(){
        addSubview(logoIcon)
        logoIcon.makeEdgeConstraints(top: nil, leading: leadingAnchor, trailing: nil, bottom: nil, edge: .init(top: 0, left: 12, bottom: 0, right: 0))
        logoIcon.makeCenterConstraints(toView: self, centerX_axis: false, centerY_axis: true)
        
        let titleStack = VerticalStack(arrangedSubViews: [titleLabel, descLabel], spacing: 3, alignment: .leading, distribution: .fill)
        addSubview(titleStack)
        titleStack.makeEdgeConstraints(top: nil, leading: logoIcon.trailingAnchor, trailing: nil, bottom: nil,edge: .init(top: 0, left: 12, bottom: 0, right: 12))
        titleStack.makeCenterConstraints(toView: logoIcon, centerX_axis: false, centerY_axis: true)
        
        let timeStack = VerticalStack(arrangedSubViews: [timeLabel], spacing: 0, alignment: .top, distribution: .fill)
        addSubview(timeStack)
        timeStack.makeEdgeConstraints(top: nil, leading: nil, trailing: trailingAnchor, bottom: nil, edge: .init(top: 0, left: 8, bottom: 0, right: 12))
        timeStack.makeCenterConstraints(toView: self, centerX_axis: false, centerY_axis: true)
        timeStack.leadingAnchor.constraint(greaterThanOrEqualTo: titleStack.trailingAnchor, constant: 12).isActive = true
        
        titleStack.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: 4).isActive = true
        titleStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -4).isActive = true
        
        logoIcon.sizeConstraints(width: 50, height: 50)
    }
    func setupConfigure(){
        titleLabel.text = "Regina"
        descLabel.text = "When will you leave?, When will you leaveWhen will you leaveWhen will you leaveWhen will you leave"
        logoIcon.image = UIImage(named: "subbeauty")
        timeLabel.text = "Now"
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        logoIcon.clipsToBounds = true
        logoIcon.cornerRadiusWithBorder(isRound: true, corner: 0, borderwidth: 0, borderColor: .clear)
    }
}
