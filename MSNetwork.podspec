
Pod::Spec.new do |s|
s.name = 'MSNetwork'
s.version = '0.0.1'
s.license = 'MIT'
s.summary = '基于AFNetworking 3.x与YYCache的二次封装,多种缓存策略任你选,麻麻再也不用担心我一句一句地写SQLite啦'
s.homepage = 'https://github.com/lztbwlkj/MSNetwork'
s.authors = { 'lztbwlkj' => 'lztbwlkj@gmail.com' }
spec.source       = { :git => "https://github.com/lztbwlkj/MSNetwork.git", :tag => "#{spec.version}" }
spec.platform     = :ios, "8.0"
s.source_files = 'MSNetwork/*.{h,m}'
spec.dependency "AFNetworking"
spec.dependency "YYCache"
s.requires_arc = true
end