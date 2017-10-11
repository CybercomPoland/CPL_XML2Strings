//
//  XMLParser.swift
//  CPL_XML2Strings
//
//  Created by Adrian Ziemecki on 09/10/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

struct TranslationItem {
    static let quotationMark = "\""
    static let stringsTraslationMark = " = "

    var name = ""
    var value = ""

    var localizableString: String {
        let string = TranslationItem.quotationMark + name + TranslationItem.quotationMark
            + TranslationItem.stringsTraslationMark + TranslationItem.quotationMark
            + value.literalized() + TranslationItem.quotationMark
        return string
    }
}

protocol CPLXMLParserDelegate: class {
    func didFinishParsing(url: URL, translatedItems: [TranslationItem])
    func errorOccured(url: URL, parseError: Error)
}

class CPLXMLParser: NSObject, XMLParserDelegate {
    private var currentItem = TranslationItem()
    private var translatedItems: [TranslationItem] = []
    weak var delegate: CPLXMLParserDelegate?
    let url: URL
    let parser: XMLParser

    init?(url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        self.url = url
        self.parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
    }

    func parse() {
        parser.parse()
    }

    func parserDidStartDocument(_ parser: XMLParser) {
        currentItem = TranslationItem()
        translatedItems.removeAll()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "string" {
            currentItem = TranslationItem()
            if let name = attributeDict["name"] {
                currentItem.name = name
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !currentItem.name.isEmpty {
            currentItem.value += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "string" && !currentItem.name.isEmpty {
            var item = TranslationItem()
            item.name = currentItem.name
            item.value = currentItem.value
            translatedItems.append(item)
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        delegate?.didFinishParsing(url: url, translatedItems: translatedItems)
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        delegate?.errorOccured(url: url, parseError: parseError)
    }
}
