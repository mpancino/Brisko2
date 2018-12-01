//
//  ViewController.swift
//  Brisko2
//
//  Created by Matt Pancino on 6/11/18.
//  Copyright © 2018 Matt Pancino. All rights reserved.
//



import UIKit
import CoreData
import Charts



let USERNAME = "mpancino@me.com"
let PASSWORD = "sandst0ne"
let DEVICE = "Briskometer"
let EVENT = "tempChanged"





class ViewController: UIViewController {
    @IBOutlet weak var lastContactLabel: UILabel!
    
    @IBOutlet weak var chartView: LineChartView!
    
    
    
    var myPhoton : ParticleDevice?
    var cook: Cook?
    var isCooking: Int = 0
    var cookCreated: Bool = false;
    var runCount: Int = 0
    var queueCount: Int = 0
    var timer: Timer!
    var buffIndex: Int = 0;
    
    // var tempCookSeries: [TempEntry] this about this as temp array
    
    
    @IBOutlet weak var stopCookButton: UIButton!
    @IBOutlet weak var addCookButton: UIBarButtonItem!
    @IBOutlet weak var probe1Label: UILabel!
    @IBOutlet weak var probe2Label: UILabel!
    @IBOutlet weak var probe3Label: UILabel!
    @IBOutlet weak var probe4Label: UILabel!
    @IBOutlet weak var cookNameLabel: UILabel!
    @IBOutlet weak var lastCLabel: UILabel!
    
    @IBOutlet weak var bufferIndexLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopCookButton.isEnabled = false
         self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        // Do the partice stuff and get the Photon connected to the cloud
        
        // This killed me......Particle cloud can only register so fast and blocks if to many events...stagger event registrations!
        self.loginCloud()
        perform(#selector(subscribeToBriskIsAwake), with: nil, afterDelay: 0.1)
        perform(#selector(subscribeToEmptyBufferEvent), with: nil, afterDelay: 0.5)
        perform(#selector(getMyPhoton), with: nil, afterDelay: 1.5)
        perform(#selector(subScribeToTempEvent), with: nil, afterDelay: 1.1)
        perform(#selector(subScribeBriskoState), with: nil, afterDelay: 2)

        
        // Get the address of the ovenTemp tab bar
        let vc = self.tabBarController!.viewControllers![1] as! OvenVCViewController
        vc.cook = cook
        
        
        
        //Set up the chartview methods
        chartView.delegate = self as? ChartViewDelegate;()
        chartView.configureChart()
        
        
        stopCookButton.setTitle("No Cook In Progress", for: .normal)
        cookNameLabel.text = ""
        
 
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appGoingBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appGoingForeGround),name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appGoingBackground),name: UIApplication.willTerminateNotification, object: nil)
    }
  
    // That is so Wrong, isCooking should be cookCreated;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        if cookCreated == true { //You have just come from newcontrollerview
        let str : String = cook?.name ?? "none"
        cookNameLabel.text = "Cook \(str) In Progress"
        stopCookButton.isEnabled = true
        createACook()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        stopCookButton.setTitle("Stop Current Cook", for: .normal)
        cookCreated = false
        }
        else {
            print("I Havent started a cook")
        }
        
    }

  
    // MARK: - Navigation
     
     @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }

    //MARK: - Generate Cook From NewViewController as Sender
    
 
    @IBAction func stopCook(_ sender: Any) {
        stopCookButton.setTitle("No Cook In Progress", for: .normal)
        stopCookButton.isEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        cookNameLabel.text = ""
        isCooking = 0 //Need to change this to cookState
        let funcArgs = ["3"]
        if (myPhoton != nil){
            var task = myPhoton!.callFunction("stopCook", withArguments: funcArgs) { (resultCode : NSNumber?, error : Error?) -> Void in
                if (error == nil) {
                    print("The cook has been stopped!")
                    //self.isCooking = 1
                }
            }
        }
       //chartView.emptyChart(cookSeries: (cook?.cookSeries)!)
 
    }
    
    
    
    // MARK: - update data from particle device
    func updateData(atTime: Date, theData: String)
    {
      //  print("In Update Data at: \(atTime) with Data: \(theData)")
        
        let dataElements = theData.components(separatedBy: ":")
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "hh:mm:ss"
        lastCLabel.text = dayTimePeriodFormatter.string(from: atTime)
        
        //update the labels here without creating a CookEvent.. if the probes come back below zero, Hide the UI element

        for (index, value) in dataElements.enumerated() {
            // Display indexes and values.
            switch index {
            case 0:
                probe1Label.text = value
                if(Double(value) ?? 0) > 0.0 {
                    probe1Label.isHidden = false;
                } else {
                    probe1Label.isHidden = true;
                }
                probe1Label.text = value
            case 1:
                probe2Label.text = value
                if (Double(value) ?? 0) > 0.0 {
                    probe2Label.isHidden = false;
                } else {
                    probe2Label.isHidden = true;
                }
            case 2:
                probe3Label.text = value
                if (Double(value) ?? 0) > 0.0 {
                    probe3Label.isHidden = false;
                } else {
                    probe3Label.isHidden = true;
                }
            case 3:
                probe4Label.text = value
                if (Double(value) ?? 0) > 0.0 {
                    probe4Label.isHidden = false
                } else {
                    probe4Label.isHidden = true
                }
                probe4Label.text = value
            default:
                print("No idea what the values coming through are")
            }
        }
        
        
// Ok, if their isCooking = true then right the information to Core data and update the chart with the core data object.
        
        if isCooking == 1 {
           //print("My initial Cook is \(String(describing: cook?.name)) with \(String(describing: cook?.meat))")
            let tempEntry:TempEntry = NSEntityDescription.insertNewObject(forEntityName: "TempEntry", into: DatabaseController.getContext()) as! TempEntry
            tempEntry.time  = atTime
            //cook?.addToCookSeries(tempEntry)
            tempEntry.p1 = Double(probe1Label.text! as String) ?? 0
            tempEntry.p2 = Double(probe2Label.text! as String) ?? 0
            tempEntry.p3 = Double(probe3Label.text! as String) ?? 0
            tempEntry.p4 = Double(probe4Label.text! as String) ?? 0
            //Add and Save the context
            cook?.addToCookSeries(tempEntry)
            chartView.updateChart(cookSeries: (cook?.cookSeries)!)
            DatabaseController.saveContext()
            

        }
    
    }
    
    // This is the function that loads all of the data of the BriskoMeter if it has stored any while app has been
    // running in background, called when event dataUpdate is used.
    
    func getbufferData(theData: String) {
        print("getbufferData: data: \(theData)")

        if isCooking == 1 {

            let tempElements = theData.components(separatedBy: ";") //first get the strings separated by ~
            
            for (index, tempValue) in tempElements.enumerated() {
                if (tempValue != "") {  //For each of those strings which have a value
                    let dataElements = tempValue.components(separatedBy: ":")       //seperate the elemements separated by :
                    let tempEntry:TempEntry = NSEntityDescription.insertNewObject(forEntityName: "TempEntry", into: DatabaseController.getContext()) as! TempEntry
                    for (index1, value) in dataElements.enumerated() {               // Iterate through them and Create new Temp Entry
                        switch index1 {
                            case 0:
                                let dayTimePeriodFormatter = DateFormatter()
                                dayTimePeriodFormatter.dateFormat = "yyMMdd HH.mm.ss"
                                tempEntry.time = dayTimePeriodFormatter.date(from: value) ?? Date();
                                print("Got the damn time \(String(describing: tempEntry.time))")
                            case 1:
                                tempEntry.p1 = Double(value) ?? 0;
                            case 2:
                                tempEntry.p2 = Double(value) ?? 0;
                            case 3:
                                tempEntry.p3 = Double(value) ?? 0;
                            case 4:
                                tempEntry.p4 = Double(value) ?? 0;
                            default:
                                print("No idea what the values coming through are")
                            }
                    }
                    print("getbufferData: Adding buffered item \(index)")
                    buffIndex+=1;
                    self.bufferIndexLabel.text = String(buffIndex)
                    cook?.addToCookSeries(tempEntry)
                    DatabaseController.saveContext()
                    chartView.updateChart(cookSeries: ((cook?.cookSeries ?? nil)!))
                }
            }
        }
}
    
    // When the brisk "briskoAwake Event occurs, this function sets and we then decide what to do with the app logic
func briskoAwake(theData: String) {
        print("BrisoAwake: in Brisko Awake with the data: \(theData)")
        var name: String = "None"
        var state: Int = 0
        let tempElements = theData.components(separatedBy: "~") //first get the strings separated by ~
        
        for (index, tempValue) in tempElements.enumerated() {
            switch index {
            case 0:
                    name = tempValue;
                    print("BrisoAwake: The cookName of the briskoMeter is \(name)")
            case 8:
                    state = Int(tempValue)!;
                    print("BrisoAwake: The cookState of the briskoMeter is \(state)")
            default:
                    print("")
            }
        }
        if (state == 1){                            // So the Brisko Was in "cooking state"
            if (cook?.name != nil) {
                print("BrisoAwake: I am going to keep cooking"); // And the cook was not nil, Assume its the last cook
            } else {
                print("BrisoAwake: Couldnt find the cook");
                var searchResults: [Cook] = []
                let fetchrequest:NSFetchRequest<Cook> = Cook.fetchRequest() // The app was killed, cook is nil, try to find it and reset cook
                do {
                        searchResults = try DatabaseController.getContext().fetch(fetchrequest)
                        print("Number of Results: \(searchResults.count)")
                        for result in searchResults as [Cook] {
                            if (result.name == name) { //Found the cook stored
                                print("BrisoAwake: I found the cook in Core data!!!");
                                cook = result;
                                cook?.name = result.name
                                cook?.cookDesc = result.cookDesc;
                                cook?.meat = result.meat
                                cook?.weight = result.weight
                                cook?.p1Target = result.p1Target
                                cook?.p2Target = result.p2Target
                                cook?.p3Target = result.p3Target
                                cook?.p4Target = result.p4Target
                                cook?.cookSeries = result.cookSeries
                                isCooking = 1;
                                let str : String = cook?.name ?? "none"     // Need to clean up how the main view Controller, sets itsself, this is
                                cookNameLabel.text = "Cook \(str) In Progress"
                                stopCookButton.isEnabled = true
                                self.navigationItem.rightBarButtonItem?.isEnabled = false
                                stopCookButton.setTitle("Stop Current Cook", for: .normal)
                                cookCreated = false
                
                        }
                      print("BrisoAwake: Searching through Cooks");
                    }
                    } catch {
                    print("Error: \(error)")
                }
            }
            
        } else {
            print("BrisoAwake: No current cook, just get ready for Cook!");
    }

    }
    
    
    
    // The function that creates the cook on the BriskoMeter by publishing an event with the cook data
    func createACook(){
        
        print("createACook: About to call create cook Function")
        var data : String = (cook?.name ?? "None") //Need at least a name, add to UI
        
         data.append("~")
        if (cook?.cookDesc == "") {
            data.append("None")
        } else {
            data.append((cook?.cookDesc)!)
        }
        data.append("~")
        
        if (cook?.meat == "") {
            data.append("0.0")
        } else {
            data.append((cook?.meat)!)
        }
        
         data.append("~")
        
         data += String((cook?.weight ?? 0.0)) +  "~" + String((cook?.p1Target ?? 0.0)) + "~" + String((cook?.p2Target ?? 0.0)) + "~"
            data += String((cook?.p3Target ?? 0.0)) + "~" + String((cook?.p4Target ?? 0.0)) + "~"
        let funcArgs = [data]
        print("createACook: calling createCook function with \(data)")
        if (myPhoton != nil){
            var task = myPhoton!.callFunction("createCook", withArguments: funcArgs) { (resultCode : NSNumber?, error : Error?) -> Void in
                if (error == nil) {
                    print("createACook: The cook has been sent!")
                    self.isCooking = 1
                }
            }
        }
        
}
    
    
    
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("preparing to leave main view controller")
    /*    let receiverVC = segue.destination as! OvenVCViewController
        receiverVC.cook = cook
        */
        if isCooking == 1 {
  //      self.cook = NSEntityDescription.insertNewObject(forEntityName: "Cook", into:  DatabaseController.getContext()) as! Cook
        }
    }
    
    //Shit subscribe methods, needs to be made generic and convert 3 to one!!!!!
    //TO FIX. GOING TO GET WHOLE DAMN PARTICLE
    @objc func subscribeToBriskIsAwake()
    {
        print("subscribeToBriskIsAwake: Subscribing to BriskoisAwake")
        
        var handler : Any?
        handler = ParticleCloud.sharedInstance().subscribeToAllEvents(withPrefix: "briskoAwake", handler: { (event :ParticleEvent?, error : Error?) in
            if let _ = error {
                print ("subscribeToBriskIsAwake: could not subscribe to events")
            } else {
                DispatchQueue.main.async(execute: {
                    print("subscribeToBriskIsAwake: got event with data \(event?.data)")
                    self.briskoAwake(theData: (event?.data)!)
                })
            }
        })
        
    }
    
    //Shit subscribe methods, needs to be made generic and convert 3 to one!!!!!
    //TO FIX. GOING TO GET WHOLE DAMN PARTICLE
    @objc func subscribeToEmptyBufferEvent()
    {
        print("subscribeToEmptyBufferEvent: Subscribing to eventBuff")
        var handler : Any?
        handler = ParticleCloud.sharedInstance().subscribeToAllEvents(withPrefix: "emptyBuff", handler: { (event :ParticleEvent?, error : Error?) in
            if let _ = error {
                print ("subscribeToEmptyBufferEventz; could not subscribe to events")
            } else {
                DispatchQueue.main.async(execute: {
                    print("subscribeToEmptyBufferEvent: got event with data \(event?.data)")
                    self.getbufferData(theData: (event?.data)!)
                })
            }
        })
        
    }
    //Shit subscribe methods, needs to be made generic and convert 3 to one!!!!!
    
    @objc func subScribeBriskoState()
    {
        print("subScribeBriskoState: Subsrcibing to BriskoState")
        var handler : Any?
        handler = ParticleCloud.sharedInstance().subscribeToMyDevicesEvents(withPrefix: "cookState", handler: { (event :ParticleEvent?, error : Error?) in
            if let _ = error {
                print ("subScribeBriskoState: could not subscribe to events")
            } else {
                DispatchQueue.main.async(execute: {
                    print("subScribeBriskoState: Caught Event - the Brisko state changed \(Int(event!.data ?? "0") ?? 0)")
                    self.isCooking = Int(event!.data ?? "no data") ?? 0
                })
            }
        })
        
    }
    
    
    //Shit subscribe methods, needs to be made generic and convert 3 to one!!!!!
    
    @objc func subScribeToTempEvent()
    {
        print("subScribeToTempEvent: Subsrcibing to TempEvent")
        var handler : Any?
        handler = ParticleCloud.sharedInstance().subscribeToMyDevicesEvents(withPrefix: "tempChanged", handler: { (event :ParticleEvent?, error : Error?) in
            if let _ = error {
                print ("subScribeToTempEvent: could not subscribe to events")
            } else {
                DispatchQueue.main.async(execute: {
                     print ("subScribeToTempEvent: Caught Event TempChanged")
                    self.updateData(atTime: event!.time, theData: event!.data ?? "no data")
                })
            }
        })
        
    
    }
    
    
    @objc func getMyPhoton() {
        
        ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
            if let _ = error {
                print("Check your internet connectivity")
            }
            else {
                if let d = devices {
                    for device in d {
                        if device.name == DEVICE {
                            self.myPhoton = device
                            print("In get my Photon: \((self.myPhoton?.name) ?? "empty")")
                            self.appGoingForeGround() // set the BBQ Meter to ON!!!
                            
                        }
                    }
                }
            }
        }
    }
    
    func loginCloud() {
        ParticleCloud.sharedInstance().login(withUser: USERNAME, password: PASSWORD) { (error:Error?) -> Void in
            if let _ = error {
                print("Wrong credentials or no internet connectivity, please try again")
            }
            else {
                print("Logged in")

                
            }

        }


        
    }
    
    
    // test function Code.
@objc  func appGoingBackground() {
    let funcArgs = ["0"]
    if (myPhoton != nil){
        _ = myPhoton!.callFunction("appActive", withArguments: funcArgs) { (resultCode : NSNumber?, error : Error?) -> Void in
        if (error == nil) {
            print("appGoingBackground: App is offline")
        }
    }
    // also publish event "biskoAwaketo get the CookData from the Briskometer
        
    }
}
    
@objc  func appGoingForeGround() {
    let funcArgs = ["1"]
    if (myPhoton != nil){
   // self.subScribeBriskoState(event: "cookState", photon: self.myPhoton!)
    var task = myPhoton!.callFunction("appActive", withArguments: funcArgs) { (resultCode : NSNumber?, error : Error?) -> Void in
        if (error == nil) {
            print("appGoingForeGround: App is online")
            self.buffIndex = 0 //This has to be removed ultimately ....just checks how many buffered items are returned.
        }
    }
    }
}
}


// MARK: TO DO LIST
// Add field validation in newcook controller for name

