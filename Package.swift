import PackageDescription

let package = Package(
    name: "sygnaler",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 3),
        .Package(url: "https://github.com/vapor/mysql-provider", majorVersion: 1, minor: 1),
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "Tests",
    ]
)
