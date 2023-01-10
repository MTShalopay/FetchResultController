//
//  CoreDataManager.swift
//  FetchResultController
//
//  Created by Shalopay on 06.01.2023.
//

import Foundation
import CoreData
class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        //reloadFolders()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FetchResultController")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    //MARK: fetchRequest CoreData
//    var jokes: [Joke] {
//        let fetchRequest: NSFetchRequest<Joke> = Joke.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreate", ascending: false)]
//        return (try? persistentContainer.viewContext.fetch(fetchRequest)) ?? []
//    }
//
//    func createJoke(from JokeCodable: JokeCodable, completionHandler: ((_ error: String?)->Void)? ) {
//        persistentContainer.performBackgroundTask { (context) in
//            let joke = Joke(context: context)
//            joke.uid = JokeCodable.id
//            joke.text = JokeCodable.value
//            joke.dateCreate = Date()
//            do {
//                try context.save()
//                completionHandler?(nil)
//            } catch {
//                print("ERROR create Joke: \(error.localizedDescription)")
//                completionHandler?("Joke ERROR: \(error.localizedDescription)")
//            }
//        }
//    }
    func createJoke(from JokeCodable: JokeCodable) {
        persistentContainer.performBackgroundTask { (context) in
            let joke = Joke(context: context)
            joke.uid = JokeCodable.id
            joke.text = JokeCodable.value
            joke.dateCreate = Date()
            JokeCodable.categories.forEach { (category) in
                let categoryJoke = self.getCategory(by: category, contex: context)
                joke.addToCategories(categoryJoke)
            }
            do {
                try context.save()
            } catch {
                print("ERROR create Joke: \(error.localizedDescription)")
            }
        }
    }
    
    func getCategory(by name: String, contex: NSManagedObjectContext) -> Categories {
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
            if let category = (try? contex.fetch(request).first) {
                return category
            } else {
                let newCategory = Categories(context: contex)
                newCategory.name = name
                return newCategory
            }
    }
    
    func deleteJoke(joke: Joke) {
        persistentContainer.viewContext.delete(joke)
        saveContext()
    }
    func deleteCategory(category: Categories) {
        category.jokes?.forEach({ (joke) in
            deleteJoke(joke: joke as! Joke)
        })
        persistentContainer.viewContext.delete(category)
        saveContext()
    }
}
