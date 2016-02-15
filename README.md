# Interceptor
Interceptor is mini-framework for mocking network responses by intercepting NSURLSessionDataTasks and responding with mock data. It lets you run unit tests with mock network responses without injecting mock services or changing any code in the host app.

## Usage:

1. Add Interceptor to your test target
2. Before each test case, set the InterceptorSession.sharedInstance.dataSource to an object that can respond with appriate mock responses.

For example, here's how you might set up a test using Quick & Nimble:

```swift
class TestAppSpec: QuickSpec {
    override func spec() {
        var networkModel = SillyNetworkModel()

        context("NSURLSession") {
            beforeEach {
                MockURLSession.sharedInstance.dataSource = self
                networkModel = SillyNetworkModel()
                networkModel.startURL(nordstromURL)
            }

            it("should eventually get some data") {
                expect(networkModel.requestResult).toEventuallyNot(beNil())
            }

            it("the contents of the data should be the string 'nordstrom response'") {
                expect(networkModel.requestResult).toEventually(equal("nordstrom response"))
            }
            
        }
```

And here's the dataSource implementation:

```swift
extension TestAppSpec: MockURLSessionResponding {

    func finalizeMockResponseValuesForRequest(initialValues: MockResponseValues) {
        switch initialValues.URL {
        case nordstromURL:
            initialValues.setData(withString: "nordstrom response")
        case uberURL:
            initialValues.setData(withString: "uber response")
        case bestBuyURL:
            initialValues.setData(withString: "best buy response")
        default:
            break
        }
    }

}
```

You set the mock response on the `MockResponseValues` object passed to the dataSource. It's initial values reflect the URL of the request and a 200 status code, but empty data. You can set data directly, as data, or by using one of its convenience functions.

After you set the response, it is delivered to the NSURLSessionDataTask as an NSHTTPURLResponse along with a NSData object. From the app's perspective, it was a real network request -- the only code changes required are in the test suite, no injection necessary.

## More

Interceptor works in both Swift and Objective-C. If for some reason you need to be able to perform real network requests during your tests (not a good idea!), you can turn the `InterceptorSession.sharedInstance.active` to false.

## Warning

Please make sure to never, ever add Interceptor to your app target. It works by swizzling NSURLSession and abusing the NSURLCache, which is fine for unit tests when you really don't want to be making actual network calls, but is an absolutely terrible idea for an actual app.