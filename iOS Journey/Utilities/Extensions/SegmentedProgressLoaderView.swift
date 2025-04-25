//
//  SegmentedProgressLoaderView.swift
//  iOS Journey
//
//  Created by ihub on 24/04/25.
//

import UIKit

final class SegmentedProgressLoaderView: UIView {
    
    private var aPath: UIBezierPath = UIBezierPath()
        
    let shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.ringColor.cgColor
        shapeLayer.lineWidth = 6
        shapeLayer.strokeEnd = 0
        shapeLayer.lineCap = .round
        return shapeLayer
    }()
    
    let trackLayer: CAShapeLayer = {
        let trackLayer = CAShapeLayer()
        trackLayer.strokeColor = UIColor.ringColor.cgColor
        trackLayer.lineWidth = 6
        trackLayer.strokeEnd = 1
        trackLayer.lineCap = .round
        return trackLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupLayers() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let Arc_center: CGPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let circlePath = UIBezierPath(arcCenter: Arc_center, radius: 60, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        aPath = circlePath//UIBezierPath()
        
        if semanticContentAttribute == .forceRightToLeft {
            aPath.move(to: CGPoint(x: bounds.width, y: bounds.midY))
            aPath.addLine(to: CGPoint(x: 0.0, y: bounds.midY))
        }else{
            aPath.move(to: CGPoint(x: 0.0, y: bounds.midY))
            aPath.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        }
        
        trackLayer.path = aPath.cgPath
        shapeLayer.path = aPath.cgPath
        
        shapeLayer.lineCap = .round
        trackLayer.lineCap = .round
    }
    
    func setProgress(_ progress: CGFloat) {
        shapeLayer.strokeEnd = progress
    }
}


final class SegmentedProgressView: UIView{
    
    private var pulsingLayer: CAShapeLayer!
    private var trackLayer: CAShapeLayer!
    private var circleShapeLayer: CAShapeLayer!
    private var circlePath: UIBezierPath!
    
    var segments: [UIView] = []
    var segmentPoints: [CGFloat] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViewLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViewLayer(){
        pulsingLayer = setupLayerUI(strokeColor: .clear, fillColor: .clear)
        layer.addSublayer(pulsingLayer)
        
        trackLayer = setupLayerUI(strokeColor: .systemGray6, fillColor: .clear)
        layer.addSublayer(trackLayer)
        
        circleShapeLayer = setupLayerUI(strokeColor: .PrimaryColor, fillColor: .clear)
        circleShapeLayer.strokeEnd = 0.0
        circleShapeLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        layer.addSublayer(circleShapeLayer)
    }
    
    private func setupLayerUI(strokeColor: UIColor, fillColor: UIColor, lineWidth: CGFloat = 8)-> CAShapeLayer{
        let layer = CAShapeLayer()
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = lineWidth
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .square
        return layer
    }
    
    private func updateLayerPath(){
        layoutIfNeeded()
        let Arc_center: CGPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let circlePath_ = UIBezierPath(arcCenter: Arc_center, radius: 46, startAngle: CGFloat.pi, endAngle: (CGFloat.pi / 1.01), clockwise: true)
        circlePath = circlePath_
        [pulsingLayer,trackLayer,circleShapeLayer].forEach{
            $0?.path = circlePath.cgPath
            $0?.position = center
            $0?.frame = bounds
        }
    }
    
    func setProgress(_ strokeEndTime: CGFloat) {
        circleShapeLayer.strokeEnd = strokeEndTime
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        updateLayerPath()
    }
}


extension SegmentedProgressView{
    
    func pauseProgress() {
        let newSegment = handleCreateSegements()
        addSubview(newSegment)

        segments.append(newSegment)
        segmentPoints.append(circleShapeLayer.strokeEnd)

        DispatchQueue.main.async {
            self.handlePositionSegment(newSegment: newSegment)
        }
    }
    
    func handleCreateSegements() -> UIView {
        let dotSize: CGFloat = 8
        let view = UIView(frame: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
        view.backgroundColor = .white
        return view
    }


    func handlePositionSegment(newSegment: UIView) {
        let radius: CGFloat = 46
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let progress = circleShapeLayer.strokeEnd
        let angle = (-CGFloat.pi / 2) + (2 * .pi * progress)

        let x = center.x + radius * cos(angle)
        let y = center.y + radius * sin(angle)
        newSegment.center = CGPoint(x: x, y: y)

        newSegment.transform = CGAffineTransform(rotationAngle: angle + .pi / 2)
    }

    func handleRemoveLastSegment(){
        segments.last?.removeFromSuperview()
        segmentPoints.removeLast()
        segments.removeLast()
        circleShapeLayer.strokeEnd = segmentPoints.last ?? 0.0
    }
}

extension UIView{
    func constraintToLeft(paddingLeft: CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        if let left = superview?.leftAnchor{
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
    }
}
