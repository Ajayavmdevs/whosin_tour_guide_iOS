//
//  UILabel-Extension.swift
//  Whosin
//
//  Created by Ronak Trambadiya on 12/05/23.
//

import UIKit

public extension UILabel {

    // MARK: - spacingValue is spacing that you need
    func addInterlineSpacing(spacingValue: CGFloat = 2) {

        // MARK: - Check if there's any text
        guard let textString = text else { return }

        // MARK: - Create "NSMutableAttributedString" with your text
        let attributedString = NSMutableAttributedString(string: textString)

        // MARK: - Create instance of "NSMutableParagraphStyle"
        let paragraphStyle = NSMutableParagraphStyle()

        // MARK: - Actually adding spacing we need to ParagraphStyle
        paragraphStyle.lineSpacing = spacingValue

        // MARK: - Adding ParagraphStyle to your attributed String
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length
        ))

        // MARK: - Assign string that you've modified to current attributed Text
        attributedText = attributedString
    }
    
    var isTruncated: Bool {
            guard let labelText = self.text ?? self.attributedText?.string else { return false }
            
            // Max size the label could take
            let maxSize = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
            
            // Attributes for calculation
            let text: NSAttributedString
            if let attributed = self.attributedText {
                text = attributed
            } else {
                text = NSAttributedString(string: labelText, attributes: [.font: self.font ?? UIFont.systemFont(ofSize: 17)])
            }
            
            let textRect = text.boundingRect(with: maxSize,
                                             options: [.usesLineFragmentOrigin, .usesFontLeading],
                                             context: nil)
            
            // Compare actual height vs. label height
            return textRect.height > self.bounds.height
        }
    
    func numberOfRenderedLines(constrainedWidth: CGFloat? = nil) -> Int {
        // Build an attributed string regardless of which API you used
        let attributed: NSAttributedString? = {
            if let a = self.attributedText { return a }
            if let t = self.text {
                return NSAttributedString(string: t, attributes: [.font: self.font as Any])
            }
            return nil
        }()

        guard let attr = attributed else { return 0 }

        // Resolve width to lay out with
        let width: CGFloat = {
            if let w = constrainedWidth { return w }
            if self.preferredMaxLayoutWidth > 0 { return self.preferredMaxLayoutWidth }
            return self.bounds.width
        }()

        guard width > 0 else { return 0 } // must be after layout

        let textStorage = NSTextStorage(attributedString: attr)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines // respects truncation limit

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        var lines = 0
        var index = 0
        var range = NSRange(location: 0, length: 0)
        while index < layoutManager.numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &range)
            index = NSMaxRange(range)
            lines += 1
        }
        return lines
    }

    /// True only if the label is actually truncating based on its `numberOfLines`.
    var isActuallyTruncated: Bool {
        guard numberOfLines > 0 else { return false }       // unlimited lines can't be "truncated"
        return numberOfRenderedLines() > numberOfLines
    }

}

extension String {
    func toDisplayDate(outputFormat: String = "dd/MM/yyyy") -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")


        if let date = ISO8601DateFormatter().date(from: self) {
            return outputFormatter.string(from: date)
        }
        
        let formats = [
            kFormatDateStandard,
            kStanderdDate,
            kFormatDate,
            kFormatDateLocal,
            kFormatDateDOB,
            kFormatDateReview,
            kFormatDateWithHourMinuteAM,
            kFormatDateTimeLocal,
            kChatTimeFormat,
            kValidityDateTimeFormat,
            kValidityPlanDateFormat,
            kValidityDateFormat,
            kFormatDateWithouTimezone,
            kFormatDateWithouTimezone2
        ]
        
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for format in formats {
            inputFormatter.dateFormat = format
            if let date = inputFormatter.date(from: self) {
                return outputFormatter.string(from: date)
            }
        }
        
        return self // fallback if parsing fails
    }
    
    func toDate() -> Date? {
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")


        if let date = ISO8601DateFormatter().date(from: self) {
            return  date
        }
        
        let formats = [
            kFormatDateStandard,
            kStanderdDate,
            kFormatDate,
            kFormatDateLocal,
            kFormatDateDOB,
            kFormatDateReview,
            kFormatDateWithHourMinuteAM,
            kFormatDateTimeLocal,
            kChatTimeFormat,
            kValidityDateTimeFormat,
            kValidityPlanDateFormat,
            kValidityDateFormat,
            kFormatDateWithouTimezone,
            kFormatDateWithouTimezone2
        ]
        
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for format in formats {
            inputFormatter.dateFormat = format
            if let date = inputFormatter.date(from: self) {
                return date
            }
        }
        
        return nil
    }
}
