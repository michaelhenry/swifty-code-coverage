import Foundation

struct SampleViewModel {

    func sum(integers: Int...) -> Int {
        integers.reduce(into: 0) {
            $0 += $1
        }
    }
}
