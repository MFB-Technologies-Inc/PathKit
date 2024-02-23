// PathKitTests.swift
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
@testable import PathKit
import XCTest

final class PathKitTests: XCTestCase {
    let (fixtures, fixturesResolved) = {
        let fixtures: String
        let fixturesResolved: String
        if let tempDirFromEnv = ProcessInfo.processInfo.environment["TEMP_DIR"] {
            fixtures = "\(tempDirFromEnv)/PathKitTests"
            fixturesResolved = "\(tempDirFromEnv)/PathKitTests"
        } else {
            fixtures = "/tmp/PathKitTests"
            #if os(Linux)
                fixturesResolved = "/tmp/PathKitTests"
            #else
                fixturesResolved = "/private/tmp/PathKitTests"
            #endif
        }
        return (fixtures, fixturesResolved)
    }()

    override func tearDown() async throws {
        if FileManager.default.fileExists(atPath: fixtures) {
            try FileManager.default.removeItem(atPath: fixtures)
        }
        try await super.tearDown()
    }

    func setupFixtures() throws {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: fixtures) {
            try fileManager.removeItem(atPath: fixtures)
        }

        let targetDir = fixtures
        let directoryDir = "\(targetDir)/directory"
        let subDirectoryDir = "\(targetDir)/directory/subdirectory"
        let permissionsDir = "\(targetDir)/permissions"
        let symlinksDir = "\(targetDir)/symlinks"

        try fileManager.createDirectory(atPath: targetDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(atPath: directoryDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(atPath: subDirectoryDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(atPath: permissionsDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(atPath: symlinksDir, withIntermediateDirectories: true)

        fileManager.createFile(atPath: "\(targetDir)/file", contents: nil)
        fileManager.createFile(atPath: "\(targetDir)/hello", contents: "Hello World\n".data(using: .utf8))
        fileManager.createFile(atPath: "\(directoryDir)/child", contents: nil)
        fileManager.createFile(atPath: "\(directoryDir)/.hiddenFile", contents: nil)
        fileManager.createFile(atPath: "\(subDirectoryDir)/child", contents: nil)

        fileManager.createFile(atPath: "\(permissionsDir)/deletable", contents: nil)
        try fileManager.setAttributes(
            [FileAttributeKey.posixPermissions: 0o222],
            ofItemAtPath: "\(permissionsDir)/deletable"
        )

        fileManager.createFile(atPath: "\(permissionsDir)/executable", contents: nil)
        try fileManager.setAttributes(
            [FileAttributeKey.posixPermissions: 0o111],
            ofItemAtPath: "\(permissionsDir)/executable"
        )

        fileManager.createFile(atPath: "\(permissionsDir)/readable", contents: nil)
        try fileManager.setAttributes(
            [FileAttributeKey.posixPermissions: 0o444],
            ofItemAtPath: "\(permissionsDir)/readable"
        )

        fileManager.createFile(atPath: "\(permissionsDir)/writable", contents: nil)
        try fileManager.setAttributes(
            [FileAttributeKey.posixPermissions: 0o222],
            ofItemAtPath: "\(permissionsDir)/writable"
        )

        fileManager.createFile(atPath: "\(permissionsDir)/none", contents: nil)
        try fileManager.setAttributes(
            [FileAttributeKey.posixPermissions: 0o000],
            ofItemAtPath: "\(permissionsDir)/none"
        )

        try fileManager.createSymbolicLink(atPath: "\(symlinksDir)/directory", withDestinationPath: directoryDir)
        try fileManager.createSymbolicLink(atPath: "\(symlinksDir)/same-dir", withDestinationPath: symlinksDir)
        try fileManager.createSymbolicLink(atPath: "\(symlinksDir)/swift", withDestinationPath: "/usr/bin/swift")
        try fileManager.createSymbolicLink(atPath: "\(symlinksDir)/file", withDestinationPath: "\(targetDir)/file")
    }

    func testSystemSeparator() throws {
        XCTAssertEqual(Path.separator, "/")
    }

    func testCurrentWorkingDirectory() throws {
        XCTAssertEqual(Path.current.description, FileManager.default.currentDirectoryPath)
    }

    func testEmptyInitialization() throws {
        XCTAssertEqual(Path().description, "")
    }

    func testStringInitialization() throws {
        let path = Path("/usr/bin/swift")
        XCTAssertEqual(path.description, "/usr/bin/swift")
    }

    func testComponentsInitialization() throws {
        let path = Path(components: ["/usr", "bin", "swift"])
        XCTAssertEqual(path.description, "/usr/bin/swift")
    }

    func testConversionToUrl() throws {
        let path = Path("/usr/bin/swift")
        try XCTAssertEqual(path.url, XCTUnwrap(URL(fileURLWithPath: "/usr/bin/swift")))
    }

    func testEquatableConformance() throws {
        let path = Path("/usr/bin/swift")
        XCTAssertEqual(path, Path("/usr/bin/swift"))
        XCTAssertNotEqual(path, Path("/usr/bin/rust"))
    }

    func testHashableConformance() throws {
        let path = Path("/usr/bin/swift")
        XCTAssertEqual(path.hashValue, Path("/usr/bin/swift").hashValue)
        XCTAssertNotEqual(path.hashValue, Path("/usr/bin/rust").hashValue)
        XCTAssertNotEqual(path.hashValue, path.description.hashValue)
    }

    func testRelativePath() throws {
        let path = Path("swift")
        XCTAssertTrue(path.isRelative)
        XCTAssertFalse(path.isAbsolute)
    }

    func testRelativePathWithTilde() throws {
        let path = Path("~")
        XCTAssertTrue(path.isRelative)
        XCTAssertFalse(path.isAbsolute)
    }

    func testConvertRelativeToAbsolute() throws {
        let path = Path("swift")
        XCTAssertEqual(path.absolute(), Path.current + Path("swift"))
    }

    func testConvertRelativeToAbsoluteWithTilde() throws {
        let path = Path("~")
        #if os(Linux)
            if let envHome = ProcessInfo.processInfo.environment["HOME"] {
                XCTAssertEqual(path.absolute().string, envHome)
            } else if NSUserName() == "root" {
                XCTAssertEqual(path.absolute(), "/root")
            } else {
                XCTAssertEqual(path.absolute(), "/home/" + NSUserName())
            }
        #elseif os(macOS)
            XCTAssertEqual(path.absolute(), "/Users/" + NSUserName())
        #endif
        XCTAssertTrue(path.isRelative)
        XCTAssertFalse(path.isAbsolute)
    }

    func testAbsolutePath() throws {
        let path = Path("/usr/bin/swift")
        XCTAssertEqual(path.absolute(), path)
        XCTAssertTrue(path.isAbsolute)
        XCTAssertFalse(path.isRelative)
    }

    func testNormalization() throws {
        let path = Path("/usr/./local/../bin/swift")
        XCTAssertEqual(path.normalize(), Path("/usr/bin/swift"))
    }

    func testAbbreviation() throws {
        let home = Path.home.string
        XCTAssertEqual(Path("\(home)/foo/bar").abbreviate(), Path("~/foo/bar"))
        XCTAssertEqual(Path("\(home)").abbreviate(), Path("~"))
        XCTAssertEqual(Path("\(home)/").abbreviate(), Path("~"))
        XCTAssertEqual(Path("\(home)/backups\(home)").abbreviate(), Path("~/backups\(home)"))
        XCTAssertEqual(Path("\(home)/backups\(home)/foo/bar").abbreviate(), Path("~/backups\(home)/foo/bar"))
        #if os(Linux)
            XCTAssertEqual(Path("\(home.uppercased())").abbreviate(), Path("\(home.uppercased())"))
        #else
            XCTAssertEqual(Path("\(home.uppercased())").abbreviate(), Path("~"))
        #endif
    }

    struct FakeFSInfo: FileSystemInfo {
        let caseSensitive: Bool

        func isFSCaseSensitiveAt(path _: Path) -> Bool {
            caseSensitive
        }
    }

    func testAbbreviationOnCaseSensitiveFileSystem() throws {
        let home = Path.home.string
        let fakeFsInfo = FakeFSInfo(caseSensitive: true)
        let path = Path("\(home.uppercased())", fileSystemInfo: fakeFsInfo)
        XCTAssertEqual(path.abbreviate().string, home.uppercased())
    }

    func testAbbreviationOnCaseInsensitiveFileSystem() throws {
        let home = Path.home.string
        let fakeFsInfo = FakeFSInfo(caseSensitive: false)
        let path = Path("\(home.uppercased())", fileSystemInfo: fakeFsInfo)
        XCTAssertEqual(path.abbreviate(), Path("~"))
    }

    func testCreateSymlinkWithRelativeDestination() throws {
        try setupFixtures()
        let path = Path("\(fixtures)/symlinks/file")
        let resolvedPath = try path.symlinkDestination()
        XCTAssertEqual(resolvedPath.normalize().string, fixtures + "/file")
    }

    func testCreateSymlinkWithAbsoluteDestination() throws {
        try setupFixtures()
        let path = Path("\(fixtures)/symlinks/swift")
        let resolvedPath = try path.symlinkDestination()
        XCTAssertEqual(resolvedPath.normalize(), "/usr/bin/swift")
    }

    func testCreateSymlinkWithSameDirectory() throws {
        #if os(macOS)
            try setupFixtures()
            let path = Path("\(fixtures)/symlinks/same-dir")
            let resolvedPath = try path.symlinkDestination()
            XCTAssertEqual(resolvedPath.normalize().string, fixtures + "/symlinks")
        #endif
    }

    func testReturnLastComponent() throws {
        XCTAssertEqual(Path("a/b/c.d").lastComponent, "c.d")
        XCTAssertEqual(Path("a/..").lastComponent, "..")
    }

    func testReturnLastComponentWithoutExtension() throws {
        XCTAssertEqual(Path("a/b/c.d").lastComponentWithoutExtension, "c")
        XCTAssertEqual(Path("a/..").lastComponentWithoutExtension, "..")
    }

    func testSplitIntoComponents() throws {
        XCTAssertEqual(Path("a/b/c.d").components, ["a", "b", "c.d"])
        XCTAssertEqual(Path("/a/b/c.d").components, ["/", "a", "b", "c.d"])
        XCTAssertEqual(Path("~/a/b/c.d").components, ["~", "a", "b", "c.d"])
    }

    func testReturnExtension() throws {
        XCTAssertEqual(Path("a/b/c.d").extension, "d")
        XCTAssertEqual(Path("a/b.c.d").extension, "d")
        XCTAssertNil(Path("a/b").extension)
    }

    func testCheckIfPathExists() throws {
        try setupFixtures()
        XCTAssertTrue(Path(fixtures).exists)
    }

    func testCheckIfPathDoesNotExist() throws {
        try setupFixtures()
        XCTAssertFalse(Path("/pathkit/test").exists)
    }

    func testCheckIfPathIsDirectory() throws {
        try setupFixtures()
        XCTAssertTrue(Path("\(fixtures)/directory").isDirectory)
        XCTAssertTrue(Path("\(fixtures)/symlinks/directory").isDirectory)
        XCTAssertFalse(Path("\(fixtures)/file").isDirectory)
        XCTAssertFalse(Path("\(fixtures)/symlinks/file").isDirectory)
    }

    func testCheckIfPathIsSymlink() throws {
        try setupFixtures()
        XCTAssertFalse(Path("\(fixtures)/file/file").isSymlink)
        XCTAssertTrue(Path("\(fixtures)/symlinks/file").isSymlink)
    }

    func testCheckIfPathIsFile() throws {
        try setupFixtures()
        XCTAssertTrue(Path("\(fixtures)/file").isFile)
        XCTAssertTrue(Path("\(fixtures)/symlinks/file").isFile)
        XCTAssertFalse(Path("\(fixtures)/directory").isFile)
        XCTAssertFalse(Path("\(fixtures)/symlinks/directory").isFile)
    }

    func testCheckIfPathIsExecutable() throws {
        try setupFixtures()
        XCTAssertTrue(Path("\(fixtures)/permissions/executable").isExecutable)
        XCTAssertFalse(Path("\(fixtures)/permissions/writable").isExecutable)
    }

    func testCheckIfPathIsReadable() throws {
        try setupFixtures()
        XCTAssertTrue(Path("\(fixtures)/permissions/readable").isReadable)
        XCTAssertFalse(Path("\(fixtures)/permissions/none").isReadable)
    }

    func testCheckIfPathIsWritable() throws {
        try setupFixtures()
        XCTAssertTrue(Path("\(fixtures)/permissions/writable").isWritable)
        XCTAssertFalse(Path("\(fixtures)/permissions/readable").isWritable)
    }

    func testCheckIfPathIsDeletable() throws {
        #if os(macOS)
            try setupFixtures()
            XCTAssertTrue(Path("\(fixtures)/permissions/deletable").isDeletable)
        #endif
    }

    func testChangeDirectory() throws {
        let current = Path.current

        Path("/usr/bin").chdir {
            XCTAssertEqual(Path.current, Path("/usr/bin"))
        }

        XCTAssertEqual(Path.current, current)
    }

    func testChangeDirectoryWithThrowingClosure() throws {
        let current = Path.current
        let error = ThrowError()

        XCTAssertThrowsError(try Path("/usr/bin").chdir {
            XCTAssertEqual(Path.current, Path("/usr/bin"))
            throw error
        })

        XCTAssertEqual(Path.current, current)
    }

    func testProvideHomeDirectory() throws {
        XCTAssertEqual(Path.home, Path(ProcessInfo.processInfo.environment["HOME"] ?? ""))
    }

    func testProvideTempDirectory() throws {
        XCTAssertEqual(Path.temporary, Path(NSTemporaryDirectory()))
        XCTAssertTrue(Path.temporary.exists)
    }

    func testReadDataFromFile() throws {
        try setupFixtures()
        let contents = try XCTUnwrap(Path("\(fixtures)/hello").read())
        let string = try XCTUnwrap(String(data: contents, encoding: .utf8))
        XCTAssertEqual(string, "Hello World\n")
    }

    func testReadDataFromNonexistentFileFails() throws {
        let path = Path("\(fixtures)/pathkit-testing")
        try XCTAssertThrowsError(path.read() as Data)
    }

    func testReadStringFromFile() throws {
        try setupFixtures()
        let contents: String = try XCTUnwrap(Path("\(fixtures)/hello").read())
        XCTAssertEqual(contents, "Hello World\n")
    }

    func testReadStringFromNonexistentFileFails() throws {
        let path = Path("\(fixtures)/pathkit-testing")
        try XCTAssertThrowsError(path.read() as String)
    }

    func testWriteDataToFile() throws {
        try setupFixtures()
        let path = Path("\(fixtures)/pathkit-testing")
        let data = try XCTUnwrap("Hi".data(using: String.Encoding.utf8, allowLossyConversion: true))

        XCTAssertFalse(path.exists)

        try path.write(data)
        try XCTAssertEqual(path.read(), "Hi")
    }

    func testWriteDataToFileFailure() throws {
        #if os(macOS)
            try setupFixtures()
            let path = Path("/")
            let data = try XCTUnwrap("Hi".data(using: String.Encoding.utf8, allowLossyConversion: true))

            try XCTAssertThrowsError(path.write(data))
        #endif
    }

    func testWriteStringToFile() throws {
        try setupFixtures()
        let path = Path("\(fixtures)/pathkit-testing")

        try path.write("Hi")
        try XCTAssertEqual(path.read(), "Hi")
    }

    func testWriteStringToFileFailure() throws {
        #if os(macOS)
            try setupFixtures()
            let path = Path("/")

            try XCTAssertThrowsError(path.write("Hi"))
        #endif
    }

    func testReturnParentDirectory() throws {
        try setupFixtures()
        XCTAssertEqual(Path(fixtures + "directory/child").parent().string, fixtures + "directory")
        XCTAssertEqual(Path(fixtures + "symlinks/directory").parent().string, fixtures + "symlinks")
        XCTAssertEqual(Path(fixtures + "/directory/child/..").parent().string, fixtures)
        XCTAssertEqual(Path("/").parent(), "/")
    }

    func testReturnChildren() throws {
        try setupFixtures()
        let children = try Path(fixtures).children().sorted(by: <)
        let expected = ["hello", "directory", "file", "permissions", "symlinks"].map { Path(fixtures) + $0 }
            .sorted(by: <)
        XCTAssertEqual(children, expected)
    }

    func testReturnChildrenRecursively() throws {
        try setupFixtures()
        let children = try Path("\(fixtures)/directory").recursiveChildren().sorted(by: <)
        let expected = [".hiddenFile", "child", "subdirectory", "subdirectory/child"]
            .map { Path("\(fixtures)/directory") + $0 }.sorted(by: <)
        XCTAssertEqual(children, expected)
    }

    func testConformsToSequenceWithoutOptions() throws {
        try setupFixtures()
        let path = Path("\(fixturesResolved)/directory")
        XCTAssertTrue(path.exists)
        XCTAssertTrue(path.isDirectory)
        try XCTAssertEqual(path.children().count, 3)
        var children = ["child", "subdirectory", ".hiddenFile"].map { path + $0 }
        let generator = path.makeIterator()
        while let child = generator.next() {
            generator.skipDescendants()
            if let index = children.firstIndex(of: child) {
                children.remove(at: index)
            } else {
                throw ThrowError()
            }
        }

        XCTAssertTrue(children.isEmpty)
        XCTAssertNil(Path("/non/existing/directory/path").makeIterator().next())
    }

    func testConformsToSequenceWithOptions() throws {
        #if os(macOS)
            try setupFixtures()
            let path = Path("\(fixturesResolved)/directory")
            var children = ["child", "subdirectory"].map { path + $0 }
            let generator = path.iterateChildren(options: .skipsHiddenFiles).makeIterator()
            while let child = generator.next() {
                generator.skipDescendants()
                if let index = children.firstIndex(of: child) {
                    children.remove(at: index)
                } else {
                    throw ThrowError()
                }
            }

            XCTAssertTrue(children.isEmpty)
            XCTAssertNil(Path("/non/existing/directory/path").makeIterator().next())
        #endif
    }

    func testPatternMatching() throws {
        XCTAssertFalse(Path("/var") ~= "~")
        XCTAssertTrue(Path("/Users") ~= "/Users")
        XCTAssertTrue((Path.home + "..") ~= "~/..")
    }

    func testComparison() throws {
        XCTAssertTrue(Path("a") < Path("b"))
    }

    func testAppend() throws {
        // Trivial cases.
        XCTAssertEqual(Path("a/b"), "a" + "b")
        XCTAssertEqual(Path("a/b"), "a/" + "b")

        // Appending (to) absolute paths
        XCTAssertEqual(Path("/"), "/" + "/")
        XCTAssertEqual(Path("/"), "/" + "..")
        XCTAssertEqual(Path("/a"), "/" + "../a")
        XCTAssertEqual(Path("/b"), "a" + "/b")

        // Appending (to) '.'
        XCTAssertEqual(Path("a"), "a" + ".")
        XCTAssertEqual(Path("a"), "a" + "./.")
        XCTAssertEqual(Path("a"), "." + "a")
        XCTAssertEqual(Path("a"), "./." + "a")
        XCTAssertEqual(Path(""), "." + ".")
        XCTAssertEqual(Path(""), "./." + "./.")
        XCTAssertEqual(Path("../a"), "." + "./../a")
        XCTAssertEqual(Path("../a"), "." + "../a")

        // Appending (to) '..'
        XCTAssertEqual(Path(""), "a" + "..")
        XCTAssertEqual(Path("a"), "a/b" + "..")
        XCTAssertEqual(Path("../.."), ".." + "..")
        XCTAssertEqual(Path("b"), "a" + "../b")
        XCTAssertEqual(Path("a/c"), "a/b" + "../c")
        XCTAssertEqual(Path("a/b/d/e"), "a/b/c" + "../d/e")
        XCTAssertEqual(Path("../../a"), ".." + "../a")
    }

    func testPathStaticGlob() throws {
        try setupFixtures()
        let pattern = Path("\(fixtures)/permissions/*").description
        let paths = Path.glob(pattern)

        let results = try Path("\(fixtures)/permissions").children().map { $0.absolute() }.sorted(by: <)
        XCTAssertEqual(paths, results.sorted(by: <))
    }

    func testGlobInsideDirectory() throws {
        try setupFixtures()
        let paths = Path(fixtures).glob("permissions/*")

        let results = try Path("\(fixtures)/permissions").children().map { $0.absolute() }.sorted(by: <)
        XCTAssertEqual(paths, results.sorted(by: <))
    }

    func testPatternMatchAgainstRelativePath() throws {
        XCTAssertTrue(Path("test.txt").match("test.txt"))
        XCTAssertTrue(Path("test.txt").match("*.txt"))
        XCTAssertTrue(Path("test.txt").match("*"))
        XCTAssertFalse(Path("test.txt").match("test.md"))
    }

    func testPatternMatchAgainstAbsolutePath() throws {
        XCTAssertTrue(Path("/home/kyle/test.txt").match("*.txt"))
        XCTAssertTrue(Path("/home/kyle/test.txt").match("/home/*.txt"))
        XCTAssertFalse(Path("/home/kyle/test.txt").match("*.md"))
    }
}
