import UIKit

final class CustomButton : UIButton {
    
    enum Buttonstyle {
        case arrowRed
        case arrowDarkRed
        case arrowGray
        
        case textPlusArrowRed
        case textPlusArrowDarkRed
        case textPlusArrowGray
        
        case squareTextRed
        case squareTextDarkRed
        case squareTextGray
        
        case circleTextRed
        case skip
    }
    
    private let style : Buttonstyle?
    private let title : String?
    
    init(style: Buttonstyle?, title: String?) {
        self.style = style
        self.title = title
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false
        addTarget(self, action: #selector(didTaped(_:)), for: .touchUpInside)
        tintColor = .black
        let grayimage = Resources.Images.Icons.arrowRight?.withTintColor(.gray)
        
        if style == .arrowRed || style == .arrowDarkRed || style == .arrowGray {
            heightAnchor.constraint(equalToConstant: 56).isActive = true
            widthAnchor.constraint(equalToConstant: 56).isActive = true
            setImage(Resources.Images.Icons.arrowRight, for: .normal)
            layer.cornerRadius = 8
            if style == .arrowRed {
                backgroundColor = .gray
            } else if style == .arrowDarkRed {
                backgroundColor = .gray
            } else {
                backgroundColor = .gray
                setImage(grayimage, for: .normal)
                isEnabled = false
            }
        } else if style == .textPlusArrowRed || style == .textPlusArrowDarkRed || style == .textPlusArrowGray {
            heightAnchor.constraint(equalToConstant: 56).isActive = true
            layer.cornerRadius = 8
            setTitle(title, for: .normal)
            setTitleColor(.white, for: .normal)
            setImage(Resources.Images.Icons.arrowRight, for: .normal)
            semanticContentAttribute = .forceRightToLeft
            titleLabel?.font = .helveticalBold(withSize: 16)
            if style == .textPlusArrowRed {
                backgroundColor = .gray
            } else if style == .textPlusArrowDarkRed {
                backgroundColor = .gray
            } else {
                backgroundColor = .gray
                setTitleColor(.black, for: .normal)
                setImage(grayimage, for: .normal)
                isEnabled = false
            }
        } else if style == .squareTextRed || style == .squareTextDarkRed || style == .squareTextGray {
            heightAnchor.constraint(equalToConstant: 56).isActive = true
            layer.cornerRadius = 8
            setTitle(title, for: .normal)
            setTitleColor(.white, for: .normal)
            titleLabel?.font = .helveticalBold(withSize: 16)
            if style == .squareTextRed {
                backgroundColor = .gray
            } else if style == .squareTextDarkRed {
                backgroundColor = .gray
            } else {
                backgroundColor = .gray
                setTitleColor(.black, for: .normal)
                isEnabled = false
            }
        } else if style == .circleTextRed {
            heightAnchor.constraint(equalToConstant: 44).isActive = true
            layer.cornerRadius = 22
            setTitle(title, for: .normal)
            setTitleColor(.white, for: .normal)
            titleLabel?.font = .helveticalBold(withSize: 20)
            backgroundColor = .gray
        } else {
            setTitle(title, for: .normal)
            setTitleColor(.white, for: .normal)
            titleLabel?.font = .helveticalLight(withSize: 10)
        }
    }
    
    @objc private func didTaped(_ sender: UIButton) {
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1
        }
    }
}
