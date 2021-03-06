//
//  GameScene.swift
//  FlappyBird
//
//  Created by セロラー on 2017/11/20.
//  Copyright © 2017年 mikiya.tadano. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var appleNode:SKNode!
    var apple:SKNode!

    
    //AVAudioPlayerのインスタンスを作成
    var audioPlayerInstance : AVAudioPlayer! = nil
    
    
    
    //衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0   //0...00001
    let groundCategory: UInt32 = 1 << 1 //0...00010
    let wallCategory: UInt32 = 1 << 2   //0...00100
    let scoreCategory: UInt32 = 1 << 3  //0...01000
    let appleCategory: UInt32 = 1 << 4  //0...10000
    
    //スコア
    var score = 0
    var itemScore = 0
    var scoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard
    
    //SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        //重力を設定
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        physicsWorld.contactDelegate = self
        
        //背景色を設定
        backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //りんご用のノード
        appleNode = SKNode()
        scrollNode.addChild(appleNode)
        
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel()
        setupApple()
        
        //サウンドファイルのパスを生成
        let soundFilePath = Bundle.main.path(forResource: "get", ofType: "mp3")!
        let sound:URL = URL(fileURLWithPath: soundFilePath)
        
        //AVAoudioPlayerのインスタンスを作成
        do {
            audioPlayerInstance = try AVAudioPlayer(contentsOf: sound, fileTypeHint: nil)
        }catch{
            print("AVAudioPlayerインスタンス作成失敗")
        }
        //バッファに保持していつでも再生できるようにする
        audioPlayerInstance.prepareToPlay()
    }
    
    //画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if scrollNode.speed > 0 {
            //鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            //鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 { //鳥が動いていない時リスタート
            restart()
        }
    }
    
    func setupGround() {
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
        /* stride(from: 0.0, to: needNumber, by: 1.0).forEach { i in  [code] }
             0.0からneedNumberまで1.0感覚でiに数値が代入されるforループ
        */
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: groundTexture.size().height / 2)
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            //スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            //衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            //衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupCloud() {
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.nearest
        
        //必要な枚数を計算
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロースさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20.0)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0.0)
        
        //左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        //スプライトを配置する
        stride(from: 0.0, to: needCloudNumber, by: 1.0).forEach { i in
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 //一番後ろになるようにする
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
            
            //スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
        
    }
    
    func setupWall() {
        //壁の画像を読み込む
        let wallTtexture = SKTexture(imageNamed: "wall")
        wallTtexture.filteringMode = SKTextureFilteringMode.linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTtexture.size().width)
        
        //画面が今で移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4.0)
        
        //自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            //壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTtexture.size().width / 2, y: 0.0)
            wall.zPosition = -50.0  //雲より手前、地面より奥
            
            //画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            //壁のY座標を上下ランダムにさせる時の最大値
            let random_y_range = self.frame.size.height / 4
            //下の壁のY軸の下限
            let under_wall_lowest_y = UInt32(center_y - wallTtexture.size().height / 2 - random_y_range / 2)
            //1~random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform(UInt32(random_y_range))
            //Y軸の下限にランダムな値を足して下の壁のY座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            //キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 6
            
            //下側の壁を作成
            let under = SKSpriteNode(texture: wallTtexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            
            //スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTtexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
            //上側の壁を作成
            let upper = SKSpriteNode(texture: wallTtexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTtexture.size().height + slit_length)
            
            //スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTtexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
            
            //スコアアップ用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        //次の壁作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成->待ち時間->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupBird() {
        //鳥の画像を２種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = SKTextureFilteringMode.linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = SKTextureFilteringMode.linear
        
        //２種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        //スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        //物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        //衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory //当たった時に跳ね返る相手
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory //当たった時にdidBeginContactを呼び出す
        
        //アニメーションを設定
        bird.run(flap)
        
        //スプライトを追加する
        addChild(bird)
    }
    
    func setupApple() {
        //りんごの画像を読み込む
        let appleTexture = SKTexture(imageNamed: "apple")
        appleTexture.filteringMode = SKTextureFilteringMode.linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + appleTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveApple = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4.0)
        
        //自身を取り除くアクションを作成
        let removeApple = SKAction.removeFromParent()
        
        //２つのアニメーションを順に実行するアクションを作成
        let appleAnimation = SKAction.sequence([moveApple, removeApple])
        
        //りんごを生成するアクションを作成
        let createAppleAnimation = SKAction.run({
            //りんご関連のノードを乗せるノードを作成
            self.apple = SKNode()
            self.apple.position = CGPoint(x: self.frame.size.width + appleTexture.size().width / 2, y: 0.0)
            self.apple.zPosition = -55.0 //壁より奥
            
            //りんごのY軸の設定
            let apple_y = arc4random_uniform(UInt32(self.frame.size.height))
            
            //りんごの作成
            let Apple = SKSpriteNode(texture: appleTexture)
            Apple.position = CGPoint(x: 0.0, y: CGFloat(apple_y) - 1)
            
            //スプライトに物理演算を設定する
            Apple.physicsBody = SKPhysicsBody(rectangleOf: appleTexture.size())
            Apple.physicsBody?.categoryBitMask = self.appleCategory
            Apple.physicsBody?.isDynamic = false
            Apple.physicsBody?.contactTestBitMask = self.birdCategory
            
            
            self.apple.addChild(Apple)
            self.apple.run(appleAnimation)
            
            self.appleNode.addChild(self.apple)
            
        })
        //次のりんご作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.wait(forDuration: TimeInterval(1 + 2 * CGFloat(arc4random_uniform(2))))
        
        //壁を作成->待ち時間->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createAppleAnimation, waitAnimation]))
        
        appleNode.run(repeatForeverAnimation)
        
    }
    

    
    //SKPhysicsContactDelegateのメソッド。衝突した時に呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        //ゲームオーバーの時は何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            //スコア用の物体と衝突した
            print("scoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            
            //ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score + itemScore > bestScore {
                bestScore = score + itemScore
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
            
            
            
        } else if (contact.bodyA.categoryBitMask & appleCategory) == appleCategory || (contact.bodyB.categoryBitMask & appleCategory) == appleCategory {
            //りんごと衝突した
            print(appleNode)
            //効果音を再生する
            audioPlayerInstance.play()
            
            print("itemScoreUp")
            itemScore += 1
            itemScoreLabelNode.text = "Apple:\(itemScore)"
            
            //自身を取り除く
            if contact.bodyA.categoryBitMask & appleCategory == appleCategory{
                contact.bodyA.node?.removeFromParent()
            }else{
                contact.bodyB.node?.removeFromParent()
            }
            
            //ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score + itemScore > bestScore {
                bestScore = score + itemScore
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
        } else {
            //壁か地面と衝突した
            print("GameOver")
            
            //スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    //リスタート用メソッド
    func restart() {
        score = 0   //スコアを０に戻す
        scoreLabelNode.text = String("Score:\(score)")
        
        itemScore = 0
        itemScoreLabelNode.text = String("Apple:\(itemScore)")
        
        bird.position = CGPoint(x: self.frame.size.width*0.2, y: self.frame.size.height * 0.7)  //鳥の位置を初期位置に戻す
        bird.physicsBody?.velocity = CGVector.zero  //鳥の落下速度を０に戻す
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()    //壁をすべて取り除く
        appleNode.removeAllChildren()   //りんごをすべて取り除く
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    //スコア表示メソッド
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        scoreLabelNode.zPosition = 100 //一番手前に表示
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.size.height - 60)
        bestScoreLabelNode.zPosition = 100 //一番手前に表示
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        itemScoreLabelNode.zPosition = 100 //一番手前に表示
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "Apple:\(itemScore)"
        self.addChild(itemScoreLabelNode)
    }
}
