// Path+FileManipulation.swift
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
    /// Create the directory.
    ///
    /// - Note: This method fails if any of the intermediate parent directories does not exist.
    ///   This method also fails if any of the intermediate path elements corresponds to a file and
    ///   not a directory.
    ///
    public func mkdir() throws {
        try Path.fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
    }

    /// Create the directory and any intermediate parent directories that do not exist.
    ///
    /// - Note: This method fails if any of the intermediate path elements corresponds to a file and
    ///   not a directory.
    ///
    public func mkpath() throws {
        try Path.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }

    /// Delete the file or directory.
    ///
    /// - Note: If the path specifies a directory, the contents of that directory are recursively
    ///   removed.
    ///
    public func delete() throws {
        try Path.fileManager.removeItem(atPath: path)
    }

    /// Move the file or directory to a new location synchronously.
    ///
    /// - Parameter destination: The new path. This path must include the name of the file or
    ///   directory in its new location.
    ///
    public func move(_ destination: Path) throws {
        try Path.fileManager.moveItem(atPath: path, toPath: destination.path)
    }

    /// Copy the file or directory to a new location synchronously.
    ///
    /// - Parameter destination: The new path. This path must include the name of the file or
    ///   directory in its new location.
    ///
    public func copy(_ destination: Path) throws {
        try Path.fileManager.copyItem(atPath: path, toPath: destination.path)
    }

    /// Creates a hard link at a new destination.
    ///
    /// - Parameter destination: The location where the link will be created.
    ///
    public func link(_ destination: Path) throws {
        try Path.fileManager.linkItem(atPath: path, toPath: destination.path)
    }

    /// Creates a symbolic link at a new destination.
    ///
    /// - Parameter destintation: The location where the link will be created.
    ///
    public func symlink(_ destination: Path) throws {
        try Path.fileManager.createSymbolicLink(atPath: path, withDestinationPath: destination.path)
    }
}
