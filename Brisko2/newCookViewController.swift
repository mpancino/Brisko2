//
//  newCookViewController.swift
//  Brisko2
//
//  Created by Matt Pancino on 6/11/18.
//  Copyright © 2018 Matt Pancino. All rights reserved.
//

import UIKit
import CoreData

class NewCookViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cookNameText: UITextField!

    @IBOutlet weak var meatNameText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var weightText: UITextField!
    
    @IBOutlet weak var p1TargetTextField: UITextField!
    @IBOutlet weak var p2TargetTextField: UITextField!
    @IBOutlet weak var p3TargetTextField: UITextField!
    @IBOutlet weak var p4TargetTextField: UITextField!
    
    @IBOutlet weak var p1slider: UISlider!
    @IBOutlet weak var p2slider: UISlider!
    @IBOutlet weak var p3slider: UISlider!
    @IBOutlet weak var p4slider: UISlider!
    
    
    // Test on pullll
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
     

        // Do any additional setup after loading the view.
    }
    
        override func viewWillAppear(_ animated: Bool) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-YY HH:mm:ss"
            var str = formatter.string(from: Date())
         
            cookNameText.text = formatter.string(from: Date())
            self.cookNameText.delegate = self
            self.meatNameText.delegate = self
            self.descriptionText.delegate = self
            self.weightText.delegate = self
            p1TargetTextField.isEnabled = false
            p2TargetTextField.isEnabled = false
            p3TargetTextField.isEnabled = false
            p4TargetTextField.isEnabled = false
            
    }

    @IBAction func p1Slider(_ sender: Any) {
        p1TargetTextField.text = String(Int(p1slider.value))
    }
    @IBAction func p2Slider(_ sender: Any) {
         p2TargetTextField.text = String(Int(p2slider.value))
    }
    @IBAction func p3slider(_ sender: Any) {
        p3TargetTextField.text = String(Int(p3slider.value))
    }
    @IBAction func p4slider(_ sender: Any) {
             p4TargetTextField.text = String(Int(p4slider.value))
    }
    
    @IBAction func createCook(_ sender: Any) {
    }
    
    // MARK: Segue handleing

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ViewController
        print("passing back data....")
        destVC.cook = NSEntityDescription.insertNewObject(forEntityName: "Cook", into:  DatabaseController.getContext()) as? Cook
        destVC.cook?.name = cookNameText.text
        destVC.cook?.meat = meatNameText.text
        destVC.cook?.cookDesc = descriptionText.text
        destVC.cook?.weight = (weightText.text! as NSString).doubleValue
        destVC.cook?.p1Target = (p1TargetTextField.text! as NSString).doubleValue
        destVC.cook?.p2Target = (p2TargetTextField.text! as NSString).doubleValue
        destVC.cook?.p3Target = (p3TargetTextField.text! as NSString).doubleValue
        destVC.cook?.p4Target = (p4TargetTextField.text! as NSString).doubleValue
        destVC.cookCreated = true;
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
