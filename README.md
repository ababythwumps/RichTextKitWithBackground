# ORIGINAL PROJECT'S README--THIS PROJECT IS A FORK AND HAS ONE EXTRA PARAMETER IN THE RICH TEXT EDIOR CALL THAT ALLOWS FOR A BACKGROUND COLOR CHANGE:
```swift
struct MyView: View {

    @State private var text = NSAttributedString(string: "Type here...")

    @State private var backgroundColor: Color = .blue
    
    @StateObject var context = RichTextContext()

    var body: some View {
        RichTextEditor(text: $text, backgroundColor: backgroundColor, context: context) {
            // You can customize the native text view here
        }
        .focusedValue(\.richTextContext, context)
    }
}
```

# BELOW IS THE ORIGINAL PROJECT'S README, THE ONLY PART CHANGED FOR THIS FORK IS ABOVE

<p align="center">
    <img src="Resources/Icon.png" alt="Project Icon" width="250" />
</p>

<p align="center">
    <img src="https://img.shields.io/github/v/release/danielsaidi/RichTextKit?color=%2300550&sort=semver" alt="Version" />
    <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift 5.9" />
    <img src="https://img.shields.io/badge/platform-SwiftUI-blue.svg" alt="Swift UI" title="Swift UI" />
    <a href="https://danielsaidi.github.io/RichTextKit"><img src="https://img.shields.io/badge/documentation-web-blue.svg" alt="Documentation" /></a>
    <img src="https://img.shields.io/github/license/danielsaidi/RichTextKit" alt="MIT License" />
</p>



# RichTextKit

RichTextKit is a Swift SDK that lets you edit rich text in `Swift` & `SwiftUI` with a multi-platform `RichTextEditor`:

<p align="center">
    <img src ="Resources/Demo.jpg" />
</p>

The `RichTextEditor` supports text styles (bold, italic, underline, etc.), fonts, font sizes, colors, text alignments, image attachments, and much more. It's powered by a `RichTextView` that bridges `UITextView` & `NSTextView` and adds additional, platform-agnostic APIs that make the two views behave more alike.

If you just want to view rich text content, you can use the `RichTextViewer` SwiftUI view, which wraps the editor and applies a read-only configuration to it.



## Installation

RichTextKit can be installed with the Swift Package Manager:

```
https://github.com/danielsaidi/RichTextKit.git
```



## Getting started

RichTextKit has a SwiftUI ``RichTextEditor`` that takes a text binding and a ``RichTextContext``:

```swift
struct MyView: View {

    @State
    private var text = NSAttributedString(string: "Type here...")
    
    @StateObject
    var context = RichTextContext()

    var body: some View {
        RichTextEditor(text: $text, context: context) {
            // You can customize the native text view here
        }
        .focusedValue(\.richTextContext, context)
    }
}
```

The editor uses a ``RichTextCoordinator`` to sync changes between the editor, context, and platform-specific view. You can use the context to change font, colors, alignment etc. and observe context changes to update the UI.

If you just want to display rich text, you can use the ``RichTextViewer`` instead:

```swift
struct MyView: View {

    private var text = NSAttributedString(...)

    var body: some View {
        RichTextViewer(text: text)
    }
}
```

RichTextKit provides UI components, keyboard shortcuts & menu commands that can be used in a rich text editor.

For more information, please see the [getting started guide][Getting-Started].



## Documentation

The [online documentation][Documentation] has more information, articles, code examples, etc.



## Demo App & Inspiration

The RichTextKit demo lets you explore the library on iOS & macOS. To try it out, just open and run the `Demo` app.

RichTextKit is also used in the following apps, so make sure to check them out for inspiration:

<a title="Chunk" href="https://www.chunkapp.com"><img src="Resources/apps/chunk.png" width=100 /></a> 
<a title="Oribi Writer" href="https://oribi.se/en"><img src="Resources/apps/oribiwriter.png" width=100 /></a>

Don't hesitate to reach out if you are using RichTextKit, and want to add your app to this list. I'd love to feature it.



## Sponsor my work

Please consider supporting my work if you find this and my other [open-source projects][OpenSource] helpful. I manage them on my spare time, and any help to keep them going is greatly appreciated.

You can [sponsor me][Sponsors] on GitHub Sponsors, [reach out][Email] for paid support, or hire me for [freelance work][Website].



## Contact

Feel free to reach out if you have questions or want to contribute in any way:

* Website: [danielsaidi.com][Website]
* E-mail: [daniel.saidi@gmail.com][Email]
* Bluesky: [@danielsaidi@bsky.social][Bluesky]
* Mastodon: [@danielsaidi@mastodon.social][Mastodon]



## License

RichTextKit is available under the MIT license. See the [LICENSE][License] file for more info.



[Email]: mailto:daniel.saidi@gmail.com
[Website]: https://danielsaidi.com
[GitHub]: https://github.com/danielsaidi
[OpenSource]: https://danielsaidi.com/opensource
[Sponsors]: https://github.com/sponsors/danielsaidi

[Bluesky]: https://bsky.app/profile/danielsaidi.bsky.social
[Mastodon]: https://mastodon.social/@danielsaidi
[Twitter]: https://twitter.com/danielsaidi

[Documentation]: https://danielsaidi.github.io/RichTextKit/
[Getting-Started]: https://danielsaidi.github.io/RichTextKit/documentation/richtextkit/getting-started
[License]: https://github.com/danielsaidi/RichTextKit/blob/master/LICENSE
