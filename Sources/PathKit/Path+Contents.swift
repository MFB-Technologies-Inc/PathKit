// Path+Contents.swift
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
    /// Reads the file.
    ///
    /// - Returns: the contents of the file at the specified path.
    ///
    public func read() throws -> Data {
        try Data(contentsOf: url, options: NSData.ReadingOptions(rawValue: 0))
    }

    /// Reads the file contents and encoded its bytes to string applying the given encoding.
    ///
    /// - Parameter encoding: the encoding which should be used to decode the data.
    ///   (by default: `NSUTF8StringEncoding`)
    ///
    /// - Returns: the contents of the file at the specified path as string.
    ///
    public func read(_ encoding: String.Encoding = String.Encoding.utf8) throws -> String {
        try NSString(contentsOfFile: path, encoding: encoding.rawValue).substring(from: 0) as String
    }

    /// Write a file.
    ///
    /// - Note: Works atomically: the data is written to a backup file, and then — assuming no
    ///   errors occur — the backup file is renamed to the name specified by path.
    ///
    /// - Parameter data: the contents to write to file.
    ///
    public func write(_ data: Data) throws {
        try data.write(to: normalize().url, options: .atomic)
    }

    /// Reads the file.
    ///
    /// - Note: Works atomically: the data is written to a backup file, and then — assuming no
    ///   errors occur — the backup file is renamed to the name specified by path.
    ///
    /// - Parameter string: the string to write to file.
    ///
    /// - Parameter encoding: the encoding which should be used to represent the string as bytes.
    ///   (by default: `NSUTF8StringEncoding`)
    ///
    /// - Returns: the contents of the file at the specified path as string.
    ///
    public func write(_ string: String, encoding: String.Encoding = String.Encoding.utf8) throws {
        try string.write(toFile: normalize().path, atomically: true, encoding: encoding)
    }
}
