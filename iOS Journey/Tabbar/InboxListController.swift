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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(InboxListCollectionCell.self, forCellWithReuseIdentifier: InboxListCollectionCell.resuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeUI()
    }
    private func addViews(){
        view.addSubview(collectionView)
        collectionView.makeEdgeConstraints(toView: view, isSafeArea: true)
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
        setNavigationBarTitleAttributes()
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
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InboxListCollectionCell.resuseIdentifier, for: indexPath) as? InboxListCollectionCell else{ return UICollectionViewCell() }
        cell.setupConfigure()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
}


final class InboxListCollectionCell: BaseCollectionCell{
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(style: .medium, size: 16)
        label.textColor = .PrimaryDarkColor
        return label
    }()
    
    private var descLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(style: .regular, size: 15)
        label.textColor = .PrimaryDarkColor
        return label
    }()
    
    private var logoIcon: UIImageView = {
        let imageView = UIImageView(cornerRadius: 0, mode: .scaleAspectFit)
        return imageView
    }()
    
    override func initalizeUI() {
        super.initalizeUI()
        setupUI()
    }
    private func setupUI(){
        let titleStack = VerticalStack(arrangedSubViews: [titleLabel, descLabel], spacing: 8, alignment: .leading, distribution: .fill)
        let logoTextStack = HorizontalStack(arrangedSubViews: [logoIcon, titleStack], alignmnent: .center, distribution: .fillProportionally)
        logoTextStack.isLayoutMarginsRelativeArrangement = true
        logoTextStack.layoutMargins = .init(top: 8, left: 8, bottom: 0, right: 0)
        addSubview(logoTextStack)
        logoTextStack.makeEdgeConstraints(top: nil, leading: leadingAnchor, trailing: nil, bottom: nil)
        logoTextStack.makeCenterConstraints(toView: self, centerX_axis: true, centerY_axis: false)
        logoIcon.sizeConstraints(width: 40, height: 40)
    }
    func setupConfigure(){
        titleLabel.text = "Regina"
        descLabel.text = "When will you leave?"
        logoIcon.image = UIImage(named: "beauty")
    }
}
