//
//  TableView+Extension.swift
//  iOS Journey
//
//  Created by Munish on  06/11/24.
//

import UIKit

extension UITableView {
    
    func register<T: BaseTableViewCell>(cell name: T.Type) {
        register(T.self, forCellReuseIdentifier: name.resuseIdentifier)
    }

    func dequeueReusableCell<T: BaseTableViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: name.resuseIdentifier, for: indexPath) as? T else {
            fatalError(
                "Couldn't find UITableViewCell for \(String(describing: name)), make sure the cell is registered with table view")
        }
        return cell
    }
    
    func numberOfRows() -> Int {
        var section = 0
        var rowCount = 0
        while section < numberOfSections {
            rowCount += numberOfRows(inSection: section)
            section += 1
        }
        return rowCount
    }
    
    func safeScrollToTop(animated: Bool) {
        guard numberOfSections > 0, numberOfRows() > 0 else { return }
        scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: animated)
    }
    
    func indexPathForLastRow(inSection section: Int) -> IndexPath? {
        guard numberOfSections > 0, section >= 0 else { return nil }
        guard numberOfRows(inSection: section) > 0 else {
            return IndexPath(row: 0, section: section)
        }
        return IndexPath(row: numberOfRows(inSection: section) - 1, section: section)
    }
    
    var lastSection: Int? {
        return numberOfSections > 0 ? numberOfSections - 1 : nil
    }
    
    var indexPathForLastRow: IndexPath? {
        guard let lastSection = lastSection else { return nil }
        return indexPathForLastRow(inSection: lastSection)
    }
    
    func safeScrollToBottom(animated: Bool) {
        guard numberOfSections > 0, numberOfRows() > 0 else { return }
        scrollToRow(at: self.indexPathForLastRow!, at: .bottom, animated: animated)
    }
    
    func isLastSectionAndRowVisible() -> Bool {
        // Ensure there is at least one section
        guard numberOfSections > 0 else { return false }
        
        // Get the last section index
        let lastSection = numberOfSections - 1
        
        // Ensure there is at least one row in the last section
        guard numberOfRows(inSection: lastSection) > 0 else { return false }
                
        // Get the last row index in the last section
        let lastRow = numberOfRows(inSection: lastSection) - 1
        
        // Create an IndexPath for the last row in the last section
        let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
        
        // Check if this IndexPath is currently visible
        return indexPathsForVisibleRows?.contains(lastIndexPath) ?? false
    }
}
