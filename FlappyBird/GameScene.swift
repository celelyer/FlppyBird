//
//  GameScene.swift
//  FlappyBird
//
//  Created by セロラー on 2017/11/20.
//  Copyright © 2017年 mikiya.tadano. All rights reserved.
//

import SpriteKit

class GameScene: SKScene{
    
    var scrollNode:SKNode!
    
    //SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        //背景色を設定
        backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.nearest //処理速度を高める設定（画質低下）
        
        //必要な枚数を計算
        let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5.0)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
        
        //左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,resetGround]))
        
        //groundのスプライトを配置する
        stride(from: 0.0, to: needNumber, by: 1.0).forEach { i in
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: groundTexture.size().height / 2)
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        

        }
}
}
