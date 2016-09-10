//
//  String+Extensions.swift
//  RegX
//
//  Created by Krunoslav Zaher on 9/9/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension String {
    func count() -> Int {
        return distance(from: startIndex, to: self.endIndex)
    }

    func index(at: Int) -> Index {
        return self.index(self.startIndex, offsetBy: at)
    }

    func character(_ index: Int) -> Character {
        let characterIndex = self.characters.index(self.characters.startIndex, offsetBy: index)
        return self.characters[characterIndex]
    }
}
