import SwiftUI
import Charts
import PinLayout

private struct Constants {
    let chartSize: CGFloat = 140
    let innerRadiusRatio: CGFloat = 0.6
    let angularInset: CGFloat = 2
    let segmentCornerRadius: CGFloat = 4
    let legendSpacing: CGFloat = 24
    let legendDotSize: CGFloat = 8
    let legendDotSpacing: CGFloat = 6
    let legendFontSize: CGFloat = 14
    let stackSpacing: CGFloat = 16
}

// MARK: - SwiftUI Chart View
private struct DonutChartSwiftUIView: View {
    
    let data: [GenderData]
    private let k = Constants()
    
    var body: some View {
        VStack(spacing: k.stackSpacing) {
            chartView
            legendView
        }
    }
}

// MARK: - Chart Components

private extension DonutChartSwiftUIView {
    var chartView: some View {
        Chart(data) { item in
            SectorMark(
                angle: .value("Percent", item.percent),
                innerRadius: .ratio(k.innerRadiusRatio),
                angularInset: k.angularInset
            )
            .foregroundStyle(item.color)
            .cornerRadius(k.segmentCornerRadius)
        }
        .frame(width: k.chartSize, height: k.chartSize)
    }
    
    var legendView: some View {
        HStack(spacing: k.legendSpacing) {
            ForEach(data) { item in
                legendItem(for: item)
            }
        }
    }
    
    func legendItem(for item: GenderData) -> some View {
        HStack(spacing: k.legendDotSpacing) {
            Circle()
                .fill(item.color)
                .frame(width: k.legendDotSize, height: k.legendDotSize)
            Text(item.gender)
                .font(.system(size: k.legendFontSize))
                .foregroundColor(Color(AppColors.textSecondary))
        }
    }
}

// MARK: - DonutChartContainerView
final class DonutChartContainerView: UIView {
    // MARK: - Properties
    private var hostingController: UIHostingController<DonutChartSwiftUIView>?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        hostingController?.view.pin.all()
    }
}

// MARK: - Public Interface
extension DonutChartContainerView {
    
    func configure(malePercent: Double, femalePercent: Double) {
        hostingController?.view.removeFromSuperview()
        
        let data = [
            GenderData(
                gender: "Мужчины \(Int(malePercent))%",
                percent: malePercent,
                color: Color(AppColors.red)
            ),
            GenderData(
                gender: "Женщины \(Int(femalePercent))%",
                percent: femalePercent,
                color: Color(AppColors.orange)
            )
        ]
        
        let chartView = DonutChartSwiftUIView(data: data)
        let hosting = UIHostingController(rootView: chartView)
        hosting.view.backgroundColor = .clear
        addSubview(hosting.view)
        hostingController = hosting
        
        setNeedsLayout()
    }
}
