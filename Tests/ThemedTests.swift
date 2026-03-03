import Combine
import XCTest
import UIKit

@testable import FMUIKit

final class ThemedTests: XCTestCase {
    final class MockThemeProvider: ThemeProvider {
        private let themeChanged = PassthroughSubject<Void, Never>()

        var currentTheme: AppTheme

        init(currentTheme: AppTheme) {
            self.currentTheme = currentTheme
        }

        var onThemeChanged: AnyPublisher<Void, Never> {
            themeChanged.eraseToAnyPublisher()
        }

        func updateTheme(_ theme: AppTheme) {
            currentTheme = theme
            themeChanged.send()
        }
    }

    func testDayNightThemeContentRefreshUsesLatestTheme() {
        let provider = MockThemeProvider(currentTheme: .day)
        let content = DayNightThemeContent(
            day: .white,
            night: .black,
            provider: provider,
            kind: .backgroundColor
        )

        XCTAssertEqual(content.currentColor, UIColor.white)
        XCTAssertEqual(content.color(for: .night), UIColor.black)

        provider.updateTheme(.night)
        let refreshed = content.refresh()

        XCTAssertEqual(refreshed.currentColor, UIColor.black)
    }

    func testThemeContentBuilderBuildsExpectedKinds() {
        let provider = MockThemeProvider(currentTheme: .day)
        let contents = ThemeContentBuilder(provider: provider)
            .textColor(day: .black, night: .white)
            .backgroundColor(.red)
            .tintColor(day: .blue, night: .green)
            .borderColor(.brown)
            .titleColor(.purple, for: .normal)
            .contents

        XCTAssertEqual(contents.count, 5)

        let kinds = Set(contents.map { content in
            switch content.kind {
            case .titleColor:
                return "titleColor"
            case .textColor:
                return "textColor"
            case .backgroundColor:
                return "backgroundColor"
            case .tintColor:
                return "tintColor"
            case .borderColor:
                return "borderColor"
            }
        })

        XCTAssertTrue(kinds.contains("textColor"))
        XCTAssertTrue(kinds.contains("backgroundColor"))
        XCTAssertTrue(kinds.contains("tintColor"))
        XCTAssertTrue(kinds.contains("borderColor"))
        XCTAssertTrue(kinds.contains("titleColor"))

        let textContent = contents.first { content in
            if case .textColor = content.kind { return true }
            return false
        }
        let tintContent = contents.first { content in
            if case .tintColor = content.kind { return true }
            return false
        }
        let titleContent = contents.first { content in
            if case .titleColor(let state) = content.kind { return state == .normal }
            return false
        }

        XCTAssertEqual(textContent?.color, UIColor.black)
        XCTAssertEqual(tintContent?.color, UIColor.blue)
        XCTAssertEqual(titleContent?.color, UIColor.purple)
    }

    func testUIViewUpdateThemeAppliesColors() {
        let provider = MockThemeProvider(currentTheme: .day)
        let contents = ThemeContentBuilder(provider: provider)
            .backgroundColor(day: .white, night: .black)
            .tintColor(.blue)
            .borderColor(.red)
            .contents

        let view = UIView()
        view.updateTheme(by: contents)

        XCTAssertEqual(view.backgroundColor, UIColor.white)
        XCTAssertEqual(view.tintColor, UIColor.blue)
        XCTAssertEqual(view.layer.borderColor, UIColor.red.cgColor)
    }

    func testReplaceThemeUpdatesOnlyMatchingColors() {
        let provider = MockThemeProvider(currentTheme: .day)
        let oldContents = ThemeContentBuilder(provider: provider)
            .backgroundColor(day: .white, night: .black)
            .textColor(day: .black, night: .white)
            .titleColor(day: .blue, night: .green, for: .normal)
            .contents
        let newContents = ThemeContentBuilder(provider: provider)
            .backgroundColor(day: .yellow, night: .gray)
            .textColor(day: .brown, night: .cyan)
            .titleColor(day: .red, night: .purple, for: .normal)
            .contents

        let label = UILabel()
        label.updateTheme(by: oldContents)
        label.replaceTheme(by: oldContents, by: newContents)

        XCTAssertEqual(label.backgroundColor, UIColor.yellow)
        XCTAssertEqual(label.textColor, UIColor.brown)

        let button = UIButton()
        button.updateTheme(by: oldContents)
        button.replaceTheme(by: oldContents, by: newContents)

        XCTAssertEqual(button.backgroundColor, UIColor.yellow)
        XCTAssertEqual(button.titleColor(for: .normal), UIColor.red)
    }

    func testThemedUpdatesWhenThemeChanges() {
        let provider = MockThemeProvider(currentTheme: .day)
        ThemeServiceContext.register(provider)

        let themedLabel = Themed(
            wrappedValue: UILabel(),
            makeContents: {
                $0.textColor(day: .black, night: .white).contents
            }
        )

        XCTAssertEqual(themedLabel.wrappedValue.textColor, UIColor.black)

        provider.updateTheme(.night)

        XCTAssertEqual(themedLabel.wrappedValue.textColor, UIColor.white)
    }
}
