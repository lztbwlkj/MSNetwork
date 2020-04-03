

Pod::Spec.new do |spec|

# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  These will help people to find your library, and whilst it
#  can feel like a chore to fill in it's definitely to your advantage. The
#  summary should be tweet-length, and the description more in depth.
#

spec.name         = "MSNetwork"
spec.version      = "0.0.4"
spec.summary      = "Based on the secondary encapsulation of AFNetworking 4.x and YYCache,you can choose a variety of caching strategies."
spec.description  = <<-DESC
                 基于AFNetworking 4.x与YYCache的二次封装,包括网络请求、文件上传、文件下载这三个方法。并且支持RESTful API,GET、POST、HEAD、PUT、DELETE、PATCH的请求,方法接口简洁明了,并结合YYCache做了网络数据的缓存策略。简单易用,一句代码搞定网络数据的请求与缓存,控制台可直接打印json中文字符,调试更方便
DESC

spec.homepage     = "https://github.com/lztbwlkj/MSNetwork"
spec.license          = { :type => 'MIT', :file => 'LICENSE' }
spec.author             = { "lztbwlkj" => "lztbwlkj@gmail.com" }
spec.platform     = :ios,"9.0"
spec.source       = { :git => "https://github.com/lztbwlkj/MSNetwork.git", :tag => "#{spec.version}" }
spec.source_files  = "MSNetwork/*.{h,m}"
spec.requires_arc = true
spec.dependency 'AFNetworking'
spec.dependency 'YYCache'

end