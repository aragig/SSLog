//
//  LogListViewController.swift
//  SSLog
//
//  Created by Toshihiko Arai on 2024/10/25.
//

import UIKit

class LogListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // テーブルビューを作成
    let tableView = UITableView()
    var fileList: [String] = []
    var filePrefix = "log_" // ファイル名のプレフィックス
    
    let utils = LogUtils()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ビューの背景色を設定
        self.view.backgroundColor = .systemBackground
        self.title = "ログファイル一覧"
        
        // ナビゲーションバーにゴミ箱ボタンを追加
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(onTrashButtonTapped))

        // テーブルビューの設定
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(tableView)
        
        fetchFileList()

    }

    func fetchFileList() {
        // ファイルリストを取得
        utils.fetchFileList(filePrefix: filePrefix) { fList in
            print(fList)
            fileList = fList
            tableView.reloadData()
        } errorHandler: { error in
            print(error)
        }


    }


    // テーブルビューのセル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }

    // テーブルビューのセル設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = fileList[indexPath.row]
        return cell
    }

    // セルが選択されたときのイベント
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile = fileList[indexPath.row]
        print("選択されたファイル: \(selectedFile)")
        let logDetailViewController = LogDetailViewController()
        logDetailViewController.fileName = selectedFile
        self.navigationController?.pushViewController(logDetailViewController, animated: true)
//        // イベントの処理（例: ファイルの内容を表示する、別画面に遷移するなど）
//        let alert = UIAlertController(title: "ファイル選択", message: "\(selectedFile) が選択されました", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
    }
    
    
    // セルを横にスワイプして削除ボタンを表示
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            utils.deleteLogFile(filename: self.fileList[indexPath.row]) {
                // ファイルリストから削除
                self.fileList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                print("\(self.fileList[indexPath.row]) を削除しました")

            } errorHandler: { error in
                print("ファイルの削除に失敗しました: \(error)")
            }

            completionHandler(true)
        }

        // 削除アクションを設定
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    // ゴミ箱ボタンが押されたときの処理
        @objc func onTrashButtonTapped() {
            let alert = UIAlertController(title: "すべてのログを削除しますか？", message: "この操作は元に戻せません。", preferredStyle: .alert)
            
            // キャンセルボタン
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            
            // すべて削除ボタン
            alert.addAction(UIAlertAction(title: "すべて削除", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                utils.cleanupLogFiles(filePrefix: filePrefix) {
                    // ファイルリストを再取得
                    self.fetchFileList()
                } errorHandler: { error in
                    print(error)
                }

            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
}
