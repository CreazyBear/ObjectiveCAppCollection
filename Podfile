# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
$repos = ENV["HOME"]+'/.cocoapods/repos/'


workspace 'ObjectiveCAppCollection'
target 'ObjectiveCAppCollection' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for ObjectiveCAppCollection
  pod 'FJCommon', :path=>"#{$repos}FJCommon"



  target 'ObjectiveCAppCollectionTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ObjectiveCAppCollectionUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end


target 'FJCommonProject' do
    project "#{$repos}FJCommon/FJCommonProject/FJCommonProject.xcodeproj"
end

target 'FJMapDemo' do
    project "./FJProjects/FJMapDemo/FJMapDemo.xcodeproj"
end

target 'ReactiveObjeCDemo' do
    project "./FJProjects/ReactiveObjeCDemo/ReactiveObjeCDemo.xcodeproj"
    pod "ReactiveObjC"
end

target 'FJQRScan' do
    project "./FJProjects/FJQRScan/FJQRScan.xcodeproj"
end



target 'Habit' do
    project "./FJProjects/Habit/Habit.xcodeproj"
    pod 'FSCalendar'
    pod 'TSMessages'
    pod 'YYText'
    pod 'TZImagePickerController'
    pod 'MWPhotoBrowser'
    pod 'YYModel'
    pod 'FJCommon', :path=>"#{$repos}FJCommon"
end
