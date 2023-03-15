//
//  ListViewController.swift
//  scavenger
//
//  Created by lemonshark on 2023/3/14.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // the `dequeueReusableCell(withIdentifier:)` method just returns a generic UITableViewCell so it's necessary to cast it to our specific custom cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell

        // Get the track that corresponds to the table view row
        let image = images[indexPath.row]

        // Configure the cell with it's associated track
        cell.configure(with: image)

        // return the cell for display in the table view
        return cell
    }
    

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the cell that triggered the segue
        if let cell = sender as? UITableViewCell,
           // Get the index path of the cell from the table view
           let indexPath = tableView.indexPath(for: cell),
           // Get the detail view controller
           let detailViewController = segue.destination as? DetailViewController {
            
            let image = images[indexPath.row]
            
            detailViewController.image = image
        }
    }
}
