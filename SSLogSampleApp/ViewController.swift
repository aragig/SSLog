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
        // Do any additional setup after loading the view.
        Log.enableLog = true
        Log.logFileName = "SSLogSampleApp.log"
        
        Log.d("Debug log test")
        Log.i("Info log test")
        Log.w("Warning log test")
        Log.e("Error log test")

        let logs: String? = Log.load()
        print(logs ?? "")

    }


}

