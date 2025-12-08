import Foundation

extension String {
    public static let attachmentCharacter: String = "\u{FFFC}"
    
    // used for NSString related task. since .count is not always equal to .length for emojis etc..
    public var length: Int {
        utf16.count
    }
    
    public var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
    
    public var pathComponents: [String] {
        (self as NSString).pathComponents
    }
    
    public var numberOfWords: Int {
        var count = 0
        enumerateSubstrings(in: startIndex..<endIndex, options: [.byWords, .substringNotRequired, .localized]) {
            _, _, _, _ -> Void in
            count += 1
        }
        return count
    }
}

extension NSString {
    public var numberOfWords: Int {
        let inputRange = CFRangeMake(0, length)
        let flag = UInt(kCFStringTokenizerUnitWord)
        let locale = CFLocaleCopyCurrent()
        let tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, self, inputRange, flag, locale)
        var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        var count = 0
        
        while tokenType != [] {
            count += 1
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        return count
    }
}
