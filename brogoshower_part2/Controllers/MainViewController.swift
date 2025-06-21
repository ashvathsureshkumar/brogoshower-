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
        button.setTitle("📸 YEET A SHOWER PIC 💦", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
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
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()

    private var showerData: [String] = []
    private var monthData: [Date?] = []
    private var currentDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "🚿 BrogoShower 💪"
        setupViews()
        setupNavigationBar()
        loadProfileInfo()
        fetchShowerData()
        setupCalendar()
        updateStatusLabel()
    }
    
    private func setupCalendar() {
        updateMonthLabel()
        setupMonthData()
        collectionView.reloadData()
        updateStatusLabel()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "✌️ Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let previousButton = UIBarButtonItem(title: "⬅️", style: .plain, target: self, action: #selector(goToPreviousMonth))
        let nextButton = UIBarButtonItem(title: "➡️", style: .plain, target: self, action: #selector(goToNextMonth))
        navigationItem.leftBarButtonItems = [previousButton, nextButton]
    }

    private func setupViews() {
        view.addSubview(emailLabel)
        view.addSubview(monthLabel)
        view.addSubview(statusLabel)
        view.addSubview(weekdaysStackView)
        view.addSubview(collectionView)
        view.addSubview(takePictureButton)
        
        setupWeekdayLabels()

        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            monthLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 15),
            monthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 8),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            weekdaysStackView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 15),
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
        let weekdays = ["☀️", "🌙", "💫", "⭐", "🔥", "🎉", "😴"]
        for day in weekdays {
            let label = UILabel()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .center
            weekdaysStackView.addArrangedSubview(label)
        }
    }
    
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = "🗓️ " + dateFormatter.string(from: currentDate) + " 🗓️"
    }
    
    private func updateStatusLabel() {
        let currentMonthShowers = getCurrentMonthShowerCount()
        let totalShowers = showerData.count
        
        if currentMonthShowers == 0 {
            statusLabel.text = "💀 NO SHOWERS THIS MONTH 💀\nSTINKY LEVEL: MAXIMUM 🤢"
        } else if currentMonthShowers < 5 {
            statusLabel.text = "🦨 ONLY \(currentMonthShowers) SHOWERS THIS MONTH\nSTILL PRETTY STINKY NGL 😬"
        } else if currentMonthShowers < 15 {
            statusLabel.text = "🧼 \(currentMonthShowers) SHOWERS - NOT BAD!\nCLEAN VIBES ACTIVATED ✨"
        } else {
            statusLabel.text = "🏆 \(currentMonthShowers) SHOWERS - ABSOLUTE UNIT!\nCLEANEST BRO ALIVE 👑"
        }
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
        setupCalendar()
    }

    @objc private func goToNextMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
        setupCalendar()
    }

    private func loadProfileInfo() {
        if let currentUser = AuthService.shared.getCurrentUser() {
            emailLabel.text = "🧑‍💻 " + currentUser
        } else {
            emailLabel.text = "👻 WHO ARE YOU??"
        }
    }

    private func fetchShowerData() {
        showerData = OpenAIService.shared.getShowerData()
        collectionView.reloadData()
        updateStatusLabel()
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
            title: "🤖 SIMULATOR DETECTED",
            message: "Bruh, you can't take pics in the simulator! 📱 Get a real phone and try again 😤",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "😔 Fine", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showCameraUnavailableAlert() {
        let alert = UIAlertController(
            title: "📷 CAMERA BROKE",
            message: "Your camera is more broken than my sleep schedule 💀",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "😭 RIP", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleLogout() {
        let alert = UIAlertController(title: "🚪 LEAVING SO SOON?", message: "You sure you wanna dip? Your shower streak is counting on you! 🏃‍♂️💨", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "🔙 Nah, I'll stay", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "✌️ Peace out", style: .destructive) { _ in
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
        let title = result.contains("Showered") ? "🎉 SHOWER DETECTED!" : "🤔 HMMMM..."
        let message = result.contains("Showered") ? 
            "YOOO YOU ACTUALLY SHOWERED! 🚿✨\nRespect the hygiene game! 💪" : 
            "That doesn't look like a shower to me chief... 🧐\nTry again with actual shower evidence! 📸"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "💯 Got it", style: .default, handler: nil))
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
