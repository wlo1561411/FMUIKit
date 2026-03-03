import UIKit

final class FavorAnimator {
    private weak var imageView: UIImageView?

    private var animation: Animation?
    private let shouldFadeOut: Bool

    private var isOn = false

    private var onScaleDown: (() -> Void)?
    private var onCompleted: (() -> Void)?

    init(
        imageView: UIImageView,
        shouldFadeOut: Bool
    ) {
        self.imageView = imageView
        self.shouldFadeOut = shouldFadeOut

        setupAnimation()
    }

    func start(isOn: Bool = true) {
        self.isOn = isOn
        removeLayerAnimations()
        animation?.perform()
    }

    func setOnCompleted(_ onCompleted: (() -> Void)?) {
        self.onCompleted = onCompleted
    }

    func setOnScaleDown(_ onScaleDown: (() -> Void)?) {
        self.onScaleDown = onScaleDown
    }

    func updateColors(
        normalColor: UIColor? = nil,
        selectedColor: UIColor? = nil
    ) {
        if let normalColor {
            normalImage = .init(systemName: "heart")?.masked(normalColor)
        }
        if let selectedColor {
            selectedImage = .init(systemName: "heart.fill")?.masked(selectedColor)
        }
        imageView?.image = isOn ? selectedImage : normalImage
    }

    func removeLayerAnimations() {
        imageView?.layer.removeAllAnimations()
    }

    // MARK: - Private

    private var normalImage: UIImage?
    private var selectedImage: UIImage?

    private func setupAnimation() {
        let scale = ScaleAnimation(layer: imageView?.layer)
            .onScaleDown { [weak self] in
                guard let self else {
                    return
                }
                imageView?.image = isOn ? selectedImage : normalImage
                onScaleDown?()
            }

        if shouldFadeOut {
            let fadeOut = FadeAnimation(layer: imageView?.layer)
                .onCompleted { [weak self] success in
                    guard let self, success else {
                        return
                    }
                    onCompleted?()
                }
            scale.nextAnimation(fadeOut)
        } else {
            scale.onCompleted { [weak self] _ in
                self?.onCompleted?()
            }
        }

        animation = scale
    }
}

// MARK: - Preview

#if swift(>=5.9)
    fileprivate class FavorAnimator_Preview: BaseHighlightableView {
        @Stylish
        private var imageView = UIImageView()

        private lazy var animator = FavorAnimator(imageView: imageView, shouldFadeOut: true)

        private var isFavor = false

        init() {
            super.init(frame: .zero)

            $imageView
                .add(to: self)
                .makeConstraints { make in
                    make.edges.equalToSuperview()
                }

            animator.updateColors(normalColor: .gray, selectedColor: .red)

            sr.makeConstraints { make in
                make.size.equalTo(50)
            }

            onTap = { [weak self] _ in
                self?.setIsFavor()
            }

            setupGesture()
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setIsFavor() {
            isFavor = !isFavor
            print(isFavor)
            animator.start(isOn: isFavor)
        }
    }

    @available(iOS 17.0, *)
    #Preview {
        FavorAnimator_Preview()
    }
#endif
