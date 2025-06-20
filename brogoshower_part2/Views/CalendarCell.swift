import UIKit

class CalendarCell: UICollectionViewCell {
    static let reuseIdentifier = "CalendarCell"
    
    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with color: UIColor, isToday: Bool = false) {
        colorView.backgroundColor = color
        
        if isToday {
            contentView.layer.borderColor = UIColor.darkGray.cgColor
            contentView.layer.borderWidth = 1.0
            contentView.layer.cornerRadius = 2.0
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = UIColor.clear.cgColor
        }
    }
} 