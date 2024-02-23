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
#if canImport(System)
    import System
#else
    import SystemPackage
#endif

extension Path {
    /// Test whether a path is absolute.
    ///
    /// - Returns: `true` iff the path begins with a slash
    ///
    public var isAbsolute: Bool {
        filePath.isAbsolute
    }

    /// Test whether a path is relative.
    ///
    /// - Returns: `true` iff a path is relative (not absolute)
    ///
    public var isRelative: Bool {
        filePath.isRelative
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

    /// Normalizes the path, this cleans up redundant ".." and ".", and double slashes.
    ///
    /// - Returns: a new path made by removing extraneous path components from the underlying String
    ///   representation.
    ///
    public func normalize() -> Path {
        Path(filePath: filePath.lexicallyNormalized(), fileSystemInfo: fileSystemInfo)
    }

    /// Replaces the prefix of the path with `~` or `./` if the prefix matches the current user's
    /// home directory or current path.
    ///
    /// - Returns: a new path made by removing extraneous path components from the underlying String
    ///   representation.
    ///
    public func abbreviate() -> Path {
        if let relativeToHome = relative(against: .home) {
            return Path("~" + relativeToHome.string)
        } else if let relativeToCurrent = relative(against: .current) {
            return Path("./") + relativeToCurrent
        } else {
            return self
        }
    }

    /// Removes the prefix of the path if the prefix matches the given leading path
    ///
    /// - Parameter leadingPath The prefix to remove if present
    /// - Returns: a new path made by removing the prefix if present. `nil` if not.
    ///
    public func relative(against leadingPath: Path) -> Path? {
        let rangeOptions: String.CompareOptions = fileSystemInfo.isFSCaseSensitiveAt(path: self) ?
            [.anchored] : [.anchored, .caseInsensitive]
        guard let leadingRange = string.range(of: leadingPath.string, options: rangeOptions),
              leadingRange.lowerBound == string.startIndex
        else {
            return nil
        }
        return Path(filePath: FilePath(string.replacingCharacters(in: leadingRange, with: "")))
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
