import Foundation
import UIKit


// MARK: - Lists Formatter
//
class TextListFormatter: ParagraphAttributeFormatter {

    /// Style of the list
    ///
    let listStyle: TextList.Style

    /// Attributes to be added by default
    ///
    let placeholderAttributes: [String: Any]?

    /// Tells if the formatter is increasing the depth of a list or simple changing the current one if any
    let increaseDepth: Bool

    /// Designated Initializer
    ///
    init(style: TextList.Style, placeholderAttributes: [String: Any]? = nil, increaseDepth: Bool = false) {
        self.listStyle = style
        self.placeholderAttributes = placeholderAttributes
        self.increaseDepth = increaseDepth
    }


    // MARK: - Overwriten Methods

    func apply(to attributes: [String : Any], andStore representation: HTMLRepresentation?) -> [String: Any] {
        let newParagraphStyle = ParagraphStyle()
        if let paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSParagraphStyle {
            newParagraphStyle.setParagraphStyle(paragraphStyle)
        }

        let newList = TextList(style: self.listStyle, with: representation)
        if newParagraphStyle.lists.isEmpty || increaseDepth {
            newParagraphStyle.insertProperty(newList, afterLastOfType: TextList.self)
        } else {
            newParagraphStyle.replaceProperty(ofType: TextList.self, with: newList)
        }

        var resultingAttributes = attributes
        resultingAttributes[NSParagraphStyleAttributeName] = newParagraphStyle

        return resultingAttributes
    }

    func remove(from attributes: [String: Any]) -> [String: Any] {
        guard let paragraphStyle = attributes[NSParagraphStyleAttributeName] as? ParagraphStyle,
              let currentList = paragraphStyle.lists.last,
              currentList.style == self.listStyle
        else {
            return attributes
        }

        let newParagraphStyle = ParagraphStyle()
        newParagraphStyle.setParagraphStyle(paragraphStyle)       
        newParagraphStyle.removeProperty(ofType: TextList.self)

        var resultingAttributes = attributes
        resultingAttributes[NSParagraphStyleAttributeName] = newParagraphStyle

        return resultingAttributes
    }

    func present(in attributes: [String: Any]) -> Bool {
        return TextListFormatter.lists(in: attributes).last?.style == listStyle
    }


    // MARK: - Static Helpers

    static func listsOfAnyKindPresent(in attributes: [String: Any]) -> Bool {
        return lists(in: attributes).isEmpty == false
    }

    static func lists(in attributes: [String: Any]) -> [TextList] {
        let style = attributes[NSParagraphStyleAttributeName] as? ParagraphStyle
        return style?.lists ?? []
    }
}

