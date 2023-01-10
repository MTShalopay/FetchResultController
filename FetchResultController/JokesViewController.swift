//
//  ViewController.swift
//  FetchResultController
//
//  Created by Shalopay on 06.01.2023.
//

import UIKit
import CoreData

class JokesViewController: UIViewController {
    let downloadManager = DownloadManager.shared
    let coreDataManager = CoreDataManager.shared
    // подгружаем категории
    var categories: Categories?
    
    private var fetchResultController: NSFetchedResultsController<Joke>?
    private lazy var jokesTableView: UITableView = {
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
        longTapping()
        setupNavigationController()
        setupView()
        initFetchResultController()
        fetchResultController?.delegate = self
        do {
            try fetchResultController?.performFetch()
        } catch {
            print("ERROR FetchResultController: \(error.localizedDescription)")
        }
    }
    private func longTapping() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTap(sender:)))
        longPressGestureRecognizer.minimumPressDuration = 2
        jokesTableView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    private func initFetchResultController() {
        let request:NSFetchRequest<Joke> = Joke.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreate", ascending: false)]
        // работа с категориями
        if (categories != nil) {
            request.predicate = NSPredicate(format: "categories contains[c] %@", categories!)
        }
       fetchResultController = NSFetchedResultsController(fetchRequest: request,
                                            managedObjectContext: coreDataManager.persistentContainer.viewContext,
                                            sectionNameKeyPath: nil,
                                            cacheName: nil)
    }
    private func setupNavigationController() {
        title = "Шутки"
        view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let addJokeButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(addJoke))
        navigationItem.rightBarButtonItems = [addJokeButtonItem]
    }
    private func setupView() {
        view.addSubview(jokesTableView)
        NSLayoutConstraint.activate([
            jokesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            jokesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            jokesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            jokesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func longTap(sender: UILongPressGestureRecognizer) {
        let touchPoint = sender.location(in: sender.view)
        guard let indexPath = jokesTableView.indexPathForRow(at: touchPoint) else { return }
        guard let joke = fetchResultController?.object(at: indexPath) else {return}
        let activityViewController = UIActivityViewController(activityItems: ["Шутка: \(joke.text!) \n", "Дата создания: \(joke.dateCreate!.formated())"], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func addJoke() {
        downloadManager.downloadJoke(categoryName: categories?.name) { (joke) in
            guard let joke = joke else {return}
            self.coreDataManager.createJoke(from: joke)
        }
    }

}

extension JokesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController?.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if let joke = fetchResultController?.object(at: indexPath) {
            cell.textLabel?.text = joke.text
            cell.detailTextLabel?.text = joke.dateCreate?.formated()
        }
        longTapping()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let joke = fetchResultController?.object(at: indexPath) else {return}
        let jokeDetailVC = JokeDetailViewController()
        jokeDetailVC.jokeText = joke.text
        navigationController?.pushViewController(jokeDetailVC, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert: print("INSERT")
        case .delete:
            if let joke = fetchResultController?.object(at: indexPath) {
                coreDataManager.deleteJoke(joke: joke)
            }
        case .none: print("NONE")
        @unknown default:
            fatalError()
        }
    }
}

extension JokesViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            self.jokesTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .insert:
            self.jokesTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .move:
            self.jokesTableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            self.jokesTableView.reloadRows(at: [indexPath!], with: .automatic)
        @unknown default:
            self.jokesTableView.reloadData()
        }
    }
}

