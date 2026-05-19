//
//  HelpViewController.swift
//  Povareshka
//

import UIKit
import MessageUI

final class HelpViewController: BaseController {

    // MARK: - ScrollView override (автоматическое управление клавиатурой)
    private let mainScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactiveWithAccessory
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    override var scrollView: UIScrollView? { mainScrollView }

    // MARK: - UI Components
    private let contentStack = UIStackView(
        axis: .vertical,
        alignment: .fill,
        spacing: Constants.spacingBig
    )

    private let infoLabel = UILabel(
        text: "Опишите вашу проблему, задайте вопрос или поделитесь идеей — мы ответим вам в ближайшее время.",
        font: .systemFont(ofSize: 14),
        textColor: AppColors.gray600,
        textAlignment: .left,
        numberOfLines: 0
    )

    private let typeHeaderLabel = UILabel(
        text: "Тип обращения",
        font: .systemFont(ofSize: 13, weight: .medium),
        textColor: AppColors.gray600
    )

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Вопрос", "Ошибка", "Предложение"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = AppColors.primaryOrange
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let messageHeaderLabel = UILabel(
        text: "Сообщение",
        font: .systemFont(ofSize: 13, weight: .medium),
        textColor: AppColors.gray600
    )

    private lazy var messageTextView = UITextView.configureTextView(
        placeholder: "Введите ваше сообщение...",
        delegate: self
    )

    private lazy var sendButton = UIButton(
        title: "Отправить",
        backgroundColor: AppColors.primaryOrange,
        titleColor: .white,
        font: .systemFont(ofSize: 16, weight: .semibold),
        cornerRadius: Constants.cornerRadiusMedium,
        target: self,
        action: #selector(sendTapped)
    )

    // MARK: - Properties
//    private let supportEmail = "lmr161990@gmail.com"

    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        navigationItem.title = "Помощь"

        view.addSubview(mainScrollView)
        mainScrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(infoLabel)
        contentStack.setCustomSpacing(24, after: infoLabel)
        contentStack.addArrangedSubview(typeHeaderLabel)
        contentStack.setCustomSpacing(Constants.spacingSmall, after: typeHeaderLabel)
        contentStack.addArrangedSubview(segmentedControl)
        contentStack.setCustomSpacing(24, after: segmentedControl)
        contentStack.addArrangedSubview(messageHeaderLabel)
        contentStack.setCustomSpacing(Constants.spacingSmall, after: messageHeaderLabel)
        contentStack.addArrangedSubview(messageTextView)
        contentStack.setCustomSpacing(32, after: messageTextView)
        contentStack.addArrangedSubview(sendButton)
    }

    override func setupConstraints() {
        sendButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        messageTextView.heightAnchor.constraint(equalToConstant: 160).isActive = true

        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: Constants.paddingMedium),
            contentStack.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -Constants.paddingMedium),
            contentStack.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -Constants.paddingMedium * 2)
        ])
    }

    // MARK: - Actions
    @objc private func sendTapped() {
        let message = messageTextView.text ?? ""

        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showInputAlert(title: "Ошибка", message: "Пожалуйста, опишите ваш вопрос или проблему")
            return
        }

        let types = ["Вопрос", "Ошибка", "Предложение"]
        let selectedType = segmentedControl.selectedSegmentIndex >= 0
            ? types[segmentedControl.selectedSegmentIndex]
            : "Вопрос"

        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setToRecipients([AppStrings.Email.supportEmail])
            composer.setSubject("[\(selectedType)] Povareshka — обращение")
            composer.setMessageBody(message, isHTML: false)
            present(composer, animated: true)
        } else {
            showInputAlert(
                title: "Почта не настроена",
                message: "Настройте почтовый клиент на устройстве или напишите нам напрямую: \(AppStrings.Email.supportEmail)"
            )
        }
    }

    private func showInputAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension HelpViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == .lightGray {
            textView.textColor = .black
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.clearButtonStatus = !textView.hasText
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        textView.clearButtonStatus = true
    }

    func textViewDidChange(_ textView: UITextView) {
        textView.placeholder = textView.hasText ? nil : "Введите ваше сообщение..."
        textView.clearButtonStatus = !textView.hasText
        textView.dynamicTextViewHeight(minHeight: 160)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension HelpViewController: @preconcurrency MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
        if result == .sent {
            messageTextView.text = ""
            messageTextView.placeholder = "Введите ваше сообщение..."
            messageTextView.textColor = .lightGray
            messageTextView.clearButtonStatus = true
            segmentedControl.selectedSegmentIndex = 0
            showInputAlert(
                title: "Отправлено",
                message: "Ваше обращение успешно отправлено. Мы ответим вам в ближайшее время."
            )
        }
    }
}
