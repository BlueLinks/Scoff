# add pods for desired Firebase products
# https://firebase.google.com/docs/ios/setup#available-pods

target 'Scoff' do
  use_frameworks!

  # Pods for Scoff

  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'URLImage'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end


end
