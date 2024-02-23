// Operators.swift
// PathKit
//
// Copyright (c) 2014, Kyle Fuller
// All rights reserved.
// Version 1.0.1
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
// After Version 1.0.1
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

import Foundation
#if canImport(System)
    import System
#else
    import SystemPackage
#endif

extension Path {
    /// Appends a Path fragment to another Path to produce a new Path
    public static func + (lhs: Path, rhs: Path) -> Path {
        lhs.path + rhs.path
    }

    /// Appends a String fragment to another Path to produce a new Path
    public static func + (lhs: Path, rhs: String) -> Path {
        lhs.path + rhs
    }
}

/// Appends a String fragment to another String to produce a new Path
private func + (lhs: String, rhs: String) -> Path {
    let rhs = Path(rhs)
    if rhs.isAbsolute {
        // Absolute paths replace relative paths
        return rhs
    } else {
        var lhs = FilePath(lhs)
        for rhsComponent in rhs.components {
            lhs.append(rhsComponent)
        }
        return Path(filePath: lhs).normalize()
    }
}
