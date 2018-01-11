//
//  CollectionViewController.swift
//  honhaSukidesuka
//
//  Created by yuka on 2018/01/11.
//  Copyright © 2018年 yuka. All rights reserved.
//

import UIKit

private let reuseIdentifier = "colleko"

class CollectionViewController: UICollectionViewController
,UICollectionViewDelegateFlowLayout
{

    @IBOutlet var myCollectionView: UICollectionView!
    var collections:[NSDictionary] = []

    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
    
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        reloadForCollectionView()
    }
    override func didReceiveMemoryWarning() {
        print(#function)
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    //=============================
    // Gesture:セグエ
    //=============================
    
    
    //=============================
    // MARK:セグエ
    //=============================
    var selectedIndex:Int = -1
    // セグエを使って、画面遷移している時は発動
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueko" {
            // 次の画面のインスタンス(オブジェクト）を取得
            let dvc:detailViewController = segue.destination as! detailViewController
            if Constants.DEBUG == true {
                print(#function)
            }
            //次の画面のプロパティ（メンバ変数）passedIndexに選択された行番号を渡す
            dvc.passedIndex = selectedIndex
        }
    }
    //移動した画面から戻ってきた時発動
    @IBAction func returnMenu(_ segu:UIStoryboardSegue) {
        if Constants.DEBUG == true {
            print(#function)
        }
        myCollectionView.reloadData()
        
    }
    // MARK: UICollectionViewDataSource

//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        print(#function)
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(#function)
        // #warning Incomplete implementation, return the number of items
        let myCoreData = ingCoreData()
        return myCoreData.bookCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(#function)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! customCell
    
        // イメージとタイトルをCoreDataから情報を取り出して入れる
        let forCell = collections[indexPath.row]
        let id = forCell["bookid"] as! Int
        cell.id = id
        cell.title.text = forCell["title"] as! String
        
        let myLocalImage:ingLocalImage = ingLocalImage()
        let image = myLocalImage.readJpgImageInDocument(nameOfImage: "image\(id).jpg")
        cell.image.image = image

        return cell
    }


    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print(#function)
        print(indexPath.section)
        print(indexPath.row)
        
        
        let cell = collectionView.cellForItem(at: indexPath) as! customCell
        selectedIndex =   cell.id
        
        //セグエの名前を指定して、画面遷移処理を発動
        //storyboadのIdentifierと名前を合わせるのを忘れずに
        performSegue(withIdentifier: "segueko", sender: nil)
        
        return true
    }
 

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    private func collectionView(_ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        print(#function)
        let width = (self.view.frame.size.width-10)/2
        
        return CGSize(width: width, height: 50)
    }

    

    func reloadForCollectionView() {
        if Constants.DEBUG == true {
            print(#function)
        }
        let myIngCoreData:ingCoreData = ingCoreData()
        collections = myIngCoreData.readRecommendAll()
        
        myCollectionView.reloadData()
        
    }
    
    
//    let margin: CGFloat = 3.0
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if indexPath.row % 3 == 0 {
//            return CGSize(width: 100.0, height: 100.0)
//        }
//        return CGSize(width: 60.0, height: 60.0)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return margin
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return margin
//    }

}
