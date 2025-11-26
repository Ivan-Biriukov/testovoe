import UIKit
import PinLayout

private struct Constants {
    let cornerRadius: CGFloat = 16
    let horizontalPadding: CGFloat = 16
    let verticalPadding: CGFloat = 16
    
    let avatarsContainerWidth: CGFloat = 70
    let avatarSize: CGFloat = 32
    let avatarCornerRadius: CGFloat = 16
    let avatarBorderWidth: CGFloat = 2
    let avatarOverlap: CGFloat = 22
    let avatarsContainerSpacing: CGFloat = 12
    
    let arrowSpacing: CGFloat = 4
    let descriptionTopSpacing: CGFloat = 4
    
    let valueFontSize: CGFloat = 24
    let arrowFontSize: CGFloat = 18
    let descriptionFontSize: CGFloat = 14
    
    let maxAvatarsCount = 3
}

// MARK: - ObserverStatView
final class ObserverStatView: UIView {
    // MARK: - Properties
    private let k = Constants()
    private var avatarImageViews: [UIImageView] = []
    
    // MARK: - UI Elements
    private let avatarsContainer = UIView()
    private let valueLabel = UILabel()
    private let arrowLabel = UILabel()
    private let descriptionLabel = UILabel()
    
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
private extension ObserverStatView {
    func setupUI() {
        setupContainer()
        setupLabels()
        addSubviews()
    }
    
    func setupContainer() {
        backgroundColor = AppColors.white
        layer.cornerRadius = k.cornerRadius
    }
    
    func setupLabels() {
        valueLabel.font = .systemFont(ofSize: k.valueFontSize, weight: .bold)
        valueLabel.textColor = AppColors.textPrimary
        
        arrowLabel.font = .systemFont(ofSize: k.arrowFontSize, weight: .medium)
        
        descriptionLabel.font = .systemFont(ofSize: k.descriptionFontSize)
        descriptionLabel.textColor = AppColors.textSecondary
        descriptionLabel.numberOfLines = 2
    }
    
    func addSubviews() {
        addSubview(avatarsContainer)
        addSubview(valueLabel)
        addSubview(arrowLabel)
        addSubview(descriptionLabel)
    }
}

// MARK: - Private Layout
private extension ObserverStatView {
    func layoutElements() {
        layoutAvatarsContainer()
        layoutAvatars()
        layoutLabels()
    }
    
    func layoutAvatarsContainer() {
        avatarsContainer.pin
            .left(k.horizontalPadding)
            .vCenter()
            .width(k.avatarsContainerWidth)
            .height(k.avatarSize)
    }
    
    func layoutAvatars() {
        var xOffset: CGFloat = 0
        for imageView in avatarImageViews {
            imageView.pin
                .left(xOffset)
                .vCenter()
                .size(k.avatarSize)
            xOffset += k.avatarOverlap
        }
    }
    
    func layoutLabels() {
        valueLabel.pin
            .after(of: avatarsContainer)
            .marginLeft(k.avatarsContainerSpacing)
            .top(k.verticalPadding)
            .sizeToFit()
        
        arrowLabel.pin
            .after(of: valueLabel)
            .marginLeft(k.arrowSpacing)
            .vCenter(to: valueLabel.edge.vCenter)
            .sizeToFit()
        
        descriptionLabel.pin
            .below(of: valueLabel)
            .marginTop(k.descriptionTopSpacing)
            .left(to: valueLabel.edge.left)
            .right(k.horizontalPadding)
            .sizeToFit(.width)
    }
}

// MARK: - Private Avatar Management
private extension ObserverStatView {
    func clearAvatars() {
        avatarImageViews.forEach { $0.removeFromSuperview() }
        avatarImageViews.removeAll()
    }
    
    func createAvatarImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = k.avatarCornerRadius
        imageView.layer.borderWidth = k.avatarBorderWidth
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.backgroundColor = AppColors.separator
        return imageView
    }
    
    func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
}

// MARK: - Interface
extension ObserverStatView {
    func configure(value: String, isPositive: Bool, description: String, avatarURLs: [URL]) {
        valueLabel.text = value
        arrowLabel.text = isPositive ? "↑" : "↓"
        arrowLabel.textColor = isPositive ? AppColors.green : AppColors.red
        descriptionLabel.text = description
        
        clearAvatars()
        
        for url in avatarURLs.prefix(k.maxAvatarsCount) {
            let imageView = createAvatarImageView()
            avatarsContainer.addSubview(imageView)
            avatarImageViews.append(imageView)
            loadImage(from: url, into: imageView)
        }
        
        setNeedsLayout()
    }
}
