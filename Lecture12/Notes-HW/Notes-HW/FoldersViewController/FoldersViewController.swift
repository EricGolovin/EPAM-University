//
//  FoldersViewController.swift
//  Notes-HW
//
//  Created by Eric Golovin on 6/30/20.
//

import UIKit
import CoreData

class FoldersViewController: UIViewController {
    
    // MARK: - Identifiers
    private let folderCellIdentifier = "FolderCell"
    private let showNotesSegueIdentifier = "showNotesSegue"
    private let showFolderInfoSegueIdentifier = "showFolderInfoSegue"
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortBarButton: UIBarButtonItem!
    
    // MARK: - Properties
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var coreDataStack = CoreDataStack.stack
    var currentUser: User?
    var selectedIndexPath: IndexPath?
    
    // MARK: Sort Descriptors
    lazy var nameSortDescriptor: NSSortDescriptor = {
        let compareSelector = #selector(NSString.localizedStandardCompare(_:))
        return NSSortDescriptor(key: #keyPath(Folder.name
                                    ), ascending: true, selector: compareSelector)
    }()
    lazy var creationDateSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Folder.creationDate), ascending: true)
    }()
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
 
        navigationItem.title = currentUser?.name ?? "Failed to Load Name"
    }
    
    // MARK: - Actions
    @IBAction func sortTapped(_ sender: UIBarButtonItem) {
        sortFolders()
    }
    @IBAction func addFolder(_ sender: UIBarButtonItem) {
        configureNewFolder(with: Folder(context: coreDataStack.managedContext))
    }
    
    @IBAction func generateFoldersTapped(_ sender: UIBarButtonItem) {
        let randomFolderCount = Int.random(in: 0...9)
        for i in 0...randomFolderCount {
            let newFolder = Folder(context: coreDataStack.managedContext)
            newFolder.name = "Folder \(i * .random(in: 0...9))"
            newFolder.creationDate = Date()
            let randomNotesCount = Int.random(in: 0...9)
            for j in 0...randomNotesCount {
                let newNote = Note(context: coreDataStack.managedContext)
                newNote.name = "Note \(i + j * .random(in: 0...9))"
                newNote.creationDate = Date()
                newFolder.addToNotes(newNote)
            }
            currentUser?.addToFolders(newFolder)
        }
        coreDataStack.saveContext()
        tableView.reloadData()
    }
    @IBAction func clearDataTapped(_ sender: UIBarButtonItem) {
        currentUser?.folders?.forEach { folder in
            coreDataStack.delete(folder as! Folder)
        }
        currentUser?.folders = nil
        coreDataStack.saveContext()
        tableView.reloadData()
    }
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "Unwind to StartVC", sender: self)
    }
}

// MARK: - TableView
extension FoldersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentUser?.folders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: folderCellIdentifier, for: indexPath) as! FolderTableViewCell
        
        guard let folder = currentUser?.folders?[indexPath.row] as? Folder,
              let folderName = folder.name,
              let folderCreationDate = folder.creationDate else {
            return cell
        }
        
        cell.folderTitleLabel.text = folderName
        cell.folderCreationLabel.text = dateFormatter.string(from: folderCreationDate)
        
        cell.infoAction = { [weak self] in
            self?.infoButtonTapped(on: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            guard let folderToRemove = getCurrentFolder(on: indexPath) else {
                return
            }
            
            currentUser?.removeFromFolders(folderToRemove)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            coreDataStack.delete(folderToRemove)
        case .none:
            break
        case .insert:
            break
        @unknown default:
            break
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndexPath = indexPath
        performSegue(withIdentifier: showNotesSegueIdentifier, sender: self)
    }
}

// MARK: - Navigation
extension FoldersViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case showFolderInfoSegueIdentifier:
            guard let folderInfoVC = (segue.destination as? UINavigationController)?.viewControllers.first as? FolderInfoTableViewController,
                  let indexPath = selectedIndexPath else {
                return
            }
            folderInfoVC.currentFolder = getCurrentFolder(on: indexPath)
            folderInfoVC.saveAction = { [weak self] in
                self?.saveAndReloadTableView()
            }
            
        case showNotesSegueIdentifier:
            guard let notesVC = segue.destination as? NotesCollectionViewController,
                  let indexPath = selectedIndexPath else {
                return
            }
            notesVC.currentFolder = getCurrentFolder(on: indexPath)
            notesVC.navigationItem.title = "Hello"
        default:
            break
        }
        selectedIndexPath = nil
    }
}

// MARK: - Helper Methods
extension FoldersViewController {
    
    func infoButtonTapped(on indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndexPath = indexPath
        performSegue(withIdentifier: showFolderInfoSegueIdentifier, sender: nil)
    }
    
    func saveAndReloadTableView() {
        coreDataStack.saveContext()
        tableView.reloadData()
    }
    
    func getCurrentFolder(on indexPath: IndexPath) -> Folder? {
        return currentUser?.folders?[indexPath.row] as? Folder
    }
    
    func configureNewFolder(with folder: Folder) {
        let alert = UIAlertController(title: "Add Folder", message: "Type Folder Information", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Title"
        })
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Details"
        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { _ in
            folder.name = alert.textFields?.first?.text
            folder.information = alert.textFields?.last?.text
            folder.creationDate = Date()
            
            self.currentUser?.addToFolders(folder)
            self.coreDataStack.saveContext()
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func filterViewController(sortDescriptor: NSSortDescriptor) {
        let fetchRequest = NSFetchRequest<Folder>(entityName: "Folder")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Folder.user.name), currentUser!.name!)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            currentUser?.folders = NSOrderedSet(array: results)
            tableView.reloadData()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func sortFolders() {
        let alert = UIAlertController(title: "Sort Folders", message: "Choose sort option", preferredStyle: .actionSheet)
        
        let byNameAction = UIAlertAction(title: "by Name", style: .default, handler: { _ in
            self.filterViewController(sortDescriptor: self.nameSortDescriptor)
        })
        
        let byDateAction = UIAlertAction(title: "by Date", style: .default, handler: { _ in
            self.filterViewController(sortDescriptor: self.creationDateSortDescriptor)
        })
        
        alert.addAction(byNameAction)
        alert.addAction(byDateAction)
        present(alert, animated: true, completion: nil)
    }
}
