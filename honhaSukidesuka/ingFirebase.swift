//
//  ingFirebase.swift
//  honhasukidesuka
//
//  Created by yuka on 2017/12/01.
//  Copyright © 2017年 yuka. All rights reserved.
//

import CoreData
import UIKit
import Firebase



//rirekiCount : 現在の履歴の数
//max_rid     : 現在の最大の r_idの位置
//maxNum      : 最大の値

class ingFirebase {
    //AppDelegateを使う用意をしておく（インスタンス化）
    let appDalegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var dics:[NSDictionary] = []
    var bookCount:Int = -1
    var min_rid:Int = -1
    var max_rid:Int = -1
    private let maxNum:Int = 100
    
//    var ref: DatabaseReference!
    
//    ref = Database.database().reference()
//    self.ref.child("users").child(user.uid).setValue(["username": username])

    init() {
        
        //エンティティを操作するためのオブジェクトを作成する
        let viewContext = appDalegate.persistentContainer.viewContext

        //エンティティオブジェクトを作成する
        let myEntity = NSEntityDescription.entity(forEntityName: "RecommendBookList", in: viewContext)

        let query:NSFetchRequest<RecommendBookList> = RecommendBookList.fetchRequest()
        query.entity = myEntity
        
        //取り出しの順番
        let sortDescripter = NSSortDescriptor(key: "createDate", ascending: true)//ascendind:true 昇順 古い順、false 降順　新しい順
        query.sortDescriptors = [sortDescripter]
        do {
            let fetchResults = try viewContext.fetch(query)
            bookCount = fetchResults.count
            if(bookCount != 0){
                for fetch:AnyObject in fetchResults {
                    if(min_rid == -1) {
                        min_rid = (fetch.value(forKey: "bookid") as? Int)!
                    }
                    max_rid = (fetch.value(forKey: "bookid") as? Int)!
                }
                NSLog("coreDataの数\(bookCount)")
                NSLog("max_ridの値:\(max_rid)")
            }
        }
        catch{
            
        }
    }
    
    //==============================
    // Create
    //==============================
    func createRecord(id:Int, title:String, author:String, recommendation:String,link:String) {
        if Constants.DEBUG == true {
            print(#function)
        }
        //エンティティを操作するためのオブジェクトを作成する
        let viewContext = appDalegate.persistentContainer.viewContext
        
        //エンティティオブジェクトを作成する
        let myEntity = NSEntityDescription.entity(forEntityName: "RecommendBookList", in: viewContext)
        
        //ToDOエンティティにレコードを挿入するためのオブジェクトを作成
        let newRecord = NSManagedObject(entity: myEntity!, insertInto: viewContext)
        
        //値のセット
        newRecord.setValue(id, forKey: "bookid")
        newRecord.setValue(title, forKey: "title")
        newRecord.setValue(author, forKey: "author")
        newRecord.setValue(recommendation, forKey: "recommendation")
        newRecord.setValue(link, forKey: "linkURL")
        newRecord.setValue(Date(), forKey: "createDate")
        
        //レコードの即時保存
        do {
            try viewContext.save()
            bookCount = bookCount + 1
            max_rid = id
        } catch {
            //エラーが発生した時に行う例外処理を書いておく
        }
        
    }
    
    //==============================
    // Read All
    //==============================
    //既に存在するデータの読み込み処理
    func readRecommendAll() -> [NSDictionary] {
        if Constants.DEBUG == true {
            print(#function)
        }
        //エンティティを操作するためのオブジェクトを作成する
        let viewContext = appDalegate.persistentContainer.viewContext
        
        //エンティティオブジェクトを作成する
        let myEntity = NSEntityDescription.entity(forEntityName: "RecommendBookList", in: viewContext)
        
        let query:NSFetchRequest<RecommendBookList> =  RecommendBookList.fetchRequest()
        query.entity = myEntity
        
        //取り出しの順番
        let sortDescripter = NSSortDescriptor(key: "createDate", ascending: false)//ascendind:true 昇順 古い順、false 降順　新しい順
        query.sortDescriptors = [sortDescripter]

        
        //データを一括取得
        do {
            
            let fetchResults = try viewContext.fetch(query)
            if( fetchResults.count != 0) {
                for fetch:AnyObject in fetchResults {
                    let id:Int = (fetch.value(forKey: "bookid") as? Int)!
                    let title:String = (fetch.value(forKey: "title") as? String)!
                    let author:String = (fetch.value(forKey: "author") as? String)!
                    let recommendation:String = (fetch.value(forKey: "recommendation") as? String)!
                    let link:String = (fetch.value(forKey: "linkURL") as? String)!
                    let createDate:NSDate = (fetch.value(forKey: "createDate") as? NSDate)!

                    let dic =  ["bookid":id,"title":title,"author":author,"recommendation":recommendation ,"linkURL":link,"createDate":createDate] as [String : Any]
                    


                    dics.append(dic as NSDictionary)
                    
                    
                }
            }
            
        } catch  {
            print(error)
            
        }
        
        return dics
        
    }
    
    
    //==============================
    // Read 1
    //==============================
    func readRecommend(id:Int) -> NSDictionary {
        if Constants.DEBUG == true {
            print(#function)
        }
        //エンティティを操作するためのオブジェクトを作成する
        let viewContext = appDalegate.persistentContainer.viewContext
        var dic:NSDictionary = NSDictionary()
        
        //どのエンティティからデータを取得してくるか設定
        let query:NSFetchRequest<RecommendBookList> =  RecommendBookList.fetchRequest()
        
        
        //===== 絞り込み =====
        let r_idPredicate = NSPredicate(format: "bookid = %d", id)
        query.predicate = r_idPredicate
        
        
        //===== データ１件取得（r_idを指定しているので) =====
        do {
            
            let fetchResults = try viewContext.fetch(query)
            
            //きちんと保存できているか、１行ずつ表示（デバッグエリア）
            for fetch:AnyObject in fetchResults {
                let id:Int = (fetch.value(forKey: "bookid") as? Int)!
                let title:String = (fetch.value(forKey: "title") as? String)!
                let author:String = (fetch.value(forKey: "author") as? String)!
                let recommendation:String = (fetch.value(forKey: "recommendation") as? String)!
                let link:String = (fetch.value(forKey: "linkURL") as? String)!
                let createDate:NSDate = (fetch.value(forKey: "createDate") as? NSDate)!

                dic =  ["bookid":id,"title":title,"author":author,"recommendation":recommendation,"linkURL":link,"createDate":createDate]
                
                print(dic)
                
            }
            
        } catch  {
            
        }
        
        return (dic as NSDictionary)
    }
    
    //==============================
    // search title
    //==============================
    func searchRecommend(title:String) -> [NSDictionary] {
        if Constants.DEBUG == true {
            print(#function)
        }
        //エンティティを操作するためのオブジェクトを作成する
        let viewContext = appDalegate.persistentContainer.viewContext
        var dicss:[NSDictionary] = []

        //どのエンティティからデータを取得してくるか設定
        let query:NSFetchRequest<RecommendBookList> =  RecommendBookList.fetchRequest()
        
        
        //===== 絞り込み =====
        let r_idPredicate = NSPredicate(format: "title CONTAINS %@", title)
        print(r_idPredicate)
        query.predicate = r_idPredicate
        
        
        //===== データ１件取得（r_idを指定しているので) =====
        //データを一括取得
        do {
            
            let fetchResults = try viewContext.fetch(query)
            if( fetchResults.count != 0) {
                for fetch:AnyObject in fetchResults {
                    let id:Int = (fetch.value(forKey: "bookid") as? Int)!
                    let title:String = (fetch.value(forKey: "title") as? String)!
                    let author:String = (fetch.value(forKey: "author") as? String)!
                    let recommendation:String = (fetch.value(forKey: "recommendation") as? String)!
                    let link:String = (fetch.value(forKey: "linkURL") as? String)!
                    let createDate:NSDate = (fetch.value(forKey: "createDate") as? NSDate)!
                    
                    let dic =  ["bookid":id,"title":title,"author":author,"recommendation":recommendation ,"linkURL":link,"createDate":createDate] as [String : Any]
                    
                    
                    
                    dicss.append(dic as NSDictionary)
                    
                    
                }
            }
        } catch  {
            
        }
        
        return dicss
    }
    
    //==============================
    // Delete all
    //==============================
    func deleteRecommendAll() {
        if Constants.DEBUG == true {
            print(#function)
        }
        //エンティティを操作するためのオブジェクトを作成する
        let viewContext = appDalegate.persistentContainer.viewContext
        
        //どのエンティティからデータを取得してくるか設定（ToDoエンティティ）
        let query:NSFetchRequest<RecommendBookList> =  RecommendBookList.fetchRequest()
        
        do {
            //削除するデータを取得（今回は全て取得）
            let fetchResults = try viewContext.fetch(query)
            
            //１行ずつ削除
            
            for fetch:AnyObject in fetchResults{
                //削除処理を行うために型変換
                let record = fetch as! NSManagedObject  // 扱いやすいように型変換
                viewContext.delete(record)
                
            }
            //削除した状態を保存
            try viewContext.save()
            bookCount = 0

            
        } catch  {
            
        }
        
    }
    
    //==============================
    // Delete 1
    //==============================
    func deleteRecommend(id:Int) {
        
        //エンティティを操作するためのオブジェクトを作成する
        let viewContext = appDalegate.persistentContainer.viewContext
        
        //どのエンティティからデータを取得してくるか設定（ToDoエンティティ）
        let query:NSFetchRequest<RecommendBookList> =  RecommendBookList.fetchRequest()
        
        //===== 絞り込み =====
        let r_idPredicate = NSPredicate(format: "bookid = %d", id)
        query.predicate = r_idPredicate
        
        
        do {
            //削除するデータを取得
            let fetchResults = try viewContext.fetch(query)
            
            //１行ずつ削除
            
            for fetch:AnyObject in fetchResults{
                //削除処理を行うために型変換
                let record = fetch as! NSManagedObject  // 扱いやすいように型変換
                viewContext.delete(record)
                
            }
            //削除した状態を保存
            try viewContext.save()
            bookCount = bookCount - 1

            
        } catch  {
            
            if Constants.DEBUG == true {
                print(#function)
                print("削除するレコードなかったよ")
            }
            
        }
        
    }
    
    //==============================
    // Edit
    //==============================
    
    func editRecommend(id:Int, title:String, author:String, recommendation:String, link:String) {
        print(#function)
        //エンティティを操作するためのオブジェクトを作成する
        let viewContext = appDalegate.persistentContainer.viewContext

        //どのエンティティからデータを取得してくるか設定（ToDoエンティティ）
        let query:NSFetchRequest<RecommendBookList> =  RecommendBookList.fetchRequest()


        //===== 絞り込み =====
        let r_idPredicate = NSPredicate(format: "bookid = %d", id)
        query.predicate = r_idPredicate

        do {

            let fetchResults = try viewContext.fetch(query)

            if (fetchResults.count == 0) {
                //なければ新規で作る
                print(#function)
                print("ないので作ります。")
                createRecord(id: id, title: title, author:  author, recommendation: recommendation, link: link)
                return  // 作って終了する
            }

            for fetch:AnyObject in fetchResults {

                //更新する対象のデータをNSManagedObjectにダウンキャスト
                let record = fetch as! NSManagedObject
                //値のセット
                record.setValue(id, forKey: "bookid")
                record.setValue(title, forKey: "title")
                record.setValue(author, forKey: "author")
                record.setValue(recommendation, forKey: "recommendation")
                record.setValue(link, forKey: "linkURL")

                //レコードの即時保存
                do {
                    try viewContext.save()
                } catch {
                    //エラーが発生した時に行う例外処理を書いておく
                    print(#function)
                    print("保存できなかった")
                }


            }


        } catch  {

        }


    }
    
    //==============================
    // 挿入 履歴maxnum件　最新に入れる
    //　戻り値：　挿入したr_id
    //==============================
    
    func insertRecommend(title:String, author:String, recommendation:String,link:String) -> Int {
        if Constants.DEBUG == true {
            print(#function)
        }
        let newid:Int = max_rid + 1
        
        createRecord(id: newid, title:  title, author:  author, recommendation: recommendation, link: link)
        if(bookCount > maxNum ) {
            deleteRecommend(id: min_rid)

        }
        
        return newid
        
    }
    
}

