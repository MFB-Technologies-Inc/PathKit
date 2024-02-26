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
func + (lhs: String, rhs: String) -> Path {
    if rhs.hasPrefix(Path.separator) {
        // Absolute paths replace relative paths
        return Path(rhs)
    } else {
        var lSlice = ArraySlice(NSString(string: lhs).pathComponents)
        var rSlice = ArraySlice(NSString(string: rhs).pathComponents)

        // Get rid of trailing "/" at the left side
        if lSlice.count > 1, lSlice.last == Path.separator {
            lSlice.removeLast()
        }

        // Advance after the first relevant "."
        lSlice = lSlice.filter { $0 != "." }
        rSlice = rSlice.filter { $0 != "." }

        // Eats up trailing components of the left and leading ".." of the right side
        while lSlice.last != "..", !lSlice.isEmpty, rSlice.first == ".." {
            if lSlice.count > 1 || lSlice.first != Path.separator {
                // A leading "/" is never popped
                lSlice.removeLast()
            }
            if !rSlice.isEmpty {
                rSlice.removeFirst()
            }

            switch (lSlice.isEmpty, rSlice.isEmpty) {
            case (true, _):
                break
            case (_, true):
                break
            default:
                continue
            }
        }

        return Path(components: lSlice + rSlice)
    }
}
