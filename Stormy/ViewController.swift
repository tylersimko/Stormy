//
//  ViewController.swift
//  Stormy
//
//  Created by Tyler Simko on 10/8/14.
//  Copyright (c) 2014 O8 Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    
    private let apiKey = "3f60bce32cdff52c184189c2db6c0007"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        refreshActivityIndicator.hidden = true
        getCurrentWeatherData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCurrentWeatherData() -> Void {
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/3f60bce32cdff52c184189c2db6c0007/\(apiKey)")
        let forecastURL = NSURL(string: "40.484089,-74.283029", relativeToURL: baseURL)
        
        let sharedSession = NSURLSession.sharedSession()
        //temporarily store JSON data at location
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL, completionHandler: { (location: NSURL!, response:NSURLResponse!, error:NSError!) -> Void in
            //  var urlContents = NSString.stringWithContentsOfURL(location, encoding: NSUTF8StringEncoding, error: nil)
            //            println(urlContents)
            
            if error == nil {
                let dataObject = NSData(contentsOfURL: location)
                let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject, options: nil, error: nil) as NSDictionary
                println(weatherDictionary)
                let currentWeather = Current(weatherDictionary: weatherDictionary)
                println(currentWeather.currentTime!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.temperatureLabel.text = "\(currentWeather.temperature)"
                    self.iconImageView.image = currentWeather.icon!
                    self.currentTimeLabel.text = "At \(currentWeather.currentTime!) it is"
                    self.humidityLabel.text = "\(currentWeather.humidity)"
                    self.precipitationLabel.text = "\(currentWeather.precipitationProbability)"
                    self.summaryLabel.text = "\(currentWeather.summary)"
                    self.refreshActivityIndicator.stopAnimating()
                    self.refreshActivityIndicator.hidden = true
                    self.refreshButton.hidden = false
                    
                })
                
            } else {
                let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data, connectivity error.", preferredStyle: .Alert)
                let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                networkIssueController.addAction(okayButton)
                networkIssueController.addAction(cancelButton)
                self.presentViewController(networkIssueController, animated: true, completion: nil)
    
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.refreshActivityIndicator.stopAnimating()
                    self.refreshActivityIndicator.hidden = true
                    self.refreshButton.hidden = false
                })
            }
        })
        downloadTask.resume()
    }


    @IBAction func refreshButtonPressed() {
        getCurrentWeatherData()
        refreshButton.hidden = true
        refreshActivityIndicator.hidden = false
        refreshActivityIndicator.startAnimating()
    }
}

