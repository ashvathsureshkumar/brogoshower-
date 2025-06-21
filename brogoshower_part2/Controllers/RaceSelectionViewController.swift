import UIKit

class RaceSelectionViewController: UIViewController {
    
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
        label.text = "(yes this matters)"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "What race are you?"
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
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
    
    private var selectedRace: Race?
    private var raceButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupRaceOptions()
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
        
        contentView.addSubview(titleLabel)
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            questionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
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
    
    private func setupRaceOptions() {
        Race.allCases.forEach { race in
            let button = createOptionButton(title: race.rawValue, race: race)
            raceButtons.append(button)
            optionsStackView.addArrangedSubview(button)
        }
    }
    
    private func createOptionButton(title: String, race: Race) -> UIButton {
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
        
        button.addTarget(self, action: #selector(raceOptionTapped(_:)), for: .touchUpInside)
        button.tag = Race.allCases.firstIndex(of: race) ?? 0
        
        return button
    }
    
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
    }
    
    private func animateAppearance() {
        titleLabel.alpha = 0
        questionLabel.alpha = 0
        optionsStackView.alpha = 0
        continueButton.alpha = 0
        
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        questionLabel.transform = CGAffineTransform(translationX: 0, y: -20)
        optionsStackView.transform = CGAffineTransform(translationX: 0, y: 20)
        continueButton.transform = CGAffineTransform(translationX: 0, y: 30)
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
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
    
    @objc private func raceOptionTapped(_ sender: UIButton) {
        let race = Race.allCases[sender.tag]
        selectedRace = race
        onboardingData.race = race
        
        // Update button states
        raceButtons.forEach { button in
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
        let majorSelectionVC = MajorSelectionViewController()
        majorSelectionVC.onboardingData = self.onboardingData
        navigationController?.pushViewController(majorSelectionVC, animated: true)
    }
} 