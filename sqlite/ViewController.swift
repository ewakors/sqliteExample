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
    let queryStatementString = "SELECT id_area, city FROM address where id_area = 32 and street like \"%44%\";"
    
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
        let s = Stopwatch()
        
        //        let queryString = "SELECT * FROM gift"
        let queryString = "SELECT * FROM santa"
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
            //            let id = sqlite3_column_int(stmt, 0)
            //            let name = String(cString: sqlite3_column_text(stmt, 1))
            //            let powerrank = "sqlite3_column_int(stmt, 2)"
            //
            //            heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: String(describing: powerrank)))
        }
        print("select from elf elapsed time: \(s.elapsedTimeString())")
        
        //        for i in 0..<heroList.count {
        //            print("\(heroList[i].name) \(heroList[i].powerRanking)")
        //        }
    }
    
    @IBAction func selectWhereButtonAcion(_ sender: Any) {
        let s = Stopwatch()
        let queryString = "SELECT g.name, c.name FROM gift g, children c where c.id = g.id_children and c.id = 4683"
        
        //        let queryString = "SELECT * FROM elf where name like \"%a\""
        //         let queryString = "SELECT * FROM gift where is_given = \"TRUE\" and give_date = 1387948873 and id_address = 8400 and id_children = 13581"
        //        let queryString = "SELECT name, company_name, is_given FROM gift where is_given = \"FALSE\" || give_date = 1387948873"
        //        let queryString = "SELECT name, company_name, is_given FROM gift where id_address = 240 and id_children = 16513"
        //        let queryString = "SELECT name, company_name, is_given FROM gift where id = 30001"
        //        let queryString = "SELECT * FROM address where id_area = 32 and (street like \"%24%\" or street like \"%44%\")"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        } else {
            print("select where okej")
        }
        heroList.removeAll()
//        traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
//                        let powerrank = String(cString: sqlite3_column_text(stmt, 2))

//            heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: String(describing: powerrank)))
        }
        
        print("select from gift elapsed time: \(s.elapsedTimeString())")
        
        for i in 0..<heroList.count {
            if let name = heroList[i].name, let power = heroList[i].powerRanking {
                print("\(name) \(power) \(heroList.count)")
            }
        }
    }
    
    @IBAction func updateButtonAction(_ sender: Any) {
        let s = Stopwatch()
        let updateStatementString = "UPDATE address SET city = 'Toledo' WHERE id_area = 32 and (street like \"%24%\" or street like \"%44%\");"
        //        let updateStatementString = "UPDATE gift SET name = 'barbie' WHERE is_given = \"FALSE\" and weight < 2;"
        //        let updateStatementString = "UPDATE gift SET name = 'barbie' WHERE id = 1432;"
        //        let updateStatementString = "UPDATE address SET city = 'Toledo' WHERE id_area = 32 and (street like \"%24%\" or street like \"%44%\");"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("update gift elapsed time: \(s.elapsedTimeString())")
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared")
        }
        sqlite3_finalize(updateStatement)
        query()
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        let s = Stopwatch()
        var stmt: OpaquePointer?
        
        //let queryString = "DELETE FROM gift where is_given = \"TRUE\""
        //        let queryString = "DELETE FROM children where age = 17"
        let queryString = "DELETE FROM elf where name like \"%a\""
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("delete gift elapsed time: \(s.elapsedTimeString())")
                print("Successfully delete row.")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
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
    
    func query() {
        var queryStatement: OpaquePointer? = nil
        // 1
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                // 3
                let id = sqlite3_column_int(queryStatement, 0)
                
                // 4
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let name = String(cString: queryResultCol1!)
                
                // 5
                print("Query Result:")
                print("\(id) | \(name)")
                
            } else {
                print("Query returned no results")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
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
        let s = Stopwatch()
        let insertSql = "INSERT INTO reindeer VALUES (?, ?, ?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        let name: NSString = "lalka barbie"
        let companyName: NSString = "barbie"
        let isGiven: Bool = false
        let giveDate: NSDate = NSDate()
        let weight: Float = 3.2
        let idAddress: Int = 768
        let idChildren = 1924
        let gender: NSString = "female"
        
        guard sqlite3_bind_int(insertStatement, 1, 30001) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil) == SQLITE_OK &&
            //            sqlite3_bind_text(insertStatement, 3, companyName.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 3, 1) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 4, 453) == SQLITE_OK
            //            sqlite3_bind_double(insertStatement, 6, Double(weight)) == SQLITE_OK  &&
            //            sqlite3_bind_int(insertStatement, 7, Int32(idAddress)) == SQLITE_OK &&
            //            sqlite3_bind_int(insertStatement,8, Int32(idChildren)) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        print("insert into gift elapsed time: \(s.elapsedTimeString())")
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
