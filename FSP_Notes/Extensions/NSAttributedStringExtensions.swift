import Foundation
import UIKit

extension NSAttributedString {
    
    var countOfImagesInAttachment: Int {
        var count = 0
        self.enumerateAttribute(.attachment , in: NSMakeRange(0, self.length), options: [], using: { attribute, range, _ in
            if let attachment = attribute as? NSTextAttachment,
                let _ = attachment.image {
                count += 1
            }
        })
        return count
    }
    
    func replaceImagesWithTags(for noteId: String) -> String {
        var mutableSelf = NSMutableAttributedString(attributedString: self)
        APP.clearFolderForNote(noteId: noteId)
        let countOfNSTextAttachment = self.countOfImagesInAttachment
        guard countOfNSTextAttachment > 0  else {
            return self.string
        }
        for _ in 1...countOfNSTextAttachment {
            var count = 0
            let attributedString = NSMutableAttributedString(attributedString: mutableSelf)
            attributedString.enumerateAttribute(.attachment, in : NSMakeRange(0, attributedString.length), options: [], using: {
                attribute, range, _ in
                if let attachment = attribute as? NSTextAttachment,
                    let image = attachment.image {
                    
                    if count == 0 {
                        guard let imageURL = image.saveImage(noteId: noteId) else {
                            return
                        }
                        let imageURLWrappedInTags = imageURL.inImgTag
                        attributedString.beginEditing()
                        attributedString.replaceCharacters(in: range, with: NSAttributedString(string : imageURLWrappedInTags))
                        attributedString.endEditing()
                        mutableSelf = attributedString
                    } else {
                        return
                    }
                    count = count + 1
                }
            })
        }
        return mutableSelf.string
    }
}
