//
//  Log.swift
//  SSLog
//
//  Created by Toshihiko Arai on 2024/09/16.
//

import UIKit

public class Log: NSObject {
    
    public enum Level: String, Comparable {
        case debug      = "Debug"
        case info       = "Info"
        case warning    = "Warning"
        case error      = "Error"
        
        // ログレベルに対応する色を返す
        var color: UIColor {
            switch self {
            case .debug:
                return UIColor.gray
            case .info:
                return UIColor.blue
            case .warning:
                return UIColor.orange
            case .error:
                return UIColor.red
            }
        }
        
        // レベルの比較
        public static func < (lhs: Level, rhs: Level) -> Bool {
            return lhs.priority < rhs.priority
        }
        
        private var priority: Int {
            switch self {
            case .debug: return 0
            case .info: return 1
            case .warning: return 2
            case .error: return 3
            }
        }
    }
    
    public static var enableLog: Bool = true
//    public static var logFileName: String?
    public static var  filePrefix = "log_" // ファイル名のプレフィックス

    
    public static var logLevel: Level = .debug // ログレベルの追加

    // シリアルキューの作成（排他制御用）
    private static let logQueue = DispatchQueue(label: "com.apppppp.SSLog")

    // ファイルパスの定義
    // ファイルパスの定義（ファイル名に日付を含める）
    static func getFileURL(_ filename: String? = nil) -> URL? {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd" // 日付をファイル名に
//        let dateString = formatter.string(from: Date())
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Log dir error")
            return nil
        }
        
        var logFileName = filename
        
        if logFileName == nil {
            // 日付フォーマットの設定
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            logFileName = "log_\(dateFormatter.string(from: Date())).log"
        }

        
        let fileUrl = dir.appendingPathComponent(logFileName!)
        return fileUrl
    }

    // 新規作成メソッドをstaticに

    public static func new() {
        logQueue.sync {
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
    }
    
    // ログ出力メソッドをstaticに
    public static func d(_ message: String, _ filename: String? = nil, file: String = #file, line: Int = #line, function: String = #function) {
        if enableLog {
            log(.debug, message, filename, file, line, function)
        }
    }

    public static func i(_ message: String, _ filename: String? = nil, file: String = #file, line: Int = #line, function: String = #function) {
        if enableLog {
            log(.info, message, filename, file, line, function)
        }
    }

    public static func w(_ message: String, _ filename: String? = nil, file: String = #file, line: Int = #line, function: String = #function) {
        if enableLog {
            log(.warning, message, filename, file, line, function)
        }
    }

    public static func e(_ message: String, _ filename: String? = nil, file: String = #file, line: Int = #line, function: String = #function) {
        if enableLog {
            log(.error, message, filename, file, line, function)
        }
    }

    // ログの基本メソッドをstaticに
    static func log(_ level: Level, _ message: String, _ filename: String? = nil, _ file: String, _ line: Int, _ function: String) {
        // 設定されたログレベル以上のみ出力
        if level < logLevel {
            return
        }

        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let dateStr = formatter.string(from: now)
        
        let fname = (file as NSString).lastPathComponent // ファイル名のみを抽出
        let caller = "(\(fname):\(line)) \(function)"
        
        let content = "\(dateStr) [\(level.rawValue)] \(caller) - \(message)"
        add(content, filename)
        print(content)
    }
    
    // ファイルへの書き込みメソッドをstaticに
    static func add(_ text: String, _ filename: String? = nil) {
        logQueue.sync {
            guard let url = getFileURL(filename) else {
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
    }
    
    // ファイルの読み込みメソッドをstaticに
    public static func loadLog() -> String? {
        guard let url = getFileURL() else {
            return nil
        }

        var logContent = ""
        /**
         bufferSizeを 1024 など小さくして分割して読み込もうとすると、エンコーディングエラーが多発するので大きくとる
         */
        let bufferSize = 104_857_600 // 100MBをバイト単位で表現
        

        do {
            let fileHandle = try FileHandle(forReadingFrom: url)
            defer {
                fileHandle.closeFile() // ファイルハンドルを必ずクローズする
            }

            while true {
                let data = fileHandle.readData(ofLength: bufferSize) // 指定されたバッファサイズで読み込み
                if data.isEmpty {
                    break // データがなくなったら終了
                }

                if let chunk = String(data: data, encoding: .utf8) {
                    logContent += chunk
                } else {
                    // エンコーディングエラーが発生した場合、バイトデータを出力
                    print("エンコーディングエラー: \(data)")
                    print("バイトデータ: \(data.map { String(format: "%02x", $0) }.joined(separator: " "))")
                    return nil
                }
            }
        } catch {
            print("Error: load at path \(url.path)")
            print("Error description: \(error.localizedDescription)")
            return nil
        }

        return logContent
    }
    
    // ログファイルを削除するメソッドをstaticに
    public static func deleteLogFile() {
        logQueue.sync {
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
}
