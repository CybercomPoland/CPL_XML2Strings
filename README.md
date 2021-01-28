# CPL_XML2Strings
XML to Strings parser, built for .xml translation files from Transifex.

# Usage
Available input parameters:
-i [path] -> input folder path, defaults to Bundle.main.path (the directory of the CPL_XML2Strings executable file).
-o [path] -> output folder path, defaults to Bundle.main.path (the directory of the CPL_XML2Strings executable file).
-n [filename] -> output filename (no extension), defaults to 'Localizable'.
-swap [Transifex country code] [language directory] -> changes the language directory that a specified Transifex file will be converted to. Useful when you have a base language selected. Example: -swap en_GB Base

The app searches for .xml files inside the input folder (no deep search, files inside other folders are omitted). Once found, the app attempts to extract strings from <string> nodes, with obligatory name parameter in the node. Incorrect nodes are omitted. The output is then converter into a .strings file, special characters included.
Formatted strings are supported, Android '%s' strings are translated into '%@' for iOS.

Transifex files use 'xmlstrings_' in their filename, followed by a country code that defines the language. The app looks for that element in the filename. If found, the new .strings file is put inside a .lproj folder with the extracted country code as the name. Otherwise, the new file is put inside a folder that is named the same as the input file.
