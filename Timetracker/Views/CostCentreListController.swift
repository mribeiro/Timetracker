//
//  CostCentreListController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 26/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

class CostCentreListController: TrackedViewController, NSOutlineViewDelegate {

    // MARK: - Outlets

    @IBOutlet var treeController: NSTreeController!
    @IBOutlet var outlineView: NSOutlineView!
    @IBOutlet var addClientOrProject: NSButton!
    @IBOutlet var itemName: NSTextField!

    // MARK: - Vars and Lets

    weak var appDelegate = NSApplication.shared.delegate as? AppDelegate

    override var analyticsScreenName: String? { "cost-centre" }

    // MARK: - ViewController callbacks

    override func viewWillAppear() {
        super.viewWillAppear()
        outlineView.delegate = self
        adaptButton()
        loadTreeData()
    }

    // MARK: - OutlineViewDelegate callbacks

    func outlineViewSelectionDidChange(_ notification: Notification) {
        adaptButton()
    }

    // MARK: - Actions

    @IBAction func addHoDClicked(_ sender: AnyObject) {
        if TaskProviderManager.instance!.saveHeadOfDevelopments(itemName.stringValue) {
            loadTreeData()
            outlineView.reloadData()
            itemName.stringValue = ""
        }
    }

    @IBAction func addProjectOrClientClicked(_ sender: NSButton) {

        guard itemName.stringValue.count > 0 else {
            showError("Please fill in the text box", because: "project-client-name-not-set")
            return
        }

        let levelToAdd = sender.tag

        var result = false

        switch levelToAdd {
        case 1: //add client

            if let hod = getSelectedObject() as? HeadOfDevelopment {
                result = TaskProviderManager.instance!.saveClient(itemName.stringValue, ofHod: hod)
            }

        case 2: //add project

            if let client = getSelectedObject() as? Client {
                result = TaskProviderManager.instance!.saveProject(itemName.stringValue, ofClient: client)
            }

        default:
            L.d("nothing known was clicked")

        }

        if result {
            loadTreeData()
            outlineView.reloadData()
            itemName.stringValue = ""

        } else {
            showError("Couldn't save 😞 Did you select anything?", because: "save-clicked-no-selection")
        }

        adaptButton()

    }

    @IBAction func deleteClicked(_ sender: AnyObject) {

        if let selectedItem = getSelectedObject() as? NSManagedObject {
            do {
                appDelegate?.managedObjectContext.delete(selectedItem)
                try appDelegate?.managedObjectContext.save()
            } catch {
                L.e("Exception deleting \(selectedItem). Does this item have children?")
                L.e("error \(error)")
                appDelegate?.managedObjectContext.rollback()
                showError("Could not delete! Does this item have children?", because: "try-delete-hierarchy")
            }
            loadTreeData()
            outlineView.reloadData()
        }
        adaptButton()

    }

    // MARK: - Private functions

    fileprivate func loadTreeData() {
        treeController.content = TaskProviderManager.instance?.getHeadOfDevelopments()
    }

    fileprivate func adaptButton() {

        let selectedItem = getSelectedObject()

        if let selected = selectedItem {

            if selected is Project {
                self.addClientOrProject.isHidden = true

            } else if selected is Client {
                self.addClientOrProject.tag = 2
                self.addClientOrProject.title = "Add project"
                self.addClientOrProject.isHidden = false

            } else if selected is HeadOfDevelopment {
                self.addClientOrProject.tag = 1
                self.addClientOrProject.title = "Add client"
                self.addClientOrProject.isHidden = false
            }

        } else {
            self.addClientOrProject.isHidden = true
        }
    }

    fileprivate func getSelectedObject() -> Any? {
        let selectedItem = outlineView.item(atRow: outlineView.selectedRow)
        return (selectedItem as? NSTreeNode)?.representedObject
    }

}
