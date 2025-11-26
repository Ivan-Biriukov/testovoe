import UIKit
import PinLayout

private struct Constants {
    let ageLabelWidth: CGFloat = 45
    let barWidth: CGFloat = 100
    let barHeight: CGFloat = 6
    let barCornerRadius: CGFloat = 3
    let barHorizontalSpacing: CGFloat = 8
    let rowVerticalSpacing: CGFloat = 4
    
    let ageFontSize: CGFloat = 14
    let percentFontSize: CGFloat = 12
}

// MARK: - AgeBarView
final class AgeBarView: UIView {
    // MARK: - Properties
    private let k = Constants()
    private var malePercent: CGFloat = 0
    private var femalePercent: CGFloat = 0
    
    // MARK: - UI Elements
    private let ageLabel = UILabel()
    private let maleBarBackground = UIView()
    private let maleBar = UIView()
    private let femaleBarBackground = UIView()
    private let femaleBar = UIView()
    private let malePercentLabel = UILabel()
    private let femalePercentLabel = UILabel()
    
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
private extension AgeBarView {
    func setupUI() {
        setupAgeLabel()
        setupBars()
        setupPercentLabels()
        addSubviews()
    }
    
    func setupAgeLabel() {
        ageLabel.font = .systemFont(ofSize: k.ageFontSize, weight: .medium)
        ageLabel.textColor = AppColors.textPrimary
    }
    
    func setupBars() {
        [maleBarBackground, femaleBarBackground].forEach {
            $0.backgroundColor = AppColors.separator
            $0.layer.cornerRadius = k.barCornerRadius
        }
        
        maleBar.backgroundColor = AppColors.red
        maleBar.layer.cornerRadius = k.barCornerRadius
        
        femaleBar.backgroundColor = AppColors.orange
        femaleBar.layer.cornerRadius = k.barCornerRadius
    }
    
    func setupPercentLabels() {
        [malePercentLabel, femalePercentLabel].forEach {
            $0.font = .systemFont(ofSize: k.percentFontSize)
            $0.textColor = AppColors.textSecondary
        }
    }
    
    func addSubviews() {
        addSubview(ageLabel)
        addSubview(maleBarBackground)
        addSubview(femaleBarBackground)
        maleBarBackground.addSubview(maleBar)
        femaleBarBackground.addSubview(femaleBar)
        addSubview(malePercentLabel)
        addSubview(femalePercentLabel)
    }
}

// MARK: - Private Layout
private extension AgeBarView {
    func layoutElements() {
        layoutAgeLabel()
        layoutMaleRow()
        layoutFemaleRow()
    }
    
    func layoutAgeLabel() {
        ageLabel.pin
            .left()
            .vCenter()
            .width(k.ageLabelWidth)
            .sizeToFit(.width)
    }
    
    func layoutMaleRow() {
        maleBarBackground.pin
            .after(of: ageLabel)
            .marginLeft(k.barHorizontalSpacing)
            .top(k.rowVerticalSpacing)
            .width(k.barWidth)
            .height(k.barHeight)
        
        maleBar.pin
            .left()
            .top()
            .bottom()
            .width(malePercent)
        
        malePercentLabel.pin
            .after(of: maleBarBackground)
            .marginLeft(k.barHorizontalSpacing)
            .vCenter(to: maleBarBackground.edge.vCenter)
            .sizeToFit()
    }
    
    func layoutFemaleRow() {
        femaleBarBackground.pin
            .after(of: ageLabel)
            .marginLeft(k.barHorizontalSpacing)
            .bottom(k.rowVerticalSpacing)
            .width(k.barWidth)
            .height(k.barHeight)
        
        femaleBar.pin
            .left()
            .top()
            .bottom()
            .width(femalePercent)
        
        femalePercentLabel.pin
            .after(of: femaleBarBackground)
            .marginLeft(k.barHorizontalSpacing)
            .vCenter(to: femaleBarBackground.edge.vCenter)
            .sizeToFit()
    }
}

// MARK: - Interface
extension AgeBarView {
    func configure(ageRange: String, malePercent: Int, femalePercent: Int) {
        ageLabel.text = ageRange
        self.malePercent = CGFloat(malePercent)
        self.femalePercent = CGFloat(femalePercent)
        
        malePercentLabel.text = malePercent > 0 ? "\(malePercent)%" : ""
        femalePercentLabel.text = femalePercent > 0 ? "\(femalePercent)%" : ""
        
        setNeedsLayout()
    }
}
