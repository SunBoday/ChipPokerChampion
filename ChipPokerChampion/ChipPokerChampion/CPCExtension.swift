//
//  CPCExtension.swift
//  ChipPokerChampion
//
//  Created by SunTory on 2024/9/26.
//

import Foundation
import Foundation
import UIKit

//MARK: - View Properties (radius, border, shadow)
@IBDesignable extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            
            // If masksToBounds is true, subviews will be
            // clipped to the rounded corners.
            layer.masksToBounds = (newValue > 0)
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
        set { layer.borderColor = newValue?.cgColor }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    //    @IBInspectable var shadowColor: UIColor {
    //        get {
    //            return UIColor(cgColor: layer.shadowColor!)
    //        }
    //        set {
    //            layer.shadowColor = newValue.cgColor
    //        }
    //    }
    //
    //    @IBInspectable var shadowOpacity: Float {
    //        get {
    //            return layer.shadowOpacity
    //        }
    //        set {
    //            layer.shadowOpacity = newValue
    //        }
    //    }
    //
    //    @IBInspectable var shadowOffset: CGSize {
    //        get {
    //            return layer.shadowOffset
    //        }
    //        set {
    //            layer.shadowOffset = newValue
    //        }
    //    }
    //
    //    @IBInspectable var shadowRadius: CGFloat {
    //        get {
    //            return layer.shadowRadius
    //        }
    //        set {
    //            layer.shadowRadius = newValue
    //        }
    //    }
    //
    //    func addShadow() {
    //        layer.shadowColor = shadowColor.cgColor
    //        layer.shadowOpacity = shadowOpacity
    //        layer.shadowOffset = shadowOffset
    //        layer.shadowRadius = shadowRadius
    //    }
    
}

//MARK: - Corner Raduis to Preticuler Corner
@IBDesignable
class CustomCornerView: UIView {
    
    @IBInspectable var topLeftCornerRadius: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    @IBInspectable var topRightCornerRadius: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    @IBInspectable var bottomLeftCornerRadius: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    @IBInspectable var bottomRightCornerRadius: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    private func updateCornerRadius() {
        var corners: CACornerMask = []
        
        if topLeftCornerRadius {
            corners.insert(.layerMinXMinYCorner)
        }
        if topRightCornerRadius {
            corners.insert(.layerMaxXMinYCorner)
        }
        if bottomLeftCornerRadius {
            corners.insert(.layerMinXMaxYCorner)
        }
        if bottomRightCornerRadius {
            corners.insert(.layerMaxXMaxYCorner)
        }
        
        layer.maskedCorners = corners
    }
}




//MARK: - Gradiet Color to Border with angle

extension UIView {
    func addGradientBorderOutside(viewname: UIView, startColor: UIColor, endColor: UIColor, width: CGFloat, angleInDegrees: CGFloat, cornerRadius: CGFloat) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        
        let startPoint = CGPoint(x: 0.5 + cos(angleInDegrees * .pi / 180) * 0.5, y: 0.5 + sin(angleInDegrees * .pi / 180) * 0.5)
        let endPoint = CGPoint(x: 0.5 - cos(angleInDegrees * .pi / 180) * 0.5, y: 0.5 - sin(angleInDegrees * .pi / 180) * 0.5)
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        
        let shape = CAShapeLayer()
        shape.lineWidth = width
        shape.path = UIBezierPath(roundedRect: viewname.bounds, cornerRadius: cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        layer.addSublayer(gradient)
    }
}

//MARK: - Gradient Color to View Background with angle

@IBDesignable
class GradientView: UIView {
    @IBInspectable var startColor: UIColor = UIColor.white {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor.black {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var angle: CGFloat = 0.0 {
        didSet {
            updateGradient()
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private func updateGradient() {
        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
        
        let angleInRadians = angle * .pi / 180.0
        let startPointX = 0.5 + cos(angleInRadians) * 0.5
        let startPointY = 0.5 + sin(angleInRadians) * 0.5
        let endPointX = 1.0 - startPointX
        let endPointY = 1.0 - startPointY
        
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
}

//MARK: - TextField Padding and Placeholder Color
extension UITextField {
    @IBInspectable var leftPadding: CGFloat {
        get {
            return leftView?.frame.size.width ?? 0
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }
    
    @IBInspectable var rightPadding: CGFloat {
        get {
            return rightView?.frame.size.width ?? 0
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
    
    @IBInspectable var placeholderColor: UIColor? {
        get {
            return self.attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        }
        set {
            guard let newValue = newValue else {
                self.attributedPlaceholder = nil
                return
            }
            
            var attributes = [NSAttributedString.Key: Any]()
            if let font = self.font {
                attributes[.font] = font
            }
            attributes[.foregroundColor] = newValue
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: attributes)
        }
    }
}

extension UIView {
    func addPulsationAnimation() {
        /// transparency animation
        /// you can pick any values you like
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1.5
        pulseAnimation.fromValue = 0.7
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        self.layer.add(pulseAnimation, forKey: nil)
        
        /// transform scale animation
        /// you can pick any values you like
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 1.5
        scaleAnimation.fromValue = 0.95
        scaleAnimation.toValue = 1
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        self.layer.add(scaleAnimation, forKey: nil)
    }
}

extension String {
    func textToDouble() -> Double {
        return Double(self) ?? 0.0
    }
}

@IBDesignable
class CircularGradientView: UIView {
    
    @IBInspectable var startColor: UIColor = .red {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var endColor: UIColor = .blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations) else { return }
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = calculateRadiusForGradient(rect: rect)
        
        context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: [])
    }
    
    private func calculateRadiusForGradient(rect: CGRect) -> CGFloat {
        let width = rect.width
        let height = rect.height
        return sqrt((width * width) + (height * height)) / 2
    }
}

@IBDesignable
class GradientView1: UITextField {
    @IBInspectable var startColor: UIColor = UIColor.white {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor.black {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var angle: CGFloat = 0.0 {
        didSet {
            updateGradient()
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private func updateGradient() {
        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
        
        let angleInRadians = angle * .pi / 180.0
        let startPointX = 0.5 + cos(angleInRadians) * 0.5
        let startPointY = 0.5 + sin(angleInRadians) * 0.5
        let endPointX = 1.0 - startPointX
        let endPointY = 1.0 - startPointY
        
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
}

import UIKit
import ImageIO

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


extension UIViewController {
    func showAlert(title: String, message: String, buttonTitles: [String], buttonActions: [() -> Void]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for (index, title) in buttonTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default) { _ in
                if index < buttonActions.count {
                    buttonActions[index]()
                }
            }
            alertController.addAction(action)
        }
        
        present(alertController, animated: true, completion: nil)
    }
}


//@IBDesignable
//class InnerShadowView: UIView {
//
//    @IBInspectable var innerShadowColor: UIColor = UIColor.black {
//        didSet { setupInnerShadow() }
//    }
//
//    @IBInspectable var innerShadowOffset: CGSize = CGSize(width: 0, height: 0) {
//        didSet { setupInnerShadow() }
//    }
//
//    @IBInspectable var innerShadowOpacity: Float = 0.5 {
//        didSet { setupInnerShadow() }
//    }
//
//    @IBInspectable var innerShadowRadius: CGFloat = 10 {
//        didSet { setupInnerShadow() }
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupInnerShadow()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupInnerShadow()
//    }
//
//    private func setupInnerShadow() {
//        // Remove existing shadow layers to prevent duplicate shadows
//        layer.sublayers?.filter { $0.name == "innerShadowLayer" }.forEach { $0.removeFromSuperlayer() }
//
//        // Create a shadow layer
//        let shadowLayer = CALayer()
//        shadowLayer.name = "innerShadowLayer"
//        shadowLayer.frame = bounds
//        shadowLayer.backgroundColor = backgroundColor?.cgColor
//        shadowLayer.shadowColor = innerShadowColor.cgColor
//        shadowLayer.shadowOffset = innerShadowOffset
//        shadowLayer.shadowOpacity = innerShadowOpacity
//        shadowLayer.shadowRadius = innerShadowRadius
//        shadowLayer.cornerRadius = layer.cornerRadius
//
//        // Create a path that is slightly inset from the view's bounds
//        let path = UIBezierPath(rect: bounds.insetBy(dx: -innerShadowRadius, dy: -innerShadowRadius))
//        let cutout = UIBezierPath(rect: bounds).reversing()
//        path.append(cutout)
//        shadowLayer.shadowPath = path.cgPath
//
//        // Add the shadow layer as a sublayer
//        layer.addSublayer(shadowLayer)
//        // Optionally, set masksToBounds to true if the shadow should respect the view's bounds
//        layer.masksToBounds = true
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        setupInnerShadow()
//    }
//}

import UIKit

//MARK: - Alert

class Utils {
    static func showAlert(title: String, message: String, from viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            
            viewController.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}


