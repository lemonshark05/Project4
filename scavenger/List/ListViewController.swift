//
//  ListViewController.swift
//  scavenger
//
//  Created by lemonshark on 2023/3/14.
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var images = [Image]() {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView()

        tableView.dataSource = self

        images = Image.mockedLists
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // This will reload data in order to reflect any changes made to a task after returning from the detail screen.
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Segue to Detail View Controller
        if segue.identifier == "DetailSegue" {
            if let detailViewController = segue.destination as? DetailViewController,
                // Get the index path for the current selected table view row.
               let selectedIndexPath = tableView.indexPathForSelectedRow {

                // Get the task associated with the slected index path
                let image = images[selectedIndexPath.row]

                // Set the selected task on the detail view controller.
                detailViewController.image = image
            }
        }
    }
    
}
extension ListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell else {
            fatalError("Unable to dequeue List Cell")
        }

        cell.configure(with: images[indexPath.row])

        return cell
    }
}
