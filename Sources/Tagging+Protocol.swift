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
    func userDidStartTyping(tagableString isTagable: Bool)
    func userDidType(tagableString TagText: String?, withRangeOf range: NSRange?)
}

public protocol TaggingDataSource: class {
    func tagging(_ tagging: Tagging, didChangedTagableList tagableList: [String])
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel])
}
