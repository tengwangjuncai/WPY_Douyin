//
//  DBHelper.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/24/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

import SQLite

let TBALE_NAME = "video_list"
let ID = rowid
let VIDEOPATH = Expression<String>("videoPath")
let CONTENT = Expression<String>("content")
let NAME = Expression<String>("name")
let IMAGE = Expression<Data>("image")
let DATE = Expression<Date>("date")
let RELEASE = Expression<Bool>("release")

let documentDicectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first

let dbPath = documentDicectory! + "/db.sqlite3"

class DBHelper: NSObject {
    
   static let manager = DBHelper()
    private var db:Connection?
    private var table:Table?
    
    
    func getDB()-> Connection{
        
        if db == nil {
            
            db = try! Connection(dbPath)
            db?.busyTimeout = 5.0
            print("======" + dbPath)
        }
        return db!
    }
    
    func getTable()-> Table{
        
        if table == nil{
            
            table = Table("videoList")
            
            try! getDB().run(table!.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (builder) in
                
                builder.column(VIDEOPATH)
                builder.column(CONTENT)
                builder.column(NAME)
//                builder.column(IMAGE)
                builder.column(DATE)
                builder.column(RELEASE)
            }))
        }
        
        
        return table!
    }
    
    
    func insert(model:WPYPhotoModel){
        
        guard let videoUrl = model.videoUrl,let name = model.name else{return}
        //VIDEOPATH <- videoUrl,CONTENT <- model.content ?? "",NAME <- name,DATE <- model.date,RELEASE <- model.release
        let insert = getTable().insert(VIDEOPATH <- videoUrl,CONTENT <- model.content ?? "",NAME <- name,DATE <- model.date,RELEASE <- model.release)
        
        if let rowId = try? getDB().run(insert){
            
            print("插入成功：\(rowId)")
        }else {
            print("插入失败")
        }
    }
    
    
    func delete(url:String){
        delete(filter: VIDEOPATH == url)
    }
    
    func delete(filter:Expression<Bool>? = nil){
        
          var query = getTable()
        if let f = filter {
            query = query.filter(f)
        }
        
        if let  count = try? getDB().run(query.delete()){
            print("删除条数为：\(count)")
        }else{
            
            print("删除失败")
        }
    }
    
    func update(model:WPYPhotoModel){
        
        let update = getTable().filter(VIDEOPATH == model.videoUrl!)
        
         guard let videoUrl = model.videoUrl,let name = model.name else{return}
        
        if let count = try? getDB().run(update.update(VIDEOPATH <- videoUrl,CONTENT <- model.content ?? "",NAME <- name,DATE <- model.date,RELEASE <- model.release)){
            
            print("修改结果为:\(count)")
        }else{
            print("修改失败")
        }
    }
    
    func selec()->Array<Any>{
        
        var array = Array<WPYPhotoModel>()
        
        for model in try! getDB().prepare(getTable()
            ){
                
              let videoModel = WPYPhotoModel()
                  videoModel.videoUrl = model[VIDEOPATH]
                  videoModel.content = model[CONTENT]
                  videoModel.name = model[NAME]
                  videoModel.date = model[DATE]
            array.insert(videoModel, at: 0)
    }
        
        return array
    }
}

