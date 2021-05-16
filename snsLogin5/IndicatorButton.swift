//
//  IndicatorButton.swift
//  snsLogin5
//
//  Created by 민트팟 on 2021/05/12.
//

import UIKit

class IndicatorButton: UIButton {
    private var text: String?
    private var image: UIImage?
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
        indicatorView.color = UIColor.white
        self.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        let centerYConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: indicatorView, attribute: .centerY, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: indicatorView, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraints([centerYConstraint, centerXConstraint])
        return indicatorView
    }()
    
    var isShowIndicator: Bool {
        get {
            return !self.indicatorView.isHidden
        }
    }
    
    func showIndicator(_ style: UIActivityIndicatorView.Style, color: UIColor) {
        self.indicatorView.style = style
        self.indicatorView.color = color
        if (self.currentTitle ?? "") != "" {
            self.image = self.currentImage
            self.text = self.currentTitle
            self.setImage(nil, for: .normal)
            self.setTitle("", for: .normal)
        }
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
    }
    
    func hideIndicator() {
        self.indicatorView.isHidden = true
        self.indicatorView.stopAnimating()
        if let image = self.image {
            self.setImage(image, for: .normal)
        }
        if let text = self.text {
            self.setTitle(text, for: .normal)
        }
    }
}
