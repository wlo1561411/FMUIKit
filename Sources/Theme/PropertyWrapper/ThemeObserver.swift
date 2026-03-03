import Combine

/// 主題變更觀察者。
///
/// Usage:
/// ```swift
/// class MyObserver: ThemeObserver {
///     override func handleThemeChanged() { }
/// }
/// ```
class ThemeObserver {
    let provider: ThemeProvider

    private var cancellable: AnyCancellable?

    init(provider: ThemeProvider = ThemeServiceContext.shared) {
        self.provider = provider
        self.cancellable = provider
            .onThemeChanged
            .sink { [weak self] in
                self?.handleThemeChanged()
            }
    }

    deinit {
        cancellable?.cancel()
        cancellable = nil
    }

    func handleThemeChanged() { }
}
