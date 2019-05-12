
platform :ios, '7.0'
#use_frameworks!
inhibit_all_warnings!

def news_pods

    pod 'TMCache'
    pod 'YYText'
    pod 'JRSwizzle'
    pod 'CocoaAsyncSocket'
    ##    pod 'JsKitFramework', :git => 'ssh://git@10.0.68.202/home/git/JsKitFramework_iOS_podspec.git', :tag => '1.1.4'
    
    pod 'Weibo_SDK'
    pod 'VZInspector', :configurations => ['Debug','InHouse-Debug','AdHoc-Release','InHouse-Release']
    pod 'FMDB'
#    pod 'JSPatchPlatform'
#    pod 'Aspects'

end

def shared_pods
    pod 'AFNetworking','~> 2.5.4'
    pod 'SDWebImage', '~> 3.8.2'
    pod 'SDWebImage/WebP'
end

target 'sohunews' do
    shared_pods
    news_pods
    project 'sohunews'
end

target 'SohuNewsTodayNews' do
    shared_pods
end

target :JsKitFramework do
    
    xcodeproj 'JsKitFramework/JsKitFramework.xcodeproj'
    shared_pods
    
end

##
#   解决AFNetworking在Extension中的使用问题
#
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        puts "=== #{target.name}"
        if target.name == "AFNetworking"
            puts "Setting AFNetworking Macro AF_APP_EXTENSIONS so that it doesn't use UIApplication in extension."
            target.build_configurations.each do |config|
                puts "Setting AF_APP_EXTENSIONS macro in config: #{config}"
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'AF_APP_EXTENSIONS=1']
            end
        end
    end
end

##
#sdk's version

#Downloading dependencies
#Using AFNetworking (2.5.4)
#Using CocoaAsyncSocket (7.5.1) -> (7.6.0)
#Using FMDB (2.6.2)
#Using JRSwizzle (1.0)
#Using JsKitFramework (1.1.2) ->(1.1.4)
#Using SDWebImage (3.8.2)
#Using TMCache (2.1.0)
#Using WeiboSDK (3.1.3)
#Using WeixinSDK (1.4.3)
#Using YYText (1.0.7)
#Using libwebp (0.5.1)
#Using JSPatchPlatform (1.6.3) ->(1.6.6)
#Generating Pods project
