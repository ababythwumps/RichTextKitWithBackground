//
//  RichTextView_UIKit.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-12.
//  Copyright © 2022-2024 Daniel Saidi. All rights reserved.
//

#if iOS || os(tvOS) || os(visionOS)
import UIKit

#if iOS || os(visionOS)
import UniformTypeIdentifiers

extension RichTextView: UIDropInteractionDelegate {}
#endif

/// This is a platform-agnostic text view for both UIKit and
/// AppKit that makes the underlying views behave more alike.
///
/// The view inherits `NSTextView` in AppKit and `UITextView`
/// in UIKit and implements ``RichTextViewComponent``, which
/// is the protocol that is used within this library.
///
/// The view will apply a disabled ``imageConfiguration`` by
/// default. You can change this by setting the property, or
/// by applying a ``RichTextDataFormat`` that handles images.
open class RichTextView: UITextView, RichTextViewComponent {

    // MARK: - Initializers

    public convenience init(
        data: Data,
        format: RichTextDataFormat = .archivedData
    ) throws {
        self.init()
        try self.setup(with: data, format: format)
    }

    public convenience init(
        string: NSAttributedString,
        format: RichTextDataFormat = .archivedData
    ) {
        self.init()
        self.setup(with: string, format: format)
    }

    // MARK: - Essentials

    /// Get the frame of a certain range.
    open func frame(of range: NSRange) -> CGRect {
        let beginning = beginningOfDocument
        guard
            let start = position(from: beginning, offset: range.location),
            let end = position(from: start, offset: range.length),
            let textRange = textRange(from: start, to: end)
        else { return .zero }
        let rect = firstRect(for: textRange)
        return convert(rect, from: textInputView)
    }

    /// Get the text range at a certain point.
    open func range(at index: CGPoint) -> NSRange? {
        let range = characterRange(at: index) ?? UITextRange()
        let location = offset(from: beginningOfDocument, to: range.start)
        let length = offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }


    // MARK: - Properties

    /// The configuration to use by the rich text view.
    public var configuration: Configuration = .standard {
        didSet {
            isScrollEnabled = configuration.isScrollingEnabled
            allowsEditingTextAttributes = configuration.allowsEditingTextAttributes
            autocapitalizationType = configuration.autocapitalizationType
            spellCheckingType = configuration.spellCheckingType
        }
    }

    public var theme: Theme = .standard {
        didSet { setup(theme) }
    }

    /// The style to use when highlighting text in the view.
    public var highlightingStyle: RichTextHighlightingStyle = .standard

    /**
     The image configuration to use by the rich text view.

     The view uses the ``RichTextImageConfiguration/disabled``
     configuration by default. You can change this by either
     setting the property manually or by setting up the view
     with a ``RichTextDataFormat`` that supports images.
     */
    public var imageConfiguration: RichTextImageConfiguration = .disabled {
        didSet {
            #if iOS || os(visionOS)
            refreshDropInteraction()
            imageConfigurationWasSet = true
            #endif
        }
    }

    /// The image configuration to use by the rich text view.
    var imageConfigurationWasSet = false

    #if iOS || os(visionOS)

    /// The image drop interaction to use.
    lazy var imageDropInteraction: UIDropInteraction = {
        UIDropInteraction(delegate: self)
    }()

    /// The interaction types supported by drag & drop.
    var supportedDropInteractionTypes: [UTType] {
        [.image, .text, .plainText, .utf8PlainText, .utf16PlainText]
    }

    #endif

    /// Keeps track of the first time a valid frame is set.
    private var isInitialFrameSetupNeeded = true

    /// Keeps track of the data format used by the view.
    private var richTextDataFormat: RichTextDataFormat = .archivedData

    // MARK: - Overrides

    /**
     Layout subviews and auto-resize images in the rich text.

     I tried to only autosize image attachments here, but it
     didn't work - they weren't resized. I then tried adding
     font size adjustment, but that also didn't work. So now
     we initialize this once, when the frame is first set.
     */
    open override var frame: CGRect {
        didSet {
            if frame.size == .zero { return }
            if !isInitialFrameSetupNeeded { return }
            isInitialFrameSetupNeeded = false
            setup(with: attributedString, format: richTextDataFormat)
        }
    }

    #if iOS || os(visionOS)
    /**
     Check whether or not a certain action can be performed.
     */
    open override func canPerformAction(
        _ action: Selector,
        withSender sender: Any?
    ) -> Bool {
        let pasteboard = UIPasteboard.general
        let hasImage = pasteboard.image != nil
        let isPaste = action == #selector(paste(_:))
        let canPerformImagePaste = imagePasteConfiguration != .disabled
        if isPaste && hasImage && canPerformImagePaste { return true }
        return super.canPerformAction(action, withSender: sender)
    }

    /**
     Paste the current content of the general pasteboard.
     */
    open override func paste(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        if let image = pasteboard.image {
            return pasteImage(image, at: selectedRange.location)
        }
        super.paste(sender)
    }
    #endif

    // MARK: - Setup

    /**
     Setup the rich text view with a rich text and a certain
     ``RichTextDataFormat``.

     - Parameters:
       - text: The text to edit with the text view.
       - format: The rich text format to edit.
     */
    open func setup(
        with text: NSAttributedString,
        format: RichTextDataFormat
    ) {
        text.autosizeImageAttachments(maxSize: imageAttachmentMaxSize)
        setupSharedBehavior(with: text, format)
        richTextDataFormat = format
        setup(theme)
    }

    // MARK: - Open Functionality

    /// Alert a certain title and message.
    open func alert(title: String, message: String, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        alert.addAction(action)
        let controller = window?.rootViewController?.presentedViewController
        controller?.present(alert, animated: true, completion: nil)
    }

    /// Copy the current selection.
    open func copySelection() {
        #if iOS || os(visionOS)
        let pasteboard = UIPasteboard.general
        let range = safeRange(for: selectedRange)
        let text = richText(at: range)
        pasteboard.string = text.string
        #else
        print("Pasteboard is not available on this platform")
        #endif
    }

    /// Delete the text at a certain range.
    open func deleteText(in range: NSRange) {
        deleteCharacters(in: range)
    }

    /// Try to redo the latest undone change.
    open func redoLatestChange() {
        undoManager?.redo()
    }

    /// Scroll to a certain range.
    open func scroll(to range: NSRange) {
        let caret = frame(of: range)
        scrollRectToVisible(caret, animated: true)
    }

    /// Set the rich text in the text view.
    open func setRichText(_ text: NSAttributedString) {
        attributedString = text
    }

    ///  Set the selected range in the text view.
    open func setSelectedRange(_ range: NSRange) {
        selectedRange = range
    }

    /// Undo the latest change.
    open func undoLatestChange() {
        undoManager?.undo()
    }

    #if iOS || os(visionOS)

    // MARK: - UIDropInteractionDelegate

    /// Whether or not the view can handle a drop session.
    open func dropInteraction(
        _ interaction: UIDropInteraction,
        canHandle session: UIDropSession
    ) -> Bool {
        if session.hasImage && imageDropConfiguration == .disabled { return false }
        let identifiers = supportedDropInteractionTypes.map { $0.identifier }
        return session.hasItemsConforming(toTypeIdentifiers: identifiers)
    }

    /// Handle an updated drop session.
    open func dropInteraction(
        _ interaction: UIDropInteraction,
        sessionDidUpdate session: UIDropSession
    ) -> UIDropProposal {
        let operation = dropInteractionOperation(for: session)
        return UIDropProposal(operation: operation)
    }

    /// The drop interaction operation for a certain session.
    open func dropInteractionOperation(
        for session: UIDropSession
    ) -> UIDropOperation {
        guard session.hasDroppableContent else { return .forbidden }
        let location = session.location(in: self)
        return frame.contains(location) ? .copy : .cancel
    }

    /**
     Handle a performed drop session.

     In this function, we reverse the item collection, since
     each item will be pasted at the drop point, which would
     result in a reverse result.
     */
    open func dropInteraction(
        _ interaction: UIDropInteraction,
        performDrop session: UIDropSession
    ) {
        guard session.hasDroppableContent else { return }
        let location = session.location(in: self)
        guard let range = self.range(at: location) else { return }
        performImageDrop(with: session, at: range)
        performTextDrop(with: session, at: range)
    }

    // MARK: - Drop Interaction Support

    /**
     Performs an image drop session.

     We reverse the item collection, since each item will be
     pasted at the original drop point.
     */
    open func performImageDrop(with session: UIDropSession, at range: NSRange) {
        guard validateImageInsertion(for: imageDropConfiguration) else { return }
        session.loadObjects(ofClass: UIImage.self) { items in
            let images = items.compactMap { $0 as? UIImage }.reversed()
            images.forEach { self.pasteImage($0, at: range.location) }
        }
    }

    /**
     Perform a text drop session.

     We reverse the item collection, since each item will be
     pasted at the original drop point.
     */
    open func performTextDrop(with session: UIDropSession, at range: NSRange) {
        if session.hasImage { return }
        _ = session.loadObjects(ofClass: String.self) { items in
            let strings = items.reversed()
            strings.forEach { self.pasteText($0, at: range.location) }
        }
    }

    /// Refresh the drop interaction based on the config.
    open func refreshDropInteraction() {
        switch imageDropConfiguration {
        case .disabled:
            removeInteraction(imageDropInteraction)
        case .disabledWithWarning, .enabled:
            addInteraction(imageDropInteraction)
        }
    }
    #endif
}

#if iOS || os(visionOS)
private extension UIDropSession {

    var hasDroppableContent: Bool {
        hasImage || hasText
    }

    var hasImage: Bool {
        canLoadObjects(ofClass: UIImage.self)
    }

    var hasText: Bool {
        canLoadObjects(ofClass: String.self)
    }
}
#endif

// MARK: - Public Extensions

public extension RichTextView {

    /// The text view's layout manager, if any.
    var layoutManagerWrapper: NSLayoutManager? {
        layoutManager
    }

    /// The spacing between the text view edges and its text.
    var textContentInset: CGSize {
        get {
            CGSize(
                width: textContainerInset.left,
                height: textContainerInset.top
            )
        } set {
            textContainerInset = UIEdgeInsets(
                top: newValue.height,
                left: newValue.width,
                bottom: newValue.height,
                right: newValue.width
            )
        }
    }

    /// The text view's text storage, if any.
    var textStorageWrapper: NSTextStorage? {
        textStorage
    }
}

// MARK: - RichTextProvider

public extension RichTextView {

    /// Get the rich text managed by the text view.
    var attributedString: NSAttributedString {
        get { super.attributedText ?? NSAttributedString(string: "") }
        set { attributedText = newValue }
    }
}

// MARK: - RichTextWriter

public extension RichTextView {

    /// Get the mutable rich text managed by the view.
    var mutableAttributedString: NSMutableAttributedString? {
        textStorage
    }
}
#endif
