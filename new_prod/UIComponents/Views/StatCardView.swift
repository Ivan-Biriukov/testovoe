import UIKit
import PinLayout

private struct Constants {
    let cornerRadius: CGFloat = 16
    let horizontalPadding: CGFloat = 16
    let verticalPadding: CGFloat = 16
    let miniChartSize = CGSize(width: 50, height: 40)
    let miniChartSpacing: CGFloat = 12
    let arrowSpacing: CGFloat = 4
    let descriptionTopSpacing: CGFloat = 4
    
    let valueFontSize: CGFloat = 28
    let arrowFontSize: CGFloat = 20
    let descriptionFontSize: CGFloat = 14
    
    let chartLineWidth: CGFloat = 2
    let chartDotSize: CGFloat = 8
}

// MARK: - StatCardView
final class StatCardView: UIView {
    
    // MARK: - Properties
    private let k = Constants()
    
    // MARK: - UI Elements
    private let miniChartView = UIView()
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
        drawMiniChart()
    }
}

// MARK: - Private Setup
private extension StatCardView {
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
        addSubview(miniChartView)
        addSubview(valueLabel)
        addSubview(arrowLabel)
        addSubview(descriptionLabel)
    }
}

// MARK: - Private Layout
private extension StatCardView {
    func layoutElements() {
        miniChartView.pin
            .left(k.horizontalPadding)
            .vCenter()
            .size(k.miniChartSize)
        
        valueLabel.pin
            .after(of: miniChartView)
            .marginLeft(k.miniChartSpacing)
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

// MARK: - Private Drawing
private extension StatCardView {
    func drawMiniChart() {
        miniChartView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let path = createChartPath()
        let shapeLayer = createShapeLayer(with: path)
        let dotLayer = createDotLayer()
        
        miniChartView.layer.addSublayer(shapeLayer)
        miniChartView.layer.addSublayer(dotLayer)
    }
    
    func createChartPath() -> UIBezierPath {
        let points: [CGPoint] = [
            CGPoint(x: 0, y: 30),
            CGPoint(x: 12, y: 20),
            CGPoint(x: 25, y: 25),
            CGPoint(x: 38, y: 10),
            CGPoint(x: 50, y: 15)
        ]
        
        let path = UIBezierPath()
        path.move(to: points[0])
        points.dropFirst().forEach { path.addLine(to: $0) }
        
        return path
    }
    
    func createShapeLayer(with path: UIBezierPath) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = AppColors.green.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = k.chartLineWidth
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        return shapeLayer
    }
    
    func createDotLayer() -> CALayer {
        let dotLayer = CALayer()
        let dotOffset = k.miniChartSize.width - k.chartDotSize / 2
        dotLayer.frame = CGRect(x: dotOffset - 4, y: 11, width: k.chartDotSize, height: k.chartDotSize)
        dotLayer.backgroundColor = AppColors.green.cgColor
        dotLayer.cornerRadius = k.chartDotSize / 2
        return dotLayer
    }
}

// MARK: - Public Interface
extension StatCardView {
    func configure(value: String, isPositive: Bool, description: String) {
        valueLabel.text = value
        arrowLabel.text = isPositive ? "↑" : "↓"
        arrowLabel.textColor = isPositive ? AppColors.green : AppColors.red
        descriptionLabel.text = description
        setNeedsLayout()
    }
}
