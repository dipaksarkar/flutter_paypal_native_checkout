#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_paypal_native_checkout.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_paypal_native_checkout'
  s.version          = '1.0.2'
  s.summary          = 'A Flutter plugin for native PayPal Checkout supporting both client-side and server-side capture workflows.'
  s.description      = <<-DESC
A Flutter plugin for native PayPal Checkout supporting both client-side and server-side capture workflows.
                       DESC
  s.homepage         = 'https://github.com/nitrofit28/flutter_paypal_native_checkout'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'NitroFit28' => 'support@nitrofit28.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'PayPalCheckout'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
