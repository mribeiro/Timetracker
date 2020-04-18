//
//  NSTextView+Utils.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 05/05/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

extension NSTextView {
    func appendText(_ line: String) {
        let attrDict = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): NSFont.systemFont(ofSize: 11.0)]
        let astring = NSAttributedString(string: "\(line)\n", attributes: convertToOptionalNSAttributedStringKeyDictionary(attrDict))
        self.textStorage?.append(astring)
        let loc = self.string.lengthOfBytes(using: String.Encoding.utf8)

        let range = NSRange(location: loc, length: 0)
        self.scrollRangeToVisible(range)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
