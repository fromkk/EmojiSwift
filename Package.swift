// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "EmojiSwift",
    products: [
        .library(name: "EmojiSwift", targets: ["EmojiSwift"])
    ],
    targets: [
        .target(
            name: "EmojiSwift",
            path: "EmojiSwift",
            exclude: []
        )
    ]
)
