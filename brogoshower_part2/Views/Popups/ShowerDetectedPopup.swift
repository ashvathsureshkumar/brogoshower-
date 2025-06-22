import UIKit

class ShowerDetectedPopup {
    static func show(on viewController: UIViewController) {
        // Create overlay view
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.alpha = 0
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(overlayView)
        
        // Create success container
        let successContainer = UIView()
        successContainer.backgroundColor = .systemBackground
        successContainer.layer.cornerRadius = 20
        successContainer.layer.shadowColor = UIColor.black.cgColor
        successContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        successContainer.layer.shadowRadius = 20
        successContainer.layer.shadowOpacity = 0.2
        successContainer.translatesAutoresizingMaskIntoConstraints = false
        successContainer.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        successContainer.alpha = 0
        overlayView.addSubview(successContainer)
        
        // Create checkmark circle
        let checkmarkContainer = UIView()
        checkmarkContainer.backgroundColor = UIColor.systemGreen
        checkmarkContainer.layer.cornerRadius = 40
        checkmarkContainer.translatesAutoresizingMaskIntoConstraints = false
        successContainer.addSubview(checkmarkContainer)
        
        // Create checkmark image
        let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmarkImageView.tintColor = .white
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkContainer.addSubview(checkmarkImageView)
        
        // Create text label
        let textLabel = UILabel()
        textLabel.text = "Shower detected... surprisingly. Good job ig. You prob still smell like shit tho. Put on some deodorant 😷"
        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel.textAlignment = .center
        textLabel.textColor = .label
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        successContainer.addSubview(textLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            
            successContainer.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            successContainer.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            successContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 320),
            successContainer.leadingAnchor.constraint(greaterThanOrEqualTo: overlayView.leadingAnchor, constant: 20),
            successContainer.trailingAnchor.constraint(lessThanOrEqualTo: overlayView.trailingAnchor, constant: -20),
            
            checkmarkContainer.centerXAnchor.constraint(equalTo: successContainer.centerXAnchor),
            checkmarkContainer.topAnchor.constraint(equalTo: successContainer.topAnchor, constant: 20),
            checkmarkContainer.widthAnchor.constraint(equalToConstant: 80),
            checkmarkContainer.heightAnchor.constraint(equalToConstant: 80),
            
            checkmarkImageView.centerXAnchor.constraint(equalTo: checkmarkContainer.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: checkmarkContainer.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 40),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 40),
            
            textLabel.topAnchor.constraint(equalTo: checkmarkContainer.bottomAnchor, constant: 16),
            textLabel.leadingAnchor.constraint(equalTo: successContainer.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: successContainer.trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: successContainer.bottomAnchor, constant: -20)
        ])
        
        // Animate in
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            overlayView.alpha = 1
            successContainer.alpha = 1
            successContainer.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                successContainer.transform = CGAffineTransform.identity
            }) { _ in
                // Auto dismiss after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 0.3, animations: {
                        overlayView.alpha = 0
                        successContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    }) { _ in
                        overlayView.removeFromSuperview()
                    }
                }
            }
        }
        
        // Add pulse animation to checkmark
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.6
        pulseAnimation.fromValue = 0.3
        pulseAnimation.toValue = 1.0
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        checkmarkContainer.layer.add(pulseAnimation, forKey: "pulse")
    }
}