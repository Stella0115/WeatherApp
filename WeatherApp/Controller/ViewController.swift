//
//  ViewController.swift
//  WeatherApp
//
//  Created by Stella on 10/28/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let arrSearch = ["Seattle WA, USA, 54℉"]
    var arrCityInfo: [CityInfo] = [CityInfo]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()
    
    var cityDetail : CityInfo?
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadCurrentConditions()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshControl = refreshControl
        
    }
    
    @objc func refreshData(){
        loadCityValues()
        self.refreshControl?.endRefreshing()
    }
        
    
    func loadCityValues(){
            
            do{
                let realm = try Realm()
                let cities = realm.objects(CityInfo.self)
             
                arrCityInfo.removeAll()
                
                getAllCityInfo(Array(cities)).done { citiesInfo in
                    self.arrCityInfo.append(contentsOf: citiesInfo)
                    self.arrSearch.append(contentsOf: citiesInfo)
                    self.tblView.reloadData()
                }
                .catch { error in
                    print(error)
                }
                
                
                
            }catch{
                print("Error in reading Database \(error)")
            }
            
        }

    
    
    
    @IBAction func addCityAction(_ sender: Any) {
        guard let key = globalTextField?.text else {return}
        
        if key == "" {
            return
        }
        self.storeValuesInDB(key)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadCurrentConditions()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count // You will replace this with arrCurrentWeather.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arr[indexPath.row] // replace this with values from arrCurrentWeather array
        return cell
    }

    
    
    func loadCurrentConditions(){
            
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    
        do{
            let realm = try Realm()
            let cities = realm.objects(CityInfo.self)
            self.arrCityInfo.removeAll()
            getAllCurrentWeather(Array(cities)).done { currentWeather in
                self.tblView.reloadData()
            }
            .catch { error in
                print(error)
            }
        }catch{
            print("Error in reading Database \(error)")
        }
            
    }
        
    func getAllCurrentWeather(_ cities: [CityInfo] ) -> Promise<[CurrentWeather]> {
        var promises: [Promise< CurrentWeather>] = []
        
        for i in 0 ... cities.count - 1 {
            promises.append( getCurrentWeather(cities[i].key) )
        }
        
        return when(fulfilled: promises)
        
    }
        
        
    func getCurrentWeather(_ cityKey : String) -> Promise<CurrentWeather>{
            return Promise<CurrentWeather> { seal -> Void in
                let url = "" // build URL for current weather here
                
                Alamofire.request(url).responseJSON { response in
                    
                    if response.error != nil {
                        seal.reject(response.error!)
                    }
                    
                  
                    let currentWeather = CurrentWeather()
                    
                    
                    seal.fulfill(currentWeather)
                    
                }
            }
    }

}

