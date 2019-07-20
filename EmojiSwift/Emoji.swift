//
//  Emoji.swift
//  EmojiSwift
//
//  Created by Kazuya Ueoka on 2017/04/08.
//
//

import Foundation

public class EmojiManager {
    public static var emojis: [Emoji] = {
        let data: Data = emojiJson.data(using: .utf8)!
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try jsonDecoder.decode([Emoji].self, from: data)
        } catch {
            print("decode failed \(error)")
            return []
        }
    }()
}

public struct Emoji: Codable {
    public let emoji: String?
    public let description: String?
    public let category: String?
    public let aliases: [String]?
    public let tags: [String]?
    public let unicodeVersion: String?
    public let iosVersion: String?
}

public extension String {
    var replacedWithEmoji: String {
        let matches: [[String]]
        do {
            matches = try self.regexp(pattern: ":([a-zA-Z0-9_]+):").matches
            let result: String = matches.reduce(self, { (res: String, currentMatches: [String]) -> String in
                guard currentMatches.indices.contains(1) else { return res }
                let matched: String = currentMatches[0]
                let alias: String = currentMatches[1]
                
                guard let emoji: Emoji = EmojiManager.emojis.filter({ (emoji: Emoji) -> Bool in
                    guard let aliases: [String] = emoji.aliases else { return false }
                    return aliases.contains(alias)
                }).first else {
                    return res
                }
                return res.replacingOccurrences(of: matched, with: emoji.emoji ?? "")
            })
            return result
        } catch {
            return self
        }
    }
    
    struct Regexp {
        let regularExpression: NSRegularExpression
        let text: String
    }
    
    func regexp(pattern: String) throws -> Regexp {
        return Regexp(regularExpression: try NSRegularExpression(pattern: pattern, options: []), text: self)
    }
    
    var nsRange: NSRange {
        return (self as NSString).range(of: self)
    }
}

extension String.Regexp {
    public var isMatched: Bool {
        return 0 < self.regularExpression.numberOfMatches(in: self.text, options: [], range: self.text.nsRange)
    }
    
    public var matches: [[String]] {
        let matched: [NSTextCheckingResult] = self.regularExpression.matches(in: self.text, options: [], range: self.text.nsRange)
        return matched.map { (textCheckingResult: NSTextCheckingResult) -> [String] in
            return (0..<textCheckingResult.numberOfRanges).map({ (i: Int) -> String in
                return (self.text as NSString).substring(with: textCheckingResult.range(at: i))
            })
        }
    }
    
    public func replace(with replace: String) -> String {
        return self.matches.reduce(self.text) { (text: String, currentMatches: [String]) -> String in
            return text.replacingOccurrences(of: currentMatches[0], with: replace)
        }
    }
}
