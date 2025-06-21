import UIKit
import AuthenticationServices

class NewLoginViewController: UIViewController {
    
    private var onboardingData = OnboardingData()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "shower.fill")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let signInLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have an account? Sign in"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var blurEffectView: UIVisualEffectView?
    private var signInModalView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        animateAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(containerView)
        
        containerView.addSubview(logoImageView)
        containerView.addSubview(getStartedButton)
        containerView.addSubview(signInLabel)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            
            logoImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            getStartedButton.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 60),
            getStartedButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            getStartedButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            getStartedButton.heightAnchor.constraint(equalToConstant: 56),
            
            signInLabel.topAnchor.constraint(equalTo: getStartedButton.bottomAnchor, constant: 20),
            signInLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            signInLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(signInTapped))
        signInLabel.addGestureRecognizer(tapGesture)
    }
    
    private func animateAppearance() {
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        })
    }
    
    @objc private func getStartedTapped() {
        let raceSelectionVC = RaceSelectionViewController()
        raceSelectionVC.onboardingData = self.onboardingData
        navigationController?.pushViewController(raceSelectionVC, animated: true)
    }
    
    @objc private func signInTapped() {
        showAppleSignInModal()
    }
    
    private func showAppleSignInModal() {
        // Create blur effect
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        blurEffectView?.alpha = 0
        
        guard let blurView = blurEffectView else { return }
        view.addSubview(blurView)
        
        // Create modal view
        signInModalView = UIView()
        signInModalView?.backgroundColor = .systemBackground
        signInModalView?.layer.cornerRadius = 20
        signInModalView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        signInModalView?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let modalView = signInModalView else { return }
        view.addSubview(modalView)
        
        // Handle
        let handleView = UIView()
        handleView.backgroundColor = .systemGray3
        handleView.layer.cornerRadius = 2.5
        handleView.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(handleView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Sign In"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(titleLabel)
        
        // Apple Sign In Button
        let appleSignInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        appleSignInButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(appleSignInButton)
        
        NSLayoutConstraint.activate([
            modalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            modalView.heightAnchor.constraint(equalToConstant: 250),
            
            handleView.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: modalView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 50),
            handleView.heightAnchor.constraint(equalToConstant: 5),
            
            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -20),
            
            appleSignInButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            appleSignInButton.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 20),
            appleSignInButton.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -20),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Animate in
        modalView.transform = CGAffineTransform(translationX: 0, y: 250)
        
        UIView.animate(withDuration: 0.3, animations: {
            blurView.alpha = 1
            modalView.transform = .identity
        })
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        blurView.addGestureRecognizer(tapGesture)
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
    
    @objc private func dismissModal() {
        guard let blurView = blurEffectView, let modalView = signInModalView else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            blurView.alpha = 0
            modalView.transform = CGAffineTransform(translationX: 0, y: 250)
        }) { _ in
            blurView.removeFromSuperview()
            modalView.removeFromSuperview()
            self.blurEffectView = nil
            self.signInModalView = nil
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension NewLoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Handle successful sign in
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Store user info and set login state
            let userEmail = appleIDCredential.email ?? "user@apple.com"
            AuthService.shared.signUp(email: userEmail, password: "apple_auth_\(userEmail)")
        }
        dismissModal()
        navigateToMainScreen()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
        print("Apple Sign In Error: \(error.localizedDescription)")
    }
    
    private func navigateToMainScreen() {
        let mainViewController = MainViewController()
        let navController = UINavigationController(rootViewController: mainViewController)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = navController
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension NewLoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
} 