//
//  String+Escaped.swift
//  CPL_XML2Strings
//
//  Created by Adrian Ziemecki on 11/10/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

extension String {
    private static let escapeSequences = [
        (original: "\0", escaped: "\\0"),
//        (original: "\\", escaped: "\\\\"), //Not used, plus there's issues with this one.
        (original: "\t", escaped: "\\t"),
        (original: "\n", escaped: "\\n"),
        (original: "\r", escaped: "\\r"),
        (original: "\"", escaped: "\\\""),
        (original: "\\'", escaped: "\'") //Transifex file already has this one escaped, while we don't need it escaped at all.
    ]

    mutating func literalize() {
        self = self.literalized()
    }

    func literalized() -> String {
        return String.escapeSequences.reduce(self) { string, seq in
            string.replacingOccurrences(of: seq.original, with: seq.escaped)
        }
    }
}
