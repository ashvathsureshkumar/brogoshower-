import UIKit

class StinkyPopup {
    static func show(on viewController: UIViewController) {
        // Trigger haptic feedback (vibration)
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Create overlay view
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlayView.alpha = 0
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(overlayView)
        
        // Create stinky container with red background
        let stinkyContainer = UIView()
        stinkyContainer.backgroundColor = UIColor.systemRed
        stinkyContainer.layer.cornerRadius = 20
        stinkyContainer.layer.shadowColor = UIColor.red.cgColor
        stinkyContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        stinkyContainer.layer.shadowRadius = 20
        stinkyContainer.layer.shadowOpacity = 0.4
        stinkyContainer.translatesAutoresizingMaskIntoConstraints = false
        stinkyContainer.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        stinkyContainer.alpha = 0
        overlayView.addSubview(stinkyContainer)
        
        // Create stink cloud container
        let stinkContainer = UIView()
        stinkContainer.backgroundColor = UIColor(red: 139/255, green: 69/255, blue: 19/255, alpha: 1.0) // Brown/muddy color
        stinkContainer.layer.cornerRadius = 40
        stinkContainer.layer.borderWidth = 3
        stinkContainer.layer.borderColor = UIColor(red: 139/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        stinkContainer.translatesAutoresizingMaskIntoConstraints = false
        stinkyContainer.addSubview(stinkContainer)
        
        // Create stink emoji
        let stinkLabel = UILabel()
        stinkLabel.text = "🤢"
        stinkLabel.font = UIFont.systemFont(ofSize: 40)
        stinkLabel.textAlignment = .center
        stinkLabel.translatesAutoresizingMaskIntoConstraints = false
        stinkContainer.addSubview(stinkLabel)
        
        // Create text label
        let textLabel = UILabel()
        textLabel.text = "No shower detected.You fucking stink! 🤮"
        textLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        textLabel.textAlignment = .center
        textLabel.textColor = .white
        textLabel.numberOfLines = 2
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        stinkyContainer.addSubview(textLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            
            stinkyContainer.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            stinkyContainer.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            stinkyContainer.widthAnchor.constraint(equalToConstant: 250),
            stinkyContainer.heightAnchor.constraint(equalToConstant: 180),
            
            stinkContainer.centerXAnchor.constraint(equalTo: stinkyContainer.centerXAnchor),
            stinkContainer.topAnchor.constraint(equalTo: stinkyContainer.topAnchor, constant: 20),
            stinkContainer.widthAnchor.constraint(equalToConstant: 80),
            stinkContainer.heightAnchor.constraint(equalToConstant: 80),
            
            stinkLabel.centerXAnchor.constraint(equalTo: stinkContainer.centerXAnchor),
            stinkLabel.centerYAnchor.constraint(equalTo: stinkContainer.centerYAnchor),
            
            textLabel.centerXAnchor.constraint(equalTo: stinkyContainer.centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: stinkyContainer.bottomAnchor, constant: -20),
            textLabel.leadingAnchor.constraint(equalTo: stinkyContainer.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: stinkyContainer.trailingAnchor, constant: -16)
        ])
        
        // Animate in with aggressive scaling
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            overlayView.alpha = 1
            stinkyContainer.alpha = 1
            stinkyContainer.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                stinkyContainer.transform = CGAffineTransform.identity
            }) { _ in
                // Auto dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    UIView.animate(withDuration: 0.3, animations: {
                        overlayView.alpha = 0
                        stinkyContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    }) { _ in
                        overlayView.removeFromSuperview()
                    }
                }
            }
        }
        
        // Add aggressive tilting side-to-side animation
        let tiltAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        tiltAnimation.values = [0, -0.3, 0.3, -0.2, 0.2, -0.1, 0.1, 0]
        tiltAnimation.duration = 1.5
        tiltAnimation.repeatCount = 2
        tiltAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        stinkyContainer.layer.add(tiltAnimation, forKey: "tilt")
        
        // Add shaking animation to stink container
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        shakeAnimation.values = [0, -0.15, 0.15, -0.1, 0.1, 0]
        shakeAnimation.duration = 0.3
        shakeAnimation.repeatCount = 5
        stinkContainer.layer.add(shakeAnimation, forKey: "shake")
        
        // Additional vibration bursts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            impactFeedback.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            impactFeedback.impactOccurred()
        }
    }
}
