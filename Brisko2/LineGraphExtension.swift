//
//  LineGraphExtension.swift
//  Brisko2
//
//  Created by Matt Pancino on 11/11/18.
//  Copyright © 2018 Matt Pancino. All rights reserved.
//

import Foundation
import Charts

extension LineChartView {
    func configureChart()  {
      
        self.chartDescription?.enabled = true
        
        self.dragEnabled = true
        self.setScaleEnabled(true)
        self.pinchZoomEnabled = true
        self.highlightPerDragEnabled = true
        
        self.backgroundColor = .white
        
        self.legend.enabled = true
        self.drawBordersEnabled = true
        
        let xAxis = self.xAxis
        xAxis.labelPosition = .bottom
//        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
     //   xAxis.labelTextColor = UIColor(red: 255/255, green: 120/255, blue: 83/255, alpha: 1)
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        // xAxis.centerAxisLabelsEnabled = true
        //xAxis.granularity = 1
        xAxis.valueFormatter = DateValueFormatter()
        xAxis.labelPosition = .bottom
        xAxis.drawLabelsEnabled = true
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.avoidFirstLastClippingEnabled = true
        
        
        
        
        let leftAxis = self.leftAxis
        leftAxis.labelPosition = .outsideChart
   //     leftAxis.labelFont = .systemFont(ofSize: 12, weight: .normal)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = false
        //leftAxis.axisMinimum = 0
        // leftAxis.axisMaximum = 170
        //leftAxis.yOffset = -9
       // leftAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        
        
        self.rightAxis.enabled = true
        
        self.legend.form = .line
        //return self
    }
    

    func updateChart(cookSeries: NSSet) {
        
        
        var p1Data : [ChartDataEntry] = [ChartDataEntry]()
        var p2Data : [ChartDataEntry] = [ChartDataEntry]()
        var p3Data : [ChartDataEntry] = [ChartDataEntry]()
        var p4Data : [ChartDataEntry] = [ChartDataEntry]()
        
        
        // try and order the damn set
        let sortedArray = cookSeries.sorted(by: { Double((($0 as! TempEntry).time?.timeIntervalSince1970)!) < Double((($1 as! TempEntry).time?.timeIntervalSince1970)!) })

        //This is were we create the temperature dataSets for the Graph, we have to have values >0...ie the probes have to be plugged in.
        
        for element in sortedArray {
            if (element as! TempEntry).p1 >= 0 {
            p1Data.append(ChartDataEntry(x: ((element as! TempEntry).time?.timeIntervalSince1970)!,y: (element as! TempEntry).p1))
            }
            if (element as! TempEntry).p2 >= 0 {
              p2Data.append(ChartDataEntry(x: ((element as! TempEntry).time?.timeIntervalSince1970)!,y: (element as! TempEntry).p2))
            }
            if (element as! TempEntry).p3 >= 0 {
                p3Data.append(ChartDataEntry(x: ((element as! TempEntry).time?.timeIntervalSince1970)!,y: (element as! TempEntry).p3))
            }
            if (element as! TempEntry).p4 >= 0 {
                p4Data.append(ChartDataEntry(x: ((element as! TempEntry).time?.timeIntervalSince1970)!,y: (element as! TempEntry).p4))
            }

        }
        // 2 - create a data set with our array
        let set1: LineChartDataSet = LineChartDataSet(values: p1Data, label: "Oven Temp")
        set1.axisDependency = .left
        set1.setColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1))
        set1.lineWidth = 1.5
        set1.drawCirclesEnabled = false
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false
        let set2: LineChartDataSet = LineChartDataSet(values: p2Data, label: "Probe 2")
        set2.axisDependency = .left
        set2.setColor(UIColor(red: 0/255, green: 141/255, blue: 255/255, alpha: 1))
        set2.lineWidth = 1.5
        set2.drawCirclesEnabled = false
        set2.drawValuesEnabled = false
        set2.drawCircleHoleEnabled = false
        let set3: LineChartDataSet = LineChartDataSet(values: p3Data, label: "Probe 3")
        set3.axisDependency = .left
        set3.setColor(UIColor(red: 151/255, green: 148/255, blue: 0/255, alpha: 1))
        set3.lineWidth = 1.5
        set3.drawCirclesEnabled = false
        set3.drawValuesEnabled = false
        set3.drawCircleHoleEnabled = false
        let set4: LineChartDataSet = LineChartDataSet(values: p4Data, label: "Probe 4")
        set4.axisDependency = .left
        set4.setColor(UIColor(red: 184/255, green: 0/255, blue: 255/255, alpha: 1))
        set4.lineWidth = 1.5
        set4.drawCirclesEnabled = false
        set4.drawValuesEnabled = false
        set4.drawCircleHoleEnabled = false
        
        
        
        //3 - create an array to store our LineChartDataSets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        dataSets.append(set3)
        dataSets.append(set4)
        let data = LineChartData(dataSets: dataSets)
        
        
        
        
        //5 - finally set our data
        self.data = data
    }
    
    func emptyChart(cookSeries: NSSet) {
        
        
        let p1Data : [ChartDataEntry] = [ChartDataEntry]()
        let set1: LineChartDataSet = LineChartDataSet(values: p1Data, label: "")
        set1.axisDependency = .left
        set1.setColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1))
        set1.lineWidth = 1.5
        set1.drawCirclesEnabled = false
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false
       
        
        
        //3 - create an array to store our LineChartDataSets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        let data = LineChartData(dataSets: dataSets)
        //5 - finally set our data
        self.data = data
    }
    
    //UpdateOven
    func updateOven(cookSeries: NSSet) {
        
        
        var p1Data : [ChartDataEntry] = [ChartDataEntry]()

        
        
        // try and order the damn set
        let sortedArray = cookSeries.sorted(by: { Double((($0 as! TempEntry).time?.timeIntervalSince1970)!) < Double((($1 as! TempEntry).time?.timeIntervalSince1970)!) })
        
        //This is were we create the temperature dataSets for the Graph, we have to have values >0...ie the probes have to be plugged in.
        
        for element in sortedArray {
            if (element as! TempEntry).p1 >= 0 {
                p1Data.append(ChartDataEntry(x: ((element as! TempEntry).time?.timeIntervalSince1970)!,y: (element as! TempEntry).p1))
            }
 
        }
        // 2 - create a data set with our array
        let set1: LineChartDataSet = LineChartDataSet(values: p1Data, label: "Oven Temp")
        set1.axisDependency = .left
        set1.setColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1))
        set1.lineWidth = 1.5
        set1.drawCirclesEnabled = false
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false
    
        
        //3 - create an array to store our LineChartDataSets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)

        let data = LineChartData(dataSets: dataSets)
        
        //5 - finally set our data
        self.data = data
    }
    
    
    
}
