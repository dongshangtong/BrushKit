Pod::Spec.new do |spec|
  spec.name         = "BrushKit"
  spec.version      = "0.0.4"
  spec.summary      = "画笔BrushKit."
  spec.description  = <<-DESC
                     MetalKit 写的画笔
                   DESC

  spec.homepage     = "https://github.com/dongshangtong/BrushKit"


  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "dongshangtong" => "dongshangtong@gmail.com" }

  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"
  spec.swift_version = '5.0'


  spec.source       = { :git => "https://github.com/dongshangtong/BrushKit.git", :tag => "#{spec.version}" }
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
  spec.source_files  = "BrushKit/Classes/**/*"
  spec.requires_arc = true
  spec.resources = "BrushKit/Textures/*.png"
  # spec.dependency "Comet", "~> 1.6.2"

end
