import Combine
import Foundation

/// 主題前綴。
///
/// 會自行監聽主題變更並更新內容。
///
/// Usage:
/// ```swift
/// @Themed
/// var label = UILabel()
/// ```
@propertyWrapper
final class Themed<T: ThemeUpdatable>: ThemeObserver {
    typealias MakeContents = (ThemeContentBuilder) -> [ThemeContent]

    private var contents: [ThemeContent] = []

    var wrappedValue: T

    init(
        wrappedValue: T,
        contents: [ThemeContent] = [],
        updateWhenInit: Bool = true
    ) {
        self.contents = contents
        self.wrappedValue = wrappedValue

        if updateWhenInit {
            wrappedValue.updateTheme(by: contents)
        }
    }

    convenience init(
        wrappedValue: T,
        makeContents: MakeContents,
        updateWhenInit: Bool = true
    ) {
        self.init(
            wrappedValue: wrappedValue,
            contents: makeContents(ThemeContentBuilder()),
            updateWhenInit: updateWhenInit)
    }

    func update(by contents: [ThemeContent]) {
        self.contents = contents
        wrappedValue.updateTheme(by: contents)
    }

    func update(makeContents: MakeContents) {
        update(by: makeContents(ThemeContentBuilder()))
    }

    override func handleThemeChanged() {
        wrappedValue.updateTheme(by: contents)
    }
}

/// 將 ThemeUpdatable 的呼叫轉發給 wrappedValue，讓多個 property wrapper 可以疊加。
extension Themed: ThemeUpdatable {
    func updateTheme(by contents: [ThemeContent]) {
        wrappedValue.updateTheme(by: contents)
    }

    func replaceTheme(by old: [ThemeContent], by new: [ThemeContent]) {
        wrappedValue.replaceTheme(by: old, by: new)
    }
}

/// 將 Localizable 的呼叫轉發給 wrappedValue，讓 @Themed 可以與 @Localizer 疊加使用。
extension Themed: Localizable where T: Localizable {
    func updateLocalization(by contents: [LocalizationContent]) {
        wrappedValue.updateLocalization(by: contents)
    }

    func replaceLocalization(by old: [LocalizationContent], by new: [LocalizationContent]) {
        wrappedValue.replaceLocalization(by: old, by: new)
    }
}
