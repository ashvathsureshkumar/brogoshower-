import UIKit

// Custom layout for GitHub-style contribution graph
class GitHubContributionLayout: UICollectionViewLayout {
    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    private let itemSize: CGSize = CGSize(width: 11, height: 11)
    private let spacing: CGFloat = 3
    private let numberOfRows: Int = 7 // Days of the week
    
    override func prepare() {
        super.prepare()
        layoutAttributes.removeAll()
        
        guard let collectionView = collectionView else { return }
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let numberOfColumns = (numberOfItems + numberOfRows - 1) / numberOfRows
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let column = item / numberOfRows
            let row = item % numberOfRows
            
            let x = CGFloat(column) * (itemSize.width + spacing)
            let y = CGFloat(row) * (itemSize.height + spacing)
            
            attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
            layoutAttributes.append(attributes)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.item]
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let numberOfColumns = (numberOfItems + numberOfRows - 1) / numberOfRows
        
        let width = CGFloat(numberOfColumns) * itemSize.width + CGFloat(numberOfColumns - 1) * spacing
        let height = CGFloat(numberOfRows) * itemSize.height + CGFloat(numberOfRows - 1) * spacing
        
        return CGSize(width: width, height: height)
    }
}

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🚿 Shower Streak"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contributionStatsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let monthsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = GitHubContributionLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    private let takePictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📸 Take Shower Picture", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleTakePicture), for: .touchUpInside)
        return button
    }()

    private var showerData: [String] = []
    private var yearData: [Date] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "BrogoShower"
        setupYearData()
        setupViews()
        setupNavigationBar()
        loadProfileInfo()
        fetchShowerData()
    }
    
    private func setupYearData() {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Sunday
        let today = Date()
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today) else { return }

        // Get all dates from one year ago to today
        var dates: [Date] = []
        var currentDate = oneYearAgo
        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Pad start to the beginning of the week (Sunday)
        if let firstDate = dates.first {
            let weekdayOfFirstDate = calendar.component(.weekday, from: firstDate) // 1 = Sunday
            let daysToPrepend = weekdayOfFirstDate - calendar.firstWeekday
            if daysToPrepend > 0 {
                for _ in 0..<daysToPrepend {
                    dates.insert(Date.distantPast, at: 0)
                }
            }
        }
        
        // Pad end to the end of the week (Saturday)
        while dates.count % 7 != 0 {
            dates.append(Date.distantPast)
        }
        
        self.yearData = dates
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }

    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(emailLabel)
        view.addSubview(contributionStatsLabel)
        view.addSubview(monthsStackView)
        view.addSubview(daysStackView)
        view.addSubview(collectionView)
        view.addSubview(takePictureButton)
        
        setupMonthLabels()
        setupDayLabels()

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            emailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            contributionStatsLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            contributionStatsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            monthsStackView.topAnchor.constraint(equalTo: contributionStatsLabel.bottomAnchor, constant: 15),
            monthsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70),
            monthsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            monthsStackView.heightAnchor.constraint(equalToConstant: 20),
            
            daysStackView.topAnchor.constraint(equalTo: monthsStackView.bottomAnchor, constant: 5),
            daysStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            daysStackView.widthAnchor.constraint(equalToConstant: 45),
            
            collectionView.topAnchor.constraint(equalTo: monthsStackView.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: daysStackView.trailingAnchor, constant: 5),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 95),

            takePictureButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 40),
            takePictureButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            takePictureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            takePictureButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setupMonthLabels() {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        for month in months {
            let label = UILabel()
            label.text = month
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .gray
            label.textAlignment = .left
            monthsStackView.addArrangedSubview(label)
        }
    }
    
    private func setupDayLabels() {
        for view in daysStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        // Corresponds to Sun, Mon, Tue, Wed, Thu, Fri, Sat
        let daySymbols = ["", "Mon", "", "Wed", "", "Fri", ""]
        for day in daySymbols {
            let label = UILabel()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .gray
            label.textAlignment = .left
            daysStackView.addArrangedSubview(label)
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
        updateContributionStats()
        collectionView.reloadData()
    }
    
    private func updateContributionStats() {
        let count = showerData.count
        contributionStatsLabel.text = "\(count) showers in the last year"
    }

    @objc private func handleTakePicture() {
        // Check if running on simulator
        #if targetEnvironment(simulator)
        showSimulatorAlert()
        return
        #endif
        
        // Check if camera is available
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
            message: "Camera functionality is not available in the iOS Simulator. Please run this app on a physical device to test the camera features.", 
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

    // MARK: - UIImagePickerControllerDelegate

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

        OpenAIService.shared.analyzeImage(image: imageData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let analysis):
                    self?.showAnalysisResult(analysis)
                    if analysis.contains("Showered") {
                        self?.saveShowerForToday()
                        self?.fetchShowerData()
                    }
                case .failure(let error):
                    self?.showAnalysisResult("Error: \(error.localizedDescription)")
                }
            }
        }
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

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return yearData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.reuseIdentifier, for: indexPath) as! CalendarCell
        
        let date = yearData[indexPath.item]
        
        if date == Date.distantPast {
            cell.configure(with: .clear)
        } else {
            let isToday = Calendar.current.isDateInToday(date)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: date)
            
            if showerData.contains(dateString) {
                cell.configure(with: .systemBlue, isToday: isToday)
            } else {
                cell.configure(with: UIColor(white: 0.9, alpha: 1.0), isToday: isToday)
            }
        }
        
        return cell
    }

    // MARK: - Helper Methods

    private func saveShowerDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        if !showerData.contains(dateString) {
            showerData.append(dateString)
            UserDefaults.standard.set(showerData, forKey: "shower_dates")
            collectionView.reloadData()
            updateContributionStats()
        }
    }
} 