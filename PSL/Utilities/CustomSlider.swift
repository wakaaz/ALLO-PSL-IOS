//
//  CustomSlider.swift
//  PSL
//
//  Created by MacBook on 08/04/2021.
//

import UIKit

class CustomSlider: UISlider {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var trackHeight: CGFloat = 3

        @IBInspectable var thumbRadius: CGFloat = 20

        // Custom thumb view which will be converted to UIImage
        // and set as thumb. You can customize it's colors, border, etc.
        private lazy var thumbView: UIView = {
            let thumb = UIView()
            thumb.backgroundColor = UICommonMethods.hexStringToUIColor(hex: "#35BE79")
            thumb.layer.borderWidth = 0.4
            thumb.layer.borderColor = UIColor.darkGray.cgColor
            return thumb
        }()

        override func awakeFromNib() {
            super.awakeFromNib()
            let thumb = thumbImage(radius: thumbRadius)
            setThumbImage(thumb, for: .normal)
        }

        private func thumbImage(radius: CGFloat) -> UIImage {
            // Set proper frame
            // y: radius / 2 will correctly offset the thumb

            thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
            thumbView.layer.cornerRadius = radius / 2

            // Convert thumbView to UIImage
            // See this: https://stackoverflow.com/a/41288197/7235585

            let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
            return renderer.image { rendererContext in
                thumbView.layer.render(in: rendererContext.cgContext)
            }
        }

        override func trackRect(forBounds bounds: CGRect) -> CGRect {
            // Set custom track height
            // As seen here: https://stackoverflow.com/a/49428606/7235585
            var newRect = super.trackRect(forBounds: bounds)
            newRect.size.height = trackHeight
            return newRect
        }


}
