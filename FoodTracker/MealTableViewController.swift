//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Diego Espinosa on 8/17/18.
//  Copyright © 2018 Diego Espinosa. All rights reserved.
//

import os.log
import UIKit

class MealTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var epi : Double = 0.0
    var tot : Double = 0.0
    var currentProgress:Float = 0.0
    
    var epCount:Int = 0
    
    var isTableEditing = false
    var isVisible = true
    var isDarkMode: Bool = false
    
    var meals = [Meal]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(MealTableViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
        
        navigationItem.leftBarButtonItem = editButtonItem
        if let savedMeals = loadMeals() {
            meals += savedMeals
        }
        else {
            // Load the sample data.
            loadSampleMeals()
        }
        //loadSampleMeals()
    }
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    @objc func defaultsChanged(){
        if UserDefaults.standard.bool(forKey: "DARK_THEME_KEY"){
            //dark theme enabled
            isDarkMode = true
            updateToDarkTheme()
        } else {
            //dark theme disabled
            isDarkMode = false
            updateToLightTheme()
        }
    }
    
    func updateToDarkTheme(){
        // background color
        self.view.backgroundColor = UIColor.black
        
        // nav bar color
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
    }

    func updateToLightTheme(){
        // background color
        self.view.backgroundColor = UIColor.white
        
        // nav bar color
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default
        self.navigationController?.navigationBar.tintColor = .systemBlue
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        if(isDarkMode){
            // cell background color
            cell.backgroundColor = UIColor.darkGray
            
            // text color
            cell.nameLabel.textColor = UIColor.white
            cell.episodeLabel.textColor = UIColor.white
            cell.totalLabel.textColor = UIColor.white
            
            //button color
            cell.stepper.tintColor = UIColor.white
            cell.stepper.layer.borderColor = UIColor.white.cgColor
            
            // progressview color
            cell.progressView.trackTintColor = UIColor.black
            cell.progressView.progressTintColor = UIColor.white
            
        } else {
            // cell background color
            cell.backgroundColor = UIColor.white
            
            // text color
            cell.nameLabel.textColor = UIColor.black
            cell.episodeLabel.textColor = UIColor.black
            cell.totalLabel.textColor = UIColor.black
            
            //button color
            //cell.stepper.tintColor = UIColor.white
            cell.stepper.layer.borderColor = UIColor.black.cgColor
            cell.stepper.tintColor = .systemBlue
            
            
            // progressview color
            cell.progressView.trackTintColor = UIColor.lightGray
            cell.progressView.progressTintColor = .systemBlue

            
        }
        
        let meal = meals[indexPath.row]
        
        cell.stepper.tag = indexPath.row

        if(Int(meal.episode)! > Int(meal.total)!){
            meal.episode = meal.total
        }
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        //cell.ratingControl.rating = meal.rating
        cell.episodeLabel.text = meal.episode
        cell.totalLabel.text = meal.total
        
        if(Int(cell.episodeLabel.text!)! >= Int(cell.totalLabel.text!)!){
//            cell.episodeLabel.text = cell.totalLabel.text
//            meal.episode = meal.total
            cell.stepper.isHidden = true
        }else{
//            cell.episodeLabel.text = String(epCount + 1)
//            meal.episode = String(epCount + 1)
            cell.stepper.isHidden = false
        }

        
        //progress view
        epi = Double(cell.episodeLabel.text!)!
        tot = Double(cell.totalLabel.text!)!
        
        
        currentProgress = Float((epi/tot))
        
        cell.progressView.setProgress(currentProgress, animated: false)
        //cell.progressView.progress = currentProgress
    
        return cell
    }


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            meals.remove(at: indexPath.row)
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedObject = self.meals[fromIndexPath.row]
        meals.remove(at: fromIndexPath.row)
        meals.insert(movedObject, at: to.row)
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }

    //MARK: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as?
            MealViewController, let meal = sourceViewController.meal{
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                
                meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveMeals()
        }
    }
    
    @IBAction func stepper(_ sender: UIButton) {
        let cell = sender.superview?.superview as! MealTableViewCell
        let meal = meals[cell.stepper.tag]
        
        epCount = Int(cell.episodeLabel.text!)!
        
        print("Episode Count: \(epCount + 1)")
        print("------------")
        
        if(epCount + 1 >= Int(cell.totalLabel.text!)!){
            cell.episodeLabel.text = cell.totalLabel.text
            meal.episode = meal.total
            cell.stepper.isHidden = true
        }else{
            cell.episodeLabel.text = String(epCount + 1)
            meal.episode = String(epCount + 1)
            cell.stepper.isHidden = false
        }
        
        //progress updated
        epi = Double(cell.episodeLabel.text!)!
        tot = Double(cell.totalLabel.text!)!
        
        currentProgress = Float((epi/tot))
        cell.progressView.setProgress(currentProgress, animated: false)
        
        saveMeals()
        
        
    }
    
    
    
    //MARK: Private Methods
    
    private func loadSampleMeals(){
        //let photo1 = UIImage(named: "meal1")
        //let photo2 = UIImage(named: "meal2")
        //let photo3 = UIImage(named: "meal3")
        let photoUnknown = UIImage(named: "defaultPhoto")
        
        guard let meal1 = Meal(name: "Sample Show", photo: photoUnknown, episode: "7", total: "24") else {
            fatalError("Unable to instantiate meal")
        }
        guard let meal2 = Meal(name: "Sample Show 2", photo: photoUnknown, episode: "23", total: "100") else{
            fatalError("Unable to instantiate meal2")
        }
        guard let meal3 = Meal(name: "Sample Show 3", photo: photoUnknown, episode: "20", total: "50") else{
            fatalError("Unable to instantiate meal 3")
        }
        meals += [meal1, meal2, meal3]
    }
    
    private func saveMeals(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        if isSuccessfulSave{
            os_log("Meals successfully saved.", log: OSLog.default, type:.debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type:.error)
        }
    }
    
    private func loadMeals() -> [Meal]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }

}

extension UIColor {
    internal class var systemBlue: UIColor {
        return UIButton(type: .system).tintColor
    }
}


