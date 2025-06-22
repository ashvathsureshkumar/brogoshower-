import UIKit

class StinkyPopup {
    static func show(on viewController: UIViewController) {
        // Create overlay view
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.alpha = 0
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(overlayView)
        
        // Create stinky container
        let stinkyContainer = UIView()
        stinkyContainer.backgroundColor = .systemBackground
        stinkyContainer.layer.cornerRadius = 20
        stinkyContainer.layer.shadowColor = UIColor.black.cgColor
        stinkyContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        stinkyContainer.layer.shadowRadius = 20
        stinkyContainer.layer.shadowOpacity = 0.2
        stinkyContainer.translatesAutoresizingMaskIntoConstraints = false
        stinkyContainer.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        stinkyContainer.alpha = 0
        overlayView.addSubview(stinkyContainer)
        
        // Create stink cloud container
        let stinkContainer = UIView()
        stinkContainer.backgroundColor = UIColor(red: 139/255, green: 69/255, blue: 19/255, alpha: 1.0) // Brown/muddy color
        stinkContainer.layer.cornerRadius = 40
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
        textLabel.text = "No shower detected.\You fucking stink! 🦨"
        textLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        textLabel.textAlignment = .center
        textLabel.textColor = .label
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
        
        // Animate in
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            overlayView.alpha = 1
            stinkyContainer.alpha = 1
            stinkyContainer.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                stinkyContainer.transform = CGAffineTransform.identity
            }) { _ in
                // Auto dismiss after 2.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    UIView.animate(withDuration: 0.3, animations: {
                        overlayView.alpha = 0
                        stinkyContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    }) { _ in
                        overlayView.removeFromSuperview()
                    }
                }
            }
        }
        
        // Add wiggle animation to stink container
        let wiggleAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        wiggleAnimation.values = [0, -0.1, 0.1, 0]
        wiggleAnimation.duration = 0.4
        wiggleAnimation.repeatCount = 3
        stinkContainer.layer.add(wiggleAnimation, forKey: "wiggle")
    }
}
