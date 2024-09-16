Pod::Spec.new do |s|
  s.name             = 'SSLog'
  s.version          = '0.1.0'
  s.summary          = 'A simple logging framework.'

  s.description      = <<-DESC
  SSLog is a lightweight logging framework for iOS that provides debug, info, warning, and error level logging.
  DESC

  s.homepage         = 'https://github.com/aragig/SSLog'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Toshihiko Arai' => 'i.officearai@gmail.com' }
  s.source           = { :git => 'https://github.com/aragig/SSLog.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  # ソースファイルのパスを修正
  s.source_files = 'SSLog/*.swift', 'SSLog/*.h'

  s.swift_version = '5.0'
end
