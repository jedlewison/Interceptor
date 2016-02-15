Pod::Spec.new do |s|
    s.name             = "Interceptor"
    s.version          = "0.0.1"
    s.summary          = "Intercept NSURLSessionDataTask requests and respond with mock data"
    s.description      = "A mini-framework mocking network responses without changing any code inside the app being tested."
    s.author           = "Jed Lewison"
    s.homepage         = "https://github.com/jedlewison/Interceptor"
    s.license          = 'MIT'
    s.source           = { :git => "https://github.com/jedlewison/Interceptor.git", :tag => s.version.to_s }
    s.platform         = :ios, '8.0'
    s.requires_arc     = true
    s.source_files     = "Interceptor/*"
end
