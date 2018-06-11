Pod::Spec.new do |s|
    s.name             = 'Anna'
    s.version          = '0.3.0'
    s.summary          = 'Separate the analytics from your main business logic.'
    s.description      = <<-DESC
  Anna is an analytics abstraction library which helps separate the analyzing part of code from the main business logic. Although inspired by AOP, Anna doesn't require method-swizzling, which consumes considerable runtime. Instead, it needs a tiny piece of code to be inserted into the analyzed method. And then all the magic starts.
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

