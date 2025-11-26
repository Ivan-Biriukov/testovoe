import UIKit
import PinLayout

protocol SegmentedFilterViewDelegate: AnyObject {
    func segmentedFilterView(_ view: SegmentedFilterView, didSelectIndex index: Int)
}

private struct Constants {
    let buttonHeight: CGFloat = 32
    let buttonCornerRadius: CGFloat = 16
    let buttonHorizontalPadding: CGFloat = 32
    let buttonSpacing: CGFloat = 8
    let fontSize: CGFloat = 14
    let borderWidth: CGFloat = 1
}

// MARK: - SegmentedFilterView
final class SegmentedFilterView: UIView {
    // MARK: - Properties
    weak var delegate: SegmentedFilterViewDelegate?
    
    private let k = Constants()
    private let items: [String]
    private var buttons: [UIButton] = []
    private var selectedIndex: Int = 0
    
    // MARK: - Init
    init(items: [String]) {
        self.items = items
        super.init(frame: .zero)
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        calculateTotalSize()
    }
}

// MARK: - Private Setup
private extension SegmentedFilterView {
    
    func setupButtons() {
        for (index, title) in items.enumerated() {
            let button = createButton(title: title, tag: index)
            addSubview(button)
            buttons.append(button)
        }
        updateSelection()
    }
    
    func createButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: k.fontSize, weight: .medium)
        button.layer.cornerRadius = k.buttonCornerRadius
        button.tag = tag
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
}

// MARK: - Private Layout
private extension SegmentedFilterView {
    func layoutButtons() {
        var xOffset: CGFloat = 0
        
        for button in buttons {
            let width = calculateButtonWidth(for: button)
            
            button.pin
                .left(xOffset)
                .top()
                .width(width)
                .height(k.buttonHeight)
            
            xOffset += width + k.buttonSpacing
        }
    }
    
    func calculateButtonWidth(for button: UIButton) -> CGFloat {
        let title = button.title(for: .normal) ?? ""
        let font = UIFont.systemFont(ofSize: k.fontSize, weight: .medium)
        let textWidth = title.size(withAttributes: [.font: font]).width
        return textWidth + k.buttonHorizontalPadding
    }
    
    func calculateTotalSize() -> CGSize {
        var totalWidth: CGFloat = 0
        
        for button in buttons {
            totalWidth += calculateButtonWidth(for: button) + k.buttonSpacing
        }
        
        return CGSize(width: totalWidth - k.buttonSpacing, height: k.buttonHeight)
    }
}

// MARK: - Private Actions
private extension SegmentedFilterView {
    @objc func buttonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateSelection()
        delegate?.segmentedFilterView(self, didSelectIndex: selectedIndex)
    }
}

// MARK: - Private UI Updates
private extension SegmentedFilterView {
    func updateSelection() {
        for (index, button) in buttons.enumerated() {
            let isSelected = index == selectedIndex
            applyStyle(to: button, isSelected: isSelected)
        }
    }
    
    func applyStyle(to button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = AppColors.red
            button.setTitleColor(.white, for: .normal)
            button.layer.borderWidth = 0
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(AppColors.textPrimary, for: .normal)
            button.layer.borderWidth = k.borderWidth
            button.layer.borderColor = AppColors.separator.cgColor
        }
    }
}

// MARK: - Interface
extension SegmentedFilterView {
    func setSelectedIndex(_ index: Int) {
        guard index < buttons.count else { return }
        selectedIndex = index
        updateSelection()
    }
}
