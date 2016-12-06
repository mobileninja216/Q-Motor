//
//  Sellingpoint.swift
//  
//
//  Created by Mahmood Nassar on 1/8/16.
//
//

import Foundation
import CoreData


class Sellingpoint: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var sellingpoint_name_ar: String?
    @NSManaged var sellingpoint_name_en: String?
    @NSManaged var updated_at: Int32

}
