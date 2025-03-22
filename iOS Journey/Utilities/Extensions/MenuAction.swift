//
//  MenuAction.swift
//  iOS Journey
//
//  Created by MAC on 22/03/25.
//


import UIKit

struct MenuAction {
    let title: String
    let imageName: String
    let isDestructive: Bool
    let actionHandler: (() -> Void)?
}

final class MenuBuilder {
    
    static func createMenu(actions: [MenuAction] = MenuAction.defaultActions, completion: @escaping (String) -> Void) -> UIMenu {
        let uiActions = actions.map { action in
            return UIAction(
                title: action.title,
                image: UIImage(systemName: action.imageName),
                attributes: action.isDestructive ? .destructive : [],
                handler: { _ in
                    action.actionHandler?()
                    completion(action.title)
                }
            )
        }
        return UIMenu(children: uiActions)
    }
}

extension MenuAction{
    
    static let defaultActions: [MenuAction] =  [
        MenuAction(title: "Like", imageName: "heart", isDestructive: false) {
            print("Liked!")
        },
        MenuAction(title: "Share", imageName: "square.and.arrow.up", isDestructive: false) {
            print("Profile Shared!")
        },
        MenuAction(title: "View Profile", imageName: "person.circle", isDestructive: false) {
            print("Viewing Profile!")
        },
        MenuAction(title: "Report", imageName: "person.fill.xmark", isDestructive: true) {
            print("Reported!")
        },
        MenuAction(title: "Not Interested", imageName: "eye.slash", isDestructive: false) {
            print("Not Interested!")
        }
    ]
}
