//
//  JokeDetailViewController.swift
//  FetchResultController
//
//  Created by Shalopay on 10.01.2023.
//

import UIKit

class JokeDetailViewController: UIViewController {
    var jokeText: String?
    
    private lazy var jokeLabel: UILabel = {
       let jokeLabel = UILabel()
        jokeLabel.numberOfLines = 0
        jokeLabel.font = UIFont.systemFont(ofSize: 20)
        jokeLabel.textColor = .black
        jokeLabel.translatesAutoresizingMaskIntoConstraints = false
        return jokeLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        title = "JOKE DETAIL"
        jokeLabel.text = jokeText
        view.backgroundColor = .white
    }
    func setupView() {
        view.addSubview(jokeLabel)
        NSLayoutConstraint.activate([
            jokeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            jokeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            jokeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            jokeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
}
