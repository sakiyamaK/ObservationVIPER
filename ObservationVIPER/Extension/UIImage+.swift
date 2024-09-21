//
//  UIImage+.swift
//  
//
//  Created by sakiyamaK on 2024/09/21.
//

import UIKit

extension UIImage {
    static func createImage(with size: CGSize, color: UIColor) -> UIImage {
        UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: size)).image { context in
            color.setFill()
            let rect = CGRect(origin: .zero, size: size)
            context.fill(rect)
        }
    }
}
