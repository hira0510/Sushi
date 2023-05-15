# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Sushi' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Sushi
  pod 'RxSwift', '5.1.1'
  pod 'RxCocoa', '5.1.1'
  pod 'RxGesture'
  pod 'RxDataSources', '4.0.1'
  pod 'Firebase/Analytics', '10.8.0'
  pod 'Firebase/Database', '10.8.0'
  pod 'Firebase/Auth', '10.8.0'
  pod 'Firebase/Storage', '10.8.0'
  pod 'Kingfisher', '5.13.4'
  pod 'SnapKit'
  pod 'Starscream', '4.0.4'
  pod 'SQLite.swift'
  pod 'TYCyclePagerView', '1.2.0' 


  target 'SushiTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SushiUITests' do
    # Pods for testing
  end

end

post_install do |installer|

  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end

  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
         end
    end
  end

end