//
//  CostCentreListController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 26/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

class CostCentreListController: NSViewController, NSOutlineViewDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet var treeController: NSTreeController!
    @IBOutlet var outlineView: NSOutlineView!
    @IBOutlet var addClientOrProject: NSButton!
    @IBOutlet var itemName: NSTextField!
    
    //MARK: - Vars and Lets
    
    let appDelegate = NSApplication.shared().delegate as! AppDelegate
    
    //MARK: - ViewController callbacks
    
    override func viewWillAppear() {
        outlineView.delegate = self
        adaptButton()
        loadTreeData()
    }
    
    //MARK: - OutlineViewDelegate callbacks
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        adaptButton()
    }
    
    //MARK: - Actions
    
    @IBAction func addHoDClicked(_ sender: AnyObject) {
        if TaskProviderManager.instance!.saveHeadOfDevelopments(itemName.stringValue) {
            loadTreeData()
            outlineView.reloadData()
            itemName.stringValue = ""
        }
    }
    
    @IBAction func addProjectOrClientClicked(_ sender: NSButton) {
        
        guard itemName.stringValue.characters.count > 0 else {
            showError("Please fill in the text box")
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
            print("nothing known was clicked")
            
        }
        
        if result {
            loadTreeData()
            outlineView.reloadData()
            itemName.stringValue = ""
            
        } else {
            showError("Couldn't save 😞 Did you select anything?")
        }
        
        adaptButton()
        
    }
    
    @IBAction func deleteClicked(_ sender: AnyObject) {
        
        if let selectedItem = getSelectedObject() as? NSManagedObject {
            appDelegate.managedObjectContext.delete(selectedItem)
            loadTreeData()
            outlineView.reloadData()
        }
        adaptButton()
        
    }
    
    //MARK: - Private functions
    
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
    
    fileprivate func getSelectedObject() -> AnyObject? {
        let selected = outlineView.selectedRow
        let item = outlineView.item(atRow: selected)
        return (item as AnyObject).representedObject
    }
    
}
