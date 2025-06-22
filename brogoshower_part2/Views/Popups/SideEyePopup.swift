import UIKit

class SideEyePopup {
    static func show(on viewController: UIViewController) {
        // Create overlay view
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlayView.alpha = 0
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(overlayView)
        
        // Create container
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 20
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 10)
        container.layer.shadowRadius = 20
        container.layer.shadowOpacity = 0.2
        container.translatesAutoresizingMaskIntoConstraints = false
        container.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        container.alpha = 0
        overlayView.addSubview(container)
        
        // Create image view for side-eye
        let sideEyeImageView = UIImageView(image: UIImage(named: "sideeye"))
        sideEyeImageView.contentMode = .scaleAspectFit
        sideEyeImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(sideEyeImageView)
        
        // Create caption label
        let captionLabel = UILabel()
        captionLabel.text = "are you serious bro?"
        captionLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        captionLabel.textAlignment = .center
        captionLabel.textColor = .label
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(captionLabel)
        
        // Create button
        let showerButton = UIButton(type: .system)
        showerButton.setTitle("my bad ill shower", for: .normal)
        showerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        showerButton.backgroundColor = UIColor.systemBlue
        showerButton.setTitleColor(.white, for: .normal)
        showerButton.layer.cornerRadius = 12
        showerButton.translatesAutoresizingMaskIntoConstraints = false
        showerButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        container.addSubview(showerButton)
        
        // Store references for button action
        overlayView.tag = 998
        
        // Setup constraints
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            
            container.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 280),
            
            sideEyeImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            sideEyeImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            sideEyeImageView.widthAnchor.constraint(equalToConstant: 200),
            sideEyeImageView.heightAnchor.constraint(equalToConstant: 200),
            
            captionLabel.topAnchor.constraint(equalTo: sideEyeImageView.bottomAnchor, constant: 16),
            captionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            captionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            showerButton.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 20),
            showerButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            showerButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            showerButton.heightAnchor.constraint(equalToConstant: 44),
            showerButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
        
        // Animate in
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            overlayView.alpha = 1
            container.alpha = 1
            container.transform = CGAffineTransform.identity
        })
        
        // Add tap to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        overlayView.addGestureRecognizer(tapGesture)
    }
    
    @objc private static func dismissPopup() {
        if let window = UIApplication.shared.windows.first,
           let overlayView = window.viewWithTag(998) {
            UIView.animate(withDuration: 0.3, animations: {
                overlayView.alpha = 0
            }) { _ in
                overlayView.removeFromSuperview()
            }
        }
    }
}