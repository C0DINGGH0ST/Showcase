//
//  DataService.swift
//  Showcase
//
//  Created by Tbakhi on 3/21/16.
//  Copyright © 2016 Tbakhi. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    static let ds = DataService() // Static means one instance in memory, globally accessible
    
        private var _REF_BASE = Firebase(url: "https://iat-games-showcase.firebaseio.com")
    
    var REF_BASE: Firebase {
        
        return _REF_BASE
    }
    

    
    
    
    
}
