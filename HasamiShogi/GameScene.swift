//
//  GameScene.swift
//  HasamiShogi
//
//  Created by kamina on 2015/02/07.
//  Copyright (c) 2015年 com.ash1taka. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    // ui 定数
    var scale:CGFloat = 1.0
    let masu_w:CGFloat = 62.0
    let masu_huchi:CGFloat = 41.0
    let board_full_size:CGFloat = 640.0
    
    // ゲームオブジェクト
    let hShogi:HasamiShogi = HasamiShogi()
    var selected_index:Int = -1
    var candidate_pos:[(Int, Int)] = [(Int, Int)]()
    var initFlag:Bool = false
    
    // UIオブジェクト
    var komas:[SKSpriteNode?] = [SKSpriteNode?](count: 18, repeatedValue: nil)
    var candidate_panel:[SKSpriteNode] = [SKSpriteNode]()
    var friendLabel:SKLabelNode! = SKLabelNode(text: "先手: 0")
    var enemyLabel:SKLabelNode! = SKLabelNode(text: "後手: 0")
    var turnLabel:SKLabelNode = SKLabelNode(text: "自分")
    var resultLabel:SKLabelNode = SKLabelNode(text: "")
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        self.scaleMode = SKSceneScaleMode.AspectFit;
        self.backgroundColor = SKColor.whiteColor()
        
        let bg = SKSpriteNode(imageNamed: "ban.png")
        scale = self.frame.size.width / bg.size.width
        bg.setScale(scale)
        NSLog("scale %@", scale);
        bg.anchorPoint = CGPointMake(0.5, 0.5);
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        addChild(bg);
        
        initializeData()
        
        friendLabel.position = CGPointMake(self.frame.size.width / 3.0, 10*scale)
        friendLabel.fontColor = SKColor.blackColor()
        friendLabel.fontSize = 48
        addChild(friendLabel)
        enemyLabel.position = CGPointMake(self.frame.size.width * 2.0 / 3.0, 10*scale)
        enemyLabel.fontColor = SKColor.blackColor()
        enemyLabel.fontSize = 48
        addChild(enemyLabel)
        
        turnLabel.position = CGPointMake(self.frame.size.width / 2.0, 10*scale)
        turnLabel.fontColor = SKColor.blackColor()
        turnLabel.fontSize = 52
        addChild(turnLabel)
        
        resultLabel.fontColor = SKColor.blackColor()
        resultLabel.fontSize = 64 * scale
        resultLabel.position = CGPointMake(self.frame.width/2, self.frame.height/2)
        resultLabel.zPosition = 5
        addChild(resultLabel)
        
        updateStatus()
        
    }
    
    func initializeData() -> Void
    {
        for spr in komas
        {
            spr?.removeFromParent()
        }
        
        for i in 0...8
        {
            let koma = createKomaSprite("koma_ho.png", x: i, y: 0)
            addChild(koma)
            komas[i] = koma
        }
        for i in 0...8
        {
            let koma_r = createKomaSprite("koma_to_r.png", x: i, y: 8)
            addChild(koma_r)
            komas[i+9] = koma_r
        }
        hShogi.initializeData()
        resultLabel.hidden = true
        initFlag = false
        updateStatus()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        if initFlag
        {
            initFlag = false
            initializeData()
            return
        }
        if hShogi.winOrLose != HasamiShogi.Judge.Playing
        {
            initFlag = true
            resultLabel.text = "最初からやる？"
            return
        }
        for touch:AnyObject in touches {
            var loc = touch.locationInNode(self)
            NSLog("%@ %@", loc.x, loc.y)
            if let pos_on_board = getPositionOnBorad(loc){
                if selected_index != -1
                {
                    NSLog("%d, %d", pos_on_board.0, pos_on_board.1)
                    // 選択状態で同じものタップすると状態クリア
                    if (candidate_pos[0].0 == pos_on_board.0 && candidate_pos[0].1 == pos_on_board.1)
                    {
                        clearBoardState()
                        return
                    }
                    
                    // 動かす
                    moveKoma(pos_on_board)
                    
                }else{
                    //タップした場所にコマがあれば選択状態に変化
                        NSLog("%d, %d", pos_on_board.0, pos_on_board.1)
                        setCandidateTile(pos_on_board.0, y: pos_on_board.1)
                    
                }
            }
            
        }
        updateStatus()
    }

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func updateStatus() -> Void
    {
        friendLabel.text = "先手: " + String(hShogi.friend)
        enemyLabel.text = "後手: " + String(hShogi.enemy)
        turnLabel.text = hShogi.turn == HasamiShogi.Turn.P1 ? "あなた" : "相手"
        return
    }
    
    func createKomaSprite(spriteName: String, x: Int, y: Int) -> SKSpriteNode
    {
        let sprite = SKSpriteNode(imageNamed: spriteName)
        sprite.anchorPoint = CGPointMake(0.5, 0.5)
        sprite.setScale(scale)
        sprite.position = getMasuPosition(x, y: y)
        sprite.zPosition = 3
        return sprite
    }
    
    func clearBoardState() -> Void
    {
        if selected_index == -1
        {
            return
        }
        
        let k = komas[selected_index]
        var textureName:String
        if (selected_index < 9){
            textureName = "koma_ho.png"
        }else{
            textureName = "koma_to_r.png"
        }
        k?.texture = SKTexture(imageNamed: textureName)
        selected_index = -1
        var canSpr:SKSpriteNode? = nil
        while true {
            if candidate_panel.count == 0
            {
                break
            }
            canSpr = candidate_panel.removeLast()
            canSpr?.removeFromParent()
            
        }
    }
    
    func setCandidateTile(x :Int, y :Int) -> Void
    {
        let spriteIndex = hShogi.exist(x, y: y)
        if spriteIndex != -1 && hShogi.canPlay(spriteIndex)
        {
            
            var textureName:String
            if (spriteIndex < 9){
                textureName = "koma_ho_hover.png"
            }else{
                textureName = "koma_to_hover_r.png"
            }
            komas[spriteIndex]?.texture = SKTexture(imageNamed: textureName)
            self.selected_index = spriteIndex
            candidate_pos = hShogi.getCandidatePositions(x, y: y)
            for p:(Int, Int) in candidate_pos
            {
                let canSpr = SKSpriteNode(imageNamed: "masu_hover.png")
                canSpr.anchorPoint = CGPointMake(0.5, 0.5)
                canSpr.position = getMasuPosition(p.0, y: p.1)
                canSpr.zPosition = 2
                canSpr.setScale(scale)
                addChild(canSpr)
                candidate_panel.append(canSpr)
                
            }
        }
    }
    
    func moveKoma(pos_on_board: (Int, Int)) -> Void
    {
        for p in candidate_pos
        {
            if p.0 == pos_on_board.0 && p.1 == pos_on_board.1
            {
//                komas[selected_index]?.position = getMasuPosition(p.0, y: p.1)
                let moveP =  getMasuPosition(p.0, y: p.1)
                let orgP = komas[selected_index]!.position
                let moveVec = CGVectorMake(moveP.x - orgP.x, moveP.y - orgP.y)
                let moveAct = SKAction.moveBy(moveVec, duration: 0.5)
                komas[selected_index]?.runAction(moveAct)
                
                let died:[Int] = hShogi.moveAndGetDiedIndexes(candidate_pos[0].0 , y: candidate_pos[0].1, newX: p.0, newY: p.1)
                // sound
                let soundFileName = hShogi.turn != HasamiShogi.Turn.P1 ? "senteaction.wav" : "goteaction.wav"
                let soundAct = SKAction.playSoundFileNamed(soundFileName, waitForCompletion: false)
                runAction(soundAct)
                if died.count > 0
                {
                    let soundFileName = "get.wav"
                    let soundAct = SKAction.playSoundFileNamed(soundFileName, waitForCompletion: false)
                    runAction(soundAct)
                }
                for dIndex in died
                {
//                    if dIndex == -1 {continue} //どっか処理甘い　-1が飛んでくる
                    komas[dIndex]?.removeFromParent()
                    komas[dIndex] = nil
                }
                checkFinishGame()
                clearBoardState()
                return
            }
        }
        // 動かせる場所をタップしてない
        let soundFileName = "cannotput.wav"
        let soundAct = SKAction.playSoundFileNamed(soundFileName, waitForCompletion: false)
        runAction(soundAct)
        return;
    }
    
    func getMasuPosition(x: Int, y: Int) -> CGPoint
    {
        let _x:CGFloat = CGFloat(x)
        let _y:CGFloat = CGFloat(y)
        let xpos:CGFloat = ((_x * masu_w) + masu_huchi + masu_w / 2.0) * scale
        let ypos:CGFloat = ((_y * masu_w) + masu_huchi + masu_w / 2.0) * scale
        return CGPointMake(xpos, ypos)
    }
    
    func checkFinishGame() -> Void
    {
        let flag:HasamiShogi.Judge = hShogi.judge()
        if flag != HasamiShogi.Judge.Playing
        {
            let txt:String = (flag == HasamiShogi.Judge.P1Win) ? "勝ち！" : "負け..."
            resultLabel.text = "あなたの" + txt
            resultLabel.hidden = false
            let soundFileName = "gamefinish.wav"
            let soundAct = SKAction.playSoundFileNamed(soundFileName, waitForCompletion: false)
            runAction(soundAct)
        }
    }
    
    func getPositionOnBorad(pos:CGPoint) -> (Int, Int)? {
        if pos.x < masu_huchi*scale || pos.x > (board_full_size - masu_huchi)*scale{
            return nil
        }
        if pos.y < masu_huchi*scale || pos.y > (board_full_size - masu_huchi)*scale{
            return nil
        }
        var x:Int = 0
        var y:Int = 0
        for i in 0...8
        {
            let _i:CGFloat = CGFloat(i)
            var _ipos:CGFloat = ((_i * masu_w) + masu_huchi) * scale
            if pos.x > _ipos
            {
                x = i            }
            if pos.y > _ipos
            {
                y = i
            }
        }
        NSLog("x=%d y= %d", x, y)
        return (x, y)
    }
}
