import UIKit

/// 主題更新介面。
///
/// Usage:
/// ```swift
/// @Themed
/// var view = UIView()
/// ```
protocol ThemeUpdatable {
    func updateTheme(by contents: [ThemeContent])
    func replaceTheme(by old: [ThemeContent], by new: [ThemeContent])
}
