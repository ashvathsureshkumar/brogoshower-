import UIKit

class SignUpViewController: UIViewController {

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
        label.text = "Create Account"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Join us to start tracking your hygiene habits"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email address"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .label
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password (6+ characters)"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .label
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let confirmPasswordContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm password"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .label
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let passwordStrengthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupKeyboardObservers()
        setupNavigationBar()
        animateInitialAppearance()
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(emailContainerView)
        contentView.addSubview(passwordContainerView)
        contentView.addSubview(passwordStrengthLabel)
        contentView.addSubview(confirmPasswordContainerView)
        contentView.addSubview(signUpButton)
        contentView.addSubview(loadingIndicator)
        
        emailContainerView.addSubview(emailTextField)
        passwordContainerView.addSubview(passwordTextField)
        confirmPasswordContainerView.addSubview(confirmPasswordTextField)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            emailContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            emailContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            emailContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            emailContainerView.heightAnchor.constraint(equalToConstant: 56),
            
            emailTextField.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: -16),
            emailTextField.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),

            passwordContainerView.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 16),
            passwordContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            passwordContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            passwordContainerView.heightAnchor.constraint(equalToConstant: 56),
            
            passwordTextField.leadingAnchor.constraint(equalTo: passwordContainerView.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordContainerView.trailingAnchor, constant: -16),
            passwordTextField.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            
            passwordStrengthLabel.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 8),
            passwordStrengthLabel.leadingAnchor.constraint(equalTo: passwordContainerView.leadingAnchor, constant: 16),
            passwordStrengthLabel.trailingAnchor.constraint(equalTo: passwordContainerView.trailingAnchor, constant: -16),

            confirmPasswordContainerView.topAnchor.constraint(equalTo: passwordStrengthLabel.bottomAnchor, constant: 8),
            confirmPasswordContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            confirmPasswordContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            confirmPasswordContainerView.heightAnchor.constraint(equalToConstant: 56),
            
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordContainerView.leadingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: confirmPasswordContainerView.trailingAnchor, constant: -16),
            confirmPasswordTextField.centerYAnchor.constraint(equalTo: confirmPasswordContainerView.centerYAnchor),

            signUpButton.topAnchor.constraint(equalTo: confirmPasswordContainerView.bottomAnchor, constant: 32),
            signUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            signUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            signUpButton.heightAnchor.constraint(equalToConstant: 56),
            signUpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: signUpButton.centerYAnchor)
        ])
        
        // Add text field delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        // Add targets for text field changes
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = ""
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func animateInitialAppearance() {
        // Set initial state
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        emailContainerView.alpha = 0
        passwordContainerView.alpha = 0
        confirmPasswordContainerView.alpha = 0
        signUpButton.alpha = 0
        
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -20)
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: -20)
        
        // Animate elements in sequence
        UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseOut], animations: {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = CGAffineTransform.identity
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseOut], animations: {
            self.subtitleLabel.alpha = 1
            self.subtitleLabel.transform = CGAffineTransform.identity
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [.curveEaseOut], animations: {
            self.emailContainerView.alpha = 1
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.4, options: [.curveEaseOut], animations: {
            self.passwordContainerView.alpha = 1
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseOut], animations: {
            self.confirmPasswordContainerView.alpha = 1
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.6, options: [.curveEaseOut], animations: {
            self.signUpButton.alpha = 1
        })
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    @objc private func textFieldDidChange() {
        updateSignUpButtonState()
    }
    
    @objc private func passwordDidChange() {
        updatePasswordStrength()
        updateSignUpButtonState()
    }
    
    private func updatePasswordStrength() {
        guard let password = passwordTextField.text, !password.isEmpty else {
            UIView.animate(withDuration: 0.2) {
                self.passwordStrengthLabel.alpha = 0
            }
            return
        }
        
        let strength = getPasswordStrength(password)
        passwordStrengthLabel.text = strength.message
        passwordStrengthLabel.textColor = strength.color
        
        UIView.animate(withDuration: 0.2) {
            self.passwordStrengthLabel.alpha = 1
        }
    }
    
    private func getPasswordStrength(_ password: String) -> (message: String, color: UIColor) {
        if password.count < 6 {
            return ("Password must be at least 6 characters", .systemRed)
        } else if password.count < 8 {
            return ("Weak password", .systemOrange)
        } else if password.count >= 8 && password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
            return ("Strong password", .systemGreen)
        } else {
            return ("Good password", .systemBlue)
        }
    }
    
    private func updateSignUpButtonState() {
        let hasEmail = !(emailTextField.text?.isEmpty ?? true)
        let hasPassword = !(passwordTextField.text?.isEmpty ?? true)
        let hasConfirmPassword = !(confirmPasswordTextField.text?.isEmpty ?? true)
        
        UIView.animate(withDuration: 0.2) {
            self.signUpButton.alpha = hasEmail && hasPassword && hasConfirmPassword ? 1.0 : 0.6
        }
    }

    @objc private func handleSignUp() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showErrorAlert(message: "Please fill in all fields.")
            return
        }
        
        guard email.contains("@") else {
            showErrorAlert(message: "Please enter a valid email address.")
            return
        }
        
        guard password.count >= 6 else {
            showErrorAlert(message: "Password must be at least 6 characters long.")
            return
        }
        
        guard password == confirmPassword else {
            showErrorAlert(message: "Passwords do not match.")
            return
        }
        
        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            self.signUpButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.signUpButton.transform = CGAffineTransform.identity
            }
        }
        
        // Show loading state
        startLoading()
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.stopLoading()
            
            if AuthService.shared.signUp(email: email, password: password) {
                self.showSuccessAlert()
            } else {
                self.showErrorAlert(message: "This email is already registered. Please use a different email or try logging in.")
            }
        }
    }
    
    private func startLoading() {
        signUpButton.setTitle("", for: .normal)
        loadingIndicator.startAnimating()
        signUpButton.isEnabled = false
        
        UIView.animate(withDuration: 0.2) {
            self.signUpButton.alpha = 0.7
        }
    }
    
    private func stopLoading() {
        loadingIndicator.stopAnimating()
        signUpButton.setTitle("Create Account", for: .normal)
        signUpButton.isEnabled = true
        
        UIView.animate(withDuration: 0.2) {
            self.signUpButton.alpha = 1.0
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
        
        // Add shake animation to indicate error
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.07
        shake.repeatCount = 4
        shake.autoreverses = true
        shake.fromValue = NSValue(cgPoint: CGPoint(x: signUpButton.center.x - 5, y: signUpButton.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: signUpButton.center.x + 5, y: signUpButton.center.y))
        signUpButton.layer.add(shake, forKey: "position")
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Account created successfully! Welcome to Shower as a Service.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Get Started", style: .default) { _ in
            self.navigateToMainScreen()
        })
        present(alert, animated: true)
    }

    private func navigateToMainScreen() {
        let mainViewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        present(navigationController, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        var containerView: UIView
        
        switch textField {
        case emailTextField:
            containerView = emailContainerView
        case passwordTextField:
            containerView = passwordContainerView
        case confirmPasswordTextField:
            containerView = confirmPasswordContainerView
        default:
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
            containerView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var containerView: UIView
        
        switch textField {
        case emailTextField:
            containerView = emailContainerView
        case passwordTextField:
            containerView = passwordContainerView
        case confirmPasswordTextField:
            containerView = confirmPasswordContainerView
        default:
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            containerView.layer.borderColor = UIColor.separator.cgColor
            containerView.transform = CGAffineTransform.identity
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            confirmPasswordTextField.resignFirstResponder()
            handleSignUp()
        default:
            break
        }
        return true
    }
} 