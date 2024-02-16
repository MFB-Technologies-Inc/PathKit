// Path+Traversing.swift
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
    /// Get the parent directory
    ///
    /// - Returns: the normalized path of the parent directory
    ///
    public func parent() -> Path {
        self + ".."
    }

    /// Performs a shallow enumeration in a directory
    ///
    /// - Returns: paths to all files, directories and symbolic links contained in the directory
    ///
    public func children() throws -> [Path] {
        try Path.fileManager.contentsOfDirectory(atPath: path).map {
            self + Path($0)
        }
    }

    /// Performs a deep enumeration in a directory
    ///
    /// - Returns: paths to all files, directories and symbolic links contained in the directory or
    ///   any subdirectory.
    ///
    public func recursiveChildren() throws -> [Path] {
        try Path.fileManager.subpathsOfDirectory(atPath: path).map {
            self + Path($0)
        }
    }
}
