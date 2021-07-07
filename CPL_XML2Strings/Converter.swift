//
//  Converter.swift
//  CPL_XML2Strings
//
//  Created by Adrian Ziemecki on 09/10/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

class Converter {
    let configuration: Configuration
    var semaphore = DispatchSemaphore(value: 0)

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func parse() {
        let inputs = inputUrls(forPath: configuration.inputFolder)
        var parser: CPLXMLParser
        for input in inputs {
            do {
                parser = try CPLXMLParser.init(url: input)
                parser.delegate = self
                parser.parse()
                semaphore.wait()
            } catch {
                print("CPL_XML2Strings: Failed to parse url: \(input)\nError: \(error)")
            }
        }
    }

    private func inputUrls(forPath path: String) -> [URL] {
        var urls: [URL] = []
        let pathUrl = URL(fileURLWithPath: path, isDirectory: true)
        let fileManager = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsSubdirectoryDescendants, .skipsHiddenFiles]
        let enumerator = fileManager.enumerator(at: pathUrl, includingPropertiesForKeys: nil, options: options, errorHandler: {(_, _) -> Bool in
                return true
        })
        if let enumerator = enumerator {
            while let path = enumerator.nextObject() as? URL {
                if path.pathExtension == Configuration.Constants.inputExtension {
                    urls.append(path)
                }
            }
        }
        return urls
    }

    private func save(translation items: [TranslationItem], fromUrl: URL) {
        let stringLines = items.map { $0.localizableString }.sorted { lhs, rhs in
            let isLhsGeneric = lhs.lowercased().hasPrefix("\"generic")
            let isRhsGeneric = rhs.lowercased().hasPrefix("\"generic")
            // other keys sorted
            if isLhsGeneric && isRhsGeneric {
                return lhs < rhs
            } else if isLhsGeneric {
                return true
            } else if isRhsGeneric {
                return false
            }
            // generic keys at the top
            return lhs < rhs
        }
        let output = stringLines.joined(separator: "\n")
        writeToFile(contents: output, inputUrl: fromUrl, fileName: configuration.localizableStringsFileName, fileExtension: Configuration.Constants.outputExtension)
    }

    private func save(infoPlistTranslation items: [TranslationItem], fromUrl: URL) {
        let stringLines = items.map { $0.localizableString }.sorted()
        let output = stringLines.joined(separator: "\n")
        writeToFile(contents: output, inputUrl: fromUrl, fileName: configuration.infoPlistStringsFileName, fileExtension: Configuration.Constants.outputExtension)
    }

    private func save(pluralTranslation items: [PluralTranslationItem], fromUrl: URL) {
        let xmlString = StringsdictCreator.stringsdict(from: items, options: [.nodePreserveAttributeOrder, .nodePrettyPrint])
        writeToFile(contents: xmlString, inputUrl: fromUrl, fileName: configuration.localizableStringsFileName, fileExtension: Configuration.Constants.pluralsOutputExtension)
    }

    private func writeToFile(contents: String, inputUrl: URL, fileName: String, fileExtension: String) {
        let inputFilename = inputUrl.deletingPathExtension().lastPathComponent
        let outputFileUrl: URL
        if let range = inputFilename.range(of: Configuration.Constants.transifexFileString) {
            var language = String(inputFilename[range.upperBound..<inputFilename.endIndex])
            if let languageSubstitute = configuration.languageFilenameSubstitutes[language] {
                language = languageSubstitute
            }
            let languagePath = "\(language).lproj"
            let directoryUrl = URL(fileURLWithPath: configuration.outputFolder)
                .appendingPathComponent(languagePath)
            outputFileUrl = directoryUrl
                .appendingPathComponent(fileName)
                .appendingPathExtension(fileExtension)
            try? FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        } else {
            let directoryUrl = URL(fileURLWithPath: configuration.outputFolder)
                .appendingPathComponent(inputFilename)
            outputFileUrl = directoryUrl
                .appendingPathComponent(fileName)
                .appendingPathExtension(fileExtension)
            try? FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        }

        do {
            try contents.write(to: outputFileUrl, atomically: true, encoding: .utf8)
            print("CPL_XML2Strings: File saved, path: \(outputFileUrl.path)")
        } catch {
            print("CPL_XML2Strings: Could not save file to path: \(outputFileUrl.path)")
        }
    }
}

extension Converter: CPLXMLParserDelegate {
    func didFinishParsing(url: URL, translatedItems: [TranslationItem], translatedPluralItems: [PluralTranslationItem], translatedInfoPlistItems: [TranslationItem]) {
        print("CPL_XML2Strings: Parsed \(url.lastPathComponent),\n translated items: \(translatedItems.count)")
        save(translation: translatedItems, fromUrl: url)
        save(pluralTranslation: translatedPluralItems, fromUrl: url)
        save(infoPlistTranslation: translatedInfoPlistItems, fromUrl: url)
        semaphore.signal()
    }

    func errorOccured(url: URL, parseError: Error) {
        print("CPL_XML2Strings: Failed to parse \(url.lastPathComponent),\n error:\(parseError.localizedDescription)")
        semaphore.signal()
    }
}
