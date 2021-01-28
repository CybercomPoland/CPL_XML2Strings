//
//  StringsdictCreator.swift
//  CPL_XML2Strings
//
//  Created by Adrian Ziemecki on 07/02/2018.
//  Copyright © 2018 Cybercom. All rights reserved.
//

import Foundation

class StringsdictCreator {
    private init() {}

    // MSG-5752 TODO: Only one variable and NSStringFormatValueType supported.
    class func stringsdict(from items: [PluralTranslationItem], options: XMLNode.Options) -> String {
        let root = XMLElement(name: "plist")
        //swiftlint:disable:next force_cast
        let plistAttribute = XMLNode.attribute(withName: "version", stringValue: "1.0") as! XMLNode
        root.addAttribute(plistAttribute)
        let dict = XMLElement(name: "dict")
        let xml = XMLDocument(rootElement: root)
        xml.documentContentKind = .xml
        xml.characterEncoding = "UTF-8"
        xml.version = "1.0"
        let dtd = XMLDTD(kind: .DTDKind)
        dtd.name = "plist"
        dtd.publicID = "-//Apple//DTD PLIST 1.0//EN"
        dtd.systemID = "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
        xml.dtd = dtd
        for item in items {
            dict.addChild(XMLElement(name: "key", stringValue: item.name))
            let itemElement = XMLElement(name: "dict")
            itemElement.addChild(XMLElement(name: "key", stringValue: "NSStringLocalizedFormatKey"))
            itemElement.addChild(XMLElement(name: "string", stringValue: "%#@Variable@"))
            itemElement.addChild(XMLElement(name: "key", stringValue: "Variable"))
            let pluralsElement = XMLElement(name: "dict")
            pluralsElement.addChild(XMLElement(name: "key", stringValue: "NSStringFormatSpecTypeKey"))
            pluralsElement.addChild(XMLElement(name: "string", stringValue: "NSStringPluralRuleType"))
            pluralsElement.addChild(XMLElement(name: "key", stringValue: "NSStringFormatValueTypeKey"))
            pluralsElement.addChild(XMLElement(name: "string", stringValue: "d"))
            for plural in item.plurals {
                pluralsElement.addChild(XMLElement(name: "key", stringValue: plural.name))
                pluralsElement.addChild(XMLElement(name: "string", stringValue: plural.value))
            }
            itemElement.addChild(pluralsElement)
            dict.addChild(itemElement)
        }
        root.addChild(dict)
        return xml.xmlString(options: options)
    }
}
