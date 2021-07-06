//
//  XMLParser.swift
//  CPL_XML2Strings
//
//  Created by Adrian Ziemecki on 09/10/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

protocol CPLXMLParserDelegate: class {
    func didFinishParsing(url: URL, translatedItems: [TranslationItem], translatedPluralItems: [PluralTranslationItem])
    func errorOccured(url: URL, parseError: Error)
}

class CPLXMLParser: NSObject, XMLParserDelegate {
    private var currentItem = TranslationItem()
    private var currentPluralItem = PluralTranslationItem()
    private var translatedItems: [TranslationItem] = []
    private var translatedPluralItems: [PluralTranslationItem] = []
    weak var delegate: CPLXMLParserDelegate?
    let url: URL
    let parser: XMLParser

    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self.url = url
        self.parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
    }

    func parse() {
        parser.parse()
    }

    // MARK: - XMLParserDelegate

    func parserDidStartDocument(_ parser: XMLParser) {
        currentItem = TranslationItem()
        translatedItems.removeAll()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        switch elementName {
        case "string":
            currentItem = TranslationItem()
            if let name = attributeDict["name"] {
                currentItem.name = name
            }
        case "plurals":
            currentPluralItem = PluralTranslationItem()
            if let name = attributeDict["name"] {
                currentPluralItem.name = name
            }
        case "item":
            currentItem = TranslationItem()
            if let quantity = attributeDict["quantity"] {
                currentItem.name = quantity
            }
        // HOTFIX: To keep the following selected html markups in the translated content
        case "a", "i", "b":
            let attributes = attributeDict.map { args in
                "\(args.key)=\"\(args.value)\""
            }.joined(separator: " ")
            currentItem.value += attributes.isEmpty ? "<\(elementName)>" : "<\(elementName) \(attributes)>"
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !currentItem.name.isEmpty {
            currentItem.value += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "string" where !currentItem.name.isEmpty:
            let item = TranslationItem(name: currentItem.name, value: currentItem.value)
            translatedItems.append(item)
            currentItem.clear()
        case "plurals" where !currentPluralItem.name.isEmpty:
            let item = PluralTranslationItem(name: currentPluralItem.name, plurals: currentPluralItem.plurals)
            translatedPluralItems.append(item)
            currentPluralItem.clear()
        case "item" where !currentItem.name.isEmpty && !currentPluralItem.name.isEmpty:
            let item = TranslationItem(name: currentItem.name, value: currentItem.value)
            currentPluralItem.plurals.append(item)
            currentItem.clear()
        // HOTFIX: To keep the following selected html markups in the translated content
        case "a", "i", "b":
            currentItem.value += "</\(elementName)>"
        default:
            break
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        delegate?.didFinishParsing(url: url, translatedItems: translatedItems, translatedPluralItems: translatedPluralItems)
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        delegate?.errorOccured(url: url, parseError: parseError)
    }
}
