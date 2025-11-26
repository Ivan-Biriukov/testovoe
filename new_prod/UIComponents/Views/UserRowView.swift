import UIKit
import PinLayout

private struct Constants {
    let horizontalPadding: CGFloat = 16
    let avatarSize: CGFloat = 40
    let avatarCornerRadius: CGFloat = 20
    let avatarNameSpacing: CGFloat = 12
    let arrowSize: CGFloat = 12
    let separatorHeight: CGFloat = 1
    
    let nameFontSize: CGFloat = 16
}

// MARK: - UserRowView
final class UserRowView: UIView {
    // MARK: - Properties
    private let k = Constants()
    
    // MARK: - UI Elements
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let arrowImageView = UIImageView()
    private let separatorView = UIView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutElements()
    }
}

// MARK: - Private Setup
private extension UserRowView {
    func setupUI() {
        setupContainer()
        setupAvatarImageView()
        setupNameLabel()
        setupArrowImageView()
        setupSeparatorView()
        addSubviews()
    }
    
    func setupContainer() {
        backgroundColor = AppColors.white
    }
    
    func setupAvatarImageView() {
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = k.avatarCornerRadius
        avatarImageView.backgroundColor = AppColors.separator
    }
    
    func setupNameLabel() {
        nameLabel.font = .systemFont(ofSize: k.nameFontSize, weight: .medium)
        nameLabel.textColor = AppColors.textPrimary
    }
    
    func setupArrowImageView() {
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = AppColors.textTertiary
        arrowImageView.contentMode = .scaleAspectFit
    }
    
    func setupSeparatorView() {
        separatorView.backgroundColor = AppColors.separator
    }
    
    func addSubviews() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(arrowImageView)
        addSubview(separatorView)
    }
}

// MARK: - Private Layout
private extension UserRowView {
    func layoutElements() {
        avatarImageView.pin
            .left(k.horizontalPadding)
            .vCenter()
            .size(k.avatarSize)
        
        arrowImageView.pin
            .right(k.horizontalPadding)
            .vCenter()
            .size(k.arrowSize)
        
        nameLabel.pin
            .after(of: avatarImageView)
            .marginLeft(k.avatarNameSpacing)
            .before(of: arrowImageView)
            .marginRight(k.avatarNameSpacing)
            .vCenter()
            .sizeToFit(.width)
        
        separatorView.pin
            .left(to: nameLabel.edge.left)
            .right()
            .bottom()
            .height(k.separatorHeight)
    }
}

// MARK: - Private Networking
private extension UserRowView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }.resume()
    }
}

// MARK: - Interface
extension UserRowView {
    func configure(name: String, age: Int, emoji: String?, avatarURL: URL?) {
        var displayName = "\(name), \(age)"
        if let emoji = emoji {
            displayName += " \(emoji)"
        }
        nameLabel.text = displayName
        
        if let url = avatarURL {
            loadImage(from: url)
        }
    }
    
    func hideSeparator(_ hide: Bool) {
        separatorView.isHidden = hide
    }
}
