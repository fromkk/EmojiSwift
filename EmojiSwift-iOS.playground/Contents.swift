//: Playground - noun: a place where people can play

import UIKit
import Emoji

let text: String = "hello :smile: world :joy: !!!"
let result: String = text.replacedWithEmoji

print(result)

let emojiKeywords: [String] = { () -> [String] in
    return "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_:".map { return String($0) }
}()
