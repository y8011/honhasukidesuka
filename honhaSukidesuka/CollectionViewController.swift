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
,SideMenuDelegate
    ,UIGestureRecognizerDelegate
    ,UITextFieldDelegate
{
    func onClickButton(sender: UIButton) {
        //
        switch sender.tag {
        case 0:
            performSegue(withIdentifier: "segueta", sender: nil)

        case 1:

            sideView.zendashi()
            self.searchReload()
            
        default:
            return
        }
    }
    

    @IBOutlet var myCollectionView: UICollectionView!
    var collections:[NSDictionary] = []

    var sideView:SideMenu!
    @IBOutlet var rightEdgePanGesture: UIScreenEdgePanGestureRecognizer!

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
        // Sidebar
        let imageArray = [UIImage(named:"read.png")!,UIImage(named:"search.png")!]
        sideView = SideMenu(image:imageArray, parentViewController:self)
        self.view.addSubview(sideView)
        
        rightEdgePanGesture.edges = .right
        myCollectionView.addGestureRecognizer(rightEdgePanGesture)
        rightEdgePanGesture.delegate = self
        sideView.delegate = self
        sideView.searchTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        self.configureObserver()
        reloadForCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(#function)
        print(rightEdgePanGesture.debugDescription)
        print(rightEdgePanGesture.description)
        print(myCollectionView.panGestureRecognizer.description)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObserver() // Notificationを画面が消えるときに削除

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
    // MARK:Gesture
    //=============================
    //スワイプを検出したときの挙動
    @IBAction func EdgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        sideView.getEdgeGesture(sender: sender)
        print(#function)
    }
    
    @IBAction func tapReload(_ sender: UIBarButtonItem) {
        reloadForCollectionView()
    }
    

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("2222222222")
        print(otherGestureRecognizer.description)
        return true

    }
    // 他のビューを触ったら、キーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        // moveDisplay = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        
        return true
    }
    
    
    // 検索
    var searchRequest:Bool = false
    var searchTitle:String = ""
    func searchReload() {
        if sideView.searchTextField.text! == "" { return } // 空白だったらzendashi
        searchRequest = true
        searchTitle = sideView.searchTextField.text!
        reloadForCollectionView()
        view.endEditing(true)
        sideView.clearViewTapped()
        sideView.searchTextField.text! = ""

    }
    
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
    
    
    //=================================
    // MARK:画面ずらす処理
    //=================================
    // Notificationを設定
    func configureObserver() {
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Notificationを削除
    func removeObserver() {
        
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    // キーボードが現れた時に、画面全体をずらす。
    var keyboadON:Bool = false
    var keyboadHeight:CGFloat = 0
    @objc func keyboardWillShow(notification: Notification?) {
        print(#function)
        if keyboadON {return } // キーボード出てたら実行しない
        
        let rect = (notification?.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
            self.keyboadHeight = (rect?.size.height)!
            //self.sideView.transform = transform
            UIView.animate(withDuration: 0.8,
                           animations: {
                            self.sideView.frame.origin.y = self.sideView.frame.origin.y-(self.keyboadHeight)
            },
                           completion:nil)
        })
        keyboadON = true
    }
    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        print(#function)
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            
            self.sideView.transform = CGAffineTransform.identity
            UIView.animate(withDuration: 0.8,
                           animations: {
                            self.sideView.frame.origin.y = self.sideView.frame.origin.y+(self.keyboadHeight)
            },
                           completion:nil)
        })
        keyboadON = false
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
        
       // let myCoreData = ingCoreData()
       // return myCoreData.bookCount
        if collections.count == 0 { //0のときはこれをクリアできないのでここで
            searchRequest = false
            searchTitle = ""
        }
        
        return collections.count
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

        searchRequest = false
        searchTitle = ""
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
        if (searchRequest == true) && (searchTitle != "")
        {
            collections = myIngCoreData.searchRecommend(title: searchTitle)
        }
        else {
            collections = myIngCoreData.readRecommendAll()
        }
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

