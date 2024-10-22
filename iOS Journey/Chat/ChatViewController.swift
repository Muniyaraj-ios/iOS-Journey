//
//  ChatViewController.swift
//  iOS Journey
//
//  Created by MacBook on 07/10/24.
//

import UIKit

final class ChatViewController: BaseController {
    
    public var userId: String
        
    lazy var chatTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear called")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear called")
        navigationController?.isNavigationBarHidden = true
    }
    private func initalizeUI(){
        setupView()
        setupTheme()
        setupLang()
        setupFont()
        setupDelegate()
        setupAction()
        setupLeftNavBarItem()
        setupNavigationBar()
    }
    private func setupView(){
        view.backgroundColor = .systemBackground
        view.addSubview(chatTableView)
        chatTableView.makeEdgeConstraints(toView: view, isSafeArea: true)
    }
    private func setupConstrainats(){
        
    }
    private func setupTheme(){
        
    }
    private func setupLang(){
        //navigationItem.title = "Martin Guptil"
    }
    private func setupFont(){
        
    }
    private func setupDelegate(){
        chatTableView.delegate = self
        chatTableView.dataSource = self
    }
    private func setupAction(){
        
    }
    func setupLeftNavBarItem() {
        // Create a container view for the custom left bar button
        let containerView = UIView()
        
        // Back Button
        let BackButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
                
        let backButton = UIButton(type: .custom)
        backButton.setTitle("", for: .normal)
        backButton.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.tintColor = .label
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Profile Image
        let profileImageView = UIImageView(image: UIImage(named: "subbeauty")) // Replace with your image
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 19 // Adjust to your needs
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.widthAnchor.constraint(equalToConstant: 38).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        // Username Label
        let usernameLabel = UILabel()
        usernameLabel.text = "Username" // Replace with actual username
        usernameLabel.font = .customFont(fontFamily: .poppins, style: .bold, size: 16)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Online Status Label
        let statusLabel = UILabel()
        statusLabel.text = "Away" // Replace with status
        statusLabel.font = .customFont(fontFamily: .poppins, style: .regular, size: 14)
        statusLabel.textColor = .darkGray // Use green color for online status
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Stack View to hold labels
        let labelStackView = UIStackView(arrangedSubviews: [usernameLabel, statusLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = 2
        labelStackView.translatesAutoresizingMaskIntoConstraints = false

        // Add profile image and label stack to container view
        //containerView.addSubview(backButton)
        containerView.addSubview(profileImageView)
        containerView.addSubview(labelStackView)
        
        // Set layout constraints for profileImageView and labelStackView
        NSLayoutConstraint.activate([
            // BackButton Constraints
//            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
//            backButton.widthAnchor.constraint(equalToConstant: 30),
//            backButton.heightAnchor.constraint(equalToConstant: 30),
//            backButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Profile Image Constraints
            profileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Label Stack Constraints
            labelStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            labelStackView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // Set the container view as the custom view for the left bar button
        //let leftBarButtonItem = UIBarButtonItem(customView: /*containerView*/)
        self.navigationItem.titleView = containerView
        self.navigationItem.leftBarButtonItem = BackButton
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
    }
    
    func setupNavigationBar() {
        // Call button
        let callButton = UIBarButtonItem(image: UIImage(systemName: "phone.fill"), style: .plain, target: self, action: #selector(callAction))
        
        // Video call button
        let videoCallButton = UIBarButtonItem(image: UIImage(systemName: "video.fill"), style: .plain, target: self, action: #selector(videoCallAction))
        
        // More button with UIMenu
        let moreInfoAction = UIAction(title: "More Info", image: UIImage(systemName: "info.circle")) { _ in
            print("More Info tapped")
        }
        
        let archiveAction = UIAction(title: "Archive", image: UIImage(systemName: "archivebox.fill")) { _ in
            print("Archive tapped")
        }
        
        let blockAction = UIAction(title: "Block", image: UIImage(systemName: "hand.raised.fill")) { _ in
            print("Block tapped")
        }
        
        // Create UIMenu for More button
        let moreButtonMenu = UIMenu(title: "", children: [moreInfoAction, archiveAction, blockAction])
        
        // Create the More UIBarButtonItem with a menu
        //let moreButton = UIBarButtonItem(title: "More", menu: moreButtonMenu)
        let moreButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis"), primaryAction: nil, menu: moreButtonMenu)
        
        // Create flexible space with negative width to reduce spacing
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = -10 // Adjust the width as needed (negative value reduces space)
        
        // Set the right bar button items with fixed space between them
        self.navigationItem.rightBarButtonItems = [moreButton, fixedSpace, videoCallButton, fixedSpace, callButton]
    }
    @objc func backButtonTapped(){
        debugPrint("tapped")
        navigationController?.popViewController(animated: true)
    }
    // Call action
    @objc func callAction() {
        print("Call button tapped")
        // Handle call action here
    }
    
    // Video call action
    @objc func videoCallAction() {
        print("Video call button tapped")
        // Handle video call action here
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = UIListContentConfiguration.cell()
                
        // Set text and secondary text
        content.text = "Good, All is Well" // Primary text
        content.secondaryText = "Subtitle for your life" // Secondary text
        
        // Customize the image
        content.image = UIImage(systemName: "person.circle.fill") // You can use a system or custom image
        content.imageProperties.tintColor = .systemBlue
        content.imageProperties.maximumSize = CGSize(width: 100, height: 100)
        
        // Customize the text properties
        content.textProperties.font = .systemFont(ofSize: 18, weight: .bold)
        content.secondaryTextProperties.font = .systemFont(ofSize: 14, weight: .light)
        content.secondaryTextProperties.color = .gray
        
        // Assign the configuration to the cell's contentConfiguration
        cell.contentConfiguration = content
        
        return cell
    }
}
