import UIKit

/// 主題內容介面。
///
/// Usage:
/// ```swift
/// let byDayNight = DayNightThemeContent(
///     day: .white,
///     night: .black,
///     provider: ThemeServiceContext.shared,
///     kind: .backgroundColor
/// )
///
/// let byColor = FixedColorThemeContent(
///     color: .systemBlue,
///     provider: ThemeServiceContext.shared,
///     kind: .tintColor
/// )
/// ```
protocol ThemeContent {
    var provider: ThemeProvider { get }
    var currentColor: UIColor { get }
    var kind: ThemeContentKind { get }

    func color(for style: AppTheme) -> UIColor
    func refresh() -> Self
}

enum ThemeContentKind {
    case textColor
    case backgroundColor
    case tintColor
    case borderColor
    case titleColor(state: UIControl.State)
}

extension ThemeContent {
    var color: UIColor {
        color(for: provider.currentTheme)
    }
}

struct DayNightThemeContent: ThemeContent {
    let day: UIColor
    let night: UIColor
    let provider: ThemeProvider
    let kind: ThemeContentKind

    var currentColor: UIColor

    init(
        day: UIColor,
        night: UIColor,
        provider: ThemeProvider,
        kind: ThemeContentKind
    ) {
        self.day = day
        self.night = night
        self.provider = provider
        self.kind = kind
        self.currentColor = Self.color(for: provider.currentTheme, day: day, night: night)
    }

    func color(for style: AppTheme) -> UIColor {
        Self.color(for: style, day: day, night: night)
    }

    func refresh() -> DayNightThemeContent {
        .init(day: day, night: night, provider: provider, kind: kind)
    }

    private static func color(for style: AppTheme, day: UIColor, night: UIColor) -> UIColor {
        switch style {
        case .day:
            day
        case .night:
            night
        }
    }
}

struct FixedColorThemeContent: ThemeContent {
    let color: UIColor
    let provider: ThemeProvider
    let kind: ThemeContentKind

    var currentColor: UIColor

    init(
        color: UIColor,
        provider: ThemeProvider,
        kind: ThemeContentKind
    ) {
        self.color = color
        self.provider = provider
        self.kind = kind
        self.currentColor = color
    }

    func color(for style: AppTheme) -> UIColor {
        color
    }

    func refresh() -> FixedColorThemeContent {
        self
    }
}
