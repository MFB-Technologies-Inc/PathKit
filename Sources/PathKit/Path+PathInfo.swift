// Path+PathInfo.swift
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
    /// Test whether a path is absolute.
    ///
    /// - Returns: `true` iff the path begins with a slash
    ///
    public var isAbsolute: Bool {
        path.hasPrefix(Path.separator)
    }

    /// Test whether a path is relative.
    ///
    /// - Returns: `true` iff a path is relative (not absolute)
    ///
    public var isRelative: Bool {
        !isAbsolute
    }

    /// Concatenates relative paths to the current directory and derives the normalized path
    ///
    /// - Returns: the absolute path in the actual filesystem
    ///
    public func absolute() -> Path {
        if isAbsolute {
            return normalize()
        }

        let expandedPath = Path(NSString(string: path).expandingTildeInPath)
        if expandedPath.isAbsolute {
            return expandedPath.normalize()
        }

        return (Path.current + self).normalize()
    }

    /// Normalizes the path, this cleans up redundant ".." and ".", double slashes
    /// and resolves "~".
    ///
    /// - Returns: a new path made by removing extraneous path components from the underlying String
    ///   representation.
    ///
    public func normalize() -> Path {
        Path(NSString(string: path).standardizingPath)
    }

    /// De-normalizes the path, by replacing the current user home directory with "~".
    ///
    /// - Returns: a new path made by removing extraneous path components from the underlying String
    ///   representation.
    ///
    public func abbreviate() -> Path {
        let rangeOptions: String.CompareOptions = fileSystemInfo.isFSCaseSensitiveAt(path: self) ?
            [.anchored] : [.anchored, .caseInsensitive]
        let home = Path.home.string
        guard let homeRange = path.range(of: home, options: rangeOptions) else { return self }
        let withoutHome = Path(path.replacingCharacters(in: homeRange, with: ""))

        if withoutHome.path.isEmpty || withoutHome.path == Path.separator {
            return Path("~")
        } else if withoutHome.isAbsolute {
            return Path("~" + withoutHome.path)
        } else {
            return Path("~") + withoutHome.path
        }
    }

    /// Returns the path of the item pointed to by a symbolic link.
    ///
    /// - Returns: the path of directory or file to which the symbolic link refers
    ///
    public func symlinkDestination() throws -> Path {
        let symlinkDestination = try Path.fileManager.destinationOfSymbolicLink(atPath: path)
        let symlinkPath = Path(symlinkDestination)
        if symlinkPath.isRelative {
            return self + ".." + symlinkPath
        } else {
            return symlinkPath
        }
    }
}
