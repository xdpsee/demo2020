source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

platform :ios, '9.3'
inhibit_all_warnings!

target 'xinamp' do
  pod 'FMDB', '~> 2.7.5'
  pod 'Masonry', '~> 1.1.0'
  pod 'GCDWebServer/WebUploader', '~> 3.5.4'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts target.name
  end
end
