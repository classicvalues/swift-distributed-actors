// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var targets: [PackageDescription.Target] = [
    // ==== ------------------------------------------------------------------------------------------------------------
    // MARK: Actors

    .target(
        name: "DistributedActors",
        dependencies: [
            "NIO",
            "NIOSSL",
            "NIOExtras",
            "NIOFoundationCompat",

            "SwiftProtobuf",

            "Logging", "Metrics",
            "Backtrace",

            "Files", // TODO: remove, currently the codegen needs it 

            "DistributedActorsConcurrencyHelpers",
            "CDistributedActorsMailbox",
        ]
    ),

    // ==== ------------------------------------------------------------------------------------------------------------
    // MARK: GenActors

    .target(
        name: "GenActors",
        dependencies: [
            "DistributedActors",
            "SwiftSyntax",
            "Stencil",
            "Files",
        ]
    ),
    
    // ==== ------------------------------------------------------------------------------------------------------------
    // MARK: Plugins
    
    .target(
         name: "ActorSingletonPlugin",
         dependencies: ["DistributedActors"]
     ),

    // ==== ------------------------------------------------------------------------------------------------------------
    // MARK: XPC

    .target(
        name: "CDistributedActorsXPC",
        dependencies: [
        ]
    ),
    .target(
        name: "DistributedActorsXPC",
        dependencies: [
            "DistributedActors",
            "CDistributedActorsXPC",
            "Files",
        ]
    ),

    // ==== ------------------------------------------------------------------------------------------------------------
    // MARK: TestKit

    /// This target is intended only for use in tests, though we have no way to mark this
    .target(
        name: "DistributedActorsTestKit",
        dependencies: ["DistributedActors", "DistributedActorsConcurrencyHelpers"]
    ),

    // ==== ------------------------------------------------------------------------------------------------------------
    // MARK: Documentation

    .testTarget(
        name: "DistributedActorsDocumentationTests",
        dependencies: [
            "DistributedActors", 
            "DistributedActorsXPC", 
            "DistributedActorsTestKit"
        ]
    ),

    // ==== ----------------------------------------------------------------------------------------------------------------
    // MARK: Tests

    .testTarget(
        name: "DistributedActorsTests",
        dependencies: ["DistributedActors", "DistributedActorsTestKit"]
    ),
    
    .testTarget(
        name: "DistributedActorsTestKitTests",
        dependencies: ["DistributedActors", "DistributedActorsTestKit"]
    ),

    .testTarget(
        name: "CDistributedActorsMailboxTests",
        dependencies: ["CDistributedActorsMailbox", "DistributedActorsTestKit"]
    ),

    .testTarget(
        name: "DistributedActorsConcurrencyHelpersTests",
        dependencies: ["DistributedActorsConcurrencyHelpers"]
    ),

    .testTarget(
        name: "GenActorsTests",
        dependencies: [
            "GenActors",
            "DistributedActorsTestKit",
        ]
    ),
    
    .testTarget(
         name: "ActorSingletonPluginTests",
         dependencies: ["ActorSingletonPlugin", "DistributedActorsTestKit"]
     ),

    // ==== ------------------------------------------------------------------------------------------------------------
    // MARK: Integration Tests - `it_` prefixed
    
    .target(
        name: "it_ProcessIsolated_escalatingWorkers",
        dependencies: [
            "DistributedActors",
        ],
        path: "IntegrationTests/tests_02_process_isolated/it_ProcessIsolated_escalatingWorkers"
    ),
    .target(
        name: "it_ProcessIsolated_respawnsServants",
        dependencies: [
            "DistributedActors",
        ],
        path: "IntegrationTests/tests_02_process_isolated/it_ProcessIsolated_respawnsServants"
    ),
    .target(
        name: "it_ProcessIsolated_noLeaking",
        dependencies: [
            "DistributedActors",
        ],
        path: "IntegrationTests/tests_02_process_isolated/it_ProcessIsolated_noLeaking"
    ),
    .target(
        name: "it_ProcessIsolated_backoffRespawn",
        dependencies: [
            "DistributedActors",
        ],
        path: "IntegrationTests/tests_02_process_isolated/it_ProcessIsolated_backoffRespawn"
    ),

    // ==== ----------------------------------------------------------------------------------------------------------------
    // MARK: Performance / Benchmarks

    .target(
        name: "DistributedActorsBenchmarks",
        dependencies: [
            "DistributedActors",
            "SwiftBenchmarkTools",
        ]
    ),
    .target(
        name: "SwiftBenchmarkTools",
        dependencies: ["DistributedActors"]
    ),

    // ==== ----------------------------------------------------------------------------------------------------------------
    // MARK: Samples are defined in Samples/Package.swift
    // ==== ----------------------------------------------------------------------------------------------------------------

    // ==== ------------------------------------------------------------------------------------------------------------
    // MARK: Internals; NOT SUPPORTED IN ANY WAY

    .target(
        name: "CDistributedActorsMailbox",
        dependencies: []
    ),

    .target(
        name: "CDistributedActorsAtomics",
        dependencies: []
    ),

    .target(
        name: "DistributedActorsConcurrencyHelpers",
        dependencies: ["CDistributedActorsAtomics"]
    ),
]

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
targets.append(contentsOf: [
    /* --- XPC Integration Tests --- */
    .target(
        name: "it_XPCActorable_echo",
        dependencies: [
            "DistributedActorsXPC",
            "it_XPCActorable_echo_api",
        ],
        path: "IntegrationTests/tests_03_xpc_actorable/it_XPCActorable_echo"
    ),
    .target(
        name: "it_XPCActorable_echo_api",
        dependencies: [
            "DistributedActorsXPC"
        ],
        path: "IntegrationTests/tests_03_xpc_actorable/it_XPCActorable_echo_api"
    ),
    .target(
        name: "it_XPCActorable_echo_service",
        dependencies: [
            "DistributedActorsXPC",
            "it_XPCActorable_echo_api",
            "Files",
        ],
        path: "IntegrationTests/tests_03_xpc_actorable/it_XPCActorable_echo_service"
    ),
])
#endif

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.12.0"),
    .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.2.0"),

    .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.7.0"),

    // ~~~ workaround for backtraces ~~~
    .package(url: "https://github.com/ianpartridge/swift-backtrace.git", from: "1.1.1"),

    // ~~~ SSWG APIs ~~~
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-metrics.git", from: "1.0.0"),

    // ~~~ only for GenActors ~~~
    // swift-syntax is Swift version dependent, and added  as such below
    .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.13.0"), // BSD license
    .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"), // MIT license
]

#if swift(>=5.1)
dependencies.append(contentsOf: [
    .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50100.0")),
])
#elseif swift(>=5.0)
dependencies.append(contentsOf: [
    .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50000.0")),
])
#else
fatalError("Currently only Swift 5.1 is supported. 5.0 could be supported, if you need Swift 5.0 support please reach out to to the team.")
#endif

let products: [PackageDescription.Product] = [
    .library(
        name: "DistributedActors",
        targets: ["DistributedActors"]
    ),
    .library(
        name: "DistributedActorsTestKit",
        targets: ["DistributedActorsTestKit"]
    ),

    /* --- genActors --- */

    .executable(
        name: "GenActors",
        targets: ["GenActors"]
    ),

    /* --- XPC --- */
    .library(
        name: "DistributedActorsXPC",
        targets: ["DistributedActorsXPC"]
    ),

    /* ---  performance --- */
    .executable(
        name: "DistributedActorsBenchmarks",
        targets: ["DistributedActorsBenchmarks"]
    ),
]

var package = Package(
    name: "swift-distributed-actors",
    products: products,

    dependencies: dependencies,

    targets: targets,

    cxxLanguageStandard: .cxx11
)
