#
# Be sure to run `pod lib lint AMKRouter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'AMKRouter'
    s.version          = '0.1.0'
    s.summary          = 'A short description of AMKRouter.'
    s.description      =  <<-DESC
                            A pod of AMKRouter.
                          DESC
    s.homepage         = 'https://github.com/AndyM129/AMKRouter'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Andy__M' => 'andy_m129@163.com' }
    s.source           = { :git => 'https://github.com/AndyM129/AMKRouter.git', :tag => s.version.to_s }
    s.ios.deployment_target = '8.0'
    s.source_files = [
        'AMKRouter/Classes/*.{h,m}',
    ]
    s.public_header_files = [
        'AMKRouter/Classes/AMKRouter.h'
    ]
    s.dependency 'AMKDispatcher'
end

