import UIKit

class StinkyViewController: UIViewController {
    
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
        label.text = "CS majors stink"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let coderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stinky-coder")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "(Including you)"
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        animateAppearance()
        
        // Auto-advance after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.navigateToLoginScreen()
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(coderImageView)
        contentView.addSubview(subtitleLabel)
        
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            coderImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            coderImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coderImageView.widthAnchor.constraint(equalToConstant: 150),
            coderImageView.heightAnchor.constraint(equalToConstant: 150),
            
            subtitleLabel.topAnchor.constraint(equalTo: coderImageView.bottomAnchor, constant: 40),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func animateAppearance() {
        titleLabel.alpha = 0
        coderImageView.alpha = 0
        subtitleLabel.alpha = 0
        
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -50)
        coderImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 0.8, delay: 0.6, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.coderImageView.alpha = 1
            self.coderImageView.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 1.2, options: .curveEaseOut, animations: {
            self.subtitleLabel.alpha = 1
            self.subtitleLabel.transform = .identity
        })
    }
    
    private func navigateToLoginScreen() {
        let newLoginViewController = NewLoginViewController()
        navigationController?.pushViewController(newLoginViewController, animated: true)
    }
} 