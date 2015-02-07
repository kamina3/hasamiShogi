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
    
    var board:[Int] = [Int](count: 81, repeatedValue: -1)
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
        if hasKoma(x, y: y) == -1
        {
            return false
        }
        if hasKoma(newX, y: newY) != -1
        {
            return false
        }
        board[newX + newY * 9] = board[x + y * 9]
        board[x + y * 9] = -1
        return true
    }
    
    func hasKoma(x:Int, y:Int) -> Int
    {
        NSLog("x:%d y:%d ->%d", x, y, board[x + y*9])
        return board[x + y*9]
    }
    
    //勝敗判定
    func judge() -> Judge
    {
     
        return HasamiShogi.Judge.Playing
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
    
}