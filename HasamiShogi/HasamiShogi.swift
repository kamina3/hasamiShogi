//
//  HasamiShogi.swift
//  HasamiShogi
//
//  Created by kamina on 2015/02/07.
//  Copyright (c) 2015年 com.ash1taka. All rights reserved.
//

import Foundation
import UIKit

typealias XY = (x:Int, y:Int)

class HasamiShogi {
    
    enum Judge{
        case Playing
        case P1Win
        case P2Win
    }
    
    enum Turn{
        case P1
        case P2
    }
    
    var winFlag:Bool = false
    var tmpWinOrLose:Judge = Judge.Playing
    var winOrLose:Judge = Judge.Playing
    var board:[Int] = [Int](count: 81, repeatedValue: -1)
    var friend:Int = 0
    var enemy:Int = 0
    var turn:Turn = Turn.P1
    
    init ()
    {
        initializeData()
    }
    
    func initializeData() -> Void
    {
        for i in 0...8
        {
            self[i, 0] = i
            self[i, 8] = i + 9
        }
        
        for i in 1...7
        {
            for j in 0...8
            {
                self[j, i] = -1
            }
        }
        
        friend = 0
        enemy = 0
        winOrLose = Judge.Playing
        tmpWinOrLose = Judge.Playing
        winFlag = false
        turn = Turn.P1
        
        return
    }
    
    subscript (x: Int, y:Int) -> Int
        {
        get {
            let idx = x + y * 9
            if idx >= 0 && idx < 81
            {
                return board[idx]
            }
            return -1
        }
        
        set (komaIdx) {
            
            let idx = x + y * 9
            if idx >= 0 && idx < 81
            {
                board[x + y * 9] = komaIdx
            }
        }
    }
    
    func moveTo(x:Int, y:Int, newX:Int, newY:Int) -> Bool
    {
        self[newX, newY] = self[x, y]
        self[x, y] = -1
        return true
    }
    
    func moveAndGetDiedIndexes(x:Int, y:Int, newX:Int, newY:Int) -> [Int]
    {
        moveTo(x, y: y, newX: newX, newY: newY)
        var me = self[newX, newY]
        var died:[Int] = [Int]()
        let vec = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        
        for v:XY in vec
        {
            died += getDiedIndex((newX, newY), vec:v)
        }
        if(turn == Turn.P1){
            friend += died.count
            turn = Turn.P2
        }else{
            enemy += died.count
            turn = Turn.P1
        }
        return died
    }
    
    func getDiedIndex(orgPoint:XY, vec:XY) -> [Int]
    {
        // 1ライン上調査
        var died:[Int] = [Int]()
        var diedPos:[XY] = [XY]()
        var curPoint:XY = orgPoint
        var orgIdx = self[orgPoint.x, orgPoint.y]
        while !isOutOfRange(curPoint)
        {
            curPoint = (curPoint.x + vec.x, curPoint.y + vec.y)
            if !isFriend(orgIdx, x: curPoint.x, y: curPoint.y) && self[curPoint.x, curPoint.y] != -1
            {
                died.append(self[curPoint.x, curPoint.y])
                diedPos.append( curPoint as XY)
            }else if isFriend(orgIdx, x: curPoint.x, y: curPoint.y){
                break
            }else{
                died = [Int]()
                diedPos = [XY]()
                break
            }
        }
        //走査してから削除処理
        for p in diedPos
        {
            self[p.x, p.y] = -1
        }
        
        // 囲まれた状態になってるか調査
        var tmpPos = [XY]()
        var tmpBoard = [Bool](count: 81, repeatedValue: false)
        let vecs:[XY] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        var died2 = [Int]()
        tmpPos.append((orgPoint.x + vec.x, orgPoint.y + vec.y) as XY)
        while tmpPos.count > 0
        {
            curPoint = tmpPos.removeLast()
            if !isOutOfRange(curPoint)
            {
                if self[curPoint.x, curPoint.y] == -1
                {
                    diedPos = [XY]()
                    died2 = [Int]()
                    break
                } else if !isFriend(orgIdx, x: curPoint.x, y: curPoint.y) {
                    died2.append(self[curPoint.x, curPoint.y])
                    for v in vecs
                    {
                        if !isOutOfRange((curPoint.x + v.x, curPoint.y + v.y)) &&
                            !tmpBoard[curPoint.x + v.x + (curPoint.y + v.y) * 9]
                        {
                            tmpPos.append((curPoint.x + v.x, curPoint.y + v.y))
                        }
                    }
                }
                tmpBoard[curPoint.x + curPoint.y * 9] = true
            }
        }
        //同様に走査してから削除処理
        for p in diedPos
        {
            self[p.x, p.y] = -1
        }
        return died + died2
    }
    
    func isOutOfRange(pos:XY) -> Bool
    {
        let idx = pos.x + pos.y * 9
        if idx >= 0 && idx < 81
        {
            return false
        }
        return true
    }
    
    //勝敗判定
    func judge() -> Judge
    {
        if friend >= 5
        {
            winOrLose = Judge.P1Win
            return Judge.P1Win
        }
        if enemy >= 5
        {
            winOrLose = Judge.P2Win
            return Judge.P2Win
        }
        
        // 3枚差分判定
        if !winFlag
        {
            let score_d = abs(friend - enemy)
            if score_d >= 3
            {
                
                winFlag = true
                tmpWinOrLose = friend > enemy ? Judge.P1Win : Judge.P2Win
            }
            return Judge.Playing
        }else{
            let score_d = abs(friend - enemy)
            if score_d >= 3
            {
                let newWinOrLose = friend > enemy ? Judge.P1Win : Judge.P2Win
                if newWinOrLose == tmpWinOrLose
                {
                    winOrLose = tmpWinOrLose
                    return tmpWinOrLose
                }
            } else {
                winFlag = false
            }
            return Judge.Playing
        }
    }
    
    func canPlay(komaIndex:Int) -> Bool
    {
        if (turn == Turn.P1 && komaIndex >= 0 && komaIndex < 9)
        {
            return true
        }
        if (turn == Turn.P2 && komaIndex >= 9 && komaIndex < 18)
        {
            return true
        }
        return false
    }
    
    func getCandidatePositions(x :Int, y: Int) -> [XY]
    {
        if self[x, y] == -1
        {
            return []
        }
        var pos_ary:[XY] = [XY]()
        pos_ary.append((x, y))
        
        var i = 1
        while x+i < 9
        {
            if self[x + i, y] == -1
            {
                pos_ary.append((x+i, y))
            }else{
                break
            }
            i++
        }
        i = 1
        while x-i >= 0
        {
            if self[x - i, y] == -1
            {
                pos_ary.append((x-i, y:y))
            }else{
                break
            }
            i++
        }
        i = 1
        while y+i < 9
        {
            if self[x, y + i] == -1
            {
                pos_ary.append((x, y:y+i))
            }else{
                break
            }
            i++
        }
        i = 1
        while y-i >= 0
        {
            if self[x, y-i] == -1
            {
                pos_ary.append((x, y-i))
            }else{
                break
            }
            i++
        }
        
        return pos_ary
    }
    
    func isFriend(me:Int, x:Int, y:Int) -> Bool
    {
        let koma = self[x, y]
        if (me >= 0 && me < 9 && koma >= 0 && koma < 9)
        {
            return true
        }
        else if (me >= 9 && me < 18 && koma >= 9 && koma < 18)
        {
            return true
        }else{
            return false
        }
    }
    
}