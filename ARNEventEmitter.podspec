Pod::Spec.new do |s|
  s.name         = "ARNEventEmitter"
  s.version      = "0.1.0"
  s.summary      = "It was inspired by Node.js EventEmitter."
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     = "https://github.com/xxxAIRINxxx/ARNEventEmitter"
  s.author       = { "Airin" => "xl1138@gmail.com" }
  s.source       = { :git => "https://github.com/xxxAIRINxxx/ARNEventEmitter.git", :tag => "#{s.version}" }
  s.platform     = :ios, '5.0'
  s.requires_arc = true
  s.source_files = 'ARNEventEmitter/*.{h,m}'
end
