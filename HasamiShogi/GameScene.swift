//
//  GameScene.swift
//  HasamiShogi
//
//  Created by kamina on 2015/02/07.
//  Copyright (c) 2015年 com.ash1taka. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var scale:CGFloat = 1.0
    let masu_w:CGFloat = 62.0
    let masu_huchi:CGFloat = 41.0
    let board_full_size:CGFloat = 640.0
    var komas:[SKSpriteNode?] = [SKSpriteNode?](count: 18, repeatedValue: nil)
    let hShogi:HasamiShogi = HasamiShogi()
    
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
        
        for i in 0...8
        {
            NSLog("add %d", i);
            let koma = SKSpriteNode(imageNamed: "koma_ho.png")
            koma.setScale(scale)
            koma.anchorPoint = CGPointMake(0.5, 0.5)
            koma.position = getMasuPosition(i, y: 0)
            addChild(koma)
            komas[i] = koma
        }
        for i in 0...8
        {
            let koma_r = SKSpriteNode(imageNamed: "koma_ho_r.png")
            koma_r.setScale(scale)
            koma_r.anchorPoint = CGPointMake(0.5, 0.5)
            koma_r.position = getMasuPosition(i, y: 8)
            addChild(koma_r)
            komas[i+9] = koma_r
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch:AnyObject in touches {
            var t: UITouch = touch as UITouch
            var location: CGPoint = t.locationInNode(self)
            // NSLog("\n x = %f \n y = %f", location.x, location.y)
            var loc = touch.locationInNode(self)
            NSLog("%@ %@", loc.x, loc.y)
            if let pos_on_board = getPositionOnBorad(loc){
                NSLog("%d, %d", pos_on_board.0, pos_on_board.1)
                if hShogi.hasKoma(pos_on_board.0, y: pos_on_board.1)
                {
                    
                }
                
            }
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func getMasuPosition(x: Int, y: Int) -> CGPoint
    {
        let _x:CGFloat = CGFloat(x)
        let _y:CGFloat = CGFloat(y)
        let xpos:CGFloat = ((_x * masu_w) + masu_huchi + masu_w / 2.0) * scale
        let ypos:CGFloat = ((_y * masu_w) + masu_huchi + masu_w / 2.0) * scale
        return CGPointMake(xpos, ypos)
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
