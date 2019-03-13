import UIKit
import Foundation

open class Tagging: UIView {
    
    // MARK: - Apperance
    
    open var cornerRadius: CGFloat {
        get { return textView.layer.cornerRadius }
        set { textView.layer.cornerRadius = newValue }
    }
    open var borderWidth: CGFloat {
        get { return textView.layer.borderWidth }
        set { textView.layer.borderWidth = newValue }
    }
    open var borderColor: CGColor? {
        get { return textView.layer.borderColor }
        set { textView.layer.borderColor = newValue }
    }
    open var textInset: UIEdgeInsets {
        get { return textView.textContainerInset }
        set { textView.textContainerInset = newValue }
    }
    override open var backgroundColor: UIColor? {
        get { return textView.backgroundColor }
        set { textView.backgroundColor = newValue }
    }
    
    // MARK: - Properties
    
    open var symbols: [String] = ["@", "#"]
    /// Current tag symbol
    open var currentTagSymbol: String = ""
    open var tagableList: [String]?
    
    public private(set) var taggedList: [TaggingModel] = []
    public weak var dataSource: TaggingDataSource?
    public weak var delegate: TaggingProtocol?
    
    private var currentTaggingText: String? {
        didSet {
            guard let currentTaggingText = currentTaggingText, let tagableList = tagableList else {return}
            let matchedTagableList = tagableList.filter {
                $0.contains(currentTaggingText.lowercased()) || $0.contains(currentTaggingText.uppercased())
            }
            dataSource?.tagging(self, didChangedTagableList: matchedTagableList)
        }
    }
    private var currentTaggingRange: NSRange?
    
    // This Regex will search for string which contain "a to z, A to Z, 0 to 9, and _" that start with one of "symbols"
    private lazy var tagRegex: NSRegularExpression! = {
        let symobols: String = {
            var temp: String = ""
            for s in self.symbols {
                temp.append(s.first!)
            }
            return temp
        }()
        return try! NSRegularExpression(pattern: "[\(symobols)][a-zA-Z0-9_]+")
    }()
    
    // MARK: - UI Components
    
    public let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Con(De)structor
    
    public init() {
        super.init(frame: .zero)
        commonSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    // MARK: - Public methods
    
    public func updateTaggedList(allText: String, tagText: String) {
        guard let range = currentTaggingRange else {return}
        
        let origin = (allText as NSString).substring(with: range)
        let tag = tagFormat(tagText)
        let replace = tag.appending(" ")
        let changed = (allText as NSString).replacingCharacters(in: range, with: replace)
        let tagRange = NSMakeRange(range.location, tag.utf16.count)
        
        taggedList.append(TaggingModel(text: tagText, range: tagRange))
        for i in 0..<taggedList.count-1 {
            var location = taggedList[i].range.location
            let length = taggedList[i].range.length
            if location > tagRange.location {
                location += replace.count - origin.count
                taggedList[i].range = NSMakeRange(location, length)
            }
        }
        
        textView.text = changed
        //        updateAttributeText(selectedLocation: range.location+replace.count)
        dataSource?.tagging(self, didChangedTaggedList: taggedList)
    }
    
    // MARK: - Private methods
    
    private func commonSetup() {
        setProperties()
        addSubview(textView)
        layout()
    }
    
    private func setProperties() {
        backgroundColor = .clear
        textView.delegate = self
    }
    
    private func tagFormat(_ text: String) -> String {
        //        return symbol.appending(text)
        #warning("symbol change")
        return currentTagSymbol.appending(text)
    }
    
}

// MARK: - Layout

extension Tagging {
    
    private func layout() {
        addConstraints(
            [NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)])
    }
    
}



// MARK: - Tagging Algorithm

extension Tagging {
    
    /// check if the current text is equal to one of the symbols
    func oneOfSymbolIs(text: String) -> Bool {
        for s in symbols {
            if s == text {
                return true
            }
        }
        return false
    }
    
    /// check if the current char is equal to one of the symbols
    func oneOfSymbolIs(char: Character) -> Bool {
        for s in symbols {
            if s.first == char {
                return true
            }
        }
        return false
    }
    
    
    private func matchedData(taggingCharacters: [Character], selectedLocation: Int, taggingText: String) -> (NSRange?, String?) {
        var matchedRange: NSRange?
        var matchedString: String?
        let tag = String(taggingCharacters.reversed())
        let textRange = NSMakeRange(selectedLocation-tag.count, tag.count)
        
        guard oneOfSymbolIs(text: tag) else {
            let matched = tagRegex.matches(in: taggingText, options: .reportCompletion, range: textRange)
            if matched.count > 0, let range = matched.last?.range {
                matchedRange = range
                matchedString = (taggingText as NSString).substring(with: range).replacingOccurrences(of: currentTagSymbol, with: "")
            }
            return (matchedRange, matchedString)
        }
        
        matchedRange = textRange
        
        matchedString = tag
        return (matchedRange, matchedString)
    }
    
    private func tagging(textView: UITextView) {
        let selectedLocation = textView.selectedRange.location
        let taggingText = (textView.text as NSString).substring(with: NSMakeRange(0, selectedLocation))
        let space: Character = " "
        let lineBrak: Character = "\n"
        var tagable: Bool = false
        var characters: [Character] = []
        
        for char in Array(taggingText).reversed() {
            if oneOfSymbolIs(char: char){
                characters.append(char)
                tagable = true
                currentTagSymbol = "\(char)"
                print("Current Symbol: ", currentTagSymbol)
                delegate?.userDidStartTyping(tagableString: true, withTagSymbol: currentTagSymbol, TextView: textView)
                break
            } else if char == space || char == lineBrak {
                tagable = false
                currentTagSymbol = ""
                delegate?.userDidStartTyping(tagableString: false, withTagSymbol: currentTagSymbol, TextView: textView)
                break
            }
            characters.append(char)
        }
        
        guard tagable else {
            currentTaggingRange = nil
            currentTaggingText = nil
            return
        }
        
        let data = matchedData(taggingCharacters: characters, selectedLocation: selectedLocation, taggingText: taggingText)
        currentTaggingRange = data.0
        currentTaggingText = data.1
        
        delegate?.userDidType(tagableString: currentTaggingText, withRangeOf: currentTaggingRange)
    }
    
    
    private func updateTaggedList(range: NSRange, textCount: Int) {
        taggedList = taggedList.filter({ (model) -> Bool in
            if model.range.location < range.location && range.location < model.range.location+model.range.length {
                return false
            }
            if range.length > 0 {
                if range.location <= model.range.location && model.range.location < range.location+range.length {
                    return false
                }
            }
            return true
        })
        
        for i in 0..<taggedList.count {
            var location = taggedList[i].range.location
            let length = taggedList[i].range.length
            if location >= range.location {
                if range.length > 0 {
                    if textCount > 1 {
                        location += textCount - range.length
                    } else {
                        location -= range.length
                    }
                } else {
                    location += textCount
                }
                taggedList[i].range = NSMakeRange(location, length)
            }
        }
        
        currentTaggingText = nil
        dataSource?.tagging(self, didChangedTaggedList: taggedList)
    }
    
}


// MARK: - UITextViewDelegate

extension Tagging: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        tagging(textView: textView)
        delegate?.tagingTextViewDidChange(textView)
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        tagging(textView: textView)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("replacementText: ", text)
        print("range: ", range)
        updateTaggedList(range: range, textCount: text.utf16.count)
        delegate?.taggingDidUpdateFromList(textView)
        return true
    }
    
}
