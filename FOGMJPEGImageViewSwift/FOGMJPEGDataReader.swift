//
//  FOGMJPEGDataReader.swift
//  FOGMJPEGImageView-Swift
//
//  Created by Xiao Xiao on 平成29-03-12.
//  Copyright © 平成29年 Xiao Xiao. All rights reserved.
//

import UIKit

//  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
protocol FOGMJPEGDataReaderDelegate: class {
    /**
     Tells the delegate that the data reader received an image, this method is invoked on the main thread.
     */
    func fogmjpegDataReader(_ reader: FOGMJPEGDataReader, receivedImage image: UIImage)
    /**
     Tells the delegate that the data reader failed loading an image, this method is invoked on the main thread.
     */
    
    func fogmjpegDataReader(_ reader: FOGMJPEGDataReader, loadingImageDidFailWithError error: Error?)
}

//  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
class FOGMJPEGDataReader: NSObject, URLSessionDataDelegate {
    
    var processingQueue: OperationQueue!
    var dataTask: URLSessionDataTask!
    var receivedData: Data!
    /**
     The URL session used by the data reader to fetch and receive the MJPEG data.
     */
    private(set) var urlSession: URLSession!
    /**
     The object that acts as the delegate of the receiving `FOGMJPEGDataReader`.
     */
    weak var delegate: FOGMJPEGDataReaderDelegate?
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        self.processingQueue = OperationQueue()
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: self.processingQueue)
    }
    
    //  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
    /**
     Begins reading MJPEG data from the given URL.
     
     @param URL The URL to make a request for MJPEG data.
     */
    func startReading(from URL: URL) {
        self.receivedData = Data()
        let request = URLRequest(url: URL)
        self.dataTask = self.urlSession.dataTask(with: request)
        self.dataTask.resume()
    }
    
    /**
     Stops reading MJPEG data.
     */
    func stop() {
        self.dataTask.cancel()
        self.dataTask = nil
    }
    
    @objc(URLSession:dataTask:didReceiveData:) func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let lockQueue = DispatchQueue(label: "self.receivedData")
        lockQueue.sync {
            self.receivedData.append(data)
            // if we don't have an end marker then we can continue
            let endMarkerRange = self.receivedData.range(of: FOGJPEGImageMarker.jpegEnd(), options: Data.SearchOptions(rawValue: 0), in: Range(uncheckedBounds: (lower: 0, upper: self.receivedData.count)))
            if endMarkerRange == nil {
                return
            }
            // if we don't have a start marker prior to the end marker discard bytes and continue
            let startMarkerRange = self.receivedData.range(of: FOGJPEGImageMarker.jpegStart(), options: Data.SearchOptions(rawValue: 0), in: endMarkerRange)
            if startMarkerRange == nil {
                // todo: should trim receivedData to endMarkerRange.location + 2 until end
                return
            }
            let imageDataLength: Int = ((endMarkerRange?.count)! + 2) - (startMarkerRange?.count)!
            let imageDataRange = Range(uncheckedBounds: (lower: (startMarkerRange?.count)!, upper: (startMarkerRange?.count)! + imageDataLength)) //NSRange(location: (startMarkerRange?.count)!, length: imageDataLength)
            let imageData = self.receivedData.subdata(in: imageDataRange)
            let image = UIImage(data: imageData, scale: 0.5)
            if image != nil {
                DispatchQueue.main.async(execute: {() -> Void in
                    let strongDelegate: FOGMJPEGDataReaderDelegate = self.delegate!
                    strongDelegate.fogmjpegDataReader(self, receivedImage: image!)
                })
            }
            let newStartLocation: Int = (endMarkerRange?.count)! + 2
            let newDataLength: Int = self.receivedData.count - newStartLocation
            let unusedData = self.receivedData.subdata(in: Range(uncheckedBounds: (lower: newStartLocation, upper: newStartLocation + newDataLength))) //NSRange(location: newStartLocation, length: newDataLength))
            self.receivedData = Data(unusedData)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let code = (error as! URLError).code
        if code == URLError.cancelled {
            // Manually cancelled request
            return
        }
        DispatchQueue.main.async(execute: {() -> Void in
            let strongDelegate: FOGMJPEGDataReaderDelegate = self.delegate!
            strongDelegate.fogmjpegDataReader(self, loadingImageDidFailWithError: error)
        })
    }
    
    func urlSession(_ session: URLSession,
                         task: URLSessionTask,
                         didReceive challenge: URLAuthenticationChallenge,
                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //Creates credentials for logged in user (username/pass)
        let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, cred)
    }
}
