import UIKit

class MajorSelectionViewController: UIViewController {
    
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
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Only use this app if you are one of the majors below"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "What's your major?"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.alpha = 0.5
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var selectedMajor: Major?
    private var majorButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupMajorOptions()
        setupActions()
        animateAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(warningLabel)
        contentView.addSubview(questionLabel)
        contentView.addSubview(optionsStackView)
        contentView.addSubview(continueButton)
        
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
            
            warningLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            warningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            warningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            questionLabel.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 24),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            optionsStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 40),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            continueButton.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 40),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            continueButton.heightAnchor.constraint(equalToConstant: 56),
            continueButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupMajorOptions() {
        Major.allCases.forEach { major in
            let button = createOptionButton(title: major.rawValue, major: major)
            majorButtons.append(button)
            optionsStackView.addArrangedSubview(button)
        }
    }
    
    private func createOptionButton(title: String, major: Major) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .secondarySystemBackground
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.clear.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        button.addTarget(self, action: #selector(majorOptionTapped(_:)), for: .touchUpInside)
        button.tag = Major.allCases.firstIndex(of: major) ?? 0
        
        return button
    }
    
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
    }
    
    private func animateAppearance() {
        warningLabel.alpha = 0
        questionLabel.alpha = 0
        optionsStackView.alpha = 0
        continueButton.alpha = 0
        
        warningLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        questionLabel.transform = CGAffineTransform(translationX: 0, y: -20)
        optionsStackView.transform = CGAffineTransform(translationX: 0, y: 20)
        continueButton.transform = CGAffineTransform(translationX: 0, y: 30)
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut, animations: {
            self.warningLabel.alpha = 1
            self.warningLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseOut, animations: {
            self.questionLabel.alpha = 1
            self.questionLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.3, options: .curveEaseOut, animations: {
            self.optionsStackView.alpha = 1
            self.optionsStackView.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.4, options: .curveEaseOut, animations: {
            self.continueButton.alpha = 0.5
            self.continueButton.transform = .identity
        })
    }
    
    @objc private func majorOptionTapped(_ sender: UIButton) {
        let major = Major.allCases[sender.tag]
        selectedMajor = major
        onboardingData.major = major
        
        // Update button states
        majorButtons.forEach { button in
            button.layer.borderColor = UIColor.clear.cgColor
            button.backgroundColor = .secondarySystemBackground
        }
        
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        sender.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        
        // Enable continue button
        UIView.animate(withDuration: 0.3) {
            self.continueButton.alpha = 1
            self.continueButton.isEnabled = true
        }
    }
    
    @objc private func continueTapped() {
        let showerFrequencyVC = ShowerFrequencyViewController()
        showerFrequencyVC.onboardingData = self.onboardingData
        navigationController?.pushViewController(showerFrequencyVC, animated: true)
    }
} 