import Foundation
import UIKit

/// UIButton 多語言支援。
///
/// Usage:
/// ```swift
/// @Localizer
/// var button = UIButton()
///
/// _button.update(
///     by: LocalizationContentBuilder()
///         .enabled("title_key")
///         .disabled("disabled_title_key")
///         .contents
/// )
/// ```
extension UIButton: Localizable {
    private static let localizationStates: [UIControl.State] = [.normal, .highlighted, .disabled, .selected]

    private static func makeLocalizationMap(from contents: [any LocalizationContent]) -> [UInt: LocalizationContent] {
        var map: [UInt: LocalizationContent] = [:]

        for content in contents {
            if let stateful = content as? StatefulLocalizationContent {
                map[stateful.state.rawValue] = stateful
            } else if map[UIControl.State.normal.rawValue] == nil {
                map[UIControl.State.normal.rawValue] = content
            }
        }

        return map
    }

    func updateLocalization(by contents: [any LocalizationContent]) {
        for content in contents {
            if let stateful = content as? StatefulLocalizationContent {
                setTitle(stateful.localized, for: stateful.state)
            } else {
                setTitle(content.localized, for: .normal)
            }
        }
    }

    func replaceLocalization(by old: [any LocalizationContent], by new: [any LocalizationContent]) {
        let oldMap = Self.makeLocalizationMap(from: old)
        let newMap = Self.makeLocalizationMap(from: new)

        for state in Self.localizationStates {
            guard let currentTitle = title(for: state), !currentTitle.isEmpty
            else {
                continue
            }

            let stateKey = state.rawValue
            let normalKey = UIControl.State.normal.rawValue
            let oldContent = oldMap[stateKey] ?? oldMap[normalKey]
            let newContent = newMap[stateKey] ?? newMap[normalKey]

            guard
                let oldContent,
                let newContent,
                currentTitle.contains(oldContent.currentLocalized) == true
            else {
                continue
            }

            let updated = currentTitle.replacingOccurrences(
                of: oldContent.currentLocalized,
                with: newContent.localized
            )

            setTitle(updated, for: state)
        }
    }
}
