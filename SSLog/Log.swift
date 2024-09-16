//
//  Log.swift
//  SSLog
//
//  Created by Toshihiko Arai on 2024/09/16.
//

import Foundation

public class Log: NSObject {
    
    public enum Level: String {
        case debug      = "Debug"
        case info       = "Info"
        case warning    = "Warning"
        case error      = "Error"
    }
    
    public static var enableLog: Bool = true
    public static var logFileName: String = "simplify-swift.log"

    // ファイルパスの定義
    // ファイルパスの定義（ファイル名に日付を含める）
    static func getFileURL() -> URL? {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd" // 日付をファイル名に
//        let dateString = formatter.string(from: Date())
        let fileName = logFileName
//        print(fileName)

        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Log dir error")
            return nil
        }
        let fileUrl = dir.appendingPathComponent(fileName)
        return fileUrl
    }

    // 新規作成メソッドをstaticに

    public static func new() {
        guard let url = getFileURL() else {
            return
        }
        
        let fileAttributes: [FileAttributeKey: Any] = [
            .posixPermissions: 0o644 // 読み取り可能なアクセス権限
        ]
        
        if FileManager.default.createFile(
            atPath: url.path,
            contents: "".data(using: .utf8),
            attributes: fileAttributes
        ) {
            print("ファイルを新規作成しました。")
        } else {
            print("ファイルの新規作成に失敗しました。")
        }
    }
    
    // ログ出力メソッドをstaticに
    public static func d(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        if enableLog {
            log(.debug, message, file, line, function)
        }
    }

    public static func i(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        if enableLog {
            log(.info, message, file, line, function)
        }
    }

    public static func w(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        if enableLog {
            log(.warning, message, file, line, function)
        }
    }

    public static func e(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        if enableLog {
            log(.error, message, file, line, function)
        }
    }

    // ログの基本メソッドをstaticに
    static func log(_ level: Level, _ message: String, _ file: String, _ line: Int, _ function: String) {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let dateStr = formatter.string(from: now)
        
        let fileName = (file as NSString).lastPathComponent // ファイル名のみを抽出
        let caller = "(\(fileName):\(line)) \(function)"
        
        let content = "\(dateStr) [\(level.rawValue)] \(caller) - \(message)"
        add(content)
    }
    
    // ファイルへの書き込みメソッドをstaticに
    static func add(_ text: String) {
        guard let url = getFileURL() else {
            return
        }

        do {
            if let fileHandle = try? FileHandle(forWritingTo: url) {
                fileHandle.seekToEndOfFile() // ファイルの末尾に移動
                if let data = (text + "\n").data(using: .utf8) {
                    fileHandle.write(data) // 追記
                }
                fileHandle.closeFile()
            } else {
                try (text + "\n").write(to: url, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Error: write to path \(url.path)")
            print("Error description: \(error.localizedDescription)")
        }
    }
    
    // ファイルの読み込みメソッドをstaticに
    public static func load() -> String? {
        guard let url = getFileURL() else {
            return nil
        }

        do {
            return try String(contentsOf: url)
        } catch {
            print("Error: load at path \(url.path)")
            print("Error description: \(error.localizedDescription)")
        }
        return nil
    }
    
    // ログファイルを削除するメソッドをstaticに
    public static func deleteLogFile() {
        guard let url = getFileURL() else {
            return
        }

        do {
            try FileManager.default.removeItem(at: url)
            print("ログファイルを削除しました。")
        } catch {
            print("Error: ファイル削除に失敗しました。\(url.path)")
            print("Error description: \(error.localizedDescription)")
        }
    }
}
