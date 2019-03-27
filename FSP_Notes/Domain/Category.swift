import Foundation

public class Category : NSObject, NSCoding, NSCopying
{
    var id = ""
    var text = ""
    var created = Date()
    var updated = Date()
    
    private static let idKey = "idKey"
    private static let textKey = "textKey"
    private static let createdKey = "createdKey"
    private static let updatedKey = "updatedKey"
    
    
    public func encode(with aCoder: NSCoder)
    {
        aCoder.encode(text, forKey: Category.textKey)
        aCoder.encode(id, forKey: Category.idKey)
        aCoder.encode(created, forKey: Category.createdKey)
        aCoder.encode(updated, forKey: Category.updatedKey)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        text = aDecoder.decodeObject(forKey: Category.textKey) as! String
        id = aDecoder.decodeObject(forKey: Category.idKey) as! String
        created = (aDecoder.decodeObject(forKey: Category.createdKey) as? Date)!
        updated = (aDecoder.decodeObject(forKey: Category.updatedKey) as? Date)!
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = Category()
        copy.id = id
        copy.text = text
        copy.created = created
        copy.updated = updated
        return copy
    }
    
    override init() { }
}
