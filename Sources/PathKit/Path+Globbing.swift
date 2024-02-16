// Path+Globbing.swift
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

#if os(Linux)
    import Glibc

    let system_glob = Glibc.glob
#else
    import Darwin

    let system_glob = Darwin.glob
#endif

import Foundation

extension Path {
    public static func glob(_ pattern: String) -> [Path] {
        var _glob_t = glob_t()
        guard let cPattern = strdup(pattern) else {
            fatalError("strdup returned null: Likely out of memory")
        }
        defer {
            globfree(&_glob_t)
            free(cPattern)
        }

        let flags = GLOB_TILDE | GLOB_BRACE | GLOB_MARK
        if system_glob(cPattern, flags, nil, &_glob_t) == 0 {
            #if os(Linux)
                let matchc = _glob_t.gl_pathc
            #else
                let matchc = _glob_t.gl_matchc
            #endif
            return (0 ..< Int(matchc)).compactMap { index in
                if let path = String(validatingUTF8: _glob_t.gl_pathv[index]!) {
                    return Path(path)
                }

                return nil
            }
        }

        // GLOB_NOMATCH
        return []
    }

    public func glob(_ pattern: String) -> [Path] {
        Path.glob((self + pattern).description)
    }

    public func match(_ pattern: String) -> Bool {
        guard let cPattern = strdup(pattern),
              let cPath = strdup(path)
        else {
            fatalError("strdup returned null: Likely out of memory")
        }
        defer {
            free(cPattern)
            free(cPath)
        }
        return fnmatch(cPattern, cPath, 0) == 0
    }
}
