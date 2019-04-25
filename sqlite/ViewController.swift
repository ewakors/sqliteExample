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

    var db: OpaquePointer?
var heroList = [Hero]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let filemgr = FileManager.default
//        let dirPaths =
//            NSSearchPathForDirectoriesInDomains(.documentDirectory,
//                                                .userDomainMask, true)
//
//        let docsDir = dirPaths[0] as! String
//
//        databasePath = docsDir.stringByAppendingPathComponent(
//            "contacts.db")
//
//        if !filemgr.fileExistsAtPath(databasePath as String) {
//
//            let contactDB = FMDatabase(path: databasePath as String)
//
//            if contactDB == nil {
//                print("Error: \(contactDB.lastErrorMessage())")
//            }
//
//            if contactDB.open() {
//                let sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)"
//                if !contactDB.executeStatements(sql_stmt) {
//                    print("Error: \(contactDB.lastErrorMessage())")
//                }
//                contactDB.close()
//            } else {
//                print("Error: \(contactDB.lastErrorMessage())")
//            }
//        }
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("HeroesDatabase.db")

        //opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        } else {
            print("open database \(fileURL)")
        }
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, powerrank TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        } else {
            print("create table")
        }
    }
    
    @IBAction func selectButtonAction(_ sender: Any) {
        let queryString = "SELECT * FROM Heroes"
        
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
            let powerrank = sqlite3_column_int(stmt, 2)
            
            //adding values to list
            heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: String(describing: powerrank)))
        }
        
        for i in 0..<heroList.count {
            print("\(heroList[i].name) \(heroList[i].powerRanking)")
        }
    }
    @IBAction func deleteButtonAction(_ sender: Any) {
        var stmt: OpaquePointer?
        
        let queryString = "DELETE FROM Heroes where id=1001"
        
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
        let name = "Ola"
        let powerRanking = "999"
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO Heroes (name, powerrank) VALUES (?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 2, (powerRanking as NSString).intValue) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
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
