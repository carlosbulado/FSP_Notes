import Foundation

public class Note : NSObject, NSCoding, NSCopying
{
    var id = ""
    var title = ""
    var text = ""
    var latitude = 0.0
    var longitude = 0.0
    var category = ""
    var categoryText = ""
    var created = Date()
    var updated = Date()
    
    private static let textKey = "textKey"
    private static let titleKey = "titleKey"
    private static let idKey = "idKey"
    private static let longitudeKey = "longitudeKey"
    private static let latitudeKey = "latitudeKey"
    private static let categoryKey = "categoryKey"
    private static let createdKey = "createdKey"
    private static let updatedKey = "updatedKey"
    private static let categoryTextKey = "categoryTextKey"
    
    
    public func encode(with aCoder: NSCoder)
    {
        aCoder.encode(title, forKey: Note.titleKey)
        aCoder.encode(text, forKey: Note.textKey)
        aCoder.encode(id, forKey: Note.idKey)
        aCoder.encode(longitude, forKey: Note.longitudeKey)
        aCoder.encode(latitude, forKey: Note.latitudeKey)
        aCoder.encode(category, forKey: Note.categoryKey)
        aCoder.encode(created, forKey: Note.createdKey)
        aCoder.encode(updated, forKey: Note.updatedKey)
        aCoder.encode(categoryText, forKey: Note.categoryTextKey)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        text = aDecoder.decodeObject(forKey: Note.textKey) as! String
        title = aDecoder.decodeObject(forKey: Note.titleKey) as! String
        id = aDecoder.decodeObject(forKey: Note.idKey) as! String
        latitude = aDecoder.decodeDouble(forKey: Note.latitudeKey)
        longitude = aDecoder.decodeDouble(forKey: Note.longitudeKey)
        category = aDecoder.decodeObject(forKey: Note.categoryKey) as! String
        created = (aDecoder.decodeObject(forKey: Note.createdKey) as? Date)!
        updated = (aDecoder.decodeObject(forKey: Note.updatedKey) as? Date)!
        categoryText = aDecoder.decodeObject(forKey: Note.categoryTextKey) as! String
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = Note()
        copy.id = id
        copy.text = text
        copy.longitude = longitude
        copy.latitude = latitude
        copy.category = category
        copy.created = created
        copy.updated = updated
        copy.categoryText = categoryText
        return copy
    }
    
    override init() { }
}
