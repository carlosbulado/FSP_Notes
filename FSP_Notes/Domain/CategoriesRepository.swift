import Foundation
import SQLite3

public class CategoriesRepository
{
    static func getAll(searchFor : String = "", orderBy : String = "", asc : Bool = true) -> [Category]
    {
        var categories : [Category] = []
        
        let database = Database.getDatabase()
        
        var query = "SELECT \(APP.CATEGORY.ID), \(APP.CATEGORY.TEXT) FROM \(APP.CATEGORY.TABLENAME) "
        
        if(searchFor != "") { query += " WHERE \(APP.CATEGORY.TEXT) LIKE '%\(searchFor)%' " }
        
        if(orderBy != "")
        {
            query += " ORDER BY \(orderBy) \(asc ? "ASC" : "DESC") "
        }
        
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK
        {
            while sqlite3_step(statement) == SQLITE_ROW
            {
                let newCategory = Category()
                newCategory.id = String(cString: sqlite3_column_text(statement, 0)!)
                if(sqlite3_column_text(statement, 1) != nil) { newCategory.text = String(cString: sqlite3_column_text(statement, 1)!) }
                categories.append(newCategory);
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        return categories
    }
    
    static func save(_ category : Category)
    {
        let database = Database.getDatabase()
        
        if(ifExists(id: category.id))
        {
            let update = "INSERT INTO \(APP.CATEGORY.TABLENAME) (\(APP.CATEGORY.ID), \(APP.CATEGORY.TEXT), \(APP.CATEGORY.CREATEDDATE)) VALUES ('\(category.id)', ?, '\(category.created.dateToString)');"
            var statement : OpaquePointer? = nil
            if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, category.text, -1, nil)
            }
            if sqlite3_step(statement) != SQLITE_DONE {
                APP.printError(className: "CategoriesRepository", method: #function, message: "Saving Category")
                sqlite3_close(database)
                return
            }
            sqlite3_finalize(statement)
            sqlite3_close(database)
        }
        else
        {
            let update = "UPDATE \(APP.CATEGORY.TABLENAME) SET \(APP.CATEGORY.TEXT) = ?, \(APP.CATEGORY.UPDATEDATE) = '\(category.updated.dateToString)' WHERE \(APP.CATEGORY.ID) = '\(category.id)';"
            var statement : OpaquePointer? = nil
            if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, category.text, -1, nil)
            }
            if sqlite3_step(statement) != SQLITE_DONE {
                APP.printError(className: "CategoriesRepository", method: #function, message: "Updating Category")
                sqlite3_close(database)
                return
            }
            sqlite3_finalize(statement)
            sqlite3_close(database)
        }
    }
    
    static func ifExists(id : String) -> Bool
    {
        let database = Database.getDatabase()
        
        var isNew = true
        
        let query = "SELECT 1 FROM \(APP.CATEGORY.TABLENAME) WHERE \(APP.CATEGORY.ID) = ?;"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK
        {
            sqlite3_bind_text(statement, 1, id, -1, nil)
            if sqlite3_step(statement) == SQLITE_ROW
            {
                isNew = false;
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        return isNew
    }
    
    static func getById(id : String) -> Category
    {
        let newNote = Category()
        
        let database = Database.getDatabase()
        
        let query = "SELECT \(APP.CATEGORY.ID), \(APP.CATEGORY.TEXT), \(APP.CATEGORY.CREATEDDATE), \(APP.CATEGORY.UPDATEDATE) FROM \(APP.CATEGORY.TABLENAME) WHERE \(APP.CATEGORY.ID) = ?;"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK
        {
            sqlite3_bind_text(statement, 1, id, -1, nil)
            if sqlite3_step(statement) == SQLITE_ROW
            {
                newNote.id = String(cString: sqlite3_column_text(statement, 0))
                if(sqlite3_column_text(statement, 1) != nil) { newNote.text = String(cString: sqlite3_column_text(statement, 1)!) }
                if((sqlite3_column_text(statement, 2)) != nil) { newNote.created = Date.fromString(stringValue: String(cString: sqlite3_column_text(statement, 2)!)) }
                if((sqlite3_column_text(statement, 3)) != nil) { newNote.updated = Date.fromString(stringValue: String(cString: sqlite3_column_text(statement, 3)!)) }
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        return newNote
    }
    
    static func getCount() -> Int
    {
        let database = Database.getDatabase()
        
        var quantityOfNotes = 0
        
        let query = "SELECT COUNT(1) FROM \(APP.CATEGORY.TABLENAME);"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK
        {
            if sqlite3_step(statement) == SQLITE_ROW { quantityOfNotes = Int(sqlite3_column_int(statement, 0)) }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        return quantityOfNotes
    }
    
    static func remove(_ categoryId : String)
    {
        let database = Database.getDatabase()
        
        let remove = "DELETE FROM \(APP.CATEGORY.TABLENAME) WHERE \(APP.CATEGORY.ID) = ?;"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(database, remove, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, categoryId, -1, nil)
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            APP.printError(className: "CategoriesRepository", method: #function, message: "Deleting Category")
            sqlite3_close(database)
            return
        }
        sqlite3_finalize(statement)
        sqlite3_close(database)
    }
}
