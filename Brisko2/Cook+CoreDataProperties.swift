//
//  Cook+CoreDataProperties.swift
//  
//
//  Created by Matt Pancino on 6/11/18.
//
//

import Foundation
import CoreData


extension Cook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cook> {
        return NSFetchRequest<Cook>(entityName: "Cook")
    }

    @NSManaged public var cookDesc: String?
    @NSManaged public var meat: String?
    @NSManaged public var name: String?
    @NSManaged public var p1Target: Double
    @NSManaged public var p2Target: Double
    @NSManaged public var p3Target: Double
    @NSManaged public var p4Target: Double
    @NSManaged public var duration: NSDate?
    @NSManaged public var start: NSDate?
    @NSManaged public var rating: Int64
    @NSManaged public var weight: Double
    @NSManaged public var cookSeries: NSSet?

}

// MARK: Generated accessors for cookSeries
extension Cook {

    @objc(addCookSeriesObject:)
    @NSManaged public func addToCookSeries(_ value: TempEntry)

    @objc(removeCookSeriesObject:)
    @NSManaged public func removeFromCookSeries(_ value: TempEntry)

    @objc(addCookSeries:)
    @NSManaged public func addToCookSeries(_ values: NSSet)

    @objc(removeCookSeries:)
    @NSManaged public func removeFromCookSeries(_ values: NSSet)

}
