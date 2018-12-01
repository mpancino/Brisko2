//
//  TempEntry+CoreDataProperties.swift
//  
//
//  Created by Matt Pancino on 6/11/18.
//
//

import Foundation
import CoreData


extension TempEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TempEntry> {
        return NSFetchRequest<TempEntry>(entityName: "TempEntry")
    }

    @NSManaged public var p1: Double
    @NSManaged public var p2: Double
    @NSManaged public var p3: Double
    @NSManaged public var p4: Double
    @NSManaged public var time: NSDate?

}
