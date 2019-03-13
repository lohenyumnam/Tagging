//
//  Tagging+Protocol.swift
//  Tagging
//
//  Created by Lohen Yumnam on 07/03/19.
//  Copyright © 2019 k-lpmg. All rights reserved.
//

import Foundation


public protocol TaggingProtocol: class {
    /// This method will call when user start typing will Bool giving status if the current text is tagable
    func userDidStartTyping(tagableString isTagable: Bool, withTagSymbol tagSymbol: String?,  TextView textView: UITextView)
    func userDidType(tagableString TagText: String?, withRangeOf range: NSRange?)
    //Will call when there is any changes in TextView
    func tagingTextViewDidChange(_ textView: UITextView)
    // Will Call when user replace text with the suggested Text
    func taggingDidUpdateFromList(_ textView: UITextView)
}

public protocol TaggingDataSource: class {
    func tagging(_ tagging: Tagging, didChangedTagableList tagableList: [String])
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel])
}
