//
//  SettingsPickerManager.swift
//  Povareshka
//
//  Created by user on 07.10.2025.
//

import UIKit

@MainActor
final class SettingsPickerManager: NSObject {
    
    // MARK: - Properties
    private weak var controller: UIViewController?
    private var onValueSelected: ((String, Int) -> Void)?
    private var settingType: RecipeSettings.SettingType?
    private var pickerData: [String] = []
    
    private lazy var pickerViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.gray100
        return view
    }()

    private var pickerView: UIPickerView?
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(AppStrings.Buttons.done, for: .normal)
        button.setTitleColor(AppColors.primaryOrange, for: .normal)
        button.titleLabel?.font = .helveticalRegular(withSize: 16)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Public Methods
    func showPicker(
        in controller: UIViewController,
        settingType: RecipeSettings.SettingType,
        currentIndex: Int,
        onValueSelected: @escaping (String, Int) -> Void
    ) {
        self.controller = controller
        self.settingType = settingType
        self.onValueSelected = onValueSelected
        self.pickerData = settingType.data
        
        // Сбрасываем старый пикер
        pickerView?.removeFromSuperview()
        pickerView = nil
        
        setupPickerContainer(in: controller.view)
        setupPickerUI()
        
        // Устанавливаем текущее значение (с проверкой границ)
        let safeIndex = max(0, min(currentIndex, pickerData.count - 1))
        pickerView?.selectRow(safeIndex, inComponent: 0, animated: false)
        
        // Анимируем появление
        animatePickerShow()
    }
    
    func hidePicker() {
        animatePickerHide()
    }
    
    // MARK: - Private Methods
    private func setupPickerContainer(in view: UIView) {
        pickerViewContainer.frame = CGRect(
            x: 0,
            y: view.frame.height,
            width: view.frame.width,
            height: 300
        )
        view.addSubview(pickerViewContainer)
    }
    
    private func setupPickerUI() {
        let newPickerView = UIPickerView()
        newPickerView.backgroundColor = AppColors.gray100
        newPickerView.dataSource = self
        newPickerView.delegate = self
        newPickerView.frame = CGRect(
            x: 0,
            y: Constants.height,
            width: pickerViewContainer.frame.width,
            height: 260
        )
        
        pickerViewContainer.addSubview(newPickerView)
        self.pickerView = newPickerView
        
        // Настраиваем кнопку Done
        doneButton.frame = CGRect(
            x: 0,
            y: 0,
            width: pickerViewContainer.frame.width,
            height: Constants.height
        )
        pickerViewContainer.addSubview(doneButton)
    }
    
    private func animatePickerShow() {
        guard let controller = controller else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.pickerViewContainer.frame.origin.y = controller.view.frame.height - 300
        }
    }
    
    private func animatePickerHide() {
        guard let controller = controller else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.pickerViewContainer.frame.origin.y = controller.view.frame.height
        } completion: { _ in
            self.pickerView?.removeFromSuperview()
            self.pickerViewContainer.removeFromSuperview()
            self.pickerView = nil
            self.cleanup()
        }
    }
    
    private func cleanup() {
        controller = nil
        onValueSelected = nil
        settingType = nil
        pickerData = []
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        guard let pickerView = pickerView else { return }
        
        let selectedIndex = pickerView.selectedRow(inComponent: 0)
        
        // Проверяем что индекс в пределах массива
        guard selectedIndex >= 0, selectedIndex < pickerData.count else {
            hidePicker()
            return
        }
        
        let selectedValue = pickerData[selectedIndex]
        onValueSelected?(selectedValue, selectedIndex)
        hidePicker()
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension SettingsPickerManager: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let settingType = settingType,
              row >= 0, row < pickerData.count else {
            return nil
        }
        return settingType.formatValue(pickerData[row], maxDifficulty: pickerData.count)
    }
}
