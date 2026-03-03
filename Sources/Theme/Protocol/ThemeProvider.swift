import Combine
import UIKit

/// 主題提供者介面。
///
/// Usage:
/// ```swift
/// ThemeServiceContext.register(MyThemeProvider())
/// ```
protocol ThemeProvider {
    var onThemeChanged: AnyPublisher<Void, Never> { get }
    var currentTheme: AppTheme { get }
}

enum AppTheme {
    case day
    case night
}

final class ThemeServiceContext {
    private static var instance: ThemeProvider?

    private init() { }

    static func register(_ instance: ThemeProvider) {
        self.instance = instance
    }

    static var shared: ThemeProvider {
        guard let instance else {
            fatalError("ThemeProvider not registered")
        }

        return instance
    }
}
