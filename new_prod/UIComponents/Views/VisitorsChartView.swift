import SwiftUI
import Charts
import PinLayout

private struct Constants {
    let cornerRadius: CGFloat = 16
    let padding: CGFloat = 16
    let tooltipPadding: CGFloat = 8
    let tooltipCornerRadius: CGFloat = 8
    let tooltipShadowRadius: CGFloat = 4
    let chartTopPadding: CGFloat = 40
    
    let valueFontSize: CGFloat = 14
    let dateFontSize: CGFloat = 12
    
    let selectedPointSize: CGFloat = 80
    let normalPointSize: CGFloat = 50
}

// MARK: - SwiftUI Chart View
private struct VisitorsChartView: View {
    let data: [VisitorData]
    @State private var selectedData: VisitorData?
    
    private let k = Constants()
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                createLineMark(for: item)
                createAreaMark(for: item)
                createPointMark(for: item)
            }
            
            if let selected = selectedData {
                createRuleMark(for: selected)
            }
        }
        .chartXAxis { createXAxis() }
        .chartYAxis(.hidden)
        .chartOverlay { proxy in
            createOverlay(proxy: proxy)
        }
        .padding(.top, k.chartTopPadding)
    }
}

// MARK: - Chart Marks
private extension VisitorsChartView {
    func createLineMark(for item: VisitorData) -> some ChartContent {
        LineMark(
            x: .value("Date", item.date),
            y: .value("Visitors", item.value)
        )
        .foregroundStyle(Color(AppColors.orange))
        .interpolationMethod(.catmullRom)
    }
    
    func createAreaMark(for item: VisitorData) -> some ChartContent {
        AreaMark(
            x: .value("Date", item.date),
            y: .value("Visitors", item.value)
        )
        .foregroundStyle(
            LinearGradient(
                colors: [
                    Color(AppColors.orange).opacity(0.3),
                    Color(AppColors.orange).opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .interpolationMethod(.catmullRom)
    }
    
    func createPointMark(for item: VisitorData) -> some ChartContent {
        PointMark(
            x: .value("Date", item.date),
            y: .value("Visitors", item.value)
        )
        .foregroundStyle(pointColor(for: item))
        .symbolSize(pointSize(for: item))
        .annotation(position: .top) {
            tooltipView(for: item)
        }
    }
    
    func createRuleMark(for item: VisitorData) -> some ChartContent {
        RuleMark(x: .value("Date", item.date))
            .foregroundStyle(Color(AppColors.red).opacity(0.5))
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
    }
}

// MARK: - Chart Configuration
private extension VisitorsChartView {
    func createXAxis() -> some AxisContent {
        AxisMarks(values: .automatic) { _ in
            AxisValueLabel()
                .font(.system(size: k.dateFontSize))
                .foregroundStyle(Color(AppColors.textTertiary))
        }
    }
    
    func createOverlay(proxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture { location in
                    handleTap(at: location, proxy: proxy, geometry: geometry)
                }
        }
    }
}

// MARK: - Helper Methods
private extension VisitorsChartView {
    func pointColor(for item: VisitorData) -> Color {
        selectedData?.date == item.date ? Color(AppColors.red) : Color.white
    }
    
    func pointSize(for item: VisitorData) -> CGFloat {
        selectedData?.date == item.date ? k.selectedPointSize : k.normalPointSize
    }
    
    @ViewBuilder
    func tooltipView(for item: VisitorData) -> some View {
        if selectedData?.date == item.date {
            VStack(spacing: 2) {
                Text("\(item.value) посетитель")
                    .font(.system(size: k.valueFontSize, weight: .semibold))
                    .foregroundColor(Color(AppColors.red))
                Text(item.date)
                    .font(.system(size: k.dateFontSize))
                    .foregroundColor(Color(AppColors.textSecondary))
            }
            .padding(k.tooltipPadding)
            .background(Color.white)
            .cornerRadius(k.tooltipCornerRadius)
            .shadow(radius: k.tooltipShadowRadius)
        }
    }
    
    func handleTap(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let x = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date: String = proxy.value(atX: x) {
            selectedData = data.first { $0.date == date }
        }
    }
}

// MARK: - LineChartContainerView
final class LineChartContainerView: UIView {
    // MARK: - Properties
    private let k = Constants()
    private var hostingController: UIHostingController<VisitorsChartView>?
    private var chartData: [VisitorData] = []
    
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
        hostingController?.view.pin.all(k.padding)
    }
}

// MARK: - Private Setup
private extension LineChartContainerView {
    func setupUI() {
        backgroundColor = AppColors.white
        layer.cornerRadius = k.cornerRadius
    }
}

// MARK: - Interface
extension LineChartContainerView {
    func configure(with data: [(String, Int)]) {
        chartData = data.map { VisitorData(date: $0.0, value: $0.1) }
        
        hostingController?.view.removeFromSuperview()
        
        let chartView = VisitorsChartView(data: chartData)
        let hosting = UIHostingController(rootView: chartView)
        hosting.view.backgroundColor = .clear
        addSubview(hosting.view)
        hostingController = hosting
        
        setNeedsLayout()
    }
}
