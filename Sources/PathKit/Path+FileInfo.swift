// Path+FileInfo.swift
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
    /// Test whether a file or directory exists at a specified path
    ///
    /// - Returns: `false` iff the path doesn't exist on disk or its existence could not be
    ///   determined
    ///
    public var exists: Bool {
        Path.fileManager.fileExists(atPath: path)
    }

    /// Test whether a path is a directory.
    ///
    /// - Returns: `true` if the path is a directory or a symbolic link that points to a directory;
    ///   `false` if the path is not a directory or the path doesn't exist on disk or its existence
    ///   could not be determined
    ///
    public var isDirectory: Bool {
        var directory = ObjCBool(false)
        guard Path.fileManager.fileExists(atPath: normalize().path, isDirectory: &directory) else {
            return false
        }
        return directory.boolValue
    }

    /// Test whether a path is a regular file.
    ///
    /// - Returns: `true` if the path is neither a directory nor a symbolic link that points to a
    ///   directory; `false` if the path is a directory or a symbolic link that points to a
    ///   directory or the path doesn't exist on disk or its existence
    ///   could not be determined
    ///
    public var isFile: Bool {
        var directory = ObjCBool(false)
        guard Path.fileManager.fileExists(atPath: normalize().path, isDirectory: &directory) else {
            return false
        }
        return !directory.boolValue
    }

    /// Test whether a path is a symbolic link.
    ///
    /// - Returns: `true` if the path is a symbolic link; `false` if the path doesn't exist on disk
    ///   or its existence could not be determined
    ///
    public var isSymlink: Bool {
        do {
            try Path.fileManager.destinationOfSymbolicLink(atPath: path)
            return true
        } catch {
            return false
        }
    }

    /// Test whether a path is readable
    ///
    /// - Returns: `true` if the current process has read privileges for the file at path;
    ///   otherwise `false` if the process does not have read privileges or the existence of the
    ///   file could not be determined.
    ///
    public var isReadable: Bool {
        Path.fileManager.isReadableFile(atPath: path)
    }

    /// Test whether a path is writeable
    ///
    /// - Returns: `true` if the current process has write privileges for the file at path;
    ///   otherwise `false` if the process does not have write privileges or the existence of the
    ///   file could not be determined.
    ///
    public var isWritable: Bool {
        Path.fileManager.isWritableFile(atPath: path)
    }

    /// Test whether a path is executable
    ///
    /// - Returns: `true` if the current process has execute privileges for the file at path;
    ///   otherwise `false` if the process does not have execute privileges or the existence of the
    ///   file could not be determined.
    ///
    public var isExecutable: Bool {
        Path.fileManager.isExecutableFile(atPath: path)
    }

    /// Test whether a path is deletable
    ///
    /// - Returns: `true` if the current process has delete privileges for the file at path;
    ///   otherwise `false` if the process does not have delete privileges or the existence of the
    ///   file could not be determined.
    ///
    public var isDeletable: Bool {
        Path.fileManager.isDeletableFile(atPath: path)
    }
}
