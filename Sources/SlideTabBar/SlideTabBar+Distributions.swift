import SnapKit
import UIKit

public protocol SlideTabBarDistribution {
    func update(
        _ stackView: UIStackView,
        _ fullConstraint: Constraint?
    )
}

extension SlideTabBar {
    public struct ContentLeadingDistribution: SlideTabBarDistribution {
        public func update(
            _ stackView: UIStackView,
            _ fullConstraint: Constraint?
        ) {
            stackView.distribution = .equalSpacing
            fullConstraint?.deactivate()
        }
    }

    public struct FillEquallyDistribution: SlideTabBarDistribution {
        public func update(
            _ stackView: UIStackView,
            _ fullConstraint: Constraint?
        ) {
            stackView.distribution = .fillEqually
            fullConstraint?.activate()
        }
    }
}
