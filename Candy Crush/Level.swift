//
//  Level.swift
//  Candy Crush
//
//  Created by amir lahav on 3.9.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9
let NumLevels = 4

class Level {
    
    var targetScore = 0
    var maximumMoves = 0
    
    var possibleSwaps = Set<Swap>()
    
    private var comboMultiplier = 0

    private var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
   
    
    init(filename: String) {

        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else {
            return }

        guard let tilesArray = dictionary["tiles"] as? [[Int]] else {

            return }
        
        targetScore = dictionary["targetScore"] as! Int
        maximumMoves = dictionary["moves"] as! Int

        for (row, rowArray) in tilesArray.enumerated() {

            let tileRow = NumRows - row - 1

            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
    }
    
   
    
    func shuffle() -> Set<Cookie> {
        
        var set: Set<Cookie>
        
        repeat {
            
            set = createInitialCookies()
            detectPossibleSwaps()
        }
            while possibleSwaps.count == 0
        
        
        return set
    }
    
    private func createInitialCookies() -> Set<Cookie> {
        var set = Set<Cookie>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if tiles[column, row] != nil {
                    
                    var cookieType: CookieType
                    
                    repeat {
                        
                        cookieType = CookieType.random()
                        
                    } while (column >= 2 &&
                        cookies[column - 1, row]?.cookieType == cookieType &&
                        cookies[column - 2, row]?.cookieType == cookieType)
                        || (row >= 2 &&
                            cookies[column, row - 1]?.cookieType == cookieType &&
                            cookies[column, row - 2]?.cookieType == cookieType)
                    

                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    
                    cookies[column, row] = cookie
                    if cookies[8,8] != nil {
                        for row in 0..<NumRows {
                            for column in 0..<NumColumns {
                            
                                if cookies[column, row] == nil {
                                }}
                            
                            }
                        }

                    set.insert(cookie)
                }
            }
            
        }
        return set
    }
    
    
    private func detectHorizontalMatches() -> Set<Chain> {

        var set = Set<Chain>()

        for row in 0..<NumRows {
            var column = 0
            while column < NumColumns-2 {

                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType

                    if cookies[column + 1, row]?.cookieType == matchType &&
                        cookies[column + 2, row]?.cookieType == matchType {

                        let chain = Chain(chainType: .Horizontal)
                        repeat {
                            chain.addCookie(cookie: cookies[column, row]!)
                            column += 1
                        } while column < NumColumns && cookies[column, row]?.cookieType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }    

                column += 1
            }
        }
        return set
    }
    
    private func detectVerticalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            var row = 0
            while row < NumRows-2 {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    if cookies[column, row + 1]?.cookieType == matchType &&
                        cookies[column, row + 2]?.cookieType == matchType {
                        let chain = Chain(chainType: .Vertical)
                        repeat {
                            chain.addCookie(cookie: cookies[column, row]!)
                            row += 1
                        } while row < NumRows && cookies[column, row]?.cookieType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }    
                row += 1
            }
        }
        return set
    }
    
    private func calculateScores(chains: Set<Chain>) {
        
        for chain in chains {
            chain.score = 60 * (chain.length - 2) * comboMultiplier
            comboMultiplier += 1

        }
    }
    func resetComboMultiplier() {
        comboMultiplier = 1
    }
    
    
    func removeMatches() -> Set<Chain> {
        
        
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeCookies(chains: horizontalChains)
        removeCookies(chains: verticalChains)
        
        calculateScores(chains: horizontalChains)
        calculateScores(chains: verticalChains)

        
        return horizontalChains.union(verticalChains)
    }
    
    
    private func removeCookies(chains: Set<Chain>) {
        for chain in chains {
            for cookie in chain.cookies {
                cookies[cookie.column, cookie.row] = nil
            }
        }
    }
    
    func fillHoles() -> [[Cookie]] {
        var columns = [[Cookie]]()

        for column in 0..<NumColumns {
            var array = [Cookie]()
            for row in 0..<NumRows {

                // check if we find gap
                if tiles[column, row] != nil && cookies[column, row] == nil {

                    for lookup in (row + 1)..<NumRows {
                        if let cookie = cookies[column, lookup] {
                            
                            //update model
                            cookies[column, lookup] = nil
                            cookies[column, row] = cookie
                            
                            cookie.row = row

                            array.append(cookie)

                            break
                        }
                    }
                }
            }

            if !array.isEmpty {
                columns.append(array)
            }
        }
        print("this is columns array:\(columns)")
        return columns
    }
    
    func topUpCookies() -> [[Cookie]] {
        var columns = [[Cookie]]()
        var cookieType: CookieType = .Unknown
        
        for column in 0..<NumColumns {
            var array = [Cookie]()
            

            var row = NumRows - 1
            while row >= 0 && cookies[column, row] == nil {

                if tiles[column, row] != nil {

                    var newCookieType: CookieType
                    repeat {
                        newCookieType = CookieType.random()
                    } while newCookieType == cookieType
                    cookieType = newCookieType

                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    array.append(cookie)
                }
                
                row -= 1
            }

            if !array.isEmpty {
                columns.append(array)
            }
        }
        print("number of columns \(columns.count)")
        return columns
    }
    
    func performSwap(swap: Swap) {
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
    
    
    func cookieAtColumn(column: Int, row: Int) -> Cookie? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cookies[column, row]
    }
    
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
        
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let cookie = cookies[column, row] {
                    
                    if column < NumColumns - 1 {
                        // Have a cookie in this spot? If there is no tile, there is no cookie.
                        if let other = cookies[column + 1, row] {
                            // Swap them
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column: column + 1, row: row) ||
                                hasChainAtColumn(column: column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            // Swap them back
                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                        }
                    }
                    if row < NumRows - 1 {
                        if let other = cookies[column, row + 1] {
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column: column, row: row + 1) ||
                                hasChainAtColumn(column: column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            // Swap them back
                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }
                }
            }
        }
        
        possibleSwaps = set

    }
    
    private func hasChainAtColumn(column: Int, row: Int) -> Bool {
        let cookieType = cookies[column, row]!.cookieType
        
        // Horizontal chain check
        var horzLength = 1
        
        // Left
        var i = column - 1
        while i >= 0 && cookies[i, row]?.cookieType == cookieType {
            i -= 1
            horzLength += 1
        }
        
        // Right
        i = column + 1
        while i < NumColumns && cookies[i, row]?.cookieType == cookieType {
            i += 1
            horzLength += 1
        }
        if horzLength >= 3 {
            
            return true }
        
        // Vertical chain check
        var vertLength = 1
        
        // Down
        i = row - 1
        while i >= 0 && cookies[column, i]?.cookieType == cookieType {
            i -= 1
            vertLength += 1
        }
        
        // Up
        i = row + 1
        while i < NumRows && cookies[column, i]?.cookieType == cookieType {
            i += 1
            vertLength += 1
        }
        return vertLength >= 3
    }
    
    


    
    

    
    
}



