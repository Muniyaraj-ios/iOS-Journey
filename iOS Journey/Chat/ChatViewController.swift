//
//  ChatViewController.swift
//  iOS Journey
//
//  Created by MacBook on 07/10/24.
//

import UIKit
import SwiftUI

final class ChatViewController: BaseController {
    
    public var userId: String

    lazy var chatTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var wholeTextView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    lazy var TextViewBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    lazy var messageTextView: PlaceholderTextView = {
        let view = PlaceholderTextView()
        view.placeholder = "Message"
        view.font = .customFont(fontFamily: .poppins, style: .medium, size: 15)
        view.textColor = .PrimaryDarkColor
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var sendMessageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("", for: .normal)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        return button
    }()
    
    private var textViewBottomConstraint: NSLayoutConstraint!
    private var textViewHeightConstraint: NSLayoutConstraint!
    public private(set) var textViewAttributes = (minHeight: CGFloat(46), maxHeight: CGFloat(120))
    
    
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        TextViewBgView.cornerRadiusWithBorder(corner: textViewAttributes.minHeight / 2, borderwidth: 0.8, borderColor: .lightGray)
        TextViewBgView.layer.masksToBounds = true
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
        observeNotification()
    }
    private func setupView(){
        view.backgroundColor = .systemBackground
        view.addSubview(wholeTextView)
        wholeTextView.makeEdgeConstraints(top: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil)
        
        textViewBottomConstraint = wholeTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -0)
        textViewBottomConstraint.isActive = true
        
        view.addSubview(chatTableView)
        chatTableView.makeEdgeConstraints(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: wholeTextView.topAnchor, edge: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        wholeTextView.addSubview(sendMessageButton)
        sendMessageButton.makeEdgeConstraints(top: nil, leading: nil, trailing: wholeTextView.trailingAnchor, bottom: nil, edge: .init(top: 0, left: 0, bottom: 0, right: 15))
        sendMessageButton.makeCenterConstraints(toView: wholeTextView, centerX_axis: false, centerY_axis: true)
        sendMessageButton.sizeConstraints(width: 45, height: 45)
        
        wholeTextView.addSubview(TextViewBgView)
        TextViewBgView.makeEdgeConstraints(top: wholeTextView.topAnchor, leading: wholeTextView.leadingAnchor, trailing: sendMessageButton.leadingAnchor, bottom: wholeTextView.bottomAnchor, edge: .init(top: 12, left: 12, bottom: 12, right: 15))
        
        //TextViewBgView.makeEdgeConstraints(toView: wholeTextView, edge: .init(top: 12, left: 12, bottom: 12, right: 12))
        //TextViewBgView.heightConstraints(height: 52)
        textViewHeightConstraint = TextViewBgView.heightAnchor.constraint(equalToConstant: textViewAttributes.minHeight)
        textViewHeightConstraint.isActive = true
        
        TextViewBgView.addSubview(messageTextView)
        messageTextView.makeEdgeConstraints(toView: TextViewBgView, edge: .init(top: 5, left: 8, bottom: 6, right: 5))
    }
    private func setupConstrainats(){
        
    }
    private func setupTheme(){
        
    }
    private func setupLang(){
        //navigationItem.title = "Martin Guptil"
        
        messageTextView.placeholder = "Message"
    }
    private func setupFont(){
        
    }
    private func setupDelegate(){
        chatTableView.delegate = self
        chatTableView.dataSource = self
        messageTextView.delegate = self
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
    
    deinit {
        removeobserveNotification()
    }
}

extension ChatViewController{
    
    private func observeNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func removeobserveNotification(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        adjustButtonForKeyboard(notification: notification, show: true)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        adjustButtonForKeyboard(notification: notification, show: false)
    }
    
    private func adjustButtonForKeyboard(notification: Notification, show: Bool) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        textViewBottomConstraint?.constant = show ? -(keyboardFrame.height - view.safeAreaInsets.bottom) : -0
        
//            UIView.animate(withDuration: 0.3) {  [weak self] in
//                self?.view.frame.origin.y = show ? -keyboardFrame.height : 0
//            }
        
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.view.layoutIfNeeded()
            guard let self = self else{ return }
            if show && chatTableView.isLastSectionAndRowVisible(){
                chatTableView.safeScrollToBottom(animated: show)
            }
        }
    }
}
extension ChatViewController: UITextViewDelegate{
    
    private func sendMessage(){
        messageTextView.text = nil
        messageTextView.textDidChange()
        textViewIsEmpty()
        resetMessageTextViewIfNeeded()
    }
    
    func textViewIsEmpty(){
        //sendMessageBtn.isEnabled = !messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        //sendMessageBtn.tintColor = sendMessageBtn.isEnabled ? .systemBlue : .tertiaryLabel
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        /*UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction]) { [weak self] in
            self?.uploadDocBtn.isHidden = true
        }*/
    }
    func textViewDidChange(_ textView: UITextView) {
        textViewIsEmpty()
        
        let estimatedTextHeight = messageTextView.sizeThatFits(CGSize(width: messageTextView.frame.width, height: .infinity)).height
        
        let newHeight: CGFloat!
        if estimatedTextHeight <= textViewAttributes.minHeight{
            messageTextView.isScrollEnabled = false
            newHeight = textViewAttributes.minHeight
        }else if estimatedTextHeight <= textViewAttributes.maxHeight{
            newHeight = estimatedTextHeight + 20
        }else{
            messageTextView.isScrollEnabled = true
            newHeight = textViewAttributes.maxHeight
        }
        
        guard textViewHeightConstraint.constant != newHeight else{ return }
        animatedTextView(newHeight: newHeight)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        resetMessageTextViewIfNeeded()
    }
    
    private func resetMessageTextViewIfNeeded(){
        guard messageTextView.text.isEmpty else{ return }
        
        if textViewHeightConstraint.constant != textViewAttributes.minHeight{
            animatedTextView(newHeight: textViewAttributes.minHeight)
        }
    }
    
    private func animatedTextView(newHeight: CGFloat){
        textViewHeightConstraint.constant = newHeight
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction]) { [weak self] in
            self?.view.layoutIfNeeded()
        }

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

struct ChatView: UIViewControllerRepresentable{
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return ChatViewController(userId: "")
    }
    
    
}

//struct ChatView_preview: PreviewProvider{
//    static var previews: some View{
//        ChatView()
//    }
//}
