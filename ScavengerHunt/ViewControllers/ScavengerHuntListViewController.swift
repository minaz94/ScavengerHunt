//
//  ViewController.swift
//  ScavengerHunt
//
//  Created by Mina on 3/1/24.
//

import UIKit

class ScavengerHuntListViewController: UIViewController {

    
    @IBOutlet weak var scavengerHuntTableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
        
    var scavengerHunts: [ScavengerHunt] = [] {
        didSet {
            if scavengerHunts.isEmpty {
                scavengerHuntTableView.isHidden = true
                emptyStateView.isHidden = false
            } else {
                scavengerHuntTableView.reloadData()
                emptyStateView.isHidden = true
                scavengerHuntTableView.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
    }


    func setupTableView() {
        scavengerHuntTableView.dataSource = self
        scavengerHuntTableView.delegate = self
        scavengerHuntTableView.backgroundColor = .clear
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Scavenger Hunt List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScavengerHunt))
        navigationItem.rightBarButtonItem?.tintColor = .red
                                                            
    }
    
    @objc func addScavengerHunt() {
        let alert = UIAlertController(title: "Create New Scavenger Hunt", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        
        alert.textFields?[0].placeholder = "Scavenger Hunt Title"
        alert.textFields?[1].placeholder = "Scavenger Hunt Description"
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        let done = UIAlertAction(title: "Done", style: .default) { [weak self] action in
            let scavengerHuntTitle = alert.textFields?[0].text ?? ""
            let scavengerHuntDescription = alert.textFields?[1].text ?? ""

            let nonEmptyTitle = scavengerHuntTitle == "" ? "New Scavenger Hunt" : scavengerHuntTitle
            let nonEmptyDescription = scavengerHuntDescription == "" ? "An Exciting Scavenger Hunt" : scavengerHuntDescription

            let newScavengerHunt = ScavengerHunt(title: nonEmptyTitle, description: nonEmptyDescription)
            self?.scavengerHunts.append(newScavengerHunt)
        }
        alert.addAction(cancel)
        alert.addAction(done)
        navigationController?.present(alert, animated: true)
    }
}

extension ScavengerHuntListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scavengerHunts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "scavengerHuntCell", for: indexPath) as? ScavengerHuntTableViewCell else {
            return UITableViewCell()
        }
        cell.configureFor(scavengerHunt: scavengerHunts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.scavengerHunts.remove(at: indexPath.row)
        }
       return UISwipeActionsConfiguration(actions: [action])
        
    }
    
}

extension ScavengerHuntListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scavengerHuntDetailVC") as? ScavengerHuntDetailViewController else { return }
        vc.scavengerHunt = scavengerHunts[indexPath.row]
        vc.onComposeScavengerHunt = { [ weak self ] hunt in
            self?.scavengerHunts[indexPath.row] = hunt
        }
        navigationController?.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

