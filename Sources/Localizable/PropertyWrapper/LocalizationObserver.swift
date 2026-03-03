import Combine

/// 多語言變更觀察者。
///
/// Usage:
/// ```swift
/// class MyObserver: LocalizationObserver {
///     override func handleLanguageChanged() { }
/// }
/// ```
class LocalizationObserver {
    let provider: LocalizationProvider

    private var cancellables: AnyCancellable?

    init(provider: LocalizationProvider = LocalizationServiceContext.shared) {
        self.provider = provider
        self.cancellables = provider
            .onLanguageChanged
            .sink { [weak self] in
                self?.handleLanguageChanged()
            }
    }

    deinit {
        cancellables?.cancel()
        cancellables = nil
    }

    func handleLanguageChanged() { }
}
