
Pod::Spec.new do |s|

    s.name         = "SSHttpNetHelper"
    s.version      = "0.0.1"
    s.summary      = "OC网络请求工具类,基于AFNetworking3.0封装!"
    s.homepage     = "https://github.com/shusheng732/SSHttpNetHelper"
    s.license      = "MIT"
    s.author       = { "Vimin" => "shusheng732@163.com" }
    s.platform     = :ios, "8.0"
    s.source       = { :git => "https://github.com/shusheng732/SSHttpNetHelper.git", :tag => s.version }
    s.source_files = "SSHttpNetHelper", "SSHttpNetHelper/*.{h,m}"
    s.requires_arc = true
    s.dependency "AFNetworking", "~> 3.1.0"

end
