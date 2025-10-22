Pod::Spec.new do |s|
  s.name         = "react-native-trubka-contacts"
  s.version      = "0.1.0"
  s.summary      = "Contacts normalization via legacy NativeModules"
  s.homepage     = "https://github.com/p7161/react-native-trubka-contacts"
  s.license      = { :type => "MIT" }
  s.author       = { "Trubka" => "dev@trubka.app" }
  s.source       = { :path => "." }

  s.platform     = :ios, "13.0"
  s.requires_arc = true
  s.swift_version = "5.7"

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.dependency "React-Core"
  s.dependency "PhoneNumberKit", "~> 4.0"
end
