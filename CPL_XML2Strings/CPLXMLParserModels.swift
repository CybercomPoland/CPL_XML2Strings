//
//  CPLXMLParserModels.swift
//  CPL_XML2Strings
//
//  Created by Adrian Ziemecki on 06/02/2018.
//  Copyright © 2018 Cybercom. All rights reserved.
//

import Foundation

struct TranslationItem {
    static let quotationMark = "\""
    static let stringsTraslationMark = " = "
    static let stringsLineEndMark = "\";"

    var name = ""
    var value = ""
    var convertedValue: String {
        return convertStringFormat(string: value.literalized())
    }

    var localizableString: String {
        let string = TranslationItem.quotationMark + name + TranslationItem.quotationMark
            + TranslationItem.stringsTraslationMark + TranslationItem.quotationMark
            + convertedValue + TranslationItem.stringsLineEndMark
        return string
    }

    private func convertStringFormat(string: String) -> String {
        var outputString = string
        let pattern = "(%)(\\d*\\$)?(s)"
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            outputString = regex.stringByReplacingMatches(in: outputString, options: [], range: NSRange(location: 0, length: outputString.characters.count), withTemplate: "$1$2@")
        }
        return outputString
    }

    mutating func clear() {
        name = ""
        value = ""
    }
}

struct PluralTranslationItem {
    var name = ""
    var plurals: [TranslationItem] = []

    mutating func clear() {
        name = ""
        plurals.removeAll()
    }
}
