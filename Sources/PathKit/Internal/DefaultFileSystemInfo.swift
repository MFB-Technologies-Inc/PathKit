// DefaultFileSystemInfo.swift
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

struct DefaultFileSystemInfo: FileSystemInfo {
    func isFSCaseSensitiveAt(path: Path) -> Bool {
        #if os(Linux)
            // URL resourceValues(forKeys:) is not supported on non-darwin platforms...
            // But we can (fairly?) safely assume for now that the Linux FS is case sensitive.
            // TODO: refactor when/if resourceValues is available, or look into using something
            // like stat or pathconf to determine if the mountpoint is case sensitive.
            return true
        #else
            var isCaseSensitive = false
            // Calling resourceValues will fail if the path does not exist on the filesystem, which
            // makes sense, but means we can only guarantee the return value is correct if the
            // path actually exists.
            if let resourceValues = try? path.url.resourceValues(forKeys: [.volumeSupportsCaseSensitiveNamesKey]) {
                isCaseSensitive = resourceValues.volumeSupportsCaseSensitiveNames ?? isCaseSensitive
            }
            return isCaseSensitive
        #endif
    }
}
