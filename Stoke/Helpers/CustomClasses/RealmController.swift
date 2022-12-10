//
//  RealmController.swift
//  Stoke
//
//  Created by Admin on 23/06/21.
//

import Foundation
import RealmSwift

class RealmController{
    
    private init(){}
    static let shared = RealmController()
    var realm : Realm{

        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                
        })

        return  try! Realm(configuration: config)
    }
    
    
    //Get Current Schema version of Realm
    var getCurrentSchemaVersion : UInt64{
        do {
            let version = try schemaVersionAtURL(realm.configuration.fileURL!)
            printDebug("schema version \(version)")
            return version
        } catch  {
            printDebug(error)
        }

        return 0
    }
    
    
    func generateUniqueID() -> String {
        return "\(Int64(Date().timeIntervalSince1970) * 1000)"
    }
    
    
    func setDefaultRealmForUser(username: String) {
        
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    
    func create<T:Object>(_ object: T){
        AppThread.realm.async {
            let realm = RealmController.shared.realm
            do{
                try realm.write {
                    realm.add(object, update: .all)
                }
            }catch{
                printDebug(error)
            }
        }
    }
        
    func fetchObjects<T: Object>(_ object: T.Type,block: @escaping ((Results<T>) -> Void)) {
        
        AppThread.realm.async {
            let realm = RealmController.shared.realm
           let results = realm.objects(object.self)
            block(results)
        }
    }
    
    func fetchObject<T: Object>(_ object: T.Type , key : String , value : Any) -> Results<T>? {
        
        var results : Results<T>!
        AppThread.realm.sync {
            let realm = RealmController.shared.realm
            
            let predicate = NSPredicate(format: "\(key) = %@", value as! CVarArg)
            results = realm.objects(object.self).filter(predicate)
        }
        return results
        
    }
    
    func fetchObject<T: Object>(_ object: T.Type , primaryKey : Any,block: @escaping ((T?) -> Void)){
        
        AppThread.realm.async {
            let realm = RealmController.shared.realm
            let result = realm.object(ofType: object, forPrimaryKey: primaryKey)
            block(result)
            
        }
    }
    
    func fetchObjectOnMainThread<T: Object>(_ object: T.Type , primaryKey : Any)-> T?{
        
            let realm = RealmController.shared.realm
            let result = realm.object(ofType: object, forPrimaryKey: primaryKey)
           return result
    }

    
    
    func update<T:Object>(_ object : T , dict : [String:Any]){
        
            let realm = RealmController.shared.realm
            do{
                try realm.write {
                    for (key,value) in dict{
                        object.setValue(value, forKey: key)
                    }
                }
            }catch{
                printDebug(error)
            }
    }
    
    func update<T:Object>(_ object : T){
        
        AppThread.realm.async {
            let realm = RealmController.shared.realm
            do{
                try realm.write {
                    realm.add(object, update: .all)
                }
            }catch{
                printDebug(error)
            }
        }
    }
    
    
    func save<T:Object>(_ objects : [T]){
        
        AppThread.realm.async {
            let realm = RealmController.shared.realm
            do{
                try realm.write {
                    realm.add(objects, update: .all)
                }
            }catch{
                printDebug(error)
            }
        }
    }
    
    func delete<T:Object>(_ object : T){
        
        AppThread.realm.async {
            let realm = RealmController.shared.realm
        do{
            try realm.write {
                realm.delete(object)
            }
        }catch{
            printDebug(error)
            }
        }
    }
    
    // delete table
    func deleteDatabase() {
        AppThread.realm.async {
            do{
                try self.realm.write {
                    self.realm.deleteAll()
                }
            }catch{
                printDebug(error)
            }
        }
    }
    
    
    func post(_ error : Error){
        NotificationCenter.default.post(name: NSNotification.Name("RealmError"), object: error)
    }
    
    func observeRealmError(in vc: UIViewController , completion : @escaping (Error?) -> Void){
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("RealmError"), object: nil, queue: nil) { (notification) in
            completion(notification.object as? Error)
        }
    }
    
    func stopObservingError(in vc: UIViewController){
        NotificationCenter.default.removeObserver(vc, name: NSNotification.Name("RealmError"), object: nil)
    }
}


enum AppThread {

    static let main = DispatchQueue.main
    static let background = DispatchQueue.global(qos: .background)
    static let realm = DispatchQueue(label: "realm", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
}
