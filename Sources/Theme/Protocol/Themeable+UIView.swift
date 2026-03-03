import UIKit

/// Theme support for UIView properties.
///
/// Usage:
/// ```swift
/// @Themed
/// var view = UIView()
///
/// _view.update(
///     by: ThemeContentBuilder()
///         .backgroundColor("cardBG")
///         .tintColor("accent")
///         .contents
/// )
/// ```
///
/// UILabel / UIButton / UITextField / UITextView will also apply `.textColor` / `.titleColor`.
/// UIView will also apply `.borderColor`.
extension UIView: ThemeUpdatable {
    func updateTheme(by contents: [ThemeContent]) {
        for content in contents {
            switch content.kind {
            case .backgroundColor:
                backgroundColor = content.color
            case .tintColor:
                tintColor = content.color
            case .borderColor:
                layer.borderColor = content.color.cgColor
            case .textColor:
                let label = self as? UILabel
                let textField = self as? UITextField
                let textView = self as? UITextView
                label?.textColor = content.color
                textField?.textColor = content.color
                textView?.textColor = content.color
            case .titleColor(let state):
                let button = self as? UIButton
                button?.setTitleColor(content.color, for: state)
            }
        }
    }

    func replaceTheme(by old: [ThemeContent], by new: [ThemeContent]) {
        let oldMap = ThemeContentMap(from: old)
        let newMap = ThemeContentMap(from: new)

        if let oldContent = oldMap.background,
           let newContent = newMap.background,
           backgroundColor == oldContent.currentColor {
            backgroundColor = newContent.color
        }

        if let oldContent = oldMap.tint,
           let newContent = newMap.tint,
           tintColor == oldContent.currentColor {
            tintColor = newContent.color
        }

        if let oldContent = oldMap.border,
           let newContent = newMap.border,
           layer.borderColor == oldContent.currentColor.cgColor {
            layer.borderColor = newContent.color.cgColor
        }

        if let oldContent = oldMap.text,
           let newContent = newMap.text {
            if let label = self as? UILabel,
               label.textColor == oldContent.currentColor {
                label.textColor = newContent.color
            }

            if let textField = self as? UITextField,
               textField.textColor == oldContent.currentColor {
                textField.textColor = newContent.color
            }

            if let textView = self as? UITextView,
               textView.textColor == oldContent.currentColor {
                textView.textColor = newContent.color
            }
        }

        if let button = self as? UIButton {
            for (rawValue, oldContent) in oldMap.titleColors {
                guard let newContent = newMap.titleColors[rawValue]
                else {
                    continue
                }

                let state = UIControl.State(rawValue: rawValue)
                if button.titleColor(for: state) == oldContent.currentColor {
                    button.setTitleColor(newContent.color, for: state)
                }
            }
        }
    }
}

private struct ThemeContentMap {
    private(set) var background: ThemeContent?
    private(set) var tint: ThemeContent?
    private(set) var border: ThemeContent?
    private(set) var text: ThemeContent?
    private(set) var titleColors: [UInt: ThemeContent] = [:]

    init(from contents: [ThemeContent]) {
        for content in contents {
            switch content.kind {
            case .backgroundColor:
                background = content
            case .tintColor:
                tint = content
            case .textColor:
                text = content
            case .borderColor:
                border = content
            case .titleColor(let state):
                titleColors[state.rawValue] = content
            }
        }
    }
}
