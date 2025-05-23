//
//  RichTextAttributeReader.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-27.
//  Copyright © 2022-2024 Daniel Saidi. All rights reserved.
//

import Foundation

/// This protocol extends the ``RichTextReader`` protocol to
/// make any implementing type able to get attributes in the
/// ``RichTextReader/richText`` property.
///
/// This protocol is implemented by `NSAttributedString` and
/// other types in the library.
///
/// > Note: The protocol used to have a lot of functionality
/// for getting various attributes, styles, etc. However, it
/// caused duplicated code since the ``RichTextViewComponent``
/// needed more capabilities as well. As such, this protocol
/// is now limited in functionality.
public protocol RichTextAttributeReader: RichTextReader {}

extension NSAttributedString: RichTextAttributeReader {}

public extension RichTextAttributeReader {

    /// Get a certain rich text attribute at a certain range.
    func richTextAttribute<Value>(
        _ attribute: RichTextAttribute,
        at range: NSRange
    ) -> Value? {
        richTextAttributes(at: range)[attribute] as? Value
    }

    /// Get all rich text attributes at a certain range.
    func richTextAttributes(
        at range: NSRange
    ) -> RichTextAttributes {
        if richText.length == 0 { return [:] }
        let range = safeRange(for: range, isAttributeOperation: true)
        return richText.attributes(at: range.location, effectiveRange: nil)
    }
}
