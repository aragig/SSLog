# SSLog

SSLog（Simplify Swift Logger）は、iOSアプリで使えるSwiftで作られたシンプルなロガーです。以下のようにして、Cocos Podsでインストールできます。



```
target 'xxxx' do
  pod 'SSLog', :git => 'https://github.com/aragig/SSLog.git', :tag => '0.3.0'
end
```


```ViewControllser.swift
import SSLog

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Log.enableLog = true
        Log.logFileName = "SSLogSampleApp.log"
        // Log.logLevel = .warning

        Log.d("Debug log test")
        Log.i("Info log test")
        Log.w("Warning log test")
        Log.e("Error log test")

        let logs: String? = Log.load()
        print(logs ?? "")
        Log.deleteLogFile()

    }


}

```
※ 詳しくはSSLogSampleAppプロジェクトを参考ください。


▼ こんな感じでログファイルをローカルドキュメントに保存します。

```log
2024/09/16 14:28:13 [Debug] (ViewController.swift:19) viewDidLoad() - Debug log test
2024/09/16 14:28:13 [Info] (ViewController.swift:20) viewDidLoad() - Info log test
2024/09/16 14:28:13 [Warning] (ViewController.swift:21) viewDidLoad() - Warning log test
2024/09/16 14:28:13 [Error] (ViewController.swift:22) viewDidLoad() - Error log test
```

Info.plistに以下を設定することで、macOS の Finder からアクセス可能になります。中身を閲覧する際は、一旦 Desktop などへコピーしてから行ってください。

