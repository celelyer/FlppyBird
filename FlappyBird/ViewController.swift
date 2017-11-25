//
//  ViewController.swift
//  FlappyBird
//
//  Created by セロラー on 2017/11/20.
//  Copyright © 2017年 mikiya.tadano. All rights reserved.
//

import UIKit
import SpriteKit
import AudioToolbox


class ViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //SKViewに型を変換する
        let skView = self.view as! SKView
        
        //FPSを表示する
        skView.showsFPS = true
        
        //ノードの数を表示する
        skView.showsNodeCount = true
        
        //ビューと同じサイズでシーンを作成する
        let scene = GameScene(size:skView.frame.size)
        
        //ビューにシーンを表示する
        skView.presentScene(scene)
        
        
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //ステータスバーを消す
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }

}

