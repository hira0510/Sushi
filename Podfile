# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Sushi' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Sushi
  pod 'RxSwift', '5.1.1'
  pod 'RxCocoa', '5.1.1'
  pod 'RxDataSources'
  pod 'Firebase/Analytics'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'
  pod 'Kingfisher', '5.13.4'

  target 'SushiTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SushiUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
         end
    end
  end
end