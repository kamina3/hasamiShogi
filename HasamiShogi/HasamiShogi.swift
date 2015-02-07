//
//  HasamiShogi.swift
//  HasamiShogi
//
//  Created by kamina on 2015/02/07.
//  Copyright (c) 2015年 com.ash1taka. All rights reserved.
//

import Foundation
import UIKit

class HasamiShogi {
    
    enum Judge{
        case Playing
        case Win
        case Lose
    }
    
    enum Turn{
        case Friend
        case Enemy
    }
    
    var winFlag:Bool = false
    var winOrLose:Judge = Judge.Playing
    var board:[Int] = [Int](count: 81, repeatedValue: -1)
    var friend:Int = 0
    var enemy:Int = 0
    var turn:Turn = Turn.Friend
    
    init ()
    {
        for i in 0...8
        {
            board[i] = i
            board[72+i] = i+9
        }
    }
    
    func moveTo(x:Int, y:Int, newX:Int, newY:Int) -> Bool
    {
        //移動判定は前でやってるのでここでやらない
//        if hasKoma(x, y: y) == -1
//        {
//            return false
//        }
//        if hasKoma(newX, y: newY) != -1
//        {
//            return false
//        }
        board[newX + newY * 9] = board[x + y * 9]
        board[x + y * 9] = -1
        return true
    }
    
    func moveAndGetDiedIndexes(x:Int, y:Int, newX:Int, newY:Int) -> [Int]
    {
        moveTo(x, y: y, newX: newX, newY: newY)
        var me = hasKoma(newX, y: newY)
        var died:[Int] = [Int]()
        let vec = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        
        for v:(Int, Int) in vec
        {
            // 境界チェック
            if ((0 < (newX + v.0) && (newX + v.1) < 9  &&
                 0 < (newY + v.0) && (newY + v.1) < 9) &&
                (0 < (newX + v.0*2) && (newX + v.1*2) < 9 &&
                 0 < (newY + v.0*2) && (newY + v.1*2) < 9))
            {
                if(!isFriend(me, x: newX + v.0, y: newY + v.1)
                    && isFriend(me, x: newX + v.0*2, y: newY + v.1*2)
                    && hasKoma(newX + v.0, y:newY + v.1) != -1)  // となりにコマが存在する
                {
                    died.append( hasKoma(newX+v.0, y: newY+v.1) )
                    board[(newX+v.0) + (newY+v.1)*9] = -1
                }
            }
        }
        if(turn == Turn.Friend){
            friend += died.count
            turn = Turn.Enemy
        }else{
            enemy += died.count
            turn = Turn.Friend
        }
        return died
    }
    
    func hasKoma(x:Int, y:Int) -> Int
    {
        NSLog("x:%d y:%d ->%d", x, y, board[x + y*9])
        return board[x + y*9]
    }
    
    //勝敗判定
    func judge() -> Judge
    {
        if friend >= 5
        {
            winOrLose = Judge.Win
            return Judge.Win
        }
        if enemy >= 5
        {
            winOrLose = Judge.Lose
            return Judge.Lose
        }
        
        // 3枚差分判定
        if !winFlag
        {
            let score_d = abs(friend - enemy)
            if score_d >= 3
            {
                
                winFlag = true
                winOrLose = friend > enemy ? Judge.Win : Judge.Lose
            }
            return Judge.Playing
        }else{
            let score_d = abs(friend - enemy)
            if score_d >= 3
            {
                let newWinOrLose = friend > enemy ? Judge.Win : Judge.Lose
                if newWinOrLose == winOrLose
                {
                    return newWinOrLose
                }
            } else {
                winFlag = false
            }
            return Judge.Playing
        }
    }
    
    func canPlay(komaIndex:Int) -> Bool
    {
        if (turn == Turn.Friend && komaIndex >= 0 && komaIndex < 9)
        {
            return true
        }
        if (turn == Turn.Enemy && komaIndex >= 9 && komaIndex < 18)
        {
            return true
        }
        return false
    }
    
    func getCandidatePositions(x :Int, y: Int) -> [(Int, Int)]
    {
        if hasKoma(x, y: y) == -1
        {
            return []
        }
        var pos_ary:[(Int, Int)] = [(Int, Int)]()
        pos_ary.append((x, y))
        
        var i = 1
        while x+i < 9
        {
            if hasKoma(x+i, y: y) == -1
            {
                pos_ary.append (x+i, y)
            }else{
                break
            }
            i++
        }
        i = 1
        while x-i >= 0
        {
            if hasKoma(x-i, y: y) == -1
            {
                pos_ary.append (x-i, y)
            }else{
                break
            }
            i++
        }
        i = 1
        while y+i < 9
        {
            if hasKoma(x, y: y+i) == -1
            {
                pos_ary.append (x, y+i)
            }else{
                break
            }
            i++
        }
        i = 1
        while y-i >= 0
        {
            if hasKoma(x, y: y-i) == -1
            {
                pos_ary.append (x, y-i)
            }else{
                break
            }
            i++
        }
        
        
        return pos_ary
    }
    
    func isFriend(me:Int, x:Int, y:Int) -> Bool
    {
        let koma = hasKoma(x, y: y)
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