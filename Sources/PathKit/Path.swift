// Path.swift
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

    extension FilePath: @unchecked Sendable {}
#endif

/// Represents a filesystem path.
public struct Path: Sendable {
    /// The character used by the OS to separate two path elements
    public static let separator = "/"

    /// The underlying `FilePath` representation
    public let filePath: FilePath

    /// The underlying string representation
    var path: String { filePath.string }

    static let fileManager = FileManager.default

    let fileSystemInfo: any FileSystemInfo

    // MARK: Init

    init(filePath: FilePath, fileSystemInfo: any FileSystemInfo) {
        self.filePath = filePath
        self.fileSystemInfo = fileSystemInfo
    }

    /// Create a Path from a `System.FilePath`
    public init(filePath: FilePath) {
        self.init(filePath: filePath, fileSystemInfo: DefaultFileSystemInfo())
    }

    public init() {
        self.init("")
    }

    /// Create a Path from a given String
    public init(_ path: String) {
        self.init(path, fileSystemInfo: DefaultFileSystemInfo())
    }

    init(_ path: String, fileSystemInfo: any FileSystemInfo) {
        self.init(filePath: FilePath(path), fileSystemInfo: fileSystemInfo)
    }

    init(fileSystemInfo: any FileSystemInfo) {
        self.init("", fileSystemInfo: fileSystemInfo)
    }

    /// Create a Path by joining multiple path components together
    public init<S: Collection>(components: S) where S.Iterator.Element == String {
        let path: String
        if components.isEmpty {
            path = ""
        } else if components.first == Path.separator, components.count > 1 {
            let _path = components.joined(separator: Path.separator)
            path = String(_path[_path.index(after: _path.startIndex)...])
        } else {
            path = components.joined(separator: Path.separator)
        }
        self.init(path)
    }
}

extension Path: ExpressibleByStringLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = StringLiteralType

    public init(extendedGraphemeClusterLiteral path: StringLiteralType) {
        self.init(stringLiteral: path)
    }

    public init(unicodeScalarLiteral path: StringLiteralType) {
        self.init(stringLiteral: path)
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension Path: CustomStringConvertible {
    public var description: String {
        filePath.description
    }
}

extension Path: CustomDebugStringConvertible {
    public var debugDescription: String {
        filePath.debugDescription
    }
}

extension Path: Equatable {
    /// Determines if two paths are identical
    public static func == (lhs: Path, rhs: Path) -> Bool {
        lhs.filePath == rhs.filePath
    }
}

extension Path: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(filePath.hashValue)
        hasher.combine(ObjectIdentifier(Self.self))
    }
}

extension Path: Comparable {
    /// Defines a strict total order over Paths based on their underlying string representation.
    public static func < (lhs: Path, rhs: Path) -> Bool {
        lhs.path < rhs.path
    }
}

// MARK: Conversion

extension Path {
    public var string: String {
        path
    }

    public var url: URL {
        URL(fileURLWithPath: path)
    }
}

// MARK: Pattern Matching

extension Path {
    /// Implements pattern-matching for paths.
    ///
    /// - Returns: `true` iff one of the following conditions is true:
    ///     - the paths are equal (based on `Path`'s `Equatable` implementation)
    ///     - the paths can be normalized to equal Paths.
    ///
    public static func ~= (lhs: Path, rhs: Path) -> Bool {
        lhs == rhs
            || lhs.normalize() == rhs.normalize()
            || lhs.absolute() == rhs.absolute()
    }
}
