# Uncomment this line to define a global platform for your project
platform :ios, '13.0'

# Uncomment this line if you're using Swift
use_frameworks!

target 'MovieLooks' do
    pod 'BButton', '~> 4.0'
    pod 'FirebaseAnalytics'
    pod 'FirebaseCrashlytics'
    pod 'DAProgressOverlayLayeredView', '~> 1.2'
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end

