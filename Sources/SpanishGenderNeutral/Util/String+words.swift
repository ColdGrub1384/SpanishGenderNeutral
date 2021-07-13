import Foundation

extension String {
    
    var words: [String] {
        return components(separatedBy: " ")
    }
}
