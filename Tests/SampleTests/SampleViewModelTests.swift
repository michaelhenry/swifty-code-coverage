import XCTest
@testable import Sample

final class SampleTests: XCTestCase {
    
    func testSum() throws {
        let sampleViewModel = SampleViewModel()
        XCTAssertEqual(sampleViewModel.sum(integers: 0,1,2,3,4,5,6,7,8,9,10), 55)
    }
}
