//
//  UIView+.swift
//  
//
//  Created by sakiyamaK on 2024/09/16.
//

import UIKit

extension UIView {
    typealias ArroundConstraintConstants = (top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat)
    
    func apply(constraints: [NSLayoutConstraint]) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
        
    func apply(constraint: NSLayoutConstraint) {
        apply(constraints: [constraint])
    }

    func applyArroundConstraint(equalTo layoutGuide: UILayoutGuide, constants: ArroundConstraintConstants = (0, 0, 0, 0)) {
        self.apply(constraints: [
            self.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: constants.top),
            self.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: constants.leading),
            layoutGuide.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: constants.bottom),
            layoutGuide.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: constants.trailing)
        ])
    }
    
    func applyArroundConstraint(equalTo view: UIView, constants: ArroundConstraintConstants = (0, 0, 0, 0)) {
        self.apply(constraints: [
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: constants.top),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constants.leading),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: constants.bottom),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: constants.trailing)
        ])
    }
}


