import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
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
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
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
        button.setTitle("📸 Take Shower Picture", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleTakePicture), for: .touchUpInside)
        return button
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var showerData: [String] = []
    private var monthData: [Date?] = []
    private var currentDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "BrogoShower"
        setupViews()
        setupNavigationBar()
        loadProfileInfo()
        fetchShowerData()
        setupCalendar()
    }
    
    private func setupCalendar() {
        updateMonthLabel()
        setupMonthData()
        collectionView.reloadData()
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
        
        let previousButton = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(goToPreviousMonth))
        let nextButton = UIBarButtonItem(title: ">", style: .plain, target: self, action: #selector(goToNextMonth))
        navigationItem.leftBarButtonItems = [previousButton, nextButton]
    }

    private func setupViews() {
        view.addSubview(emailLabel)
        view.addSubview(monthLabel)
        view.addSubview(weekdaysStackView)
        view.addSubview(collectionView)
        view.addSubview(takePictureButton)
        
        setupWeekdayLabels()

        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            monthLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            monthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            weekdaysStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 10),
            weekdaysStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weekdaysStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: weekdaysStackView.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 5.0/7.0),

            takePictureButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            takePictureButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            takePictureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            takePictureButton.heightAnchor.constraint(equalToConstant: 55)
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
            weekdaysStackView.addArrangedSubview(label)
        }
    }
    
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: currentDate)
    }

    @objc private func goToPreviousMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        setupCalendar()
    }

    @objc private func goToNextMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
        setupCalendar()
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
    }
    
    @objc private func handleTakePicture() {
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
                // GitHub green for shower days
                cell.configure(with: UIColor(red: 0.16, green: 0.68, blue: 0.38, alpha: 1.0), isToday: isToday)
            } else {
                // Light gray for no shower days (GitHub style)
                cell.configure(with: UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0), isToday: isToday)
            }
        } else {
            // Transparent for empty cells
            cell.configure(with: .clear)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
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
} 
