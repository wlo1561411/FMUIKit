import Combine
import SnapKit
import UIKit

public class SlideTabBar: UIView {
    private let tagStartPoint = 100

    private let trackerView = UIView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let itemsStackView = UIStackView()

    private var fullConstraint: Constraint?

    private var items: [SlideTabBarItem] = []
    private var itemsCount: Int {
        items.count
    }

    private var _selectedIndex: Int = -1 {
        willSet {
            switchTo(newValue)
        }
    }

    private(set) var selectedIndex: Int {
        get {
            _selectedIndex
        }
        set {
            guard
                _selectedIndex != newValue,
                itemsCount > 0,
                shouldAllowSelect?(newValue) ?? true
            else {
                return
            }

            _selectedIndex = newValue

            guard _selectedIndex >= 0
            else {
                return
            }

            guard !dropFirstTimeReloadSelectAction
            else {
                dropFirstTimeReloadSelectAction = false
                return
            }

            onItemSelected?(_selectedIndex)
        }
    }

    private var getNumberOfItems: (() -> Int)?
    private var itemFactory: ((Int) -> SlideTabBarItem)?
    private var shouldAllowSelect: ((Int) -> Bool)?
    private var onItemSelected: ((Int) -> Void)?

    private var numberOfItems: Int {
        getNumberOfItems?() ?? 0
    }

    private var dropFirstTimeReloadSelectAction = false

    public var numberOfTabs: Int {
        itemsCount
    }

    public var itemSettings: SlideTabBarItem.Settings = [:]
    public var itemSpacing: CGFloat = 10

    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            itemsStackView.layoutMargins = contentInset
        }
    }

    public var trackerHeight: CGFloat = 0
    public var trackerRadius: CGFloat = 0 {
        didSet {
            trackerView.layer.cornerRadius = trackerRadius
        }
    }

    public var trackerColor: UIColor = .blue {
        didSet {
            trackerView.backgroundColor = trackerColor
        }
    }

    public var hasTracker: Bool {
        trackerHeight > 0 && trackerColor != .clear
    }

    public var distribution: SlideTabBarDistribution = SlideTabBar.ContentLeadingDistribution()
    public var trackerMode: SlideTabBarTrackerMode = SlideTabBar.ByContentTrackerMode()

    public var contentSizePublisher: AnyPublisher<CGSize, Never> {
        scrollView
            .publisher(for: \.contentSize)
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        prepareForLayout()
    }

    public func setup(
        numberOfItems: @escaping () -> Int,
        factory: @escaping (Int) -> SlideTabBarItem,
        shouldItemAllowSelect: ((Int) -> Bool)? = nil,
        onSelected: ((Int) -> Void)? = nil
    ) {
        getNumberOfItems = numberOfItems
        itemFactory = factory
        shouldAllowSelect = shouldItemAllowSelect
        onItemSelected = onSelected
    }

    public func reload(
        at index: Int = 0,
        animated: Bool,
        dropFirstTimeReloadSelectAction: Bool = false
    ) {
        self.dropFirstTimeReloadSelectAction = dropFirstTimeReloadSelectAction

        reset()

        buildItemViews(at: index)
    }

    public func select(
        at index: Int?,
        animated: Bool,
        withAction: Bool = true,
        force: Bool = false
    ) {
        if let index {
            if _selectedIndex == index {
                if force, withAction {
                    onItemSelected?(_selectedIndex)
                }
            } else {
                if withAction {
                    selectedIndex = index
                } else {
                    _selectedIndex = index
                }
            }
        } else {
            selectedIndex = -1
        }
    }

    public func refreshItemsUI() {
        for (index, itemView) in items.enumerated() {
            updateItem(itemView, isSelected: index == selectedIndex)
        }
    }

    public func insertPrefixView(
        by view: UIView,
        customSpacing: CGFloat? = nil
    ) {
        guard !itemsStackView.arrangedSubviews.contains(view)
        else {
            return
        }

        itemsStackView.insertArrangedSubview(view, at: 0)

        if let customSpacing {
            itemsStackView.setCustomSpacing(customSpacing, after: view)
        }
    }
}

// MARK: UI

extension SlideTabBar {
    private func prepareForLayout() {
        guard
            scrollView.frame.size.height != 0,
            scrollView.frame.size.width != 0
        else {
            return
        }

        distribution.update(itemsStackView, fullConstraint)

        if
            hasTracker,
            let item = tabBarItem(at: selectedIndex) {
            moveTracker(item, animated: false)
        }
    }

    private func setupUI() {
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false

        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.height.edges.equalToSuperview()
        }

        itemsStackView.isLayoutMarginsRelativeArrangement = true

        contentView.addSubview(itemsStackView)
        itemsStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            fullConstraint = make.width.equalTo(0).constraint
        }

        fullConstraint?.deactivate()

        trackerView.isHidden = true
        trackerView.backgroundColor = trackerColor

        scrollView.insertSubview(trackerView, at: 0)
    }

    private func buildItemViews(at index: Int) {
        guard numberOfItems > 0
        else {
            return
        }

        items = (0..<numberOfItems)
            .compactMap { index in
                guard let item = setupItem(at: index)
                else {
                    return nil
                }

                itemsStackView.addArrangedSubview(item)

                return item
            }

        itemsStackView.spacing = itemSpacing

        setNeedsLayout()
        layoutIfNeeded()

        guard index >= 0
        else {
            scrollView.setContentOffset(.zero, animated: true)
            return
        }

        selectedIndex = index
    }

    private func setupItem(at index: Int) -> SlideTabBarItem? {
        guard let item = itemFactory?(index)
        else {
            return nil
        }

        item.tag = tagStartPoint + index
        updateItem(item, isSelected: false)

        let tap = UITapGestureRecognizer(target: self, action: #selector(onItemTapped(_:)))
        item.addGestureRecognizer(tap)

        return item
    }

    private func updateItem(_ item: SlideTabBarItem?, isSelected: Bool) {
        item?.setSelected(isSelected, settings: itemSettings)
    }

    @objc
    private func onItemTapped(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag
        else {
            return
        }

        selectedIndex = tag - tagStartPoint
    }

    private func tabBarItem(at index: Int) -> SlideTabBarItem? {
        if let item = itemsStackView.arrangedSubviews.first(where: { $0.tag - tagStartPoint == index }) as? SlideTabBarItem {
            return item
        }
        return nil
    }

    private func reset() {
        _selectedIndex = -1

        trackerView.isHidden = true

        for arrangedSubview in itemsStackView.arrangedSubviews where arrangedSubview is SlideTabBarItem {
            itemsStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }

        items.removeAll()
    }
}

// MARK: Animate

extension SlideTabBar {
    private func switchTo(_ selectedIndex: Int) {
        guard itemsCount > 0
        else {
            return
        }

        let preIndex = self.selectedIndex
        let toIndex = selectedIndex

        /// For Reset
        if preIndex >= 0 {
            updateItem(tabBarItem(at: preIndex), isSelected: false)
        }

        if
            toIndex >= 0, toIndex < itemsCount,
            let toItem = tabBarItem(at: toIndex) {
            updateItem(toItem, isSelected: true)

            DispatchQueue.main.async {
                self.scrollToMiddle(toItem, animated: true)
                self.moveTracker(toItem, animated: true)
            }
        }
    }

    private func scrollToMiddle(_ toItem: SlideTabBarItem, animated: Bool) {
        guard scrollView.contentSize.width + contentInset.left + contentInset.right > scrollView.frame.width
        else {
            return
        }

        if contentInset == .zero {
            /// Calculate scrollView center point with toItem
            let calced = CGRect(
                x: toItem.center.x - scrollView.bounds.width / 2,
                y: toItem.frame.origin.y,
                width: scrollView.bounds.width,
                height: scrollView.bounds.height
            )

            scrollView.scrollRectToVisible(calced, animated: animated)
        }

        var offsetX = toItem.center.x - (scrollView.bounds.width / 2)

        /// If item is the first, scroll to the start
        if selectedIndex == 0 {
            offsetX = -scrollView.contentInset.left
        }
        /// If item is the last, scroll to the end
        else if selectedIndex == numberOfItems - 1 {
            offsetX = scrollView.contentSize.width - scrollView.bounds.width + scrollView.contentInset.right
        }
        /// If item can be displayed in the middle, adjust offsetX to center item
        else {
            offsetX = min(
                max(offsetX, -scrollView.contentInset.left),
                scrollView.contentSize.width - scrollView.bounds.width + scrollView.contentInset.right
            )
        }

        let offsetPoint = CGPoint(x: offsetX, y: 0)
        scrollView.setContentOffset(offsetPoint, animated: animated)
    }

    private func moveTracker(_ toItem: SlideTabBarItem, animated: Bool) {
        guard hasTracker
        else {
            return
        }

        let location = trackerMode.location(
            with: toItem,
            spacing: itemSpacing,
            at: scrollView
        )

        let frame = CGRect(
            x: location.x,
            y: bounds.height - trackerHeight,
            width: location.width,
            height: trackerHeight
        )

        if trackerView.isHidden {
            trackerView.isHidden = false
            trackerView.frame = frame
        } else {
            guard animated
            else {
                trackerView.frame = frame
                return
            }

            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                options: .curveEaseIn,
                animations: { [weak trackerView] in
                    trackerView?.frame = frame
                },
                completion: nil
            )
        }
    }
}

// MARK: - Preview

#if canImport(SwiftUI) && swift(>=5.9)
import SwiftUI

@available(iOS 17.0, *)
#Preview {
    let title = (0...20).map { "Test \($0)" }
//    let image = ["arcade.stick.console.fill", "keyboard.badge.ellipsis.fill", "arrowkeys.fill"]

    return SlideTabBar()
        .sr
        .trackerHeight(5)
        .trackerColor(.blue)
        .contentInset(.init(top: 50, left: 16, bottom: 10, right: 16))
        .itemSpacing(10)
        .itemSettings([
            .normal: .init(
                font: .systemFont(ofSize: 14),
                textColor: .darkGray,
                borderColor: .systemGreen,
                borderWidth: 0,
                backgroundColor: .systemGray5
            ),
            .selected: .init(
                font: .systemFont(ofSize: 14),
                textColor: .systemGreen,
                borderWidth: 1
            )
        ])
        .makeConstraints({ make in
            make.width.equalTo(300)
            make.height.equalTo(100)
        })
        .other { tabBar in
            tabBar.backgroundColor = .yellow
            tabBar.setup(
                numberOfItems: { title.count },
                factory: { index in
                    let item = SlideTabBar.DefaultItem()
                    item.backgroundColor = .lightGray
                    item.titleLabel.text = title[index]
                    return item
//                    let item = SlideTabBar.TextOrImageItem(imageWidth: 100)
//                    item.titleLabel.text = title[index]
//                    item.imageView.image = .init(systemName: image[index])
//                    return item
                },
                onSelected: {
                    if $0 == 4 {
//                        tabBar.reload(at: 2, animated: true)
                        tabBar.select(at: 2, animated: true)
                    }
                    print("Tap", $0)
                }
            )
            tabBar.reload(animated: true)
        }
        .unwrap()
}
#endif
