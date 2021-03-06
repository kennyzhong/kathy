//
//  ChatTextView.swift
//  Kathy
//
//  Created by Michael Bujol on 6/13/16.
//  Copyright © 2016 heptal. All rights reserved.
//

import Cocoa

class ChatTextView: NSScrollView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        let textView = NSTextView()
        textView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        textView.identifier = "chatView"
        textView.editable = false
        textView.selectable = true
        textView.displaysLinkToolTips = true
        documentView = textView

        hasVerticalScroller = true
        autohidesScrollers = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
