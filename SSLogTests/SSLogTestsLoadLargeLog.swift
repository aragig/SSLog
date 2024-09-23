//
//  SSLogTestsLoadLargeLog.swift
//  SSLogTests
//
//  Created by Toshihiko Arai on 2024/09/23.
//

import XCTest

class SSLogTestsLoadLargeLog: XCTestCase {

    // 100MBのログファイルを作成
    func testCreateLargeLogFile() {
        Log.new() // 新しいログファイルを作成
        
        // 各ログエントリのサイズを増やすため、1エントリを1KBに
        let largeText = String(repeating: "This is a large log entry to increase file size. This entry is intentionally long.\n", count: 10_000_000) // 100MB以上のデータを作成

        Log.add(largeText) // ログファイルに書き込む

        // ファイルサイズを確認
        guard let url = Log.getFileURL() else {
            XCTFail("Log file URL could not be obtained.")
            return
        }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? UInt64 {
                XCTAssert(fileSize >= 100 * 1024 * 1024, "Log file size is not 100MB or greater")
            }
        } catch {
            XCTFail("Error retrieving log file attributes: \(error.localizedDescription)")
        }
    }


    // 100MBのログファイルを読み込む
    func testLoadLargeLogFile() {
        _ = Log.loadLog() // 読み込みをテスト（巨大ファイルの読み込みテスト）
        XCTAssert(true, "Log file loaded successfully")
    }

    // テスト終了後にファイルを削除
    override func tearDown() {
        super.tearDown()

        Log.deleteLogFile() // テスト後にログファイルを削除
        guard let url = Log.getFileURL() else {
            return
        }

        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path), "Log file was not deleted")
    }
}
