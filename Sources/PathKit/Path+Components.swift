// Path+Components.swift
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
    /// The last path component
    ///
    /// - Returns: the last path component
    ///
    public var lastComponent: String {
        filePath.lastComponent?.string ?? ""
    }

    /// The last path component without file extension
    ///
    /// - Note: This returns "." for ".." on Linux, and ".." on Apple platforms.
    ///
    /// - Returns: the last path component without file extension
    ///
    public var lastComponentWithoutExtension: String {
        filePath.stem ?? ""
    }

    /// Splits the string representation on the directory separator.
    /// Absolute paths remain the leading slash as first component.
    ///
    /// - Returns: all path components
    ///
    public var components: [String] {
        if let root = filePath.root {
            CollectionOfOne(root.string) + filePath.components.map(\.string)
        } else {
            filePath.components.map(\.string)
        }
    }

    /// The file extension behind the last dot of the last component.
    ///
    /// - Returns: the file extension
    ///
    public var `extension`: String? {
        filePath.extension
    }
}
