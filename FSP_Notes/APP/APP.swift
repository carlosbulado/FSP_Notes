import Foundation
import CoreData

public class APP
{
    public static let fileManager = FileManager.default
    public static let fileManagerUrls = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
    
    public static let APP_FOLDER = "FSP_NOTES"
    public static let APP_IMAGES_FOLDER = "IMAGES"
    public static let APP_DATABASE_FOLDER = "DATABASE"
    public static let APP_NOTES_INFO_FOLDER = "NOTES"
    public static let APP_DATABASE_FILENAME = "FSP_NOTES_DATABASE.db"
    
    public class NOTE
    {
        public static let TABLENAME = "NOTE"
        public static let ID = "NOTE_ID"
        public static let TITLE = "NOTE_TITLE"
        public static let TEXT = "NOTE_TEXT"
        public static let LATITUDE = "NOTE_LATITUDE"
        public static let LONGITUDE = "NOTE_LONGITUDE"
        public static let CATEGORY = "NOTE_CATEGORY"
        public static let CREATEDDATE = "NOTE_CREATED_DATE"
        public static let UPDATEDATE = "NOTE_UPDATED_DATE"
    }
    
    public class CATEGORY
    {
        public static let TABLENAME = "CATEGORY"
        public static let ID = "CATEGORY_ID"
        public static let TEXT = "CATEGORY_TEXT"
        public static let IMAGE = "CATEGORY_IMAGE"
        public static let CREATEDDATE = "CATEGORY_CREATED_DATE"
        public static let UPDATEDATE = "CATEGORY_UPDATED_DATE"
    }
    
    static func createBasicAppsDirectories()
    {
        APP.createAppsDirectories(name: APP_IMAGES_FOLDER)
        APP.createAppsDirectories(name: APP_DATABASE_FOLDER)
        APP.createAppsDirectories(name: APP_NOTES_INFO_FOLDER)
    }
    
    static func createAppsDirectories(name : String)
    {
        do
        {
            try fileManager.createDirectory(at: (fileManagerUrls.first?.appendingPathComponent("\(APP.APP_FOLDER)/\(name)"))!, withIntermediateDirectories: true, attributes: nil)
        }
        catch { }
    }
    
    static func createNoteDirectory(noteId : String)
    {
        do
        {
            try fileManager.createDirectory(at: (fileManagerUrls.first?.appendingPathComponent("\(APP.APP_FOLDER)/\(APP.APP_NOTES_INFO_FOLDER)/\(noteId)"))!, withIntermediateDirectories: false, attributes: nil)
        }
        catch { }
    }
    
    static func databasePathFile() -> String
    {
        return (fileManagerUrls.first?.appendingPathComponent("\(APP.APP_FOLDER)/\(APP.APP_DATABASE_FOLDER)/\(APP.APP_DATABASE_FILENAME)").path)!
    }
    
    static func clearFolderForNote(noteId : String) {
        let noteDirectoryURL = fileManagerUrls.first?.appendingPathComponent("\(APP.APP_FOLDER)/\(APP_NOTES_INFO_FOLDER)/\(noteId)")
        do {
            let directoryContents = try fileManager.contentsOfDirectory(atPath: noteDirectoryURL!.path)
            if !directoryContents.isEmpty {
                for itemName in directoryContents {
                    let itemPath = noteDirectoryURL!.appendingPathComponent(itemName)
                    try fileManager.removeItem(at: itemPath)
                }
                
            }
        } catch(let error) {
            printError(className: "APP", method: #function, message: error.localizedDescription)
        }
    }
    
    static func deleteFolderForNote(noteId : String) {
        let noteDirectoryURL = fileManagerUrls.first?.appendingPathComponent("\(APP_NOTES_INFO_FOLDER)/\(noteId)")
        do {
            try fileManager.removeItem(at: noteDirectoryURL!)
        } catch(let error) {
            printError(className: "APP", method: #function, message: error.localizedDescription)
        }
    }
    
    static func printError(className : String, method : String, message : String)
    {
        print("\nCustom App Error Message")
        print("\tMethod Called := \(className).\(method)")
        print("\tError := \(message)")
        print("End Custom App Error Message\n")
    }
}
