//
//  IRCMessage.swift
//  Kathy
//
//  Created by Michael Bujol on 6/13/16.
//  Copyright © 2016 heptal. All rights reserved.
//

import Foundation

struct IRCMessage: CustomStringConvertible {
    let prefix: IRCMessagePrefix?
    let command: String
    let params: String?
    let raw: String!

    var data: NSData! {
        return raw.dataUsingEncoding(NSUTF8StringEncoding)
    }

    init(data: NSData) {
        raw = String(data: data, encoding: NSUTF8StringEncoding)
        var message = raw.stringByReplacingOccurrencesOfString("\r\n", withString: "", options: [.AnchoredSearch, .BackwardsSearch], range: nil)

        let prefixEnd = message.characters.indexOf(" ")
        var messagePrefix: IRCMessagePrefix?
        if message.hasPrefix(":") && prefixEnd != nil {
            messagePrefix = IRCMessagePrefix(prefix: message.substringToIndex(prefixEnd!))
            message = message.substringFromIndex(prefixEnd!.successor())
        }

        if let index = message.characters.indexOf(" ") {
            command = message.substringToIndex(index)
            params = message.substringFromIndex(index.successor())
        } else {
            command = message
            params = nil
        }

        prefix = command != "MODE" ? messagePrefix : nil
    }

    init(command cmd: String, params parameters: String?) {
        command = cmd.uppercaseString
        params = parameters
        prefix = nil
        raw = command + (params != nil ? " \(params!)" : "") + "\r\n"
    }

    var description: String {
        return "\(raw)\nprefix:\(prefix ?? nil)\ncommand:\(command)\nparams:\(params ?? nil)"
    }
}

struct IRCMessagePrefix: CustomStringConvertible {
    let nick: String?
    let user: String?
    let host: NSURL!
    let raw: String!

    init?(prefix: String) {
        guard var index = prefix.characters.indexOf(":") else {
            return nil
        }

        if let nickEnd = prefix.characters.indexOf("!"), userEnd = prefix.characters.indexOf("@") {
            nick = prefix[index.successor()..<nickEnd]
            user = prefix[nickEnd.successor()..<userEnd]
            index = userEnd
        } else {
            nick = nil
            user = nil
        }

        host = NSURL(string: prefix.substringFromIndex(index.successor()))
        raw = prefix
    }

    var description: String {
        return "\(raw)\nhost:\(host)\nnick:\(nick ?? nil)\nuser:\(user ?? nil)"
    }
}

extension IRCMessage {

    func log() {
        let fm = NSFileManager.defaultManager()

        if let supportDir = try? fm.URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true) {
            let appSupportDir = supportDir.URLByAppendingPathComponent("/Kathy")
            if let appSupportDirPath = appSupportDir.path {
                if !fm.fileExistsAtPath(appSupportDirPath) {
                    let _ = try? fm.createDirectoryAtURL(appSupportDir, withIntermediateDirectories: true, attributes: nil)
                }

                let logFile = appSupportDirPath + "/log.txt"

                if !fm.fileExistsAtPath(logFile) {
                    fm.createFileAtPath(logFile, contents: nil, attributes: nil)
                }

                if let fh = NSFileHandle(forUpdatingAtPath: logFile) {
                    fh.seekToEndOfFile()
                    fh.writeData(self.data)
                    fh.closeFile()
                }
            }
        }
    }

}
