//
//  Generics.swift
//  honhaSukidesuka
//
//  Created by yuka on 2018/05/08.
//  Copyright © 2018年 yuka. All rights reserved.
//

import UIKit

extension UIViewController: StatusAlertDelegate
{
    class var className: String {
        return "\(self)"
    }
    var className: String {
        return type(of: self).className
    }
    
    func onDismiss(sender: StatusAlert) {
        switch sender.tag {
        case 2:
            alertDelete(s_title: "本当に削除しますか？", s_message: "")
        case 4:
            alertSelectCamera(s_title: "本の写真", s_message: "")
        default:
            break
        }

    }

    
    func alertDelete(s_title:String, s_message:String){
        
        let dvc = self as! detailViewController
        //部品となるアラート
        let alert = UIAlertController(
            title: s_title ,
            message: s_message,
            preferredStyle: .alert
        )
        
        //ボタンを増やしたいときは、addActionをもう一つ作ればよい
        alert.addAction(
            UIAlertAction(
                title: "はい",
                style: .default,
                handler: {
                    action in dvc.deleteDetail()
            }
            )
        )
        
        
        alert.addAction(
            UIAlertAction(
                title: "やめる",
                style: .default,
                handler: nil
            )
        )
        // アラート表示
        present(alert, animated: true, completion: nil)
        
        
    }
    


    func alertNormal1(s_title:String, s_message:String,duration:Double,tag:Int) -> StatusAlert {
        let statusAlert:StatusAlert = StatusAlert.instantiate(
                withImage: UIImage(named: "Okayu_icon.jpg"),
                title: s_title,
                message: s_message,
                canBePickedOrDismissed: true)

        statusAlert.alertShowingDuration = duration
        statusAlert.appearance.messageFont = UIFont(name: "Hiragino Maru Gothic Pro", size: 16)!
        statusAlert.appearance.titleFont = UIFont(name: "Hiragino Maru Gothic Pro", size: 28)!
        statusAlert.delegate = self
        statusAlert.tag = tag

        return statusAlert
    }
    
    func alertSelectCamera(s_title:String, s_message:String){

        //部品となるアラート
        let alert = UIAlertController(
            title: s_title ,
            message: s_message,
            preferredStyle: .alert
        )
        
        switch self.className {
        case "submitViewController":
            let vc = self as! submitViewController
            alert.addAction(
                UIAlertAction(
                    title: "カメラ",
                    style: .default,
                    handler: {
                        action in vc.showCamera()
                }
                )
            )
            
            alert.addAction(
                UIAlertAction(
                    title: "フォトアルバム",
                    style: .default,
                    handler: {
                        action in vc.showAlbum()
                }
                )
            )
            
        default:
            let vc = self as! detailViewController
            alert.addAction(
                UIAlertAction(
                    title: "カメラ",
                    style: .default,
                    handler: {
                        action in vc.showCamera()
                }
                )
            )
            
            alert.addAction(
                UIAlertAction(
                    title: "フォトアルバム",
                    style: .default,
                    handler: {
                        action in vc.showAlbum()
                }
                )
            )
            
        }

        

        alert.addAction(
            UIAlertAction(
                title: "やめる",
                style: .default,
                handler: nil
            )
        )
        // アラート表示
        present(alert, animated: true, completion: nil)
        
        
    }

    
    
    
}
