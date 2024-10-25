//
//  LogUtils.swift
//  SSLog
//
//  Created by Toshihiko Arai on 2024/10/25.
//

import Foundation

public class LogUtils {
    
    let filePrefix = Log.filePrefix
    
    // ファイルの内容を読み込んで改行単位で配列に格納
    public func loadLogFileContent(fileName: String, compleation:([String])->(), errorHandler:(String)->()) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first

        guard let directory = documentDirectory else { return }
        
        let filePath = directory.appendingPathComponent(fileName).path
        
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            let contents = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            
            compleation(contents)
        } catch {
            errorHandler("ファイルの読み込みに失敗しました: \(error)")
        }
    }
    
    // ファイルリストの取得
    public func fetchFileList(compleation:([String])->(), errorHandler:(String)->()) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first

        guard let directory = documentDirectory else { return }
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directory.path)
            let fileList:[String] = files.filter { $0.hasPrefix(filePrefix) }
            compleation(fileList.sorted(by: >))
        } catch {
            errorHandler("ファイルの取得に失敗しました: \(error)")
        }
    }
    
    // ログファイルの一括削除
    public func cleanupLogFiles(compleation:()->(), errorHandler:(String)->()) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first

        guard let directory = documentDirectory else {
            print("ドキュメントディレクトリが見つかりません")
            return
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directory.path)
            let logFiles = files.filter { $0.hasPrefix(filePrefix) }
            for file in logFiles {
                let filePath = directory.appendingPathComponent(file).path
                do {
                    try fileManager.removeItem(atPath: filePath)
                    print("\(filePath) を削除しました")
                } catch {
                    print("\(file) の削除に失敗しました: \(error)")
                }
            }
            compleation()

        } catch {
            errorHandler("ファイルの取得に失敗しました: \(error)")
        }
    }
    
    public func deleteLogFile(filename: String, compleation:()->(), errorHandler:(String)->()) {
        let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            
            if let directory = documentDirectory {
                let filePath = directory.appendingPathComponent(filename).path
                do {
                    try fileManager.removeItem(atPath: filePath)
                    compleation()
                    
                } catch {
                    print("ファイルの削除に失敗しました: \(error)")
                    errorHandler("ファイルの削除に失敗しました: \(error)")
                }
            }
    }

}

