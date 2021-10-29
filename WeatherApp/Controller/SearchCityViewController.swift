//
//  SearchCityViewController.swift
//  WeatherApp
//
//  Created by Stella on 10/28/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire

class SearchCityViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    let arr = ["Seattle WA, USA, 54℉", "Wuhan Hubei, China, 77℉"]
    
    var arrCityInfo : [CityInfo] = [CityInfo]()
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 3 {
            return
        }
        getCitiesFromSearch(searchText)
        
        

    }
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // You will change this to arrCityInfo.count
        return arrCityInfo.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
        cell.textLabel?.text = "" + arrCityInfo[indexPath.row].localizedName + "," + arrCityInfo[indexPath.row].countryLocalizedName // You will change this to getr values from arrCityinfo and assign text
            
        return cell
    }
        
    func getSearchURL(_ searchText : String) -> String{
        return locationSearchURL + "apikey=" + apiKey + "&q=" + searchText
    }
    
    
    func getCitiesFromSearch(_ searchText : String) {
        getCityInfo(searchText)
            .done { city in
                self.addCityinDB(city)
            }
            .catch{ (error) in
                print(error)
            }
        
        tblView.reloadData()
                
                // You will receive JSON array
                // Parse the JSON array
                // Add values in arrCityInfo
                // Reload table with the values
        
        
    }
        
        
        
    func getCityInfo(_ searchText : String) -> Promise<CityInfo>{
        
        let url = getSearchURL(searchText)
        
        
        return Promise<CityInfo> { seal -> Void in
            let url = getSearchURL(searchText)
            
        
        Alamofire.request(url).responseJSON { response in
                
            if response.error != nil {
                seal.reject(response.error!)
            }
                
            
            let cities = JSON(response.data!).array
            
            guard let firstCity = cities!.first else { seal.fulfill(CityInfo())
                    return
            }
            
            
            let companyInfo = CompanyInfo()
            cityInfo.key = firstCity["key"].stringValue
            cityInfo.type = firstCity["type"].stringValue
            cityInfo.localizedName = firstCity["localizedName"].stringValue
            cityInfo.countryLocalizedName = firstCity["countryLocalizedName"].stringValue
            cityInfo.administrativeID = firstCity["administrativeID"].stringValue
            
            seal.fulfill(cityInfo)
        
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // You will get the Index of the city info from here and then add it into the realm Database
        // Once the city is added in the realm DB pop the navigation view controller
        
        cityDetail = arrCityInfo[indexPath.row]
        performSegue(withIdentifier: "segueDetails", sender: self)
        
        storeValuesInDB(cityDetail.key)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetails" {
            let detailsVC = segue.destination as! DetailsViewController
            detailsVC.cityInfo = cityDetail
        }
    }
    
    
    
    func addCityinDB(_ cityInfo : CityInfo){
            do{
                let realm = try Realm()
                try realm.write {
                    realm.add(cityInfo, update: .modified)
                }
            }catch{
                print("Error in getting values from DB \(error)")
            }
        }
        
    func storeValuesInDB(_ key : String ){
        
        getCityInfo(key)
            .done { city in
                self.addCitykinDB(city)
            }
            .catch{ (error) in
                print(error)
            }
    }
    
    func doesCityExistInDB(_ key : String) -> Bool {
       do{
           let realm = try Realm()
           if realm.object(ofType: CityInfo.self, forPrimaryKey: key) != nil { return true }
           
       }catch{
           print("Error in getting values from DB \(error)")
       }
       return false
   }

}








