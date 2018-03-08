//
//  BottomAlignedLable.swift
//  paths
//
//  Created by Kevin Finn on 3/7/18.
//https://stackoverflow.com/questions/34059260/text-bottom-center-uilabel-ios-swift

import UIKit

@IBDesignable class BottomAlignedLabel: UILabel {

    override func drawText(in rect: CGRect) {
        
        guard text != nil else {
            return super.drawText(in: rect)
        }
        
        let height = self.sizeThatFits(rect.size).height
        let y = rect.origin.y + rect.height - height
        super.drawText(in: CGRect(x: 0, y: y, width: rect.width, height: height))
    }
}
