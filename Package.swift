import PackageDescription

let package = Package(
    name: "sygnaler",
    targets: [
        Target(name: "Sygnaler"),
        Target(name: "App", dependencies: ["Sygnaler"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 4),
        .Package(url: "https://github.com/vapor/mysql-provider", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/matthijs2704/vapor-apns.git", majorVersion: 1, minor: 2)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "travis"
    ]
)
