//
//  UISegmentControl+Extension.swift
//  iOS Journey
//
//  Created by Munish on  28/09/24.
//

import UIKit

@MainActor private var isAnimatingKey: UInt8 = 0
extension UISegmentedControl {
    
    var isAnimating: Bool {
        get {
            return objc_getAssociatedObject(self, &isAnimatingKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &isAnimatingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
        
    private var underlineHeight: CGFloat { 3.5 }
    
    private var segmentWidth: CGFloat { bounds.width / CGFloat(numberOfSegments) }
    
    private var underlineMinY: CGFloat { bounds.height - 1.0 }
    
    func setup() {
        style()
        transparentBackground()
        addUnderline()
    }
    
    func style() {
        clipsToBounds = false
        tintColor = .clear
        backgroundColor = .clear
        selectedSegmentTintColor = .clear
        selectedSegmentIndex = 0
        
        let attributes: [NSAttributedString.Key: Any] = NSAttributedString.createAttributes(font: .customFont(style: .semiBold, size: 16), color: .ButtonTextColor, lineSpacing: 0, alignment: .center)
        setTitleTextAttributes(attributes, for: .normal)
        setTitleTextAttributes(attributes, for: .selected)
        sizeToFit()
    }

    func transparentBackground() {
        let backgroundImage = UIImage.coloredRectangleImageWith(color: UIColor.clear.cgColor, andSize: self.bounds.size)
        let dividerImage = UIImage.coloredRectangleImageWith(color: UIColor.clear.cgColor, andSize: CGSize(width: 1, height: self.bounds.height))
        setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)
        setDividerImage(dividerImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    func addUnderline() {
        let underline = UIView()
        underline.backgroundColor = UIColor.ButtonTextColor
        underline.tag = 1
        
        updateUnderlineframe(underline: underline)
        self.addSubview(underline)
    }
    
    func updateUnderlineframe(underline: UIView, animated: Bool = false){
        let selectedIndex = selectedSegmentIndex
        let underLineWidth = widthForSegmentTitle(at: selectedIndex)
        
        let underlineX = xPositionForSegmentTitle(at: selectedIndex)
        
        isAnimating = true
        
        if animated{
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                guard let self else{ return }
                underline.frame = CGRect(x: underlineX, y: underlineMinY, width: underLineWidth, height: underlineHeight)
            }) { [weak self] _ in
                self?.isAnimating = false
            }
        }else{
            underline.frame = CGRect(x: underlineX, y: underlineMinY, width: underLineWidth, height: underlineHeight)
        }
    }
    
    func widthForSegmentTitle(at index: Int) -> CGFloat {
        guard let title = titleForSegment(at: index) else { return 0 }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.customFont(style: .semiBold, size: 16)
        ]
        return (title as NSString).size(withAttributes: attributes).width
    }
    
    // Method to calculate the x position of a segment's text (starting point for the underline)
    private func xPositionForSegmentTitle(at index: Int) -> CGFloat {
        
        // Calculate the leading space within the segment where the text starts
        let textWidth = widthForSegmentTitle(at: index)
        let leadingSpace = (segmentWidth - textWidth) / 2
        
        // Calculate the x-position for the selected segment's text
        let underlineX = (segmentWidth * CGFloat(index)) + leadingSpace
        return underlineX
    }
    func moveUnderline(){
        guard let underline = self.viewWithTag(1) else {return}
        updateUnderlineframe(underline: underline, animated: true)
    }
    func moveUnderlineX_dynamic(scrollOffset: CGFloat, scrollWidth: CGFloat){
        if isAnimating{ return }
        
        guard let underline = self.viewWithTag(1) else {return}
        
        
        // Calculate how far the scroll has moved as a percentage
        let percentage = (scrollOffset - scrollWidth) / scrollWidth
        
        // Get the x-positions for the current and next segments
        let currentXPosition = xPositionForSegmentTitle(at: selectedSegmentIndex)
        let nextSegmentIndex = min(max(selectedSegmentIndex + (percentage > 0 ? 1 : -1), 0), numberOfSegments - 1)
        let nextXPosition = xPositionForSegmentTitle(at: nextSegmentIndex)

        // Interpolate between the current and next segment positions
        let interpolatedX = currentXPosition + (nextXPosition - currentXPosition) * abs(percentage)
        
        // Set the underline's x position dynamically
        underline.frame.origin.x = interpolatedX
    }
}

// MARK: - UIImage extension
extension UIImage {
    class func coloredRectangleImageWith(color: CGColor, andSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }

}
