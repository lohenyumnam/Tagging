public protocol TaggingDataSource: class {
    func tagging(_ tagging: Tagging, didChangedTagableList tagableList: [String])
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel])
    func tagging(currentPossible TagText: String?, withRangeOf range: NSRange?)
}

public extension TaggingDataSource {
    func tagging(_ tagging: Tagging, didChangedTagableList tagableList: [String]) {return}
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel]) {return}
}
