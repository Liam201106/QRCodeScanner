// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "QRCodeScanner",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "QRCodeScanner",
            targets: ["QRCodeScanner"]
        )
    ],
    targets: [
        .target(
            name: "QRCodeScanner",
            dependencies: [],
            resources: [
                .process("Resources/QRCodeScannerView.xib")
            ]
        )
    ]
)
