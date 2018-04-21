# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'


workspace 'ObjectiveCAppCollection'
target 'ObjectiveCAppCollection' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for ObjectiveCAppCollection
  pod 'FJCommon', :git => 'https://github.com/WalterCreazyBear/FJCommon.git'



  target 'ObjectiveCAppCollectionTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ObjectiveCAppCollectionUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end


target 'FJCommon' do
    project "./FJRepoTarget/FJCommon/FJCommon.xcodeproj"
end