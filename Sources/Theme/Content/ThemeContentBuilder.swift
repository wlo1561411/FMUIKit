import UIKit

/// 主題內容建立器。
///
/// Usage:
/// ```swift
/// let contents = ThemeContentBuilder()
///     .textColor(day: .black, night: .white)
///     .backgroundColor(day: .white, night: .black)
///     .contents
///
/// let fixedContents = ThemeContentBuilder()
///     .textColor(.label)
///     .borderColor(.separator)
///     .contents
/// ```
final class ThemeContentBuilder {
    private let provider: ThemeProvider

    private(set) var contents: [ThemeContent] = []

    init(provider: ThemeProvider = ThemeServiceContext.shared) {
        self.provider = provider
    }

    @discardableResult
    func textColor(day: UIColor, night: UIColor) -> Self {
        contents.append(
            DayNightThemeContent(
                day: day,
                night: night,
                provider: provider,
                kind: .textColor
            )
        )

        return self
    }

    @discardableResult
    func textColor(_ color: UIColor) -> Self {
        contents.append(
            FixedColorThemeContent(
                color: color,
                provider: provider,
                kind: .textColor
            )
        )

        return self
    }

    @discardableResult
    func backgroundColor(day: UIColor, night: UIColor) -> Self {
        contents.append(
            DayNightThemeContent(
                day: day,
                night: night,
                provider: provider,
                kind: .backgroundColor
            )
        )

        return self
    }

    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        contents.append(
            FixedColorThemeContent(
                color: color,
                provider: provider,
                kind: .backgroundColor
            )
        )

        return self
    }

    @discardableResult
    func tintColor(day: UIColor, night: UIColor) -> Self {
        contents.append(
            DayNightThemeContent(
                day: day,
                night: night,
                provider: provider,
                kind: .tintColor
            )
        )

        return self
    }

    @discardableResult
    func tintColor(_ color: UIColor) -> Self {
        contents.append(
            FixedColorThemeContent(
                color: color,
                provider: provider,
                kind: .tintColor
            )
        )

        return self
    }

    @discardableResult
    func borderColor(day: UIColor, night: UIColor) -> Self {
        contents.append(
            DayNightThemeContent(
                day: day,
                night: night,
                provider: provider,
                kind: .borderColor
            )
        )

        return self
    }

    @discardableResult
    func borderColor(_ color: UIColor) -> Self {
        contents.append(
            FixedColorThemeContent(
                color: color,
                provider: provider,
                kind: .borderColor
            )
        )

        return self
    }

    @discardableResult
    func titleColor(day: UIColor, night: UIColor, for state: UIControl.State) -> Self {
        contents.append(
            DayNightThemeContent(
                day: day,
                night: night,
                provider: provider,
                kind: .titleColor(state: state)
            )
        )

        return self
    }

    @discardableResult
    func titleColor(_ color: UIColor, for state: UIControl.State) -> Self {
        contents.append(
            FixedColorThemeContent(
                color: color,
                provider: provider,
                kind: .titleColor(state: state)
            )
        )

        return self
    }
}
