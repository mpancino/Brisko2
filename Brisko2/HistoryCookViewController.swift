//
//  newCookViewController.swift
//  Brisko2
//
//  Created by Matt Pancino on 3/11/18.
//  Copyright © 2018 Matt Pancino. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import Charts






class HistoryCookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var deleteCook: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var meatLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var ovenLabel: UILabel!
    @IBOutlet weak var probe2Label: UILabel!
    @IBOutlet weak var probe3Label: UILabel!
    @IBOutlet weak var probe4Label: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
    
    
    let textCellIdentifier = "TextCell"
    var cookLabels: [String] = []
    var searchResults: [Cook] = []
    var cookIndex = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the table view Methods
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: textCellIdentifier)
        tableView.layer.masksToBounds = true
        tableView.layer.borderWidth = 1.0
        chartView.delegate = self as? ChartViewDelegate;()
        chartView.configureChart()
       


    }
    
    override func viewWillAppear(_ animated: Bool){
       // remove all the labels so as to update with latest
        // Get the Cooks From the datastore
        cookLabels.removeAll()
     
        let fetchrequest:NSFetchRequest<Cook> = Cook.fetchRequest()
        
        do {
            searchResults = try DatabaseController.getContext().fetch(fetchrequest)
            print("Number of Results: \(searchResults.count)")
            for result in searchResults as [Cook] {
                cookLabels.append(result.name ?? "Empty")
                
                
            }
        } catch {
            print("Error: \(error)")
        }
        tableView.reloadData()
    }
    

    
    @IBAction func load(_ sender: Any) {
    }
    
    
    @IBAction func createCook(_ sender: Any) {
        print("IN CREATE COOK")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Table view methods

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cookLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = cookLabels[row]
   
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        print(indexPath.row)
        let tmp : Cook = searchResults[indexPath.row] as Cook
        print("Object at \(indexPath.row) name is \(String(describing: tmp.name))")
        ovenLabel.text =  String(Int(tmp.p1Target))
        probe2Label.text = String(Int(tmp.p2Target))
        probe3Label.text = String(Int(tmp.p3Target))
        probe4Label.text = String(Int(tmp.p4Target))
        descLabel.text = tmp.cookDesc
        weightLabel.text = String(tmp.weight)
        meatLabel.text = tmp.meat
        chartView.updateChart(cookSeries: (tmp.cookSeries)!)
        self.tableView.reloadData()
    }
    
    // Got this off the internet to swipe the delete
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let tmp : Cook = searchResults[indexPath.row] as Cook
            print("Deleting at: \(indexPath.row) Object: \(String(describing: tmp.name))")
            searchResults.remove(at: indexPath.row)
            DatabaseController.getContext().delete(tmp)
            DatabaseController.saveContext()
            
            cookLabels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
              self.tableView.reloadData()

           

        }
    }

    
    @IBAction func deleteCook(_ sender: Any) {
       
        print(searchResults)
      //  DatabaseController.getContext().delete(searchResults[cookIndex] as! NSManagedObject)
        
    }
    

}
