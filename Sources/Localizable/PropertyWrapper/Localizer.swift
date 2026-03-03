import Combine
import Foundation

/// 多語言前綴。
///
/// 會自行監聽語言轉換，並依照 mode 更新內容。
///
/// Usage:
/// ```swift
/// @Localizer(key: "abc")
/// var label = UILabel()
///
/// @Localizer(mode: .replace)
/// var otherLabel = UILabel()
/// ```
enum LocalizationUpdateMode {
    case updateAll
    case replace
}

@propertyWrapper
class Localizer<T: Localizable>: LocalizationObserver {
    typealias MakeContents = (LocalizationContentBuilder) -> [LocalizationContent]

    private var contents: [LocalizationContent] = []
    private let mode: LocalizationUpdateMode

    var wrappedValue: T

    init(
        wrappedValue: T,
        mode: LocalizationUpdateMode = .updateAll,
        contents: [LocalizationContent] = [],
        updateWhenInit: Bool = true
    ) {
        self.contents = contents
        self.wrappedValue = wrappedValue
        self.mode = mode

        if updateWhenInit {
            wrappedValue.updateLocalization(by: contents)
        }
    }

    convenience init(
        wrappedValue: T,
        mode: LocalizationUpdateMode = .updateAll,
        makeContents: MakeContents,
        updateWhenInit: Bool = true
    ) {
        self.init(
            wrappedValue: wrappedValue,
            mode: mode,
            contents: makeContents(LocalizationContentBuilder()),
            updateWhenInit: updateWhenInit
        )
    }

    func update(by contents: [LocalizationContent]) {
        self.contents = contents

        wrappedValue.updateLocalization(by: contents)
    }

    func update(makeContents: MakeContents) {
        update(by: makeContents(LocalizationContentBuilder()))
    }

    func replace(by contents: [LocalizationContent]) {
        let previous = self.contents
        self.contents = contents

        wrappedValue.replaceLocalization(by: previous, by: contents)
    }

    func replace(makeContents: MakeContents) {
        replace(by: makeContents(LocalizationContentBuilder()))
    }

    override func handleLanguageChanged() {
        switch mode {
        case .updateAll:
            wrappedValue.updateLocalization(by: contents)
        case .replace:
            let previous = contents
            contents = contents.map { $0.refresh() }
            wrappedValue.replaceLocalization(by: previous, by: contents)
        }
    }
}
