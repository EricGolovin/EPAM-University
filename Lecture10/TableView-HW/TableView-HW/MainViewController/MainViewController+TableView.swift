//
//  MainViewController+TableView.swift
//  TableView-HW
//
//  Created by Eric Golovin on 6/25/20.
//

import UIKit

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        search.results.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if search.results.count > indexPath.row {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.searchResultCell.rawValue, for: indexPath) as! SearchResultCell
            
            cell.configure(for: search.results[indexPath.row])
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.resultsCountCell.rawValue, for: indexPath) as! ResultsCountCell
            
            cell.configure(for: search.results.count)
            
            resultLabelIndexPath = indexPath
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            search.deleteResult(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        /* To disable swipe to delete and enable delete only for edit mode
         if tableView.isEditing {
         return .delete
         }
         return .none
         */
        if indexPath == resultLabelIndexPath {
            return .none
        }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath != resultLabelIndexPath {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath != resultLabelIndexPath {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath != resultLabelIndexPath && destinationIndexPath != resultLabelIndexPath {
            let movedObject = search.results[sourceIndexPath.row]
            search.deleteResult(at: sourceIndexPath)
            search.results.insert(movedObject, at: destinationIndexPath.row)
        }
    }
    
}
