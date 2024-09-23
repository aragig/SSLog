//
//  SSLogTests2.swift
//  SSLogTests
//
//  Created by Toshihiko Arai on 2024/09/23.
//

import XCTest

class SSLogTestsThreadSafe: XCTestCase {
    
    override func setUpWithError() throws {
        // 各テストの前にログファイルを新規作成して初期化
        Log.new()
    }
    
    override func tearDownWithError() throws {
        // 各テストの後にログファイルを削除
        Log.deleteLogFile()
    }
    
    // 複数スレッドでログ書き込みのテスト
    func testConcurrentLogWriting() {
        let expectation = XCTestExpectation(description: "Log writing from multiple threads")
        
        // スレッド数
        let threadCount = 10
        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()
        
        for i in 0..<threadCount {
            group.enter()
            queue.async {
                Log.d("ログ書き込み \(i)")
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            expectation.fulfill() // 全スレッドの完了を確認
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // ログ内容を確認
        if let logContent = Log.loadLog() {
            XCTAssertTrue(logContent.contains("ログ書き込み 0"))
            XCTAssertTrue(logContent.contains("ログ書き込み 9"))
        } else {
            XCTFail("ログファイルの読み込みに失敗しました")
        }
    }
    
    // 複数スレッドでログ読み込みと書き込みを同時に行うテスト
    func testConcurrentReadAndWrite() {
        let expectation = XCTestExpectation(description: "Concurrent log read and write")
        
        // スレッド数
        let threadCount = 5
        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()
        
        // 書き込みスレッド
        for i in 0..<threadCount {
            group.enter()
            queue.async {
                Log.i("並行ログ書き込み \(i)")
                group.leave()
            }
        }
        
        // 読み込みスレッド
        for _ in 0..<threadCount {
            group.enter()
            queue.async {
                _ = Log.loadLog()
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            expectation.fulfill() // 全スレッドの完了を確認
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // ログ内容を確認
        if let logContent = Log.loadLog() {
            XCTAssertTrue(logContent.contains("並行ログ書き込み 0"))
            XCTAssertTrue(logContent.contains("並行ログ書き込み 4"))
        } else {
            XCTFail("ログファイルの読み込みに失敗しました")
        }
    }
    
    // 複数スレッドでのログ削除のテスト
    func testConcurrentLogDeletion() {
        let expectation = XCTestExpectation(description: "Concurrent log deletion")
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()
        
        // スレッドでのログ削除とログ書き込みを実行
        group.enter()
        queue.async {
            Log.deleteLogFile() // ログファイルの削除
            group.leave()
        }
        
        group.enter()
        queue.async {
            Log.w("削除後のログ書き込み")
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            expectation.fulfill() // 全スレッドの完了を確認
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // ログ内容を確認
        if let logContent = Log.loadLog() {
            XCTAssertTrue(logContent.contains("削除後のログ書き込み"))
        } else {
            XCTFail("ログファイルの読み込みに失敗しました")
        }
    }
}
