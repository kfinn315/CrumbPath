//
//  TopAlignedLable.swift
//  paths
//
//  Created by Kevin Finn on 3/7/18.
//https://stackoverflow.com/questions/1054558/vertically-align-text-to-top-within-a-uilabel

import UIKit

/**
 Label that pushes its text to the top
 */
@IBDesignable class TopAlignedLabel: UILabel {
    
    override func drawText(in rect:CGRect) {
        guard let labelText = text else {  return super.drawText(in: rect) }
        
        let attributedText = NSAttributedString(string: labelText, attributes: [NSAttributedStringKey.font: font])
        var newRect = rect
        newRect.size.height = attributedText.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, context: nil).size.height
        
        if numberOfLines != 0 {
            newRect.size.height = min(newRect.size.height, CGFloat(numberOfLines) * font.lineHeight)
        }
        
        super.drawText(in: newRect)
    }    
}
