//
//  FOGJPEGImageMarker.swift
//  FOGMJPEGImageView-Swift
//
//  Created by Xiao Xiao on 平成29-03-12.
//  Copyright © 平成29年 Xiao Xiao. All rights reserved.
//

import Foundation
class FOGJPEGImageMarker: NSObject {
    /**
     `NSData` representation of the bytes that denote the start of JPEG encoded image.
     */
    static var startMarker:Data? {
        let bytes: [UInt8] = [0xff, 0xd8]
        return Data(bytes: bytes)
    }
    
    static var endMarker:Data? {
        let bytes: [UInt8] = [0xff, 0xd9]
        return Data(bytes: bytes)
    }
    class func jpegStart() -> Data {
        return startMarker!
    }
    /**
     `NSData` representation of the bytes that denote the end of a JPEG encoded image.
     */
    
    class func jpegEnd() -> Data {
        return endMarker!
    }
}
