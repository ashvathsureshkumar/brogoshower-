import UIKit

class CalendarCell: UICollectionViewCell {
    static let reuseIdentifier = "CalendarCell"
    
    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12.0
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with color: UIColor, isToday: Bool = false) {
        colorView.backgroundColor = color
        
        if isToday {
            colorView.layer.borderColor = UIColor.black.cgColor
            colorView.layer.borderWidth = 1.5
        } else {
            colorView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
            colorView.layer.borderWidth = 1.0
        }
    }
} 
