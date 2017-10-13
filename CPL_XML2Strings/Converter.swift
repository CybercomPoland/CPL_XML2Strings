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
        var parser: CPLXMLParser?
        for input in inputs {
            parser = CPLXMLParser.init(url: input)
            if let parser = parser {
                parser.delegate = self
                parser.parse()
                semaphore.wait()
            }
        }
    }

    private func inputUrls(forPath path: String) -> [URL] {
        var urls: [URL] = []
        let pathUrl = URL(fileURLWithPath: path, isDirectory: true)
        let fileManager = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsSubdirectoryDescendants, .skipsHiddenFiles]
        let enumerator = fileManager.enumerator(at: pathUrl, includingPropertiesForKeys: nil, options: options, errorHandler: {(url, error) -> Bool in
                return true
        })
        if let enumerator = enumerator {
            while let path = enumerator.nextObject() as? URL {
                if path.pathExtension == Configuration.inputExtension {
                    urls.append(path)
                }
            }
        }
        return urls
    }

    fileprivate func save(translation items: [TranslationItem], fromUrl: URL) {
        let stringLines = items.map{ (item) -> String in
            return item.localizableString
        }
        var output = stringLines.reduce("") { return $0+"\n"+$1 }
        output.removeFirst()
        let inputFilename = fromUrl.deletingPathExtension().lastPathComponent
        let outputFileUrl: URL
        if let range = inputFilename.range(of: Configuration.transifexFileString) {
            let language = String(inputFilename[range.upperBound..<inputFilename.endIndex])
            let languagePath = "\(language).lproj"
            let directoryUrl = URL(fileURLWithPath: configuration.outputFolder).appendingPathComponent(languagePath)
            outputFileUrl = directoryUrl.appendingPathComponent(configuration.outputName).appendingPathExtension(Configuration.outputExtension)
            try? FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        } else {
            outputFileUrl = URL(fileURLWithPath: configuration.outputFolder).appendingPathComponent(configuration.outputName).appendingPathExtension(Configuration.outputExtension)
        }

        do {
            try output.write(to: outputFileUrl, atomically: true, encoding: .utf8)
            print("File saved, path: \(outputFileUrl.path)")
        } catch {
            print("Could not save file to path: \(outputFileUrl.path)")
        }
        semaphore.signal()
    }
}

extension Converter: CPLXMLParserDelegate {
    func didFinishParsing(url: URL, translatedItems: [TranslationItem]) {
        print("Parsed \(url.lastPathComponent),\n translated items: \(translatedItems.count)")
        save(translation: translatedItems, fromUrl: url)
    }

    func errorOccured(url: URL, parseError: Error) {
        print("Failed to parse \(url.lastPathComponent),\n error:\(parseError.localizedDescription)")
        semaphore.signal()
    }
}
