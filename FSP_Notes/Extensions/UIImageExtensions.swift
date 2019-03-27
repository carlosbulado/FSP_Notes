import Foundation
import Accelerate
import UIKit

extension UIImage
{
    func resizeImageUsingVImage(size : CGSize) -> UIImage?
    {
        let cgImage = self.cgImage!
        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue), version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
        var sourceBuffer = vImage_Buffer()
        defer {
            free(sourceBuffer.data)
        }
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        // create a destination buffer
        let scale = self.scale
        let destWidth = Int(size.width)
        let destHeight = Int(size.height)
        let bytesPerPixel = self.cgImage!.bitsPerPixel/8
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        defer {
            //destData.deallocate(capacity: destHeight * destBytesPerRow)
            destData.deallocate()
        }
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        // scale the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }
        // create a CGImage from vImage_Buffer
        var destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
        guard error == kvImageNoError else { return nil }
        // create a UIImage
        let resizedImage = destCGImage.flatMap { UIImage(cgImage: $0, scale: 0.0, orientation: self.imageOrientation) }
        destCGImage = nil
        return resizedImage
    }
    
    func resizeImageBy(width : Double, height : Double) -> UIImage?
    {
        return self.resizeImageUsingVImage(size: CGSize(width: width, height: height))
    }
    
    func saveImage() -> String
    {
        let uuid = UUID().uuidString
        var url : String?
        url = ""
        url = APP.fileManagerUrls.first?.appendingPathComponent("\(APP.APP_FOLDER)/\(APP.APP_IMAGES_FOLDER)/\(uuid).png").path
        APP.fileManager.createFile(atPath: url!, contents: self.pngData(), attributes: nil)
        return uuid
    }
    
    func saveImage(noteId : String) -> String?
    {
        let uuid = UUID().uuidString
        APP.createNoteDirectory(noteId: noteId)
        let url = APP.fileManagerUrls.first?.appendingPathComponent("\(APP.APP_FOLDER)/\(APP.APP_NOTES_INFO_FOLDER)/\(noteId)/\(uuid).png").path
        APP.fileManager.createFile(atPath: url!, contents: self.pngData(), attributes: nil)
        return "\(noteId)/\(uuid).png"
    }
    
    static func loadImageFrom(path: String) -> UIImage?
    {
        let imageUrl = APP.fileManagerUrls.first?.appendingPathComponent("\(APP.APP_FOLDER)/\(APP.APP_NOTES_INFO_FOLDER)/\(path)")
        if APP.fileManager.fileExists(atPath: imageUrl!.path),
            let imageData: Data = try? Data(contentsOf: imageUrl!),
            let image: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale) {
            return image
        } else {
            return nil
        }
    }
    
    func resizeImage(scale: CGFloat) -> UIImage
    {
        let newSize = CGSize(width: self.size.width*scale, height: self.size.height*scale)
        let rect = CGRect(origin: CGPoint.zero, size: newSize)
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
