import UIKit
import PinLayout
import RxSwift
import BusinessLogic

private struct Constants {
    let horizontalPadding: CGFloat = 16
    let bottomPadding: CGFloat = 32
    
    let titleTopPadding: CGFloat = 16
    let sectionSpacing: CGFloat = 24
    let elementSpacing: CGFloat = 12
    let filterSpacing: CGFloat = 16
    
    let statCardHeight: CGFloat = 80
    let lineChartHeight: CGFloat = 200
    let userRowHeight: CGFloat = 56
    let ageBarHeight: CGFloat = 32
    let ageBarSpacing: CGFloat = 12
    let ageBarPadding: CGFloat = 16
    let observerCardHeight: CGFloat = 80
    
    let donutChartSize = CGSize(width: 250, height: 200)
    
    let titleFontSize: CGFloat = 32
    let sectionFontSize: CGFloat = 18
    
    let maxTopVisitors = 3
    let ageRanges = ["18-21", "22-25", "26-30", "31-35", "36-40", "40-50", ">50"]
}

// MARK: - StatisticsViewController
final class StatisticsViewController: UIViewController {
    // MARK: - Properties
    private let k = Constants()
    private let disposeBag = DisposeBag()
    private var users: [User] = []
    private var statistics: [UserStatistics] = []
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let refreshControl = UIRefreshControl()
    private let titleLabel = UILabel()
    
    // Visitors Section
    private let visitorsSectionLabel = UILabel()
    private let visitorsStatCard = StatCardView()
    private lazy var visitorsFilterView = SegmentedFilterView(items: ["По дням", "По неделям", "По месяцам"])
    private let lineChartView = LineChartContainerView()
    
    // Top Visitors Section
    private let topVisitorsSectionLabel = UILabel()
    private let topVisitorsContainer = UIView()
    private var userRowViews: [UserRowView] = []
    
    // Gender & Age Section
    private let genderAgeSectionLabel = UILabel()
    private lazy var genderAgeFilterView = SegmentedFilterView(items: ["Сегодня", "Неделя", "Месяц", "Все время"])
    private let donutChartView = DonutChartContainerView()
    private let ageStatsContainer = UIView()
    private var ageBarViews: [AgeBarView] = []
    
    // Observers Section
    private let observersSectionLabel = UILabel()
    private let newObserversView = ObserverStatView()
    private let lostObserversView = ObserverStatView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData(forceRefresh: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }
}

// MARK: - Private Setup
private extension StatisticsViewController {
    func setupUI() {
        setupView()
        setupScrollView()
        setupLabels()
        setupContainers()
        setupAgeBars()
        addSubviews()
    }
    
    func setupView() {
        view.backgroundColor = AppColors.background
    }
    
    func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    func setupLabels() {
        titleLabel.text = "Статистика"
        titleLabel.font = .systemFont(ofSize: k.titleFontSize, weight: .bold)
        titleLabel.textColor = AppColors.textPrimary
        
        [visitorsSectionLabel, topVisitorsSectionLabel, genderAgeSectionLabel, observersSectionLabel].forEach {
            $0.font = .systemFont(ofSize: k.sectionFontSize, weight: .semibold)
            $0.textColor = AppColors.textPrimary
        }
        
        visitorsSectionLabel.text = "Посетители"
        topVisitorsSectionLabel.text = "Чаще всех посещают Ваш профиль"
        genderAgeSectionLabel.text = "Пол и возраст"
        observersSectionLabel.text = "Наблюдатели"
    }
    
    func setupContainers() {
        [topVisitorsContainer, ageStatsContainer].forEach {
            $0.backgroundColor = AppColors.white
            $0.layer.cornerRadius = 16
        }
    }
    
    func setupAgeBars() {
        for _ in k.ageRanges {
            let barView = AgeBarView()
            ageStatsContainer.addSubview(barView)
            ageBarViews.append(barView)
        }
    }
    
    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, visitorsSectionLabel, visitorsStatCard, visitorsFilterView, lineChartView,
         topVisitorsSectionLabel, topVisitorsContainer,
         genderAgeSectionLabel, genderAgeFilterView, donutChartView, ageStatsContainer,
         observersSectionLabel, newObserversView, lostObserversView].forEach {
            contentView.addSubview($0)
        }
    }
}

// MARK: - Private Layout
private extension StatisticsViewController {
    
    func layoutUI() {
        layoutScrollView()
        layoutTitle()
        layoutVisitorsSection()
        layoutTopVisitorsSection()
        layoutGenderAgeSection()
        layoutObserversSection()
        updateContentSize()
    }
    
    func layoutScrollView() {
        scrollView.pin.all(view.pin.safeArea)
        contentView.pin.top().horizontally()
    }
    
    func layoutTitle() {
        titleLabel.pin
            .top(k.titleTopPadding)
            .horizontally(k.horizontalPadding)
            .sizeToFit(.width)
    }
    
    func layoutVisitorsSection() {
        visitorsSectionLabel.pin
            .below(of: titleLabel)
            .marginTop(k.sectionSpacing)
            .horizontally(k.horizontalPadding)
            .sizeToFit(.width)
        
        visitorsStatCard.pin
            .below(of: visitorsSectionLabel)
            .marginTop(k.elementSpacing)
            .horizontally(k.horizontalPadding)
            .height(k.statCardHeight)
        
        visitorsFilterView.pin
            .below(of: visitorsStatCard)
            .marginTop(k.filterSpacing)
            .left(k.horizontalPadding)
            .sizeToFit()
        
        lineChartView.pin
            .below(of: visitorsFilterView)
            .marginTop(k.filterSpacing)
            .horizontally(k.horizontalPadding)
            .height(k.lineChartHeight)
    }
    
    func layoutTopVisitorsSection() {
        topVisitorsSectionLabel.pin
            .below(of: lineChartView)
            .marginTop(k.sectionSpacing)
            .horizontally(k.horizontalPadding)
            .sizeToFit(.width)
        
        let rowsHeight = CGFloat(userRowViews.count) * k.userRowHeight
        let containerHeight = max(rowsHeight, k.userRowHeight)
        
        topVisitorsContainer.pin
            .below(of: topVisitorsSectionLabel)
            .marginTop(k.elementSpacing)
            .horizontally(k.horizontalPadding)
            .height(containerHeight)
        
        var yOffset: CGFloat = 0
        for rowView in userRowViews {
            rowView.pin
                .top(yOffset)
                .horizontally()
                .height(k.userRowHeight)
            yOffset += k.userRowHeight
        }
    }
    
    func layoutGenderAgeSection() {
        genderAgeSectionLabel.pin
            .below(of: topVisitorsContainer)
            .marginTop(k.sectionSpacing)
            .horizontally(k.horizontalPadding)
            .sizeToFit(.width)
        
        genderAgeFilterView.pin
            .below(of: genderAgeSectionLabel)
            .marginTop(k.elementSpacing)
            .left(k.horizontalPadding)
            .sizeToFit()
        
        donutChartView.pin
            .below(of: genderAgeFilterView)
            .marginTop(k.filterSpacing)
            .hCenter()
            .size(k.donutChartSize)
        
        layoutAgeStats()
    }
    
    func layoutAgeStats() {
        let barsCount = CGFloat(ageBarViews.count)
        let totalHeight = barsCount * k.ageBarHeight + (barsCount - 1) * k.ageBarSpacing + k.ageBarPadding * 2
        
        ageStatsContainer.pin
            .below(of: donutChartView)
            .marginTop(k.filterSpacing)
            .horizontally(k.horizontalPadding)
            .height(totalHeight)
        
        var yOffset: CGFloat = k.ageBarPadding
        for barView in ageBarViews {
            barView.pin
                .top(yOffset)
                .horizontally(k.ageBarPadding)
                .height(k.ageBarHeight)
            yOffset += k.ageBarHeight + k.ageBarSpacing
        }
    }
    
    func layoutObserversSection() {
        observersSectionLabel.pin
            .below(of: ageStatsContainer)
            .marginTop(k.sectionSpacing)
            .horizontally(k.horizontalPadding)
            .sizeToFit(.width)
        
        newObserversView.pin
            .below(of: observersSectionLabel)
            .marginTop(k.elementSpacing)
            .horizontally(k.horizontalPadding)
            .height(k.observerCardHeight)
        
        lostObserversView.pin
            .below(of: newObserversView)
            .marginTop(k.elementSpacing)
            .horizontally(k.horizontalPadding)
            .height(k.observerCardHeight)
    }
    
    func updateContentSize() {
        contentView.pin
            .top()
            .horizontally()
            .wrapContent(.vertically, padding: PEdgeInsets(top: 0, left: 0, bottom: k.bottomPadding, right: 0))
        
        scrollView.contentSize = contentView.frame.size
    }
}

// MARK: - Private Data Loading
private extension StatisticsViewController {
    func loadData(forceRefresh: Bool) {
        BusinessLogicCore.shared.statisticsService
            .loadAggregatedStatistics(forceRefresh: forceRefresh)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] stats in
                    self?.statistics = stats
                    self?.users = stats.compactMap { $0.user }
                    self?.updateUI()
                    self?.refreshControl.endRefreshing()
                },
                onError: { [weak self] error in
                    print("Error loading statistics: \(error)")
                    self?.refreshControl.endRefreshing()
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - Private Actions
private extension StatisticsViewController {
    @objc func handleRefresh() {
        loadData(forceRefresh: true)
    }
}

// MARK: - Private UI Updates
private extension StatisticsViewController {
    func updateUI() {
        updateVisitorsCard()
        updateLineChart()
        updateTopVisitors()
        updateGenderChart()
        updateAgeBars()
        updateObservers()
        view.setNeedsLayout()
    }
    
    func updateVisitorsCard() {
        let totalViews = statistics.reduce(0) { $0 + $1.viewsCount }
        visitorsStatCard.configure(
            value: "\(totalViews)",
            isPositive: true,
            description: "Количество посетителей в этом месяце выросло"
        )
    }
    
    func updateLineChart() {
        var dateViews: [String: Int] = [:]
        
        for stat in statistics {
            for date in stat.viewDates {
                let dateString = formatDate(date)
                dateViews[dateString, default: 0] += 1
            }
        }
        
        let sortedData = dateViews.sorted { $0.key < $1.key }.suffix(7)
        let chartData = sortedData.map { ($0.key, $0.value) }
        
        if chartData.isEmpty {
            lineChartView.configure(with: [
                ("01.09", 8),
                ("03.09", 4),
                ("05.09", 6),
                ("09.09", 8),
                ("10.09", 6)
            ])
        } else {
            lineChartView.configure(with: chartData)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
    }
    
    func updateTopVisitors() {
        clearUserRows()
        createUserRows()
    }
    
    func clearUserRows() {
        userRowViews.forEach { $0.removeFromSuperview() }
        userRowViews.removeAll()
    }
    
    func createUserRows() {
        let topStats = statistics.sorted { $0.viewsCount > $1.viewsCount }.prefix(k.maxTopVisitors)
        
        for (index, stat) in topStats.enumerated() {
            guard let user = stat.user else { continue }
            let rowView = createUserRowView(for: user, at: index)
            topVisitorsContainer.addSubview(rowView)
            userRowViews.append(rowView)
        }
    }
    
    func createUserRowView(for user: User, at index: Int) -> UserRowView {
        let rowView = UserRowView()
        let emoji = emojiForIndex(index)
        let isLastRow = index == min(k.maxTopVisitors - 1, statistics.count - 1)
        
        rowView.configure(
            name: user.username,
            age: user.age,
            emoji: emoji,
            avatarURL: user.avatarURL
        )
        rowView.hideSeparator(isLastRow)
        
        return rowView
    }
    
    func emojiForIndex(_ index: Int) -> String? {
        switch index {
        case 0: return "🍒"
        case 1: return "🍓"
        default: return nil
        }
    }
    
    func updateGenderChart() {
        let maleCount = users.filter { $0.sex == "M" }.count
        let femaleCount = users.filter { $0.sex == "W" }.count
        let total = maleCount + femaleCount
        
        if total > 0 {
            let malePercent = Double(maleCount) / Double(total) * 100
            let femalePercent = Double(femaleCount) / Double(total) * 100
            donutChartView.configure(malePercent: malePercent, femalePercent: femalePercent)
        } else {
            donutChartView.configure(malePercent: 50, femalePercent: 50)
        }
    }
    
    func updateAgeBars() {
        let ageGroups = calculateAgeGroups()
        
        for (index, ageRange) in k.ageRanges.enumerated() {
            let group = ageGroups[ageRange] ?? (male: 0, female: 0)
            ageBarViews[index].configure(
                ageRange: ageRange,
                malePercent: group.male,
                femalePercent: group.female
            )
        }
    }
    
    func calculateAgeGroups() -> [String: (male: Int, female: Int)] {
        var groups: [String: (male: Int, female: Int)] = [:]
        let total = max(users.count, 1)
        
        for user in users {
            let ageRange = ageRangeFor(age: user.age)
            var current = groups[ageRange] ?? (male: 0, female: 0)
            
            if user.sex == "M" {
                current.male += 1
            } else {
                current.female += 1
            }
            
            groups[ageRange] = current
        }
        
        var percentGroups: [String: (male: Int, female: Int)] = [:]
        for (range, counts) in groups {
            percentGroups[range] = (
                male: Int(Double(counts.male) / Double(total) * 100),
                female: Int(Double(counts.female) / Double(total) * 100)
            )
        }
        
        return percentGroups
    }
    
    func ageRangeFor(age: Int) -> String {
        switch age {
        case 18...21: return "18-21"
        case 22...25: return "22-25"
        case 26...30: return "26-30"
        case 31...35: return "31-35"
        case 36...40: return "36-40"
        case 41...50: return "40-50"
        default: return ">50"
        }
    }
    
    func updateObservers() {
        let totalSubscriptions = statistics.reduce(0) { $0 + $1.subscriptionsCount }
        let totalUnsubscriptions = statistics.reduce(0) { $0 + $1.unsubscriptionsCount }
        
        let avatarURLs = users.prefix(3).compactMap { $0.avatarURL }
        
        newObserversView.configure(
            value: "\(totalSubscriptions)",
            isPositive: true,
            description: "Новые наблюдатели в этом месяце",
            avatarURLs: avatarURLs
        )
        
        lostObserversView.configure(
            value: "\(totalUnsubscriptions)",
            isPositive: false,
            description: "Пользователей перестали за Вами наблюдать",
            avatarURLs: Array(avatarURLs.prefix(2))
        )
    }
}
