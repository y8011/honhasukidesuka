//
//  SideMenu.swift
//  honhaSukidesuka
//
//  Created by yuka on 2018/01/11.
//  Copyright © 2018年 yuka. All rights reserved.
//

import UIKit

@objc protocol SideMenuDelegate {
    func onClickButton(sender:UIButton)
}

class SideMenu: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */


    //サイドメニューのサイズ
    var size: CGRect?
    //メニュー閉じる用
    var clearView : UIView!
    var leftConstraint: NSLayoutConstraint!
    var parentVC: UIViewController!
    var isSideMenuhidden: Bool = true

    var searchTextField: UITextField!
    //デリゲートのインスタンスを宣言
    weak var delegate: SideMenuDelegate?

    //イニシャライザー
    init(image: [UIImage],parentViewController: UIViewController) {
        self.size = CGRect(x:UIScreen.main.bounds.width, //画面の外に配置
            y:0,
            width:UIScreen.main.bounds.width*2,
            height:UIScreen.main.bounds.height
        )
        super.init(frame: size!)
        //サイドメニューの背景色
        self.backgroundColor = UIColor(red: 255/255, green: 224/255, blue: 0, alpha: 0.8)
        //サイドメニューの背景色の透過度
        //self.alpha = 0.8
        
        //ボタンをおした時にbuttonSet関数を呼び出す
        self.buttonSet(num: image.count,image: image)
 ////////////////////////////////////追加
        searchTextField = UITextField(frame: CGRect(x:80+20+25,
                                                  y:(Int(UIScreen.main.bounds.height) - (100+120*1-40+15)),
                                                  width:Int(UIScreen.main.bounds.width/2), height:30))
        searchTextField.layer.cornerRadius = 5
        searchTextField.backgroundColor = UIColor.white
        
        self.addSubview(searchTextField)
////////////////////////////////////
        //親ViewControllerを指定
        self.parentVC = parentViewController
        
        //メニュー以外の場所をタップしたときにメニューを下げる
        clearView =
            UIView(frame:CGRect(x:0,y:0,
                                width:UIScreen.main.bounds.width,
                                height:UIScreen.main.bounds.height
            ))
        clearView.alpha = 1.0//
        parentVC.view.addSubview(clearView)
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(self.clearViewTapped)
        )
        tapGesture.numberOfTapsRequired = 1
        clearView.isHidden = true
        clearView.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func clearViewTapped(){
        print(#function)
       // if clearView.isHidden == false {
            UIView.animate(withDuration: 0.8,
                           animations: {
                            self.frame.origin.x = UIScreen.main.bounds.width
                            self.searchButton.backgroundColor = UIColor.white
            },
                           completion:nil)
        //    clearView.isHidden = true
       // }

        
    }
        

    //UIViewを継承したクラスには必要?ここら辺よくわかりません
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //親ビューで指定した画像の数だけボタンを生成、配置
    var searchButton:UIButton!
    func buttonSet(num:Int, image:[UIImage]){
        
        print(#function)
        for i in 0..<num{
            let button =
                UIButton(frame:CGRect(x:20,
                                      y:(Int(UIScreen.main.bounds.height) - (100+120*i)),
                                      width:80, height:80))
            //ボタンの画像
            button.setImage(image[i], for: .normal)
            //ボタンの四隅に余白をつける
            button.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
            //ボタンの背景色
            button.backgroundColor = UIColor.white
            // サイズの半分の値を設定 (丸いボタンにするため)
            button.layer.cornerRadius = 40
            //ボタンにタグをつける
            button.tag = i
            //ボタンをおした時の動作
            button.addTarget(self,
                             action:#selector(self.onClickButton(sender:)),
                             for: .touchUpInside)
            if i == 1{
                searchButton = button
            }
            self.addSubview(button)
        }
    }
    
    func getEdgeGesture(sender: UIScreenEdgePanGestureRecognizer) {
        //移動量を取得する。
        let move:CGPoint = sender.translation(in: parentVC.view)
        
        //画面の端からの移動量
        self.frame.origin.x += move.x
        //画面表示を更新する。
        self.layoutIfNeeded()
        
        //ドラッグ終了時の処理
        if(sender.state == UIGestureRecognizerState.ended) {
            if(self.frame.origin.x < UIScreen.main.bounds.width - parentVC.view.frame.size.width/4) {
                print("成功！")
                
                //ドラッグの距離が画面幅の1/2を超えた場合は全部出す
                if(self.frame.origin.x < UIScreen.main.bounds.width - parentVC.view.frame.size.width/2)
                {
                    UIView.animate(withDuration: 0.8,
                                   animations: {
                                    self.frame.origin.x = 0
                                    self.searchButton.backgroundColor = UIColor.brown
                    },
                                   completion:nil)
                    
                    
                }
                else {
                    //ドラッグの距離が画面幅の1/3を超えた場合はメニューを出す
                    UIView.animate(withDuration: 0.8,
                                   animations: {
                                    self.frame.origin.x = UIScreen.main.bounds.width*2/3
                    },
                                   completion:nil)
                }
                //後述
                //clearView.isHidden = false
                
            }else {
                //ドラッグの距離が画面幅の1/3以下の場合はそのままメニューを右に戻す。
                UIView.animate(withDuration: 0.8,
                               animations: {
                                self.frame.origin.x = UIScreen.main.bounds.width
                },
                               completion:nil)
            }
        }
        //移動量をリセットする。
        sender.setTranslation(CGPoint.zero, in: parentVC.view)
    }

    //委譲するメソッド
    @objc func onClickButton(sender:UIButton){
        self.delegate?.onClickButton(sender: sender)
    }
    
    func zendashi(){
        UIView.animate(withDuration: 0.8,
                       animations: {
                        self.frame.origin.x = 0
                        self.searchButton.backgroundColor = UIColor.brown
        },
                       completion:nil)
    }
    
    
}




