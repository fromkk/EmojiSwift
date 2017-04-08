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
        guard let url: URL = Bundle(for: EmojiManager.self).url(forResource: "emoji", withExtension: "json") else {
            fatalError("emoji.json load failed")
        }
        
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            fatalError("json get failed \(error)")
        }
        
        let json: [[AnyHashable: Any]]
        do {
            guard let result: [[AnyHashable: Any]] = try JSONSerialization.jsonObject(with: data, options: []) as? [[AnyHashable: Any]] else {
                fatalError("json convert failed")
            }
            
            json = result
        } catch {
            fatalError("json parse failed \(error)")
        }
        
        return json.flatMap({ (dictionary: [AnyHashable : Any]) -> Emoji? in
            return Emoji(dictionary: dictionary)
        })
    }()
}

public struct Emoji {
    public let emoji: String
    public let description: String?
    public let category: String?
    public let aliases: [String]?
    public let tags: [String]?
    public let unicodeVersion: String?
    public let iosVersion: String?
    
    public init?(dictionary: [AnyHashable: Any]) {
        guard let emoji: String = dictionary["emoji"] as? String else {
            return nil
        }
        
        self.emoji = emoji
        self.description = dictionary["description"] as? String
        self.category = dictionary["category"] as? String
        self.aliases = dictionary["aliases"] as? [String]
        self.tags = dictionary["tags"] as? [String]
        self.unicodeVersion = dictionary["unicode_version"] as? String
        self.iosVersion = dictionary["ios_version"] as? String
    }
}

public extension String {
    public var replacedWithEmoji: String {
        let matches: [[String]]
        do {
            matches = try self.regexp(pattern: ":([a-zA-Z0-9]+):").matches
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
                return res.replacingOccurrences(of: matched, with: emoji.emoji)
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
                return (self.text as NSString).substring(with: textCheckingResult.rangeAt(i))
            })
        }
    }
    
    public func replace(with replace: String) -> String {
        return self.matches.reduce(self.text) { (text: String, currentMatches: [String]) -> String in
            return text.replacingOccurrences(of: currentMatches[0], with: replace)
        }
    }
}
