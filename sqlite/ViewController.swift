//
//  ViewController.swift
//  sqlite
//
//  Created by Ewa Korszaczuk on 25/04/2019.
//  Copyright © 2019 Ewa Korszaczuk. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController {
    var heroList = [Hero]()
    
    internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    private var db: OpaquePointer?
    private var statement: OpaquePointer?
    private var cities: [String] = []
    
    fileprivate var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(db) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.db = self.openDatabase()
    }
    
    deinit {
        self.finalize(statement: statement)
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
    }
    @IBAction func selectButtonAction(_ sender: Any) {
        
        self.statement = self.prepareStatement()
//        self.cities = self.bindAndExecute(statement: self.statement, searchString: "")
//        print("cities \(self.cities)")
        let s = Stopwatch()
        
        let queryString = "SELECT * FROM elf"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let powerrank = "sqlite3_column_int(stmt, 2)"
            
            heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: String(describing: powerrank)))
        }
        print("select from elf elapsed time: \(s.elapsedTimeString())")

        for i in 0..<heroList.count {
            print("\(heroList[i].name) \(heroList[i].powerRanking)")
        }
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        var stmt: OpaquePointer?
        
        let queryString = "DELETE FROM Heroes where id=5"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        do {
            try insertContact()
        } catch {
            print("db.errorMessage")
        }
    }
    //        let name = "jan"
    //        let powerRanking = "999"
    //        var stmt: OpaquePointer?
    //
    //        let queryString = "INSERT INTO Heroes (name, powerrank) VALUES (?,?)"
    //
    //        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
    //            let errmsg = String(cString: sqlite3_errmsg(db)!)
    //            print("error preparing insert: \(errmsg)")
    //            return
    //        }
    //
    //        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
    //            let errmsg = String(cString: sqlite3_errmsg(db)!)
    //            print("failure binding name: \(errmsg)")
    //            return
    //        }
    //
    //        if sqlite3_bind_int(stmt, 2, (powerRanking as NSString).intValue) != SQLITE_OK{
    //            let errmsg = String(cString: sqlite3_errmsg(db)!)
    //            print("failure binding name: \(errmsg)")
    //            return
    //        }
    //
    //        if sqlite3_step(stmt) != SQLITE_DONE {
    //            let errmsg = String(cString: sqlite3_errmsg(db)!)
    //            print("failure inserting hero: \(errmsg)")
    //            return
    //        }
}
extension ViewController {
    private func openDatabase() -> OpaquePointer? {
        guard let path = Bundle.main.path(forResource: "SantaClaus", ofType: "db") else {
            fatalError("No database file found")
        }
        print("Database exists: " + (FileManager.default.fileExists(atPath: path) ? "yes" : "no"))
        
        var fileSize : UInt64
        
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
        } catch {
            fatalError("Error getting file size: \(error)")
        }
        print("Database file size: " + String(describing: fileSize))
        
        var db: OpaquePointer?
        if sqlite3_open(path, &db) != SQLITE_OK {
            fatalError("error opening database")
        } else {
            print("database connection succeeded")
        }
        
        var statement: OpaquePointer?
        
        // Final check: list number of tables
        
        if sqlite3_prepare_v2(db, "SELECT count(*) as tablecount FROM santa", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            fatalError("Error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let tablecount = sqlite3_column_int64(statement, 0)
            print("tablecount = \(tablecount)")
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            fatalError("Error finalizing prepared statement: \(errmsg)")
        }
        return db
    }
    
    private func prepareStatement() -> OpaquePointer? {
        guard let db = self.db else {
            fatalError("No connection to database")
        }
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT * FROM elf", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            fatalError("error preparing select: \(errmsg)")
        }
        
        return statement
    }
    
    private func bindAndExecute(statement: OpaquePointer?, searchString: String) -> [String] {
        var results: [String] = []
        
        if sqlite3_bind_text(statement, 1, searchString + "%", -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            fatalError("failure binding: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            if let cString = sqlite3_column_text(statement, 0) {
                let name = String(cString: cString)
                results.append(name)
            }
        }
        
        self.finalize(statement: statement)
        
        return results
    }
    
    private func finalize(statement: OpaquePointer?) {
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            fatalError("error finalizing prepared statement: \(errmsg)")
        }
    }
    
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }
    
        func insertContact() throws {
            let insertSql = "INSERT INTO elf VALUES (?, ?, ?);"
            let insertStatement = try prepareStatement(sql: insertSql)
            defer {
                sqlite3_finalize(insertStatement)
            }
            
            let name: NSString = "elfik"
            guard sqlite3_bind_int(insertStatement, 1, 501) == SQLITE_OK  &&
                sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil) == SQLITE_OK && sqlite3_bind_int(insertStatement,3, 1) == SQLITE_OK else {
                    throw SQLiteError.Bind(message: errorMessage)
            }
            
            guard sqlite3_step(insertStatement) == SQLITE_DONE else {
                throw SQLiteError.Step(message: errorMessage)
            }
            
            print("Successfully inserted row.")
        }
}

class Hero {
    
    var id: Int
    var name: String?
    var powerRanking: String?
    
    init(id: Int, name: String?, powerRanking: String?){
        self.id = id
        self.name = name
        self.powerRanking = powerRanking
    }
}

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}
