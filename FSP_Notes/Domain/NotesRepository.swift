import Foundation
import SQLite3

public class NotesRepository
{
    static func getAll(searchFor : String = "", orderBy : String = "", asc : Bool = true) -> [Note]
    {
        var notes : [Note] = []
        
        let database = Database.getDatabase()
        
        var query = "SELECT \(APP.NOTE.ID), \(APP.NOTE.TEXT), \(APP.NOTE.TITLE), \(APP.NOTE.LATITUDE), \(APP.NOTE.LONGITUDE), \(APP.NOTE.CATEGORY), \(APP.CATEGORY.TEXT), \(APP.NOTE.CREATEDDATE), \(APP.NOTE.UPDATEDATE) FROM \(APP.NOTE.TABLENAME) LEFT JOIN \(APP.CATEGORY.TABLENAME) ON \(APP.NOTE.CATEGORY) = \(APP.CATEGORY.ID)"
        
        if(searchFor != "") { query += " WHERE \(APP.NOTE.TITLE) LIKE '%\(searchFor)%' OR \(APP.CATEGORY.TEXT) LIKE '%\(searchFor)%'" }
        
        if(orderBy != "")
        {
            query += " ORDER BY \(orderBy) \(asc ? "ASC" : "DESC") "
        }
        
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK
        {
            while sqlite3_step(statement) == SQLITE_ROW
            {
                let newNote = Note()
                newNote.id = String(cString: sqlite3_column_text(statement, 0)!)
                if(sqlite3_column_text(statement, 1) != nil) { newNote.text = String(cString: sqlite3_column_text(statement, 1)!) }
                if(sqlite3_column_text(statement, 2) != nil) { newNote.title = String(cString: sqlite3_column_text(statement, 2)!) }
                newNote.latitude = Double(sqlite3_column_double(statement, 3))
                newNote.longitude = Double(sqlite3_column_double(statement, 4))
                newNote.category = String(cString: sqlite3_column_text(statement, 5)!)
                if((sqlite3_column_text(statement, 6)) != nil) { newNote.categoryText = String(cString: sqlite3_column_text(statement, 6)!) }
                if((sqlite3_column_text(statement, 7)) != nil) { newNote.created = Date.fromString(stringValue: String(cString: sqlite3_column_text(statement, 7)!)) }
                if((sqlite3_column_text(statement, 8)) != nil) { newNote.updated = Date.fromString(stringValue: String(cString: sqlite3_column_text(statement, 8)!)) }
                notes.append(newNote);
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        return notes
    }
    
    static func getCount() -> Int
    {
        let database = Database.getDatabase()
        
        var quantityOfNotes = 0
        
        let query = "SELECT COUNT(1) FROM \(APP.NOTE.TABLENAME);"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK
        {
            if sqlite3_step(statement) == SQLITE_ROW { quantityOfNotes = Int(sqlite3_column_int(statement, 0)) }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        return quantityOfNotes
    }
    
    static func save(_ note : Note)
    {
        let database = Database.getDatabase()
        
        if(ifExists(id: note.id))
        {
            let update = "INSERT INTO \(APP.NOTE.TABLENAME) (\(APP.NOTE.ID), \(APP.NOTE.TITLE), \(APP.NOTE.TEXT), \(APP.NOTE.LATITUDE), \(APP.NOTE.LONGITUDE), \(APP.NOTE.CATEGORY), \(APP.NOTE.CREATEDDATE)) VALUES ('\(note.id)', '\(note.title)', '\(note.text)', ?, ?, ?, '\(Date().dateToString)');"
            var statement : OpaquePointer? = nil
            if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
                //sqlite3_bind_text(statement, 1, note.title, -1, nil)
                //sqlite3_bind_text(statement, 1, note.text, -1, nil)
                sqlite3_bind_double(statement, 1, Double(note.latitude))
                sqlite3_bind_double(statement, 2, Double(note.longitude))
                sqlite3_bind_text(statement, 3, note.category, -1, nil)
            }
            if sqlite3_step(statement) != SQLITE_DONE {
                APP.printError(className: "NotesRepository", method: #function, message: "Saving Note")
                sqlite3_close(database)
                return
            }
            sqlite3_finalize(statement)
            sqlite3_close(database)
        }
        else
        {
            let update = "UPDATE \(APP.NOTE.TABLENAME) SET \(APP.NOTE.TITLE) = '\(note.title)', \(APP.NOTE.TEXT) = '\(note.text)', \(APP.NOTE.LATITUDE) = ?, \(APP.NOTE.LONGITUDE) = ?, \(APP.NOTE.CATEGORY) = ?, \(APP.NOTE.UPDATEDATE) = '\(Date().dateToString)' WHERE \(APP.NOTE.ID) = '\(note.id)';"
            var statement : OpaquePointer? = nil
            if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
                //sqlite3_bind_text(statement, 1, note.title, -1, nil)
                //sqlite3_bind_text(statement, 1, note.text, -1, nil)
                sqlite3_bind_double(statement, 1, Double(note.latitude))
                sqlite3_bind_double(statement, 2, Double(note.longitude))
                sqlite3_bind_text(statement, 3, note.category, -1, nil)
            }
            if sqlite3_step(statement) != SQLITE_DONE {
                APP.printError(className: "NotesRepository", method: #function, message: "Updating Note")
                sqlite3_close(database)
                return
            }
            sqlite3_finalize(statement)
            sqlite3_close(database)
        }
        let _ = NotesRepository.getById(id: note.id).title
    }
    
    static func getNextRow() -> Int
    {
        let database = Database.getDatabase()
        
        var next = 1
        
        let query = "SELECT \(APP.NOTE.ID) FROM \(APP.NOTE.TABLENAME) ORDER BY \(APP.NOTE.ID) DESC;"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK
        {
            if sqlite3_step(statement) == SQLITE_ROW { next = Int(sqlite3_column_int(statement, 0)) + 1 }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        return next
    }
    
    static func ifExists(id : String) -> Bool
    {
        let database = Database.getDatabase()
        
        var isNew = true
        
        let query = "SELECT 1 FROM \(APP.NOTE.TABLENAME) WHERE \(APP.NOTE.ID) = ?;"
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
    
    static func getById(id : String) -> Note
    {
        let newNote = Note()
        
        let database = Database.getDatabase()
        
        let query = "SELECT \(APP.NOTE.ID), \(APP.NOTE.TEXT), \(APP.NOTE.TITLE), \(APP.NOTE.LATITUDE), \(APP.NOTE.LONGITUDE), \(APP.NOTE.CATEGORY), \(APP.CATEGORY.TEXT), \(APP.NOTE.CREATEDDATE), \(APP.NOTE.UPDATEDATE) FROM \(APP.NOTE.TABLENAME) LEFT JOIN \(APP.CATEGORY.TABLENAME) ON \(APP.NOTE.CATEGORY) = \(APP.CATEGORY.ID) WHERE \(APP.NOTE.ID) = ?;"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK
        {
            sqlite3_bind_text(statement, 1, id, -1, nil)
            if sqlite3_step(statement) == SQLITE_ROW
            {
                newNote.id = String(cString: sqlite3_column_text(statement, 0))
                if(sqlite3_column_text(statement, 1) != nil) { newNote.text = String(cString: sqlite3_column_text(statement, 1)!) }
                if(sqlite3_column_text(statement, 2) != nil) { newNote.title = String(cString: sqlite3_column_text(statement, 2)!) }
                newNote.latitude = Double(sqlite3_column_double(statement, 3))
                newNote.longitude = Double(sqlite3_column_double(statement, 4))
                newNote.category = String(cString: sqlite3_column_text(statement, 5)!)
                if((sqlite3_column_text(statement, 6)) != nil) { newNote.categoryText = String(cString: sqlite3_column_text(statement, 6)!) }
                if((sqlite3_column_text(statement, 7)) != nil) { newNote.created = Date.fromString(stringValue: String(cString: sqlite3_column_text(statement, 7)!)) }
                if((sqlite3_column_text(statement, 8)) != nil) { newNote.updated = Date.fromString(stringValue: String(cString: sqlite3_column_text(statement, 8)!)) }
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        return newNote
    }
    
    static func remove(_ noteId : String)
    {
        let database = Database.getDatabase()
        
        let remove = "DELETE FROM \(APP.NOTE.TABLENAME) WHERE \(APP.NOTE.ID) = ?;"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(database, remove, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, noteId, -1, nil)
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            APP.printError(className: "NotesRepository", method: #function, message: "Deleting Note")
            sqlite3_close(database)
            return
        }
        sqlite3_finalize(statement)
        sqlite3_close(database)
    }
}
