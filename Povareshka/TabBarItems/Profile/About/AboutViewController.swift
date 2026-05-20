//
//  AboutViewController.swift
//  Povareshka
//

import UIKit

final class AboutViewController: BaseController {

    // MARK: - UI Components
    private let mainScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack = UIStackView(
        axis: .vertical,
        alignment: .center,
        spacing: Constants.spacingBig
    )

    private let appIconImageView = UIImageView(
        image: UIImage(named: "AppIcon60x60"),
        size: Constants.viewSize100,
        cornerRadius: 22,
        contentMode: .scaleAspectFit,
        tintColor: AppColors.primaryOrange,
        backgroundColor: .clear
    )

    private let appNameLabel = UILabel(
        text: "Povareshka",
        font: .systemFont(ofSize: 24, weight: .bold),
        textAlignment: .center
    )

    private let versionLabel: UILabel = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return UILabel(
            text: "Версия \(version)",
            font: .systemFont(ofSize: 14),
            textColor: AppColors.gray600,
            textAlignment: .center
        )
    }()

    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        navigationItem.title = "О приложении"

        view.addSubview(mainScrollView)
        mainScrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(appIconImageView)
        contentStack.setCustomSpacing(12, after: appIconImageView)
        contentStack.addArrangedSubview(appNameLabel)
        contentStack.addArrangedSubview(versionLabel)
        contentStack.setCustomSpacing(28, after: versionLabel)
        for card in [makeDescriptionCard(), makeFeaturesCard(), makeContactCard()] {
            contentStack.addArrangedSubview(card)
            card.widthAnchor.constraint(equalTo: contentStack.widthAnchor).isActive = true
        }
    }

    override func setupConstraints() {
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 32),
            contentStack.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: Constants.paddingMedium),
            contentStack.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -Constants.paddingMedium),
            contentStack.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -Constants.paddingMedium * 2)
        ])
    }

    // MARK: - Card Builders
    private func makeDescriptionCard() -> UIView {
        let label = UILabel(
            text: "Povareshka — ваш личный кулинарный помощник. Открывайте новые рецепты, сохраняйте любимые блюда и делитесь своими кулинарными находками с другими пользователями.",
            font: .systemFont(ofSize: 15),
            textAlignment: .center,
            numberOfLines: 0
        )
        return wrapInCard(label)
    }

    private func makeFeaturesCard() -> UIView {
        let features: [(UIImage?, String)] = [
            (AppImages.Icons.fork,           "Тысячи рецептов на любой вкус"),
            (AppImages.Icons.heart,          "Избранное и сохранённые рецепты"),
            (AppImages.TabBar.shop,          "Список покупок из ингредиентов"),
            (AppImages.Icons.starFilled,     "Оценки и отзывы пользователей"),
            (AppImages.Icons.personBadgePlus,"Создавайте собственные рецепты")
        ]

        let stack = UIStackView(axis: .vertical, alignment: .fill, spacing: 14)
        for (icon, text) in features {
            stack.addArrangedSubview(makeFeatureRow(icon: icon, text: text))
        }
        return wrapInCard(stack)
    }

    private func makeContactCard() -> UIView {
        let titleLabel = UILabel(
            text: "Связаться с нами",
            font: .systemFont(ofSize: 15, weight: .semibold),
            textAlignment: .center
        )
        let emailLabel = UILabel(
            text: AppStrings.Email.supportEmail,
            font: .systemFont(ofSize: 14),
            textColor: AppColors.primaryOrange,
            textAlignment: .center
        )
        let stack = UIStackView(axis: .vertical, alignment: .center, spacing: 6)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(emailLabel)
        return wrapInCard(stack)
    }

    // MARK: - Helpers
    private func wrapInCard(_ content: UIView) -> UIView {
        let card = UIView(backgroundColor: .systemBackground, cornerRadius: Constants.cornerRadiusMedium)
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: Constants.paddingMedium),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Constants.paddingMedium),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Constants.paddingMedium),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Constants.paddingMedium)
        ])
        return card
    }

    private func makeFeatureRow(icon: UIImage?, text: String) -> UIView {
        let imageView = UIImageView(
            image: icon,
            size: Constants.viewSize20,
            contentMode: .scaleAspectFit,
            tintColor: AppColors.primaryOrange,
            backgroundColor: .clear
        )
        let label = UILabel(
            text: text,
            font: .systemFont(ofSize: 15),
            numberOfLines: 0
        )
        let row = UIStackView(axis: .horizontal, alignment: .center, spacing: 12)
        row.addArrangedSubview(imageView)
        row.addArrangedSubview(label)
        return row
    }
}
