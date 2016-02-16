import Devcheckouts

Devcheckouts.create {

    workspace("Interceptor")
    
    inhibitAllWarnings()

    source("https://github.com/CocoaPods/Specs.git")

    target("InterceptorTests", project: "Interceptor", platform: .IOS("8.0")) {
        pod(Cocoapods.Quick)
        pod(Cocoapods.Nimble)
    }

    target("TestApp", project: "Interceptor", platform: .IOS("8.0")) {
        pod(Cocoapods.Alamofire)
    }

    target("TestAppTests", project: "Interceptor", platform: .IOS("8.0")) {
        pod(Shared.Interceptor)
        pod(Cocoapods.Quick)
        pod(Cocoapods.Nimble)
    }

}
