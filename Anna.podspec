Pod::Spec.new do |s|
    s.name             = 'Anna'
    s.version          = '0.3.1'
    s.swift_version    = '4.1'
    s.summary          = 'Separate the analytic code from other code.'
    s.description      = <<-DESC
Anna offers an abstraction layer which helps separate the analytic code from other code.
    DESC

    s.homepage         = 'https://github.com/coppercash/Anna'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'William' => 'coderdreamer@gmail.com' }
    s.source           = { :git => 'https://github.com/coppercash/Anna.git', :tag => s.version.to_s }
    s.ios.deployment_target = '8.0'
    s.source_files = 'Anna/**/*.{h,m,swift}', 'CoreJS/**/*.{swift}', 'Anna_iOS/Anna.h'
    s.public_header_files = 'Anna/**/*.h', 'Anna_iOS/Anna.h'
    s.static_framework = true
    s.user_target_xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }
    s.framework            = "JavaScriptCore"
    s.subspec 'core' do |cs|
        cs.resource_bundles = {
            'anna' => ['core/built/anna/*.js'],
        }
    end
    s.subspec 'corejs' do |js|
        js.resource_bundles = {
            'corejs' => ['CoreJS/built/core/*.js'],
        }
    end
end

