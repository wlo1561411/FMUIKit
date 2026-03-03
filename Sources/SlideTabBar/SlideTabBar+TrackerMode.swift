import UIKit

public protocol SlideTabBarTrackerMode {
    func location(
        with item: SlideTabBarItem,
        spacing: CGFloat,
        at scrollView: UIScrollView
    ) -> (x: CGFloat, width: CGFloat)
}

extension SlideTabBar {
    public struct ByViewTrackerMode: SlideTabBarTrackerMode {
        public func location(
            with item: SlideTabBarItem,
            spacing: CGFloat,
            at scrollView: UIScrollView
        ) -> (x: CGFloat, width: CGFloat) {
            let converted = scrollView.convert(item.bounds, from: item)
            return (converted.origin.x - spacing / 2, item.frame.width + spacing)
        }
    }

    public struct ByContentTrackerMode: SlideTabBarTrackerMode {
        public func location(
            with item: SlideTabBarItem,
            spacing _: CGFloat,
            at scrollView: UIScrollView
        ) -> (x: CGFloat, width: CGFloat) {
            let converted = scrollView.convert(item.bounds, from: item)
            return (converted.origin.x, item.frame.width)
        }
    }
}
