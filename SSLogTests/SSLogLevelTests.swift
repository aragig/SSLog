//
//  SSLogLevelTests.swift
//  SSLogTests
//
//  Created by Toshihiko Arai on 2024/09/28.
//

import XCTest

class SSLogLevelTests: XCTestCase {

    override func setUpWithError() throws {
        // テストごとに呼ばれる前のセットアップ
        Log.enableLog = true
//        Log.logFileName = "test-log.log"
        Log.deleteLogFile() // テスト前にログファイルを削除
    }

    override func tearDownWithError() throws {
        // テストごとに呼ばれる後のクリーンアップ
        Log.deleteLogFile()
    }

    func testLogLevel() {
        // ログレベルを設定
        Log.logLevel = .warning

        // 各レベルのログを出力
        Log.d("This is a debug message")
        Log.i("This is an info message")
        Log.w("This is a warning message")
        Log.e("This is an error message")
        
        // ログファイルを読み込み
        let logContent = Log.loadLog()
        
        // 確認
        XCTAssertNotNil(logContent)
        XCTAssertFalse(logContent!.contains("This is a debug message"), "Debug level log should not be present")
        XCTAssertFalse(logContent!.contains("This is an info message"), "Info level log should not be present")
        XCTAssertTrue(logContent!.contains("This is a warning message"), "Warning level log should be present")
        XCTAssertTrue(logContent!.contains("This is an error message"), "Error level log should be present")
    }
}
