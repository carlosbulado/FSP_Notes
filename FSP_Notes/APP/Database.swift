import Foundation
import SQLite3

public class Database
{
    static func LoadUpdateDatabase()
    {
        var database : OpaquePointer? = nil
        var result = sqlite3_open(APP.databasePathFile(), &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            APP.printError(className: "Database", method: #function, message: "Failed to open database")
            return
        }
        
        // Note Table
        let createNoteTable = "CREATE TABLE IF NOT EXISTS \(APP.NOTE.TABLENAME) (\(APP.NOTE.ID) TEXT PRIMARY KEY, \(APP.NOTE.TITLE) TEXT, \(APP.NOTE.TEXT) TEXT, \(APP.NOTE.LATITUDE) NUMERIC, \(APP.NOTE.LONGITUDE) NUMERIC, \(APP.NOTE.CATEGORY) INTEGER, \(APP.NOTE.CREATEDDATE) TEXT, \(APP.NOTE.UPDATEDATE) TEXT);"
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        result = sqlite3_exec(database, createNoteTable, nil, nil, &errMsg)
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            APP.printError(className: "Database", method: #function, message: "Failed to create note table")
            return
        }
        
        // Category Table
        let createCategoryTable = "CREATE TABLE IF NOT EXISTS \(APP.CATEGORY.TABLENAME) (\(APP.CATEGORY.ID) TEXT PRIMARY KEY, \(APP.CATEGORY.TEXT) TEXT, \(APP.CATEGORY.IMAGE) TEXT, \(APP.CATEGORY.CREATEDDATE) TEXT, \(APP.CATEGORY.UPDATEDATE) TEXT);"
        errMsg = nil
        result = sqlite3_exec(database, createCategoryTable, nil, nil, &errMsg)
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            APP.printError(className: "Database", method: #function, message: "Failed to create category table")
            return
        }
    }
    
    static func getDatabase() -> OpaquePointer?
    {
        var database : OpaquePointer? = nil
        let result = sqlite3_open(APP.databasePathFile(), &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            APP.printError(className: "Database", method: #function, message: "Failed to open database")
        }
        return database
    }
}
