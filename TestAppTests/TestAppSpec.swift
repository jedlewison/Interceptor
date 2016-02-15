import Quick
import Nimble
@testable import TestApp
import Interceptor

let nordstromURL = NSURL(string: "https://www.nordstrom.com")!
let uberURL = NSURL(string: "https://www.uber.com")!
let bestBuyURL = NSURL(string: "https://www.bestbuy.com")!

extension TestAppSpec: InterceptorResponding {
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

class TestAppSpec: QuickSpec {
    override func spec() {
        var networkModel = SillyNetworkModel()

        context("NSURLSession") {
            beforeEach {
                InterceptorSession.sharedInstance.active = true
                InterceptorSession.sharedInstance.dataSource = self
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

        context("Alamofire") {
            beforeEach {
                networkModel = SillyNetworkModel()
                networkModel.startAlamofire(bestBuyURL)
            }

            it("should eventually get some data") {
                expect(networkModel.requestResult).toEventuallyNot(beNil())
            }

            it("the contents of the data should be the string 'best buy response'") {
                expect(networkModel.requestResult).toEventually(equal("best buy response"))
            }

        }

        context("NSURLSession") {
            beforeEach {
                networkModel = SillyNetworkModel()
                networkModel.startURLRequest(uberURL)
            }

            it("should eventually get some data") {
                expect(networkModel.requestResult).toEventuallyNot(beNil())
            }

            it("the contents of the data should be the string 'uber response'") {
                expect(networkModel.requestResult).toEventually(equal("uber response"))
            }
        }
    }
}
