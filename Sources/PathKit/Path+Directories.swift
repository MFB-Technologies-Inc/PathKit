// Path+Directories.swift
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
    /// The current working directory of the process
    ///
    /// - Returns: the current working directory of the process
    ///
    public static var current: Path {
        get {
            self.init(Path.fileManager.currentDirectoryPath)
        }
        set {
            _ = Path.fileManager.changeCurrentDirectoryPath(newValue.description)
        }
    }

    /// Changes the current working directory of the process to the path during the execution of the
    /// given block.
    ///
    /// - Note: The original working directory is restored when the block returns or throws.
    /// - Parameter closure: A closure to be executed while the current directory is configured to
    ///   the path.
    ///
    public func chdir(closure: () throws -> Void) rethrows {
        let previous = Path.current
        Path.current = self
        defer { Path.current = previous }
        try closure()
    }

    /// - Returns: the path to either the user’s or application’s home directory,
    ///   depending on the platform.
    ///
    public static var home: Path {
        Path(NSHomeDirectory())
    }

    /// - Returns: the path of the temporary directory for the current user.
    ///
    public static var temporary: Path {
        Path(NSTemporaryDirectory())
    }

    /// - Returns: the path of a temporary directory unique for the process.
    /// - Note: Based on `NSProcessInfo.globallyUniqueString`.
    ///
    public static func processUniqueTemporary() throws -> Path {
        let path = temporary + ProcessInfo.processInfo.globallyUniqueString
        if !path.exists {
            try path.mkdir()
        }
        return path
    }

    /// - Returns: the path of a temporary directory unique for each call.
    /// - Note: Based on `NSUUID`.
    ///
    public static func uniqueTemporary() throws -> Path {
        let path = try processUniqueTemporary() + UUID().uuidString
        try path.mkdir()
        return path
    }
}
