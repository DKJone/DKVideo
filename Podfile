# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'

target 'DKVideo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DKVideo
  # UI
  pod 'NVActivityIndicatorView'
  pod 'SuperPlayer'
  pod 'SnapKit'
  pod 'IQKeyboardManagerSwift'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/luckychris/Chameleon'
  pod 'Toast-Swift'
  pod 'XLPagerTabStrip'
  pod 'KafkaRefresh'
  pod 'DZNEmptyDataSet'
  pod 'Aspects'
  pod 'FloatingPanel'
# Debug
  pod 'FLEX', :configurations => ['Debug']

  # Tools
   pod 'R.swift'
   pod 'SwifterSwift'
   pod "GCDWebServer/WebDAV"
   pod 'SwiftyJSON'
   pod 'AttributedLib'
   pod 'HandyJSON'
   pod 'Tiercel'
  # RX
    pod 'RxSwiftExt'
    pod 'NSObject+Rx'
    pod 'RxViewController'
    pod 'RxGesture'
    pod 'RxOptional'
    pod 'RxDataSources'
    pod 'RxTheme'
    pod 'RxSwift' , '~> 5.0.0'

end

# Cocoapods optimization, always clean project after pod updating
post_install do |installer|
    Dir.glob(installer.sandbox.target_support_files_root + "Pods-*/*.sh").each do |script|
        flag_name = File.basename(script, ".sh") + "-Installation-Flag"
        folder = "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
        file = File.join(folder, flag_name)
        content = File.read(script)
        content.gsub!(/set -e/, "set -e\nKG_FILE=\"#{file}\"\nif [ -f \"$KG_FILE\" ]; then exit 0; fi\nmkdir -p \"#{folder}\"\ntouch \"$KG_FILE\"")
        File.write(script, content)
    end
    
    # enable tracing resources
    installer.pods_project.targets.each do |target|
      if target.name == 'RxSwift'
        target.build_configurations.each do |config|
          if config.name == 'Debug'
            config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
          end
        end
      end

      if target.name == "CocoaHTTPServer"
        target.build_configurations.each do |config|
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DD_LEGACY_MACROS=1']
        end
      end
    end
end


