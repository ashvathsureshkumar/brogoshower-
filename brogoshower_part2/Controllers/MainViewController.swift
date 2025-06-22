import UIKit
import MessageUI

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let weekdaysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let takePictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Did you shower today? 🤢", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleTakePicture), for: .touchUpInside)
        return button
    }()
    
    private let challengeFriendsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Challenge Friends to Shower 💪", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        button.backgroundColor = UIColor(red: 218/255, green: 165/255, blue: 32/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleChallengeFriends), for: .touchUpInside)
        return button
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var showerData: [String] = []
    private var monthData: [Date?] = []
    private var currentDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Shower as a Service 🚿"
        setupViews()
        setupNavigationBar()
        loadProfileInfo()
        fetchShowerData()
        setupCalendar()
        updateStatsLabel()
    }
    
    private func setupCalendar() {
        updateMonthLabel()
        setupMonthData()
        collectionView.reloadData()
        updateStatsLabel()
    }
    
    private func setupMonthData() {
        monthData.removeAll()
        
        let calendar = Calendar.current
        var calendarForMonth = calendar
        calendarForMonth.firstWeekday = 1 // Sunday
        
        guard let monthRange = calendarForMonth.range(of: .day, in: .month, for: currentDate) else { return }
        let firstDayOfMonth = calendarForMonth.date(from: calendarForMonth.dateComponents([.year, .month], from: currentDate))!
        let firstWeekday = calendarForMonth.component(.weekday, from: firstDayOfMonth)
        
        let daysToPrepend = firstWeekday - calendarForMonth.firstWeekday
        if daysToPrepend > 0 {
            for _ in 0..<daysToPrepend {
                monthData.append(nil)
            }
        }
        
        for day in monthRange {
            let date = calendarForMonth.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
            monthData.append(date)
        }
        
        let cellsToFill = 35 // 7x5 grid
        while monthData.count < cellsToFill {
            monthData.append(nil)
        }
        
        if monthData.count > cellsToFill {
            monthData = Array(monthData.prefix(cellsToFill))
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(goToPreviousMonth))
        let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(goToNextMonth))
        navigationItem.leftBarButtonItems = [previousButton, nextButton]
    }

    private func setupViews() {
        view.addSubview(emailLabel)
        view.addSubview(monthLabel)
        view.addSubview(statsLabel)
        view.addSubview(weekdaysStackView)
        view.addSubview(collectionView)
        view.addSubview(takePictureButton)
        view.addSubview(challengeFriendsButton)
        
        setupWeekdayLabels()

        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            monthLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 24),
            monthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statsLabel.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 8),
            statsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            weekdaysStackView.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 24),
            weekdaysStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weekdaysStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            weekdaysStackView.heightAnchor.constraint(equalToConstant: 30),
            
            collectionView.topAnchor.constraint(equalTo: weekdaysStackView.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 5.0/7.0),

            takePictureButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 32),
            takePictureButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            takePictureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            takePictureButton.heightAnchor.constraint(equalToConstant: 56),
            
            challengeFriendsButton.topAnchor.constraint(equalTo: takePictureButton.bottomAnchor, constant: 16),
            challengeFriendsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            challengeFriendsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            challengeFriendsButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupWeekdayLabels() {
        for view in weekdaysStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        for day in weekdays {
            let label = UILabel()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            weekdaysStackView.addArrangedSubview(label)
        }
    }
    
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: currentDate)
    }
    
    private func updateStatsLabel() {
        let currentMonthShowers = getCurrentMonthShowerCount()
        statsLabel.text = "\(currentMonthShowers) showers this month"
    }
    
    private func getCurrentMonthShowerCount() -> Int {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        return showerData.filter { dateString in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let date = formatter.date(from: dateString) else { return false }
            
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            
            return month == currentMonth && year == currentYear
        }.count
    }

    @objc private func goToPreviousMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        animateCalendarTransition()
    }

    @objc private func goToNextMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
        animateCalendarTransition()
    }
    
    private func animateCalendarTransition() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.collectionView.alpha = 0.7
        }) { _ in
            self.setupCalendar()
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.collectionView.alpha = 1.0
            })
        }
    }

    private func loadProfileInfo() {
        if let currentUser = AuthService.shared.getCurrentUser() {
            emailLabel.text = currentUser
        } else {
            emailLabel.text = "Not logged in"
        }
    }

    private func fetchShowerData() {
        showerData = OpenAIService.shared.getShowerData()
        collectionView.reloadData()
        updateStatsLabel()
    }
    
    @objc private func handleTakePicture() {
        // Add button press animation
        UIView.animate(withDuration: 0.1, animations: {
            self.takePictureButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.takePictureButton.transform = CGAffineTransform.identity
            }
        }
        
        #if targetEnvironment(simulator)
        showSimulatorAlert()
        return
        #endif
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showCameraUnavailableAlert()
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    private func showSimulatorAlert() {
        let alert = UIAlertController(
            title: "Simulator Detected",
            message: "Camera functionality is not available in the iOS Simulator. Please run this app on a physical device.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showCameraUnavailableAlert() {
        let alert = UIAlertController(
            title: "Camera Unavailable",
            message: "The camera is not available on this device.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleLogout() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            AuthService.shared.logout()
            self.navigateToLogin()
        })
        present(alert, animated: true)
    }
    
    private func navigateToLogin() {
        let loginViewController = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        guard let imageData = image.pngData() else {
            print("Could not get PNG data from image")
            return
        }

        // Show loading animation
        showAnalysisLoadingAnimation()

        OpenAIService.shared.analyzeImage(image: imageData) { [weak self] result in
            DispatchQueue.main.async {
                // Hide loading animation
                self?.hideAnalysisLoadingAnimation()
                
                switch result {
                case .success(let analysis):
                    print("Claude Vision Response: \(analysis)")
                    if analysis.lowercased().contains("showered") && !analysis.lowercased().contains("not showered") {
                        self?.showShowerDetectedAnimation()
                        self?.saveShowerForToday()
                        self?.fetchShowerData()
                    } else {
                        self?.showAnalysisResult("No shower detected in image")
                    }
                case .failure(let error):
                    self?.showAnalysisResult("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private var analysisLoadingOverlay: UIView?
    
    private func showAnalysisLoadingAnimation() {
        // Remove any existing overlay
        hideAnalysisLoadingAnimation()
        
        // Create overlay view
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlayView.alpha = 0
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        // Create loading container
        let loadingContainer = UIView()
        loadingContainer.backgroundColor = .systemBackground
        loadingContainer.layer.cornerRadius = 20
        loadingContainer.layer.shadowColor = UIColor.black.cgColor
        loadingContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        loadingContainer.layer.shadowRadius = 20
        loadingContainer.layer.shadowOpacity = 0.2
        loadingContainer.translatesAutoresizingMaskIntoConstraints = false
        loadingContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        loadingContainer.alpha = 0
        overlayView.addSubview(loadingContainer)
        
        // Create AI icon
        let aiIconContainer = UIView()
        aiIconContainer.backgroundColor = UIColor.systemBlue
        aiIconContainer.layer.cornerRadius = 30
        aiIconContainer.translatesAutoresizingMaskIntoConstraints = false
        loadingContainer.addSubview(aiIconContainer)
        
        let aiIcon = UIImageView(image: UIImage(systemName: "brain.head.profile"))
        aiIcon.tintColor = .white
        aiIcon.contentMode = .scaleAspectFit
        aiIcon.translatesAutoresizingMaskIntoConstraints = false
        aiIconContainer.addSubview(aiIcon)
        
        // Create spinner
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .systemBlue
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        loadingContainer.addSubview(spinner)
        
        // Create text labels
        let titleLabel = UILabel()
        titleLabel.text = "AI Analysis"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingContainer.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Analyzing your photo with AI..."
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingContainer.addSubview(subtitleLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingContainer.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            loadingContainer.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            loadingContainer.widthAnchor.constraint(equalToConstant: 300),
            loadingContainer.heightAnchor.constraint(equalToConstant: 180),
            
            aiIconContainer.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            aiIconContainer.topAnchor.constraint(equalTo: loadingContainer.topAnchor, constant: 20),
            aiIconContainer.widthAnchor.constraint(equalToConstant: 60),
            aiIconContainer.heightAnchor.constraint(equalToConstant: 60),
            
            aiIcon.centerXAnchor.constraint(equalTo: aiIconContainer.centerXAnchor),
            aiIcon.centerYAnchor.constraint(equalTo: aiIconContainer.centerYAnchor),
            aiIcon.widthAnchor.constraint(equalToConstant: 30),
            aiIcon.heightAnchor.constraint(equalToConstant: 30),
            
            spinner.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: aiIconContainer.bottomAnchor, constant: 16),
            
            titleLabel.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: loadingContainer.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: loadingContainer.trailingAnchor, constant: -16),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: loadingContainer.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: loadingContainer.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: loadingContainer.bottomAnchor, constant: -16)
        ])
        
        // Store reference
        analysisLoadingOverlay = overlayView
        
        // Animate in
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            overlayView.alpha = 1
            loadingContainer.alpha = 1
            loadingContainer.transform = CGAffineTransform.identity
        })
        
        // Add pulsing animation to AI icon
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.5
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        aiIconContainer.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    private func hideAnalysisLoadingAnimation() {
        guard let overlay = analysisLoadingOverlay else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            overlay.alpha = 0
            overlay.subviews.first?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            overlay.removeFromSuperview()
            self.analysisLoadingOverlay = nil
        }
    }
    
    private func showShowerDetectedAnimation() {
        // Create overlay view
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.alpha = 0
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
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
        textLabel.text = "Shower detected"
        textLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        textLabel.textAlignment = .center
        textLabel.textColor = .label
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        successContainer.addSubview(textLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            successContainer.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            successContainer.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            successContainer.widthAnchor.constraint(equalToConstant: 200),
            successContainer.heightAnchor.constraint(equalToConstant: 160),
            
            checkmarkContainer.centerXAnchor.constraint(equalTo: successContainer.centerXAnchor),
            checkmarkContainer.topAnchor.constraint(equalTo: successContainer.topAnchor, constant: 20),
            checkmarkContainer.widthAnchor.constraint(equalToConstant: 80),
            checkmarkContainer.heightAnchor.constraint(equalToConstant: 80),
            
            checkmarkImageView.centerXAnchor.constraint(equalTo: checkmarkContainer.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: checkmarkContainer.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 40),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 40),
            
            textLabel.centerXAnchor.constraint(equalTo: successContainer.centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: successContainer.bottomAnchor, constant: -20),
            textLabel.leadingAnchor.constraint(equalTo: successContainer.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: successContainer.trailingAnchor, constant: -16)
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
    
    private func saveShowerForToday() {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: today)
        
        var showerDates = UserDefaults.standard.stringArray(forKey: "showerDates") ?? []
        if !showerDates.contains(dateString) {
            showerDates.append(dateString)
            UserDefaults.standard.set(showerDates, forKey: "showerDates")
        }
    }

    private func showAnalysisResult(_ result: String) {
        let alert = UIAlertController(title: "Analysis Result", message: result, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.reuseIdentifier, for: indexPath) as! CalendarCell
        
        let date = monthData[indexPath.item]
        
        if let date = date {
            let isToday = Calendar.current.isDateInToday(date)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: date)
            
            if showerData.contains(dateString) {
                // Blue for shower days
                cell.configure(with: UIColor.systemBlue, isToday: isToday)
            } else {
                // Light gray for no shower days
                cell.configure(with: UIColor.systemGray5, isToday: isToday)
            }
        } else {
            // Transparent for empty cells
            cell.configure(with: .clear)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = 2 * 6 // 6 gaps between 7 columns
        let width = (collectionView.frame.width - CGFloat(totalSpacing)) / 7
        return CGSize(width: width, height: width)
    }

    private func saveShowerDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        if !showerData.contains(dateString) {
            showerData.append(dateString)
            UserDefaults.standard.set(showerData, forKey: "shower_dates")
            collectionView.reloadData()
        }
    }

    @objc private func handleChallengeFriends() {
        // Add button press animation
        UIView.animate(withDuration: 0.1, animations: {
            self.challengeFriendsButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.challengeFriendsButton.transform = CGAffineTransform.identity
            }
        }
        
        MessageService.shared.sendChallenge(from: self, delegate: self)
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        MessageService.handleMessageResult(result, viewController: self)
    }
} 
