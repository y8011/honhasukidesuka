//
//  ListViewController.swift
//  honhaSukidesuka
//
//  Created by oyuka on 2018/09/08.
//  Copyright © 2018年 yuka. All rights reserved.
//

import UIKit
//import Spring
import ChameleonFramework
import GoogleMobileAds

private let reuseIdentifier = "colleko"

class ListViewController: UIViewController
    ,SideMenuDelegate
    ,UIGestureRecognizerDelegate
    ,UITextFieldDelegate
{

    func onClickButton(sender: UIButton) {
        //サイドメニューの内容
        switch sender.tag {
        case 0:
            performSegue(withIdentifier: "goToSubmit", sender: nil)
            
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
    
    @IBOutlet weak var addSpringButtonWidth: NSLayoutConstraint!
    let margin: CGFloat = 8.0

    @IBOutlet weak var addSpringButton: SpringButton!
    @IBOutlet weak var button1: SpringButton!
    @IBOutlet weak var button2: SpringButton!
    @IBOutlet weak var button3: SpringButton!
    lazy var buttons = [button1,button2,button3]

    var bannerView: GADBannerView!

    
    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()

        // Register cell classes
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        // Sidebar
        let imageArray = [UIImage(named: "read")!,UIImage(named: "search")!]
        sideView = SideMenu(image:imageArray, parentViewController:self)
        self.view.addSubview(sideView)
        
        rightEdgePanGesture.edges = .right
        myCollectionView.addGestureRecognizer(rightEdgePanGesture)
        rightEdgePanGesture.delegate = self
        sideView.delegate = self
        sideView.searchTextField.delegate = self
        
        // Button
        initAddButton()

        // Admob
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = AdmobBannerID
        bannerView.rootViewController = self
        bannerView.delegate = self

        //広告のリクエスト
        //リクエストオブジェクトを出して広告をもらってくる
        let admobRequest = GADRequest()
        
        //リクエストのロード
        bannerView.load(admobRequest)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadForCollectionView()
        initCheck()

    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        print(#function)
        super.didReceiveMemoryWarning()
    }

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
    
    @IBAction func tapAddButton(_ sender: SpringButton) {
        buttonPutOut(sender: sender)

        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print(otherGestureRecognizer.description)
        return true
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        // キーボードを閉じる
        //        textField.resignFirstResponder()
        self.searchReload()
        
        
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
        if segue.identifier == "goToDetail" {
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

}

extension ListViewController:
     UICollectionViewDelegate
    ,UICollectionViewDataSource
    ,UICollectionViewDelegateFlowLayout
 {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(#function)
        if collections.count == 0 { //0のときはこれをクリアできないのでここで
            searchRequest = false
            searchTitle = ""
        }
        
        return collections.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(#function)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! customCell
        
        if indexPath.row < collections.count {
            // イメージとタイトルをCoreDataから情報を取り出して入れる
            let forCell = collections[indexPath.row]
            let id = forCell["bookid"] as! Int
            cell.id = id
            cell.title.text = forCell["title"] as! String
            cell.title.backgroundColor = UIColor.white

            let myLocalImage:ingLocalImage = ingLocalImage()
            if let image = myLocalImage.readJpgImageInDocument(nameOfImage: "image\(id).jpg") {
                cell.imageView.image = image
            } else {
                cell.imageView.image = UIImage(named: "noImage")
            }
            
            searchRequest = false
            searchTitle = ""
            
        } else {
            cell.imageView.image = UIImage(named: "newbook")
            cell.imageView.contentMode = .scaleAspectFill
            cell.title.text = ""
            cell.title.backgroundColor = UIColor.clear
        }
        
        return cell
    }
    
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row < collections.count {
            let cell = collectionView.cellForItem(at: indexPath) as! customCell
            selectedIndex = cell.id

            performSegue(withIdentifier: "goToDetail", sender: nil)
        } else {
            performSegue(withIdentifier: "goToSubmit", sender: nil)

        }
        return true
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width
        
        var colNum:CGFloat = 2
        if UIDevice.current.model == "iPad" {
            colNum = 3
        }
        let widthOfCol  = (width - margin * (colNum + 1)) / colNum
        let heightOfCol = widthOfCol * 1.4141
        return CGSize(width: widthOfCol, height: heightOfCol)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        print(#function)
        let width = (self.view.frame.size.width-10)/2
        
        return CGSize(width: width, height: 50)
    }
    
    
    
    func reloadForCollectionView() {
        let myIngCoreData:MyCoreData = MyCoreData()
        if (searchRequest == true) && (searchTitle != "") {
            collections = myIngCoreData.searchRecommend(title: searchTitle)
        } else {
            collections = myIngCoreData.readRecommendAll()
        }
        
        myCollectionView.reloadData()
    }

    // 画面の端からの距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
    
    // collectionView同士の幅、横軸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    
}

extension ListViewController {
    func initCheck() {
        if collections.count == 0 {
            performSegue(withIdentifier: "goToSubmit", sender: nil)
        }
        else {
        }
    }
}

// TODO: Button
extension ListViewController {
    func initAddButton() {
        addSpringButton.layer.cornerRadius = addSpringButtonWidth.constant/2
        addSpringButton.layer.backgroundColor = #colorLiteral(red: 1, green: 0.9261571765, blue: 0.2912220657, alpha: 1)
        addSpringButton.layer.shadowOffset = CGSize(width: 1, height: 1 )
        addSpringButton.layer.shadowColor = UIColor.gray.cgColor
        addSpringButton.layer.shadowRadius = 5
        addSpringButton.layer.shadowOpacity = 0.5

        buttons.forEach(){
            $0?.layer.backgroundColor = UIColor.flatSand.cgColor
            $0?.layer.cornerRadius = 10
            $0?.layer.shadowOffset = CGSize(width: 1, height: 1 )
            $0?.layer.shadowColor = UIColor.gray.cgColor
            $0?.layer.shadowRadius = 5
            $0?.layer.shadowOpacity = 0.5


        }
    }
    
    func buttonPutOut(sender:SpringButton) {
        let bool:CGFloat = sender.titleLabel?.text == "+" ? 1 : -1
        
        sender.animation =  ""
        sender.rotate = 450 * bool
        sender.animate()
        
            if bool == 1 {
                self.buttons.forEach(){
                    $0?.animation = ""
                    $0?.scaleX = 0
//                    $0?.scaleY = 1
                    $0?.duration = 1
                    $0?.animate()
                }
                sender.setTitle("×", for: .normal)
            }else {
                self.buttons.forEach(){
                    $0?.animation = "fadeOut"
                    $0?.duration = 1
                    $0?.animate()
                }
                sender.setTitle("+", for: .normal)
            }
    }
}


