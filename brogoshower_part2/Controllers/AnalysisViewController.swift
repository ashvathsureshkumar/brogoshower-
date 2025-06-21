import UIKit
import AuthenticationServices

class AnalysisViewController: UIViewController {
    
    var onboardingData = OnboardingData()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Analyzing Your Hygiene Needs..."
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.tintColor = .systemBlue
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let analysisContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let analysisIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chart.bar.doc.horizontal")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let analysisResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.text = "Based on your responses, our advanced AI algorithm has calculated your personal hygiene score and shower recommendations."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let continueWithAppleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .black)
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        startAnalysis()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(analysisContainerView)
        contentView.addSubview(continueWithAppleButton)
        
        analysisContainerView.addSubview(analysisIconView)
        analysisContainerView.addSubview(analysisResultLabel)
        analysisContainerView.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            progressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            analysisContainerView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 60),
            analysisContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            analysisContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            analysisIconView.topAnchor.constraint(equalTo: analysisContainerView.topAnchor, constant: 24),
            analysisIconView.centerXAnchor.constraint(equalTo: analysisContainerView.centerXAnchor),
            analysisIconView.widthAnchor.constraint(equalToConstant: 50),
            analysisIconView.heightAnchor.constraint(equalToConstant: 50),
            
            analysisResultLabel.topAnchor.constraint(equalTo: analysisIconView.bottomAnchor, constant: 20),
            analysisResultLabel.leadingAnchor.constraint(equalTo: analysisContainerView.leadingAnchor, constant: 20),
            analysisResultLabel.trailingAnchor.constraint(equalTo: analysisContainerView.trailingAnchor, constant: -20),
            
            detailsLabel.topAnchor.constraint(equalTo: analysisResultLabel.bottomAnchor, constant: 16),
            detailsLabel.leadingAnchor.constraint(equalTo: analysisContainerView.leadingAnchor, constant: 20),
            detailsLabel.trailingAnchor.constraint(equalTo: analysisContainerView.trailingAnchor, constant: -20),
            detailsLabel.bottomAnchor.constraint(equalTo: analysisContainerView.bottomAnchor, constant: -24),
            
            continueWithAppleButton.topAnchor.constraint(equalTo: analysisContainerView.bottomAnchor, constant: 40),
            continueWithAppleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            continueWithAppleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            continueWithAppleButton.heightAnchor.constraint(equalToConstant: 50),
            continueWithAppleButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupActions() {
        continueWithAppleButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
    }
    
    private func startAnalysis() {
        // Animate progress bar
        progressView.setProgress(0, animated: false)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            let currentProgress = self.progressView.progress
            let increment: Float = 0.02
            
            if currentProgress < 1.0 {
                self.progressView.setProgress(currentProgress + increment, animated: true)
            } else {
                timer.invalidate()
                self.showAnalysisResults()
            }
        }
    }
    
    private func showAnalysisResults() {
        // Get the analysis result based on shower frequency
        guard let frequency = onboardingData.showerFrequency else { return }
        analysisResultLabel.text = frequency.analysisResult
        
        // Animate in the results
        UIView.animate(withDuration: 0.8, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: [], animations: {
            self.analysisContainerView.alpha = 1
            self.analysisContainerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.analysisContainerView.transform = .identity
            })
        }
        
        // Show continue button after results
        UIView.animate(withDuration: 0.6, delay: 1.5, options: .curveEaseOut, animations: {
            self.continueWithAppleButton.alpha = 1
            self.continueWithAppleButton.transform = CGAffineTransform(translationX: 0, y: -20)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.continueWithAppleButton.transform = .identity
            })
        }
    }
    
    @objc private func handleAppleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AnalysisViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Handle successful sign in
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Store user info and set login state
            let userEmail = appleIDCredential.email ?? "user@apple.com"
            AuthService.shared.signUp(email: userEmail, password: "apple_auth_\(userEmail)")
        }
        navigateToMainScreen()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
        print("Apple Sign In Error: \(error.localizedDescription)")
        
        // For demo purposes, still navigate to main screen
        navigateToMainScreen()
    }
    
    private func navigateToMainScreen() {
        let mainViewController = MainViewController()
        let navController = UINavigationController(rootViewController: mainViewController)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = navController
            
            // Add a nice transition
            UIView.transition(with: sceneDelegate.window!, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AnalysisViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
} 