//
//  CategoriesViewContoller.swift
//  FetchResultController
//
//  Created by Shalopay on 06.01.2023.
//

import UIKit
import CoreData
class CategoriesViewContoller: UIViewController {
    let coreDataManager = CoreDataManager.shared
    
    private lazy var fetchResultController: NSFetchedResultsController<Categories> = {
        let request:NSFetchRequest<Categories> = Categories.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
       let frc = NSFetchedResultsController(fetchRequest: request,
                                            managedObjectContext: coreDataManager.persistentContainer.viewContext,
                                            sectionNameKeyPath: nil,
                                            cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    private lazy var categoriesTableView: UITableView = {
        let tableview = UITableView(frame: .zero, style: .grouped)
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableview.dataSource = self
        tableview.delegate = self
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 50
        tableview.translatesAutoresizingMaskIntoConstraints = false
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupView()
        do {
            try fetchResultController.performFetch()
        } catch {
            print("ERROR FetchResultController: \(error.localizedDescription)")
        }
        
    }
    private func setupNavigationController(){
        title = "Категории"
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    private func setupView() {
        view.addSubview(categoriesTableView)
        NSLayoutConstraint.activate([
            categoriesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
extension CategoriesViewContoller: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let category = fetchResultController.object(at: indexPath)
        cell.textLabel?.text = category.name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let jokesVC = JokesViewController()
        let category = fetchResultController.object(at: indexPath)
        jokesVC.categories = category
        jokesVC.title = category.name
        navigationController?.pushViewController(jokesVC, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let category = fetchResultController.object(at: indexPath)
            coreDataManager.deleteCategory(category: category)
        default:
            fatalError()
        }
    }
}
extension CategoriesViewContoller: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        categoriesTableView.reloadData()
    }
}
