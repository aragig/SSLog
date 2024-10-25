//
//  LogDetailViewController.swift
//  SSLog
//
//  Created by Toshihiko Arai on 2024/10/25.
//

import UIKit

class LogDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    let utils = LogUtils()

    var fileName: String? // 前のコントローラーから渡されるファイル名
    var logContent: [String] = [] // フィルター後の表示用ログ内容
    var originalLogContent: [String] = [] // 元の全ログ内容を保持
 
    let tableView = UITableView()
    let searchBar = UISearchBar()
    var selectedFilters = ["Debug", "Info", "Warning", "Error"]
    var searchText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = fileName ?? "ログ詳細"
        self.view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "フィルター", style: .plain, target: self, action: #selector(onFilterButtonTapped))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        searchBar.delegate = self
        searchBar.placeholder = "検索"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if let fileName = fileName {
            loadLogFileContent(fileName: fileName)
        }
    }
        
    
    @objc func onFilterButtonTapped() {
        let filterVC = FilterViewController()
        filterVC.selectedFilters = selectedFilters
        
        filterVC.onApplyFilters = { [weak self] filters in
            self?.selectedFilters = filters
            self?.applyFilter(selectedFilters: filters, searchText: self?.searchText ?? "")
        }
        
        let navController = UINavigationController(rootViewController: filterVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    func applyFilter(selectedFilters: [String], searchText: String) {
        // フィルターと検索文字列の両方を考慮
        logContent = originalLogContent.filter { log in
            let matchesFilter = selectedFilters.isEmpty || selectedFilters.contains { filter in log.contains(filter) }
            let matchesSearchText = searchText.isEmpty || log.localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearchText
        }
        tableView.reloadData()
    }
    
    func loadLogFileContent(fileName: String) {
        utils.loadLogFileContent(fileName: fileName) { contents in
            originalLogContent = contents
            logContent = contents
            tableView.reloadData()
        } errorHandler: { error in
            print(error)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logContent.count
    }

    // テーブルビューのセル設定（ログレベルごとに色を分ける）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 10) // 極小フォントサイズ
        cell.textLabel?.numberOfLines = 0 // テキストの折り返しを許可
        let log = logContent[indexPath.row]
        cell.textLabel?.text = log
        
        if log.contains(Log.Level.debug.rawValue) {
            cell.textLabel?.textColor = Log.Level.debug.color
        } else if log.contains(Log.Level.info.rawValue) {
            cell.textLabel?.textColor = Log.Level.info.color
        } else if log.contains(Log.Level.warning.rawValue) {
            cell.textLabel?.textColor = Log.Level.warning.color
        } else if log.contains(Log.Level.error.rawValue) {
            cell.textLabel?.textColor = Log.Level.error.color
        } else {
            cell.textLabel?.textColor = UIColor.black
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedText = logContent[indexPath.row]
        UIPasteboard.general.string = selectedText
        showToast(message: "コピーしました")
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width / 2 - 75,
                                               y: self.view.frame.size.height - 100,
                                               width: 150,
                                               height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, delay: 2.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        applyFilter(selectedFilters: selectedFilters, searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // スクロール時にキーボードを閉じる
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}


// フィルター画面用のビューコントローラ
class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedFilters: [String] = []
    let logLevels = ["Debug", "Info", "Warning", "Error"]
    let tableView = UITableView()
    var onApplyFilters: (([String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.title = "フィルター"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(tableView)
        
        // ナビゲーションバーに「適用」ボタンを追加
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "適用", style: .done, target: self, action: #selector(onApplyButtonTapped))
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logLevels.count
    }
    
    // セルの設定
    // モーダルビュー内のフィルターレベルの色分け
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let level = logLevels[indexPath.row]
        cell.textLabel?.text = level
        
        // ログレベルごとに文字の色を設定
        switch level {
        case Log.Level.debug.rawValue:
            cell.textLabel?.textColor = Log.Level.debug.color
        case Log.Level.info.rawValue:
            cell.textLabel?.textColor = Log.Level.info.color
        case Log.Level.warning.rawValue:
            cell.textLabel?.textColor = Log.Level.warning.color
        case Log.Level.error.rawValue:
            cell.textLabel?.textColor = Log.Level.error.color
        default:
            cell.textLabel?.textColor = UIColor.black
        }
        
        // 選択されているフィルターにチェックを付ける
        if selectedFilters.contains(level) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // セルが選択されたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let level = logLevels[indexPath.row]
        
        if let index = selectedFilters.firstIndex(of: level) {
            selectedFilters.remove(at: index)
        } else {
            selectedFilters.append(level)
        }
        
        tableView.reloadData()
    }
    
    // 「適用」ボタンが押されたときの処理
    @objc func onApplyButtonTapped() {
        onApplyFilters?(selectedFilters)
        self.dismiss(animated: true, completion: nil)
    }
}
