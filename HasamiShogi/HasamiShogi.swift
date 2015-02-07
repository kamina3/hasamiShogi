//
//  HasamiShogi.swift
//  HasamiShogi
//
//  Created by kamina on 2015/02/07.
//  Copyright (c) 2015年 com.ash1taka. All rights reserved.
//

import Foundation

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
        if !hasKoma(x, y: y)
        {
            return false
        }
        if hasKoma(newX, y: newY)
        {
            return false
        }
        board[newX + newY * 9] = board[x + y * 9]
        board[x + y * 9] = -1
        return true
    }
    
    func hasKoma(x:Int, y:Int) -> Bool
    {
        return board[x + y*9] != -1
    }
    
    //勝敗判定
    func judge() -> Judge
    {
     
        return HasamiShogi.Judge.Playing
    }
}