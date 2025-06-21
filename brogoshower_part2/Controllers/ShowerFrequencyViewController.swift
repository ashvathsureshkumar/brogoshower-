import UIKit

class ShowerFrequencyViewController: UIViewController {
    
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
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "How many times do you shower a week?"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
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
    
    private let dogImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "side-eye-dog")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.alpha = 0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
    
    private var selectedFrequency: ShowerFrequency?
    private var frequencyButtons: [UIButton] = []
    private var dogImageHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupFrequencyOptions()
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
        
        contentView.addSubview(questionLabel)
        contentView.addSubview(optionsStackView)
        contentView.addSubview(dogImageView)
        contentView.addSubview(continueButton)
        
        dogImageHeightConstraint = dogImageView.heightAnchor.constraint(equalToConstant: 0)
        
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
            
            questionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            optionsStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 40),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            dogImageView.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 20),
            dogImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dogImageView.widthAnchor.constraint(equalToConstant: 200),
            dogImageHeightConstraint,
            
            continueButton.topAnchor.constraint(equalTo: dogImageView.bottomAnchor, constant: 20),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            continueButton.heightAnchor.constraint(equalToConstant: 56),
            continueButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupFrequencyOptions() {
        ShowerFrequency.allCases.forEach { frequency in
            let button = createOptionButton(title: frequency.rawValue, frequency: frequency)
            frequencyButtons.append(button)
            optionsStackView.addArrangedSubview(button)
        }
    }
    
    private func createOptionButton(title: String, frequency: ShowerFrequency) -> UIButton {
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
        
        button.addTarget(self, action: #selector(frequencyOptionTapped(_:)), for: .touchUpInside)
        button.tag = ShowerFrequency.allCases.firstIndex(of: frequency) ?? 0
        
        return button
    }
    
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
    }
    
    private func animateAppearance() {
        questionLabel.alpha = 0
        optionsStackView.alpha = 0
        continueButton.alpha = 0
        
        questionLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        optionsStackView.transform = CGAffineTransform(translationX: 0, y: 20)
        continueButton.transform = CGAffineTransform(translationX: 0, y: 30)
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut, animations: {
            self.questionLabel.alpha = 1
            self.questionLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseOut, animations: {
            self.optionsStackView.alpha = 1
            self.optionsStackView.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.3, options: .curveEaseOut, animations: {
            self.continueButton.alpha = 0.5
            self.continueButton.transform = .identity
        })
    }
    
    private func showDogAnimation() {
        dogImageHeightConstraint.constant = 200
        
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.dogImageView.alpha = 1
            self.view.layoutIfNeeded()
        })
        
        // Add a little wiggle animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.wiggleDog()
        }
    }
    
    private func hideDogAnimation() {
        dogImageHeightConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dogImageView.alpha = 0
            self.view.layoutIfNeeded()
        })
    }
    
    private func wiggleDog() {
        UIView.animate(withDuration: 0.1, animations: {
            self.dogImageView.transform = CGAffineTransform(rotationAngle: 0.05)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.dogImageView.transform = CGAffineTransform(rotationAngle: -0.05)
            }) { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.dogImageView.transform = .identity
                })
            }
        }
    }
    
    @objc private func frequencyOptionTapped(_ sender: UIButton) {
        let frequency = ShowerFrequency.allCases[sender.tag]
        selectedFrequency = frequency
        onboardingData.showerFrequency = frequency
        
        // Update button states
        frequencyButtons.forEach { button in
            button.layer.borderColor = UIColor.clear.cgColor
            button.backgroundColor = .secondarySystemBackground
        }
        
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        sender.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        
        // Show or hide dog based on frequency
        if frequency.needsDogAnimation {
            showDogAnimation()
        } else {
            hideDogAnimation()
        }
        
        // Enable continue button
        UIView.animate(withDuration: 0.3) {
            self.continueButton.alpha = 1
            self.continueButton.isEnabled = true
        }
    }
    
    @objc private func continueTapped() {
        let analysisVC = AnalysisViewController()
        analysisVC.onboardingData = self.onboardingData
        navigationController?.pushViewController(analysisVC, animated: true)
    }
} 