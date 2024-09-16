//
//  SSLogTests.swift
//  SSLogTests
//
//  Created by Toshihiko Arai on 2024/09/16.
//

import XCTest
@testable import SSLog // SSLogはプロジェクト名に合わせて変更してください

class LogTests: XCTestCase {

    override func setUpWithError() throws {
        // テスト前に呼ばれる
        Log.new() // ログファイルを新規作成
        //Log.enableLog = false
    }

    override func tearDownWithError() throws {
        // テスト後に呼ばれる
        // テストが終わったら、ログファイルを削除しても良い
        guard let url = Log.getFileURL() else { return }
        try? FileManager.default.removeItem(at: url)
    }

    func testLogDebug() throws {
        // Debugログのテスト
        Log.d("Debug log test")
        
        guard let logContent = Log.load() else {
            XCTFail("Log file could not be read.")
            return
        }
        
        XCTAssertTrue(logContent.contains("Debug log test"), "Log does not contain expected debug message")
    }
    
    func testLogInfo() throws {
        // Infoログのテスト
        Log.i("Info log test")
        
        guard let logContent = Log.load() else {
            XCTFail("Log file could not be read.")
            return
        }
        
        XCTAssertTrue(logContent.contains("Info log test"), "Log does not contain expected info message")
    }
    
    func testLogWarning() throws {
        // Warningログのテスト
        Log.w("Warning log test")
        
        guard let logContent = Log.load() else {
            XCTFail("Log file could not be read.")
            return
        }
        
        XCTAssertTrue(logContent.contains("Warning log test"), "Log does not contain expected warning message")
    }
    
    func testLogError() throws {
        // Errorログのテスト
        Log.e("Error log test")
        
        guard let logContent = Log.load() else {
            XCTFail("Log file could not be read.")
            return
        }
        
        XCTAssertTrue(logContent.contains("Error log test"), "Log does not contain expected error message")
    }
    
    func testLogFileCreation() throws {
        // ファイルが正しく作成されているかのテスト
        guard let fileURL = Log.getFileURL() else {
            XCTFail("Log file URL could not be obtained.")
            return
        }
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path), "Log file does not exist")
    }
    
    func testLogFileAppending() throws {
        // ログが追記されるかのテスト
        Log.d("First log entry")
        Log.i("Second log entry")
        
        guard let logContent = Log.load() else {
            XCTFail("Log file could not be read.")
            return
        }
        
        XCTAssertTrue(logContent.contains("First log entry"), "Log does not contain first log entry")
        XCTAssertTrue(logContent.contains("Second log entry"), "Log does not contain second log entry")
    }
}
