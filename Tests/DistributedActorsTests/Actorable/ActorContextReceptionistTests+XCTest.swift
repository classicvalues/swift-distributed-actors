//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Actors open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Distributed Actors project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import XCTest

///
/// NOTE: This file was generated by generate_linux_tests.rb
///
/// Do NOT edit this file directly as it will be regenerated automatically when needed.
///

extension ActorContextReceptionTests {
    static var allTests: [(String, (ActorContextReceptionTests) -> () throws -> Void)] {
        return [
            ("test_autoUpdatedListing_updatesAutomatically", test_autoUpdatedListing_updatesAutomatically),
            ("test_autoUpdatedListing_invokesOnUpdate", test_autoUpdatedListing_invokesOnUpdate),
            ("test_lookup_ofGenericType", test_lookup_ofGenericType),
            ("test_autoUpdatedListing_shouldQuicklyUpdateFromThousandsOfUpdates", test_autoUpdatedListing_shouldQuicklyUpdateFromThousandsOfUpdates),
        ]
    }
}
