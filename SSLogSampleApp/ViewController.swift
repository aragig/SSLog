//
//  ViewController.swift
//  SSLogSampleApp
//
//  Created by Toshihiko Arai on 2024/09/16.
//

import UIKit
//import SSLog

class ViewController: UIViewController {
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 日付フォーマットの設定
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"

        // 開始日付
        var date = dateFormatter.date(from: "20241001")!

        // カレンダーを使用して日付を1日ずつ増加
        let calendar = Calendar.current
        
        for _ in 0...20 {
            Log.enableLog = true
            
            // 日付を文字列に変換してログファイル名に使用
            let logFileName = "\(Log.filePrefix)\(dateFormatter.string(from: date)).log"

            print("\n\n")
            print(logFileName)
            
            // ログ出力
            Log.d("Debug log test Debug log test Debug log test Debug log test Debug log test Debug log test Debug log test Debug log test", logFileName)
            Log.i("Info log test Info log test Info log test Info log test Info log test Info log test Info log test Info log test Info log test", logFileName)
            Log.w("Warning log test Warning log test Warning log test Warning log test Warning log test Warning log test Warning log test", logFileName)
            Log.e("Error log test Error log test Error log test Error log test Error log test Error log test Error log test Error log test", logFileName)

            // 次の日にインクリメント
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }

    }

    @IBAction func onTappedToListButton(_ sender: Any) {
        let logListViewController = LogListViewController()
        
        // UINavigationControllerでラップ
        let navigationController = UINavigationController(rootViewController: logListViewController)
        
        // モーダル表示
        navigationController.modalPresentationStyle = .fullScreen // 必要に応じて設定
        self.present(navigationController, animated: true, completion: nil)
    }

}

