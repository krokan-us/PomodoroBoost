import UIKit
import Lottie

class CircularProgressBar: UIView {
    
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var centerView = UIView()
    private var animationView = UIView()
    
    var progress: CGFloat = 0.0 {
        didSet {
            if progress != oldValue {
                animateProgress()
            }
        }
    }
    
    var barColor: UIColor = .red {
        didSet {
            progressLayer.strokeColor = barColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }
    
    private func createCircularPath() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                      radius: bounds.width / 2,
                                      startAngle: -CGFloat.pi / 2,
                                      endAngle: 3 * CGFloat.pi / 2,
                                      clockwise: true)
        
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.white.cgColor
        circleLayer.strokeColor = UIColor.lightGray.cgColor
        circleLayer.lineWidth = 15.0
        circleLayer.strokeEnd = 1.0
        layer.addSublayer(circleLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = barColor.cgColor
        progressLayer.lineWidth = 15.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
        
        setupCenterView()
    }
    
    private func setupCenterView() {
        let sideLength = bounds.width / 2
        centerView.frame = CGRect(x: bounds.midX - sideLength / 2, y: bounds.midY - sideLength / 2, width: sideLength, height: sideLength)
        centerView.backgroundColor = .white
        addSubview(centerView)
        
        animationView.frame = centerView.bounds
        centerView.addSubview(animationView)
    }
    
    private func animateProgress() {
        DispatchQueue.main.async {
            let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
            progressAnimation.duration = 1.0
            progressAnimation.fromValue = self.progressLayer.strokeEnd
            progressAnimation.toValue = self.progress
            progressAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            self.progressLayer.strokeEnd = self.progress
            self.progressLayer.add(progressAnimation, forKey: "progressAnimation")
        }
    }
    
    func putAnimation(animationName: String) {
        // Remove all previous subviews (animations)
        animationView.subviews.forEach { $0.removeFromSuperview() }

        let lottieAnimation = LottieAnimationView(name: animationName)
        lottieAnimation.frame = animationView.bounds
        lottieAnimation.contentMode = .scaleAspectFit
        lottieAnimation.alpha = 0.0
        animationView.addSubview(lottieAnimation)
        
        lottieAnimation.loopMode = .loop
        lottieAnimation.play()
        
        // Animate alpha value change over 0.5 seconds
        UIView.animate(withDuration: 0.5) {
            lottieAnimation.alpha = 1.0
        }
    }
}
