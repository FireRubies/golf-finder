//
//  Golf_FinderApp.swift
//  Golf Finder WatchKit Extension
//
//  Created by Kyler Smith on 1/21/22.
//

import SwiftUI
import Foundation
import WatchKit
import CoreLocation
import MapKit
import Network
import SQLite



@main
struct Golf_FinderApp: App {
    init() {
        setup()
    }
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(locationU: locationU)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

import Foundation
import WatchKit

var countries = ["None", "United States","Afghanistan","Albania","Algeria","Andorra","Angola","Anguilla","Antigua and Barbuda","Argentina","Armenia","Aruba","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bermuda","Bhutan","Bolivia","Bosnia and Herzegovina","Botswana","Brazil","British Virgin Islands","Brunei","Bulgaria","Burkina Faso","Burundi","Cambodia","Cameroon","Cape Verde","Cayman Islands","Chad","Chile","China","Colombia","Congo","Cook Islands","Costa Rica","Cote D Ivoire","Croatia","Cruise Ship","Cuba","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","Equatorial Guinea","Estonia","Ethiopia","Falkland Islands","Faroe Islands","Fiji","Finland","France","French Polynesia","French West Indies","Gabon","Gambia","Georgia","Germany","Ghana","Gibraltar","Greece","Greenland","Grenada","Guam","Guatemala","Guernsey","Guinea","Guinea Bissau","Guyana","Haiti","Honduras","Hong Kong","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland","Isle of Man","Israel","Italy","Jamaica","Japan","Jersey","Jordan","Kazakhstan","Kenya","Kuwait","Kyrgyz Republic","Laos","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macau","Macedonia","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Mauritania","Mauritius","Mexico","Moldova","Monaco","Mongolia","Montenegro","Montserrat","Morocco","Mozambique","Namibia","Nepal","Netherlands","Netherlands Antilles","New Caledonia","New Zealand","Nicaragua","Niger","Nigeria","Norway","Oman","Pakistan","Palestine","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Poland","Portugal","Puerto Rico","Qatar","Reunion","Romania","Russia","Rwanda","Saint Pierre and Miquelon","Samoa","San Marino","Satellite","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Slovakia","Slovenia","South Africa","South Korea","Spain","Sri Lanka","St Kitts and Nevis","St Lucia","St Vincent","St. Lucia","Sudan","Suriname","Swaziland","Sweden","Switzerland","Syria","Taiwan","Tajikistan","Tanzania","Thailand","Timor L'Este","Togo","Tonga","Trinidad and Tobago","Tunisia","Turkey","Turkmenistan","Turks and Caicos","Uganda","Ukraine","United Arab Emirates", "United Kingdom","Uruguay","Uzbekistan","Venezuela","Vietnam","Virgin Islands (US)","Yemen","Zambia","Zimbabwe"];

var latitude = Double()
var longitude = Double()
var searchlist:Array<String> = []
var locationManager:CLLocationManager?
var locationU = UserLocation()
var timer = Timer()
var timer2 = Timer()
var timer3 = Timer()
var testLocation = CLLocation(latitude: 33.7181584, longitude: 73.071358)
var currentState = ""
var currentCountry = ""
var currentCity = ""
var defaultDegree = CLLocationDegrees(0)



let coursesTable = Table("courses")
let cachedCoursesTable = Table("cachedCourses")
let nameColumn = Expression<String?>("name")
let idColumn = Expression<Int64>("id")
let countryColumn = Expression<String?>("country")

extension FileManager {

   static func getDocumentsDirectory() -> URL {
       let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
       let documentsDirectory = paths[0]
       return documentsDirectory
   }
}

func setup() {
    
    for family in UIFont.familyNames {
        print(family)
        
//        for names in UIFont.fontNames(forFamilyName: family){
//            print("== \(names)")
//        }
    }
    
        
    
    print("Path: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String)")
    getUserLocation()
    timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
            updateLocations()
        })
    updateLocations()
    
    let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
    ).first!
//    do {
//        let db = try Connection("\(path)/courses.sqlite3")
//        let coursesTable = Table("courses")
//        let cachedCoursesTable = Table("cachedCourses")
//        let nameColumn = Expression<String?>("name")
//        let idColumn = Expression<Int64>("id")
//        let countryColumn = Expression<String?>("country")
//        let holesColumn = Expression<String?>("holes")
//        let landmarkNamesColumn = Expression<String?>("landmarkNames")
//        let landmarkCoordsColumn = Expression<String?>("landmarkCoords")
//        try db.run(coursesTable.create(ifNotExists: true) { t in
//            t.column(idColumn, unique: true)
//            t.column(nameColumn)
//            t.column(countryColumn)
//        })
//
//        try db.run(cachedCoursesTable.create(ifNotExists: true) { t in
//            t.column(idColumn, unique: true)
//            t.column(nameColumn)
//            t.column(countryColumn)
//            t.column(holesColumn)
//            t.column(landmarkNamesColumn)
//            t.column(landmarkCoordsColumn)
//
//
//        })
//    } catch {
//        print(error)
//    }
    
    
    //getHighestCourseID()
    downloadDataOnce()
}

extension CLLocation {
    func fetchLocationData(completion: @escaping (_ city: String?, _ country:  String?, _ state: String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $0?.first?.administrativeArea, $1) }
    }
}

extension String {
   var isNumeric: Bool {
     return !(self.isEmpty) && self.allSatisfy { $0.isNumber }
   }
}


func updateLocations() {
    locationU.latitude = locationManager?.location?.coordinate.latitude
    locationU.longitude = locationManager?.location?.coordinate.longitude
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
         print("Lat : \(location.coordinate.latitude) \nLng : \(location.coordinate.longitude)")
    }
}

func getUserLocation() {
     locationManager = CLLocationManager()
     locationManager?.requestAlwaysAuthorization()
     locationManager?.startUpdatingLocation()
    print(locationManager?.location?.coordinate.latitude as Any)
 }

func getHoles(id: String) -> Array<Array<String>> {
    
    var holes:Array<Array<String>> = []
        
    let sem2 = DispatchSemaphore.init(value: 0)
    let urlHoles = URL(string: ("https://tiemposystems.com/coursedetail_json.php?courseid=" + id))
    let taskHoles = URLSession.shared.holesTask(with: urlHoles!) { hole, response, error in
        defer { sem2.signal() }
         if let hole = hole {
             print("dwdwdwdwdwdwdwdwdwdwdassasd")
             print(hole.count)
             for i in hole {
                 if (i.name == "Middle of Green") {
                     holes.append([i.latitude, i.longitude])
                 }
             }
             }
         
       }
       taskHoles.resume()
    sem2.wait()
    print("holes****")
    print(holes)
    if holes.count < 1 {
        return []
    } else {
        return holes
    }
}

func getHolesDatabase(id: String) -> Array<Array<String>> {
    var holes:Array<Array<String>> = []
    let idColumn = Expression<Int64>("id")
    let holesColumn = Expression<String?>("holes")
    let landmarkNamesColumn = Expression<String?>("landmarkNames")
    let landmarkCoordsColumn = Expression<String?>("landmarkCoords")
    let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
    ).first!
    do {
        let db = try Connection("\(path)/courses.sqlite3")
        
            let query = cachedCoursesTable.filter(idColumn == Int64(Int(id)!))
            for item in try db.prepare(query) {
                var iHolesColumn = String(describing: item[holesColumn]!).components(separatedBy: "|")
                
                for hole in iHolesColumn {
                    holes.append(hole.components(separatedBy: ","))
                }
                
            }
            
    } catch {
        print(error)
    }
    print("holes****")
    print(holes)
    return holes
    
}


func getLandmarks(id: String) -> Array<Array<Array<String>>> {
    var landmarks:Array<Array<Array<String>>> = []
    
    let sem2 = DispatchSemaphore.init(value: 0)
    var numHoles2:Int = 0
    let urlHoles = URL(string: ("https://tiemposystems.com/coursedetail_json.php?courseid=" + id))
    let taskHoles = URLSession.shared.holesTask(with: urlHoles!) { hole, response, error in
        defer { sem2.signal() }
         if let hole = hole {
             print("dwdwdwdwdwdwdwdwdwdwdassasd")
             numHoles2 = 0
             for i in hole {
                 if (Int(i.holenum)! > numHoles2) {
                     numHoles2 = Int(i.holenum)!
                 }
             }
             print(numHoles2)
             if numHoles2 <= 0 {
                 return
             }
             
             for _ in 0...numHoles2-1 {
                 landmarks.append([])
             }
             for i in hole {
                 if (i.name != "Middle of Green") {
                     landmarks[(Int(i.holenum)!)-1].append([i.name, i.latitude, i.longitude])
                 }
             }
         }
       }
    
    taskHoles.resume()
    sem2.wait()
    print(landmarks)
    if landmarks.count < 1 {
        return []
    } else {
        return landmarks
    }
}

func getLandmarksDatabase(id: String) -> Array<Array<Array<String>>> {
    var landmarks:Array<Array<Array<String>>> = []
    var holes:Array<Array<String>> = []
    let idColumn = Expression<Int64>("id")
    let holesColumn = Expression<String?>("holes")
    let landmarkNamesColumn = Expression<String?>("landmarkNames")
    let landmarkCoordsColumn = Expression<String?>("landmarkCoords")
    
    var aLandmarkCoords:Array<Array<String>> = []
    let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
    ).first!
    do {
        let db = try Connection("\(path)/courses.sqlite3")
        
            let query = cachedCoursesTable.filter(idColumn == Int64(Int(id)!))
            for item in try db.prepare(query) {
                var iLandmarkNamesColumn = String(describing: item[landmarkNamesColumn]!).replacingOccurrences(of: "|", with: "*").components(separatedBy: "*")
                var iLandmarkCoordsColumn = String(describing: item[landmarkCoordsColumn]!).components(separatedBy: "|")
                for landmark in iLandmarkCoordsColumn {
                    print("landmarks")
                    print(landmark)
                    aLandmarkCoords.append(landmark.components(separatedBy: "*"))
                }
                print("efewfsfe")
                print(aLandmarkCoords)
                if iLandmarkNamesColumn == [""] || aLandmarkCoords[0][0] == "" {
                    return []
                }
                
                for _ in aLandmarkCoords {
                    landmarks.append([])
                }
                var landmarkCurrentName = 0
                for i in 0...aLandmarkCoords.count-1 {
                    for j in aLandmarkCoords[i] {
                        print("Current Name: ", iLandmarkNamesColumn[landmarkCurrentName])
                        landmarks[i].append([iLandmarkNamesColumn[landmarkCurrentName], j.components(separatedBy: ",")[0], j.components(separatedBy: ",")[1]])
                        landmarkCurrentName += 1
                    }
                }
                
            }
            
    } catch {
        print(error)
    }
    print(landmarks)
    return landmarks
}

func getHighestCourseID() -> Int {
    let idColumn = Expression<Int64>("id")
    let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
    ).first!
    do {
        let db = try Connection("\(path)/courses.sqlite3")
        
            let query = coursesTable.select(idColumn).order(idColumn.desc).limit(1)
        for i in try db.prepare(query) {
            print("Highest Course ID: ")
            print(i[idColumn])
            return Int(i[idColumn])
        }
                
    } catch {
        print(error)
    }
    return 1
}

func cacheCourse(id: String, coursename: String, country: String, holesCoords:Array<Array<String>>, courseLandmarks:Array<Array<Array<String>>>) -> Bool {
    
    print("cacheCourse Vars:")
    print(id)
    print(coursename)
    print(country)
    print("*** - holesCoords")
    print(holesCoords)
    print("*** - courseLandmarks")
    print(courseLandmarks)
    
    
    let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
    ).first!
    let numHoles = holesCoords.count-1
    
    let iCountry = country
    let iName = coursename
    let iId = Int64(Int(id)!)
    let cachedCoursesTable = Table("cachedCourses")
    var iHoles = ""
    var iLandmarkNames = ""
    var iLandmarkCoords = ""
    
    guard 0 < numHoles else {
        print("Lower bound must be lower than upper bound")
        return false
    }
    for i in 0...numHoles {
        print("i: \(i)")
        if i < numHoles {
            iHoles += "\(holesCoords[i][0]),\(holesCoords[i][1])|"
        } else {
            iHoles += "\(holesCoords[i][0]),\(holesCoords[i][1])"
        }
    }
    
    for i in 0...numHoles {
        var iLandmarkSectionSection = ""
        for j in 0...courseLandmarks[numHoles].count-1 {
            if j >= courseLandmarks[numHoles].count-1 {
                iLandmarkSectionSection += "\(courseLandmarks[numHoles][j][1]),\(courseLandmarks[numHoles][j][2])"
            } else {
                iLandmarkSectionSection += "\(courseLandmarks[numHoles][j][1]),\(courseLandmarks[numHoles][j][2])*"
            }
        }
        if (i >= numHoles) {
            iLandmarkCoords += iLandmarkSectionSection
        } else {
            iLandmarkCoords += "\(iLandmarkSectionSection)|"
        }
    }
    
    for i in 0...numHoles {
        var iLandmarkSectionSection = ""
        for j in 0...courseLandmarks[numHoles].count-1 {
            if j >= courseLandmarks[numHoles].count-1 {
                iLandmarkSectionSection += "\(courseLandmarks[numHoles][j][0])"
            } else {
                iLandmarkSectionSection += "\(courseLandmarks[numHoles][j][0])*"
            }
        }
        if (i >= numHoles) {
            iLandmarkNames += iLandmarkSectionSection
        } else {
            iLandmarkNames += "\(iLandmarkSectionSection)|"
        }
    }
    
    print("Landmark Names")
    print(iLandmarkNames)
    let holes = Expression<String>("holes")
    let landmarkNames = Expression<String>("landmarkNames")
    let landmarkCoords = Expression<String>("landmarkCoords")
    let name = Expression<String>("name")
    let id = Expression<Int64>("id")
    let country = Expression<String>("country")
    

    do {
        let db = try Connection("\(path)/courses.sqlite3")
        try db.run(cachedCoursesTable.upsert(country <- iCountry, name <- iName, id <- iId, holes <- iHoles, landmarkNames <- iLandmarkNames, landmarkCoords <- iLandmarkCoords, onConflictOf: id))
        } catch {
            print(error)
        }
    
    return true

}


func cacheUserCourse(coursename: String, holesCoords:Array<Array<String>>, courseLandmarks:Array<Array<Array<String>>>) {
    
    print("cacheCourse Vars:")
    print(coursename)
    print("*** - holesCoords")
    print(holesCoords)
    print("*** - courseLandmarks")
    print(courseLandmarks)
    
    
    let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
    ).first!
    let numHoles = holesCoords.count-1
    
    let iCountry = "User Courses"
    let iName = coursename
    var courseLandmarks = courseLandmarks
    var courseLandmarksNew:Array<Array<Array<String>>> = []
            for i in 0...courseLandmarks.count-1 {
                let j = courseLandmarks[i].filter { $0[0] != "" }
                if (j != []) {
                    courseLandmarksNew.append(j)
                }
            }
    print(courseLandmarksNew)
    
    
    let numLandmarks = courseLandmarksNew.count-1
    
    var iID = Int64(getHighestCourseID()+1)
    var iHoles = ""
    var iLandmarkNames = ""
    var iLandmarkCoords = ""
    
    
    for i in 0...numHoles {
        print("i: \(i)")
        if i < numHoles {
            iHoles += "\(holesCoords[i][0]),\(holesCoords[i][1])|"
        } else {
            iHoles += "\(holesCoords[i][0]),\(holesCoords[i][1])"
        }
    }
    if courseLandmarksNew.count >= 1 {
        for i in 0...courseLandmarksNew.count-1 {
            var iLandmarkSectionSection = ""
            for j in 0...courseLandmarksNew[numLandmarks].count-1 {
                if j >= courseLandmarksNew[numLandmarks].count-1 {
                    print("CLNL: \(courseLandmarksNew[numLandmarks].count-1)")
                    print("j: \(j)")
                    print("\(courseLandmarksNew[numLandmarks][j][1]),\(courseLandmarksNew[numLandmarks][j][2])")
                    iLandmarkSectionSection += "\(courseLandmarksNew[numLandmarks][j][1]),\(courseLandmarksNew[numLandmarks][j][2])"
                } else {
                    print("\(courseLandmarksNew[numLandmarks][j][1]),\(courseLandmarksNew[numLandmarks][j][2])*")
                    iLandmarkSectionSection += "\(courseLandmarksNew[numLandmarks][j][1]),\(courseLandmarksNew[numLandmarks][j][2])*"
                }
            }
            if (i >= numLandmarks) {
                iLandmarkCoords += iLandmarkSectionSection
            } else {
                iLandmarkCoords += "\(iLandmarkSectionSection)|"
            }
        }
    }
    if numLandmarks > 0 {
        for i in 0...numLandmarks {
            var iLandmarkSectionSection = ""
            for j in 0...courseLandmarksNew[numLandmarks].count-1 {
                if j >= courseLandmarksNew[numLandmarks].count-1 {
                    iLandmarkSectionSection += "\(courseLandmarksNew[numLandmarks][j][0])"
                } else {
                    iLandmarkSectionSection += "\(courseLandmarksNew[numLandmarks][j][0])*"
                }
            }
            if (i >= numLandmarks) {
                iLandmarkNames += iLandmarkSectionSection
            } else {
                iLandmarkNames += "\(iLandmarkSectionSection)|"
            }
        }
    }
    
    print("Landmark Names")
    print(iLandmarkNames)
    let holes = Expression<String>("holes")
    let landmarkNames = Expression<String>("landmarkNames")
    let landmarkCoords = Expression<String>("landmarkCoords")
    let name = Expression<String>("name")
    let id = Expression<Int64>("id")
    let country = Expression<String>("country")

    do {
        let db = try Connection("\(path)/courses.sqlite3")
        let coursesTable = Table("courses")
        try db.run(coursesTable.insert(country <- iCountry, name <- iName, id <- iID))
    } catch {
        print(error)
    }

    do {
        let db = try Connection("\(path)/courses.sqlite3")
        try db.run(cachedCoursesTable.insert(country <- iCountry, name <- iName, id <- iID, holes <- iHoles, landmarkNames <- iLandmarkNames, landmarkCoords <- iLandmarkCoords))
        } catch {
            print(error)
        }

}


func getSearchResults(searchText: String, currentCountry: String) -> [String] {
    print("hiiiiiiii")
    print(currentCountry)
    if (countries.contains(currentCountry) || currentCountry == "User Courses") {
        print("edeeded")
    let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
    ).first!
    do {
    print("hi321")
    let db = try Connection("\(path)/courses.sqlite3")
    print("good")

    if (currentCountry != "" ) {
        print("LOPHG")
        let query = coursesTable.filter(countryColumn == currentCountry)
        let items = try db.prepare(query)
        searchlist = []
        for item in items {
            searchlist.append("\(String(describing: item[nameColumn]!))\n - \(String(item[idColumn]))")
        }
    }
    if (searchText.isEmpty) {
        print("search text is empty")
        return searchlist
    } else {
        print("filtering searchlist")
        return searchlist.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    } catch {
        print(error)
    }
    }
    let toReturnSearchlist = searchlist.prefix(50).map{String($0)}
    print("toReturnSearchlistCount")
    print(toReturnSearchlist.count)
    return toReturnSearchlist
}

/*TODO: Fix the weird bug where it's showing you more
 results than it should be. Like more than 50.
 That shouldn't be happening however it is
 and it happened after you added the searchCountry
 thing which is using some of the same variable names so
 perhaps change the variable names or start commenting out
 parts of the selectCountry view section until it works! :)

*/
func getCountrySearchResults(searchText: String) -> [String] {
    searchlist = countries
    
    if (searchText.isEmpty) {
        print("search text is empty")
        return searchlist
    } else {
        print("filtering searchlist")
        return searchlist.filter { $0.contains(searchText) }
    }
    }
 //   return searchlist.prefix(50).map{String($0)}


func downloadDataOnce() {
    print(UserDefaults.standard.bool(forKey: "hasDownloadedCourses"))
    if (!UserDefaults.standard.bool(forKey: "hasDownloadedCourses")) {
        print("Downloading course data")
        importCoursesFromDatabaseFile()
        //downloadData()
    } else {
        print("Already downloaded course data.")
    }
}

class FileDownloader {

    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else if let dataFromURL = NSData(contentsOf: url)
        {
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
                print("file saved [\(destinationUrl.path)]")
                completion(destinationUrl.path, nil)
            }
            else
            {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
        else
        {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }

    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else
        {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(destinationUrl.path, error)
                                }
                                else
                                {
                                    completion(destinationUrl.path, error)
                                }
                            }
                            else
                            {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }
}

func importCoursesFromDatabaseFile() {
    
    
    // Get a reference to the FileManager
    let fileManager = FileManager.default

    // Get the URL for the system Documents folder
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        fatalError("Unable to get the Documents directory URL.")
    }
    
    
    var url = URL(string: "https://download850.mediafire.com/ezdkmqs3b8rg4iaFiNctfLYmnc_sArbKPI2eCEHXCWoSbSvNdrKIhw6T270BPeBkjGnI3NaZjHxj89H7_xaIGLZGX6zKJG8tzZwDSviyfmip4AD9YHfgR9HMcfxiuUqntIAskjgnQ8ZC7wz7pUSOdTpUXSdwV05OCTZBqn-wKc3S/xnwwgk21r2w8za1/courses.sqlite3")
    
    //let url = URL(string: "http://www.filedownloader.com/mydemofile.pdf")
    FileDownloader.loadFileAsync(url: url!) { (documentsURL, error) in
        print("File downloaded to : \(documentsURL!)")
    }
    
    
    
    return
    
    

    //print(Bundle)
    
    //print(Bundle.path(forResource: "default_courses", ofType: "Default - Data", inDirectory: "Golf Finder WatchKit Extension")!)
    
    

    
    
    // Get the URL for the original file in your WatchKit Extension folder
    let originalFileURL = Bundle.main.url(forResource: "default_courses", withExtension: "bundle")!.appendingPathComponent("courses.sqlite3")
    
    //originalFileURL = originalFileURL.appendPathComponent("/courses.sqlite3")
    
    //let originalFileURL = Bundle.main.url(forResource: "courses", withExtension: "sqlite3")
    
    print(originalFileURL)
    
    //let originalFileURL = originalFileURL
    
    //Bundle.path(forResource: "courses", ofType: "sqlite3", inDirectory: "Golf Finder WatchKit Extension")

    // Create a new URL for the file in the Documents folder
    let newFileURL = documentsURL.appendingPathComponent("courses.sqlite3")

    do {
        // Check if the file already exists in the Documents folder
        if fileManager.fileExists(atPath: newFileURL.path) {
            // Delete the file if it already exists
            try fileManager.removeItem(at: newFileURL)
        }

        // Move the file from the original location to the Documents folder
        try fileManager.moveItem(at: originalFileURL, to: newFileURL)
    } catch {
        print("Error moving file: \(error)")
    }
    
    
//    let path = NSSearchPathForDirectoriesInDomains(
//        .documentDirectory, .userDomainMask, true
//    ).first!
//
//    var url = URL(fileURLWithPath: "Golf Finder WatchKit Extension/courses.sqlite3")
//
//    var newURL = FileManager.getDocumentsDirectory()
//    newURL.appendPathComponent(url.lastPathComponent)
//    do {
//    if FileManager.default.fileExists(atPath: newURL.path) {
//        try FileManager.default.removeItem(atPath: newURL.path)
//    }
//    try FileManager.default.moveItem(atPath: url.path, toPath: newURL.path)
//        print("The new URL: \(newURL)")
//    } catch {
//        print(error.localizedDescription)
//    }
    
    
//    guard let filePath = Bundle.main.path(forResource: "courses", ofType: "sqlite3") else {
//        // handle error if file not found
//        return
//    }
//
//    guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//        // handle error if documents directory not found
//        return
//    }
//
//    let destinationUrl = documentsUrl.appendingPathComponent("courses.sqlite3")
//
//    do {
//        try FileManager.default.copyItem(atPath: filePath, toPath: destinationUrl.path)
//    } catch {
//        // handle error if copy operation fails
//    }
//

}


func convertCourseDataToJSON(landmarks:Array<Array<Array<String>>>, holes:Array<Array<String>>, numHoles:Int) -> String {
    var courseJSON = "["
    print("*******CCDTJ DATA START")
    print(landmarks)
    print(holes)
    print(numHoles)
    print("*********CCDTJ DATA END")
    for i in 0...numHoles-1 {
      if (holes[i][1] != "" && holes[i][0] != "") {
        courseJSON += """
 {"holenum" : "\(i+1)", "name" : "Middle of Green", "longitude" : "\(holes[i][1])", "latitude" : "\(holes[i][0])"},
"""
      }
        if (landmarks[i].count > 0) {
            for landmark in landmarks[i] {
              if (landmark[0] != "" && landmark[1] != "" && landmark[2] != "") {
                courseJSON += """
        {"holenum" : "\(i+1)", "name" : "\(landmark[0].replacingOccurrences(of: "|", with: "").replacingOccurrences(of: "*", with: ""))", "longitude" : "\(landmark[1])", "latitude" : "\(landmark[2])"},
"""
              }
            }
        }
    }
    print(courseJSON.prefix(courseJSON.count-1) + "]")
    return courseJSON.prefix(courseJSON.count-1) + "]"
}

let sem = DispatchSemaphore.init(value: 0)
func downloadData() {
    var courses: Array<Course> = []
    let urlCourses = URL(string: "https://tiemposystems.com/courselist_json.php")
    let taskCourses = URLSession.shared.coursesTask(with: urlCourses!) { course, response, error in
        defer { sem.signal() }
         if let course = course {
             print(course.count)
             print(course[17351])
             courses = course
         }
       }
    
       taskCourses.resume()
    sem.wait()
    let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
    ).first!
    for cinc in courses {
        let iCountry = cinc.country
        let iName = cinc.coursename
        let iId = Int64(Int(cinc.courseid)!)
        let name = Expression<String>("name")
        let id = Expression<Int64>("id")
        let country = Expression<String>("country")
        do {
            let db = try Connection("\(path)/courses.sqlite3")
            let coursesTable = Table("courses")
            try db.run(coursesTable.insert(country <- iCountry, name <- iName, id <- iId))
        } catch {
            print(error)
        }
    }
    print("Done downloading courses.")
    UserDefaults.standard.set(true, forKey: "hasDownloadedCourses")
    return

}

func readPropertyList(country: String) -> NSMutableDictionary {

    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let path = paths.appending("/courses.plist")
    let plistDict = NSDictionary(contentsOfFile: path)
    print(path)

    print(plistDict!.count)
    if (plistDict![country] == nil) {
        return NSMutableDictionary.init()
    }

    if ((plistDict![country] as! NSDictionary).count > 0) {
        return plistDict![country] as! NSMutableDictionary
    } else {
        return NSMutableDictionary.init()
    }

}
