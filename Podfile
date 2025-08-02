# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Margo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Margo

 
  pod 'KeychainSwift'
  pod 'JGProgressHUD'
  pod 'KSToastView', '0.5.7'
  pod 'TTGSnackbar'
  pod 'SideMenu'
  pod 'CHIPageControl/Aleppo'
  pod 'FSCalendar'
  pod 'MSPeekCollectionViewDelegateImplementation'
  pod 'SVProgressHUD'
  pod 'GDCheckbox'
  pod "Koloda"
  pod 'SDWebImage'
  pod 'CountryPickerView'
  pod 'AlamofireSwiftyJSON'
  pod 'MessageKit'
  pod 'TagListView'
  pod 'MercariQRScanner'
  pod 'iOSDropDown'
  pod 'ImageSlideshow/Alamofire'
  pod 'MarqueeLabel'
  pod 'IQKeyboardManagerSwift'
  pod 'JGProgressHUD'
  pod 'CollectionViewPagingLayout'
  pod 'CollectionViewSlantedLayout', '~> 3.1'

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
end
