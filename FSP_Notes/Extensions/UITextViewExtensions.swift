import Foundation
import UIKit

extension UITextView
{
    func getText(for noteId : String) -> String
    {
        return self.attributedText.replaceImagesWithTags(for: noteId)
    }
    
    func setText(text : String)
    {
        
    }
}
