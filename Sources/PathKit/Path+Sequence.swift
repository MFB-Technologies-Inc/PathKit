// Path+Sequence.swift
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

extension Path: Sequence {
    public struct DirectoryEnumerationOptions: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static var skipsSubdirectoryDescendants = DirectoryEnumerationOptions(
            rawValue: FileManager
                .DirectoryEnumerationOptions.skipsSubdirectoryDescendants.rawValue
        )
        public static var skipsPackageDescendants = DirectoryEnumerationOptions(
            rawValue: FileManager
                .DirectoryEnumerationOptions.skipsPackageDescendants.rawValue
        )
        public static var skipsHiddenFiles = DirectoryEnumerationOptions(
            rawValue: FileManager.DirectoryEnumerationOptions
                .skipsHiddenFiles.rawValue
        )
    }

    /// Represents a path sequence with specific enumeration options
    public struct PathSequence: Sequence {
        private var path: Path
        private var options: DirectoryEnumerationOptions
        init(path: Path, options: DirectoryEnumerationOptions) {
            self.path = path
            self.options = options
        }

        public func makeIterator() -> DirectoryEnumerator {
            DirectoryEnumerator(path: path, options: options)
        }
    }

    /// Enumerates the contents of a directory, returning the paths of all files and directories
    /// contained within that directory. These paths are relative to the directory.
    public struct DirectoryEnumerator: IteratorProtocol {
        let path: Path
        let directoryEnumerator: FileManager.DirectoryEnumerator?

        init(path: Path, options mask: DirectoryEnumerationOptions = []) {
            let options = FileManager.DirectoryEnumerationOptions(rawValue: mask.rawValue)
            self.path = path
            directoryEnumerator = Path.fileManager.enumerator(
                at: path.url,
                includingPropertiesForKeys: nil,
                options: options
            )
        }

        public func next() -> Path? {
            let next = directoryEnumerator?.nextObject()

            if let next = next as? URL {
                return Path(next.path)
            }
            return nil
        }

        /// Skip recursion into the most recently obtained subdirectory.
        public func skipDescendants() {
            directoryEnumerator?.skipDescendants()
        }
    }

    /// Perform a deep enumeration of a directory.
    ///
    /// - Returns: a directory enumerator that can be used to perform a deep enumeration of the
    ///   directory.
    ///
    public func makeIterator() -> DirectoryEnumerator {
        DirectoryEnumerator(path: self)
    }

    /// Perform a deep enumeration of a directory.
    ///
    /// - Parameter options: FileManager directory enumerator options.
    ///
    /// - Returns: a path sequence that can be used to perform a deep enumeration of the
    ///   directory.
    ///
    public func iterateChildren(options: DirectoryEnumerationOptions = []) -> PathSequence {
        PathSequence(path: self, options: options)
    }
}
