//
//  FOGMJPEGImageView.swift
//  FOGMJPEGImageView-Swift
//
//  Created by Xiao Xiao on 平成29-03-12.
//  Copyright © 平成29年 Xiao Xiao. All rights reserved.
//

import UIKit

protocol FOGMJPEGImageViewDelegate: NSObjectProtocol {
    /**
     Tells the delegate that the mjpeg image view received an image, this method is invoked on the main thread.
     */
    func fogmjpegImageViewDidReceiveImage(_ mjpegImageView: FOGMJPEGImageView)
    /**
     Tells the delegate that the mjpeg image view failed loading the stream, this method is invoked on the main thread.
     */
    
    func fogmjpegImageView(_ mjpegImageView: FOGMJPEGImageView, loadingImageDidFailWithError error: Error?)
}

class FOGMJPEGImageView: UIImageView, URLSessionDataDelegate, FOGMJPEGDataReaderDelegate {
    var urlSession: URLSession {
        return self.dataReader.urlSession
    }
    weak var delegate: FOGMJPEGImageViewDelegate?
    var dataReader: FOGMJPEGDataReader!
    var isReadingData: Bool = false
    // MARK: - Initializers
    
//    init() {
//        super.init()
//        self.dataReader = FOGMJPEGDataReader()
//        self.dataReader.delegate = self
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataReader = FOGMJPEGDataReader()
        self.dataReader.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.dataReader = FOGMJPEGDataReader()
        self.dataReader.delegate = self
    }
    
//    func urlSession() -> URLSession {
//        return self.dataReader.urlSession
//    }
    // MARK: - FOGMJPEGImageView
    
    func start(with url: URL?) {
        guard url != nil else{
            return
        }
        if self.isReadingData {
            return
        }
        self.isReadingData = true
        self.dataReader.startReading(from: url!)
    }
    
    func stop() {
        if !self.isReadingData {
            return
        }
        self.dataReader.stop()
        self.isReadingData = false
    }
    // MARK: - FOGMJPEGDataReaderDelegate
    
    func fogmjpegDataReader(_ reader: FOGMJPEGDataReader, receivedImage image: UIImage) {
        self.image = image
        if (self.delegate?.responds(to: Selector(("fogmjpegImageViewDidReceiveImage"))))! {
            self.delegate?.fogmjpegImageViewDidReceiveImage(self)
        }
    }
    
    func fogmjpegDataReader(_ reader: FOGMJPEGDataReader, loadingImageDidFailWithError error: Error?) {
        if (self.delegate?.responds(to: Selector(("FOGMJPEGImageView:loadingImgaeDidFailWithError:"))))! {
            self.delegate?.fogmjpegImageView(self, loadingImageDidFailWithError: error)
        }
    }
}
