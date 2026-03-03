import Foundation
import UIKit

/// 多語言內容建立器。
///
/// Usage:
/// ```swift
/// let contents = LocalizationContentBuilder()
///     .single("title_key")
///     .contents
/// ```
final class LocalizationContentBuilder {
    private let provider: LocalizationProvider

    private(set) var contents: [LocalizationContent] = []

    init(provider: LocalizationProvider = LocalizationServiceContext.shared) {
        self.provider = provider
    }

    /// 建立單一狀態 LocalizationContent
    @discardableResult
    func single(_ key: String, arguments: [CVarArg] = []) -> Self {
        contents = [
            GeneralLocalizationContent(
                key: key,
                arguments: arguments,
                provider: provider
            )
        ]

        return self
    }

    @discardableResult
    func normal(_ key: String, arguments: [CVarArg] = []) -> Self {
        stateful(key, arguments: arguments, state: .normal)
        return self
    }

    @discardableResult
    func disabled(_ key: String, arguments: [CVarArg] = []) -> Self {
        stateful(key, arguments: arguments, state: .disabled)
        return self
    }

    @discardableResult
    func highlighted(_ key: String, arguments: [CVarArg] = []) -> Self {
        stateful(key, arguments: arguments, state: .highlighted)
        return self
    }

    @discardableResult
    private func stateful(
        _ key: String,
        arguments: [CVarArg] = [],
        state: UIControl.State
    )
        -> Self {
        contents.append(
            StatefulLocalizationContent(
                key: key,
                arguments: arguments,
                provider: provider,
                state: state
            )
        )

        return self
    }
}
