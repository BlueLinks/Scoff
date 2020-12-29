# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# add pods for desired Firebase products
# https://firebase.google.com/docs/ios/setup#available-pods

target 'Scoff' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Scoff

  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Storage'
  pod 'URLImage'
  pod 'Stripe'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end


end
