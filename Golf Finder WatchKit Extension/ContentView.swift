//
//  ContentView.swift
//  Golf Finder WatchKit Extension
//
//  Created by Kyler Smith on 1/21/22.
//

import SwiftUI
import Foundation
import UIKit


//TODO: TINY THINGS
//???: test
//struct greenButton: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .padding()
//            .background(.green)//.saturation(0.75)
//            .saturation(0.75)
//            .foregroundColor(.brown)
//        //Color.
//            .cornerRadius(6)
//
//            //.clipShape(Capsule())
//    }
//}

//For creating courses make it actually make the JSON needed
//For creating courses have the inputs actually restrict the stuff the user can input
// so like only numbers in number slots that kinda thing.

class UserLocation: ObservableObject {
    @Published var longitude = locationManager?.location?.coordinate.longitude
    @Published var latitude = locationManager?.location?.coordinate.latitude
}



//class LimitCharsName: ObservableObject {
//    var limit: Int = 50
//
//    @Published var cCourseName: String = "" {
//        didSet {
//            if cCourseName.count > limit {
//                cCourseName = String(cCourseName.prefix(limit))
//            }
//        }
//    }
//}

//class LimitChars: ObservableObject {
//    var courseNameLimit: Int = 5
//    var courseNumHolesLimit: Int = 3
//
//    @Published var cCourseName: String = "" {
//        didSet {
//            if cCourseName.count > courseNameLimit {
//                cCourseName = String(cCourseName.prefix(courseNameLimit))
//            }
//        }
//    }
//
//    @Published var cCourseNumHoles: String = "" {
//        didSet {
//            cCourseName = cCourseName.filter { $0.isNumber }
//            if cCourseName.count > courseNumHolesLimit {
//                cCourseName = String(cCourseName.prefix(courseNumHolesLimit))
//            }
//        }
//    }
//}

struct ContentView: View {
    //Colors
    //var sand = UIColor(red: 194, green: 178, blue: 128, alpha: 1)
    //var backgroundColor = Color(red: 110, green: 179, blue: 118)
    
        

    @State private var currentView = "Menu"
    @State private var addCourseStage = "BData"
    @State private var searchText:String = ""
    @State private var currentCourse:String = ""
    @State private var currentCourseId:String = ""
    @State private var currentHole:Int = 1
    @State private var holesCoords:Array<Array<String>> = []
    @State private var numHoles:Int = 0
    @State private var courseLandmarks:Array<Array<Array<String>>> = []//[[["", "", ""]]]
    @State private var selectedCountry = ""
    @State private var previousCountry = ""
    @State private var currentLandmark:Int = 0
    @ObservedObject var locationU:UserLocation
    @State var showingAlert = false
    //@ObservedObject private var limitChars = LimitChars()
    //Creating Course Vars
    @State private var cCourseName = ""
    @State private var cCourseNumHoles = 1
    @State private var cCourseHoles:Array<Array<String>> = []
    //@State private var cCourseNumHoles = 0
    @State private var cCourseEditingHole = 1
    @State private var cCourseEditingHoleLat = "Not Set"
    @State private var cCourseEditingHoleLon = ""
    
    let maxHoles = 50
    let maxCourseNameChars = 50
    
    @State private var cCourseEditingHoleLandmark = 0
    @State private var cCourseEditingLandmarkForHole = 0
    @State private var cCourseLandmarks:Array<Array<Array<String>>> = [[["", "", ""]]]
    //                                                        [["Name", "Lat", "Lon"]]
    //Alert
    @State private var presentAlert = false
    
    //Colors
    
    var buttonBackgroundColor:Color = Color(red:66/255, green:147/255, blue:36/255)
    var buttonForegroundColor:Color = Color(red:27/255, green:81/255, blue:7/255)
    
    var backgroundColor:Color = Color(red:108/255, green:171/255, blue:85/255)
    
    var searchResults = ""
    
    func goHome() {
        currentView = "Menu"
        addCourseStage = "BData"
        
        numHoles = 0
        currentHole = 1
        searchText = ""
        currentCourse = ""
        currentCourseId = ""
        holesCoords = []
        cCourseName = ""
        cCourseNumHoles = 1
        cCourseHoles = []
        cCourseEditingHole = 1
        cCourseEditingHoleLat = "Not Set"
        cCourseEditingHoleLon = ""
        cCourseEditingHoleLandmark = 0
        cCourseEditingLandmarkForHole = 0
        cCourseLandmarks = [[["", "", ""]]]
        courseLandmarks = [[["", "", ""]]]
        currentLandmark = 0
        selectedCountry = ""
        previousCountry = ""
        
    }
    
    var body: some View {
        
        //return Group<Any> do {
            if (currentView == "Menu") {
                VStack() {
                    Spacer()
                    Text("Golf Finder")
                    //Divider()
                    Button(action: {
                        currentView = "Search"
                    }) {
                        Text("Search Courses")
                    }
                    .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                    .foregroundColor(buttonForegroundColor)
//                    .background(.green)
//                    .saturation(0.75)
////                    .background(Color.purple)
//                    .cornerRadius(6)
////                    .background(Color.purple)
////                    .cornerRadius(6)
                    
                    //Spacer()
                    
                    Button(action: {
                        currentView = "Add"
//                        if (internetConnection) {
//                            currentView = "Add"
//                        }
                    }) {
                        //.foregroundColor(.green).saturation(0.75)
                        Text("Add Course")
                            
                        
                    }
                    .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                    .foregroundColor(buttonForegroundColor)
                    
                    //Spacer()
                    
                    Button(action: {
                        currentView = "Settings"
                    }) {
                        Text("Settings")
                    }
                    .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                    .foregroundColor(buttonForegroundColor)

                }
                
////                .background(UIColor(red: 110, green: 179, blue: 118, alpha: 1))
//
//                .buttonStyle(greenButton())
                
                
            } else if (currentView == "Search") {
                //return Group {
                if (selectedCountry != "User Courses") {
                    var searchResults:[String] = getSearchResults(searchText: searchText, currentCountry: selectedCountry)
                    VStack() {
                        HStack {
                            Button("⌂") {
                                goHome()
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                            
                            Button("Your Courses") {
                                previousCountry = selectedCountry
                                selectedCountry = "User Courses"
                                searchResults = []
                                    
                                }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                            
                            
                            Button("Countries") {
                                searchText = ""
                                currentView = "selectCountry"
                                    
                                }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                            
//                            List {
//                            Picker("Country", selection: $selectedCountry, content: {
//                                ForEach(countries, id: \.self, content: { country in
//                                    Text(country)
//                                        .background(Color.green, ignoresSafeAreaEdges: [])
//                                        .listRowBackground(Color.green)
//                                })
//                            })
//                                .tint(Color.green)
//                                    //.background(Color.green)
//                                    //.listRowBackground(Color.green)
//                                    //.backgro
//
//                            }
//                            .tint(Color.green)
                        }
                        
                            //Remove spacing between Buttons above this comment
                            // and the search bar. It's annoying.
                        NavigationView {
                            List {
                                ForEach(searchResults.prefix(50), id: \.self) { name in
        //                            NavigationLink(destination: Text(name)) {
        //                                Text(name)
        //
                                    Button(name) {
                                        currentCourse = name.components(separatedBy: " - ")[0]
                                        currentCourseId = name.components(separatedBy: " - ")[1]
                                        //add check here so it also checks
                                        //if course is a User course in database before caching!!!!
                                        print(("SC Check:", selectedCountry))
                                        if (selectedCountry != "User Courses" && selectedCountry != "None") {
                                            print("Attempting to cache course using the Internet. :3")
                                            do {
                                                if ((try? cacheCourse(id: currentCourseId, coursename: currentCourse, country: selectedCountry, holesCoords: getHoles(id: currentCourseId), courseLandmarks: getLandmarks(id: currentCourseId))) != false) {
                                                    holesCoords = getHolesDatabase(id: currentCourseId)
                                                    courseLandmarks = getLandmarksDatabase(id: currentCourseId)
                                                    numHoles = holesCoords.count
                                                    //&*
                                                    currentView = "Course"
                                                } else {
                                                    if ((try? holesCoords = getHolesDatabase(id: currentCourseId)) != nil) {
                                                        if (holesCoords.count > 0) {
                                                            courseLandmarks = getLandmarksDatabase(id: currentCourseId)
                                                            numHoles = holesCoords.count
                                                            currentView = "Course"
                                                        }
                                                    }
                                                }
                                                
                                            } catch {
                                                
                                            }
                                        }
                                        

                                        
                                        // else {
//                                            holesCoords = getHolesDatabase(id: currentCourseId)
//                                            courseLandmarks = getLandmarksDatabase(id: currentCourseId)
//                                            numHoles = holesCoords.count
//                                        }
                                        
                                        //Add a Sem thing here to make it wait
                                        //until the course had been cached before
                                        //continuing!
                                        print(name)
                                    }
                                    //.background(buttonBackgroundColor)
                                    //.background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                                    .foregroundColor(buttonForegroundColor)
                                    }
                                .listRowBackground(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                                }
//                                .navigationBarTitle("")
//                                .navigationBarBackButtonHidden(true)
//                                //.navigationBarHidden(true)
                            }
                            .searchable(text: $searchText)
                        
                            //Text("Searches are limited to a max of 50 results to prevent lag.")
                        }
                
//                    searchResults -> [String] {
            //}
                    
//                    .background(Color.green)
    //                .background(UIColor(red: 110, green: 179, blue: 118, alpha: 1))
                    
                //}
                } else {
                    VStack {
                        HStack {
                        Button("⌂") {
                            goHome()
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                        //.foregroundColor(.brown)
                        Button("Other Courses") {
                            selectedCountry = previousCountry
                                
                            }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                        //.foregroundColor(.brown)
                        }
                    let searchResults:[String] = getSearchResults(searchText: searchText, currentCountry: selectedCountry)
                        
                    NavigationView {
                        List {
                            ForEach(searchResults.prefix(50), id: \.self) { name in
    //                            NavigationLink(destination: Text(name)) {
    //                                Text(name)
    //
                                Button(name) {
                                    currentCourse = name.components(separatedBy: " - ")[0]
                                    currentCourseId = name.components(separatedBy: " - ")[1]
                                    currentView = "Course"
                                    //add check here so it also checks
                                    //if course is a User course in database before caching!!!!
                                    print(("SC Check:", selectedCountry))

                                        holesCoords = getHolesDatabase(id: currentCourseId)
                                        courseLandmarks = getLandmarksDatabase(id: currentCourseId)
                                        numHoles = holesCoords.count
                                    
                                    //Add a Sem thing here to make it wait
                                    //until the course had been cached before
                                    //continuing!
                                    print(name)
                                }
                                .listRowBackground(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                                .foregroundColor(buttonForegroundColor)
                                }
                            }
                        }
                        .searchable(text: $searchText)
                        //.navigationTitle("Courses")
                        
                        //Text("Searches are limited to a max of 50 results to prevent lag.")
                    }
                    
            }
            } else if(currentView == "selectCountry") {
                VStack {
                    
                    let searchResults:[String] = getCountrySearchResults(searchText: searchText)
                    
                    Button("⌂") {
                        goHome()
                    }
                    .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                    .foregroundColor(buttonForegroundColor)
                    
                    
                    NavigationView {
                        List {
                            ForEach(searchResults, id: \.self) { name in
    //                            NavigationLink(destination: Text(name)) {
    //                                Text(name)
    //
                                Button(name) {
                                    selectedCountry = name
                                    searchlist = []
                                    searchText = ""
                                    currentView = "Search"
                                }
                                .listRowBackground(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                                .foregroundColor(buttonForegroundColor)
                                }
                            }
                        }
//                        .searchable(text: $searchText)
                }

                
                
                
                
            } else if (currentView == "Add") {
                if (addCourseStage == "BData") {
                    VStack {
                        Button("⌂") {
                            goHome()
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                        
                        TextField("Enter course name", text: $cCourseName)
                        
                        HStack {
                            Button("-") {
                                if (cCourseNumHoles > 1) {
                                    cCourseNumHoles -= 1
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                            
                            Text("Hls: \(cCourseNumHoles)")
                            
                            Button("+") {
                                if (cCourseNumHoles < maxHoles) {
                                    cCourseNumHoles += 1
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                        }

                        Button("Done") {
                            //Make this show what the problem is later on
                            cCourseName = cCourseName.replacingOccurrences(of: "|", with: "").replacingOccurrences(of: "*", with: "")
                            if (cCourseName.count <= maxCourseNameChars) {
                            addCourseStage = "Holes"
                                for _ in 1...cCourseNumHoles {
                                cCourseHoles.append(["Not Set", ""])
                            }
                            }
                            
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                    }
                } else if (addCourseStage == "Holes") {
                    VStack {
                        HStack {
                            Button("⌂") {
                                goHome()
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                        }
//                            Button("Done") {
//                                for holes in cCourseHoles {
//                                    if holes[1] == "" {
//                                        return
//                                    }
//                                }
//                                addCourseStage = "Landmarks"
//                            }
//                        }

                        HStack {
                            Button("-") {
                                if (cCourseEditingHole > 1) {
                                    cCourseEditingHole -= 1
                                }
                                cCourseEditingHoleLat = cCourseHoles[cCourseEditingHole-1][0]
                                cCourseEditingHoleLon = cCourseHoles[cCourseEditingHole-1][1]
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                            
                            Text("Hole: \(cCourseEditingHole)")
                            
                            Button("+") {
                                if (cCourseEditingHole + 1 > cCourseNumHoles) {
                                for holes in cCourseHoles {
                                    if holes[1] == "" {
                                        return
                                    }
                                }
                                addCourseStage = "Landmarks"
                                print("********")
                                print(cCourseLandmarks[cCourseEditingLandmarkForHole][cCourseEditingHoleLandmark])
                                return
                                }
                                
                                if ((cCourseEditingHole + 1) <= cCourseNumHoles) {
                                    cCourseEditingHole += 1
                                }
                                cCourseEditingHoleLat = cCourseHoles[cCourseEditingHole-1][0]
                                cCourseEditingHoleLon = cCourseHoles[cCourseEditingHole-1][1]
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                        }
                        
                        Button("Set Hole Location") {
                            print(cCourseHoles[cCourseEditingHole-1][0])
                            cCourseHoles[cCourseEditingHole-1] = ["\(String(describing: (locationManager?.location?.coordinate.latitude)!))", "\(String(describing: (locationManager?.location?.coordinate.longitude)!))"]
                            cCourseEditingHoleLat = cCourseHoles[cCourseEditingHole-1][0]
                            cCourseEditingHoleLon = cCourseHoles[cCourseEditingHole-1][1]
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                        
                        HStack {
                            Text("Set: \(String(cCourseEditingHoleLon != ""))")
//                            Text(cCourseEditingHoleLat)
//                            Text(cCourseEditingHoleLon)
                        }
                        //Layout Planning
                        //   + Button -
                        //Input Field (Lat)
                        //Input Field (Lon)
                    }
                } else if (addCourseStage == "Landmarks") {
                    VStack {
                        //TODO: CHECK BELOW THIS IS VERY IMPORTANT
                        //Add verification to make sure all landmarks
                        //are filled out before going to next hole
                        //when going to next hole also cull
                        //any empty landmarks!!!!!!!!!!

                        HStack {
                            Button("-") {
                                if (cCourseEditingLandmarkForHole > 0) {
                                    cCourseEditingLandmarkForHole -= 1
                                    cCourseEditingHoleLandmark = 0
                                }
//                                cCourseEditingHoleLat = cCourseHoles[cCourseEditingHole-1][0]
//                                cCourseEditingHoleLon = cCourseHoles[cCourseEditingHole-1][1]
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                            
                            Text("Hole: \(cCourseEditingLandmarkForHole+1)")
                            
                            Button("+") {
                                //this code is problem
                                //it was removing the whole array from thingy
                                //and thus messing up everything!
                                //cuz on 2nd hole it would tyr to access array[1]
                                //but it wouldn't exist since there would only be 1 element in array
                                //now.
//                                for holes in cCourseLandmarks {
//                                    for landmarks in holes {
//                                        if landmarks[0] == "" && landmarks[1] == "" {
//                                            cCourseLandmarks.remove(at: cCourseLandmarks[cCourseLandmarks.firstIndex(of: holes)!].firstIndex(of: ["", "", ""])!)
//                                        }
//                                }
//                            }
                                //SOLUTION FOR FINISHING LANDMARKS IS BELOW:
                                //make it so that for first landmark
                                //it oonly checks if one is set and not the other
                                //cuz there may not be any landmarks for that hole!!!
                                //maybe add a delete button so user can remove landmarks
                                //and a button that makes that hole have no landmarks!!!!!
                                
                                //if (cCourseLandmarks[0][])
                                
                                
                                //check for bugs here later
                                for holes in cCourseLandmarks {
                                    for landmarks in holes/*[1...]*/ {
                                        if (landmarks[0] == "" && landmarks[1] != "") || (landmarks[1] == "" && landmarks[0] != "") {
                                            return
                                        }
                                    }
                                }
                                    
                                if (cCourseEditingLandmarkForHole+1 >= cCourseNumHoles) {
                                    addCourseStage = "Confirm"
                                    return
                                }
                                
                            
                                if ((cCourseEditingLandmarkForHole + 1) <= cCourseNumHoles) {
                                    cCourseEditingLandmarkForHole += 1
                                    cCourseEditingHoleLandmark = 0
                                    print("&&")
                                    print(cCourseLandmarks.count);
                                    print(cCourseEditingLandmarkForHole);
                                    if (cCourseLandmarks.count < cCourseEditingLandmarkForHole+2) {
                                        print("appending");
                                        cCourseLandmarks.append([["", "", ""]]);
                                        print(cCourseLandmarks)
                                    }
                                }
                                print(cCourseLandmarks);
                                print(cCourseEditingLandmarkForHole);
                                print(cCourseEditingHoleLandmark);
//                                cCourseEditingHoleLat = cCourseHoles[cCourseEditingHole-1][0]
//                                cCourseEditingHoleLon = cCourseHoles[cCourseEditingHole-1][1]
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                            
                        }
                        HStack {
                            Button("-") {
                                if (cCourseEditingHoleLandmark > 0) {
                                    cCourseEditingHoleLandmark -= 1
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                            
                            Text("Landmark: \(String(cCourseEditingHoleLandmark+1))")
                            
                            Button("+") {
                                
                                if ((cCourseEditingHoleLandmark + 1) <= cCourseLandmarks[cCourseEditingLandmarkForHole].count && cCourseLandmarks[cCourseEditingLandmarkForHole][cCourseEditingHoleLandmark][0] != "" && cCourseLandmarks[cCourseEditingLandmarkForHole][cCourseEditingHoleLandmark][1] != "") {
                                    print("Appending Landmark Placeholder")
                                    cCourseLandmarks[cCourseEditingLandmarkForHole].append(["", "", ""])
                                    print(cCourseLandmarks)
                                    cCourseEditingHoleLandmark += 1
                                }
                            
                        }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                        }
                        
                        HStack {
                            TextField("Name", text:( $cCourseLandmarks[cCourseEditingLandmarkForHole][cCourseEditingHoleLandmark][0]))
                            
                            Button ("Location") {
                                cCourseLandmarks[cCourseEditingLandmarkForHole][cCourseEditingHoleLandmark][1] = String(describing: (locationManager?.location?.coordinate.latitude)!)
                                cCourseLandmarks[cCourseEditingLandmarkForHole][cCourseEditingHoleLandmark][2] = String(describing: (locationManager?.location?.coordinate.longitude)!)
                                print(cCourseLandmarks[cCourseEditingLandmarkForHole][cCourseEditingHoleLandmark][1])
                                print(cCourseLandmarks[cCourseEditingLandmarkForHole][cCourseEditingHoleLandmark][2])
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
//                            Text("Set: \(String((cCourseLandmarks[cCourseEditingLandmarkForHole][cCourseEditingHoleLandmark][1]) != ""))")
                        }
                    }
                    
                } else if (addCourseStage == "Confirm") {
                    VStack {
                        Text("Are you sure you want to submit \(cCourseName)?")
                        HStack {
                            Button("Yes") {
                                //Put code to upload course to database
                                //and filter here!
                                let courseJSON = convertCourseDataToJSON(landmarks: cCourseLandmarks, holes: cCourseHoles, numHoles: cCourseNumHoles)
                                
                                var cacheCourseHoleCoords:Array<Array<String>> = []
                                
                                for i in cCourseHoles {
                                    cacheCourseHoleCoords.append(contentsOf: [[i[0], i[1]]])
                                }
                                print(cacheCourseHoleCoords)
                                
                                cacheUserCourse(coursename: cCourseName, /*country: currentCountry,*/ holesCoords: cacheCourseHoleCoords, courseLandmarks: cCourseLandmarks)
                                //HAVE IT JUST STORE CLIENTSIDE IN THE SQL DATABASE
                                //THEN WORK ON MAKING THE UI BETTER AND MORE
                                //INTUITIVE!!! FOR WORKING ON IT SKETCH UP STUFF
                                //IN PAINT OR SOMETHING INTO A PLAN BOARD OR SOMETHING
                                //THEN EMAIL IT TO ERIC FOR HIS OPINION
                                //AFTER THAT REFACTOR EVERYTHINGGGGGG!!!!!!!
                                
                                
                                
                                
                                
                                
                                //You're gonna have to do some server-side stuff here
                                //like calculating the courseid and stuff
                                //Oh and make sure to get the country grabby stuff
                                //working!!!!
                                //and MAYBE the city and state stuff but idk
                                let courseListJSON = """
{"coursename" : "\(cCourseName)" , "city" : "Tafuna" , "state" : "--" , "country" : "American Samoa" , "courseid" : "312132" }
"""
                                //code to upload to database goes here
                                goHome()
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                            
                            Button("No") {
                                goHome()
                            }
                            .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                            .foregroundColor(buttonForegroundColor)
                        }
                    }
                }

            } else if (currentView == "Settings") {
                VStack {
                    HStack {
                        Text("Settings")
                        Button("⌂") {
                            goHome()
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                    }
                    Divider()
                    Button("Redownload Courses") {
                        downloadData()
                    }
                    .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                    .foregroundColor(buttonForegroundColor)
                }
                
            } else if (currentView == "Course") {
                VStack {
                    HStack {
                        Button("⌂") {
                            goHome()
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                        
                        Button("L's") {
                            if (courseLandmarks.count > 0 && courseLandmarks.count >= currentHole && courseLandmarks[currentHole - 1].count > 0) {
                                currentView = "Landmark"
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                    }
                    
                    GeometryReader { geometry in
                        ScrollView(.horizontal) {
                            Text(currentCourse)
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)

               }
           }
                    HStack {
                        Button("-") {
                            if (currentHole > 1) {
                                currentHole -= 1
                            }
                            print(locationManager?.location?.coordinate.latitude as Any)
                            
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                        
                        GeometryReader { geometry in
                            ScrollView(.horizontal) {
                                Text("\(currentHole)")
                        .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)

                   }
               }
                        Button("+") {
                            if ((currentHole + 1) <= numHoles) {
                                currentHole += 1
                            }
                            print(locationManager?.location?.coordinate.latitude as Any)
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                    }
                    Spacer()
                    HStack {
                            Text("\(Int(round(CLLocation(latitude: locationU.latitude ?? defaultDegree, longitude: locationU.longitude ?? defaultDegree).distance(from: CLLocation(latitude: Double(holesCoords[currentHole - 1][0])!, longitude: Double(holesCoords[currentHole - 1][1])!)))))m")
                                .font(Font.custom("7SEGMENTALDIGITALDISPLAY", size: 28))
                                .scaledToFit()
                            //.foregroundColor(.green)
                            //                            .font(Font.custom("Arial", size: 36))
                            //                            .foregroundColor(Color(#colorLiteral(red: 0.292, green: 0.081, blue: 0.6, alpha: 255)))
                            
                                .foregroundColor(.green).saturation(0.5)
                                .shadow(color: .green, radius: 12)
                                .shadow(color: .green, radius: 12)
                                .shadow(color: .green, radius: 12)
                    }
                    //Later on change distance to this to make it nice big and fancy
                    //Text("\(0)").font(.system(size: 50, weight: .heavy))

                //Text("Hole: \(currentHole)")
                }
            } else if (currentView == "Landmark") {
                VStack {
                    HStack {
                        Button("⌂") {
                            goHome()
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                        Button("H's") {
                            currentView = "Course"
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                    }
                    
                    GeometryReader { geometry in
                        ScrollView(.horizontal) {
                            Text("\(courseLandmarks[currentHole-1][currentLandmark][0])")
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                    .foregroundColor(buttonForegroundColor)

               }
           }
                    HStack {
                        Button("-") {
                            if (currentLandmark > 0) {
                                currentLandmark -= 1
                            }
                            print(courseLandmarks)
                            print("@@@@@")
                            print(currentHole)
                            print(currentLandmark)
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                        
                        
                        GeometryReader { geometry in
                            ScrollView(.horizontal) {
                                Text("\(String(currentLandmark+1))")
                        .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)
                        .foregroundColor(buttonForegroundColor)

                   }
               }
                        
                    
//                        Button("Name") {
//                            showingAlert = true
//                        }
//                        .alert("\(courseLandmarks[currentHole-1][currentLandmark][0]): \(String(currentLandmark+1))", isPresented: $showingAlert) {
//                            Button("OK", role: .cancel) { }
//                        }
                        
                        
                        Button("+") {
                            if ((currentLandmark + 2) <= courseLandmarks[currentHole - 1].count) {
                                currentLandmark += 1
                            }
                            print(courseLandmarks[currentHole-1])
                        }
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                        .foregroundColor(buttonForegroundColor)
                    }
                    Spacer()
                    HStack {
                        //Finish this part in the morning
                        //
                        //  ||  ||  ||  ||  ||  ||
                        //  ||  ||  ||  ||  ||  ||
                        //  \/  \/  \/  \/  \/  \/
                        
                        //Add check above to make sure that a landmark exists before
                        //switching to landmark view
                        Text("\(Int(round(CLLocation(latitude: locationU.latitude ?? defaultDegree, longitude: locationU.longitude ?? defaultDegree).distance(from: CLLocation(latitude: Double(courseLandmarks[currentHole - 1][currentLandmark][1])!, longitude: Double(courseLandmarks[currentHole - 1][currentLandmark][2])!)))))m")
                            .font(Font.custom("7SEGMENTALDIGITALDISPLAY", size: 28))
                            .scaledToFit()
                        
                            .foregroundColor(buttonForegroundColor).saturation(0.5)
                            .shadow(color: .green, radius: 12)
                            .shadow(color: .green, radius: 12)
                            .shadow(color: .green, radius: 12)

                    }
                    //Later on change distance to this to make it nice big and fancy
                    //Text("\(0)").font(.system(size: 20, weight: .heavy))
                }
                .background(backgroundColor)
            } else {
                Button("⌂") {
                    goHome()
                }
                .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(buttonBackgroundColor))
                .foregroundColor(buttonForegroundColor)
                Text("Error")
                    .foregroundColor(buttonForegroundColor)
            }
    }
        
}
//}

//struct CourseView: View {
//    var courseName: String
//
//    var course: some View {
//
//    }
//}

//struct MenuView: View {
//    var body: some View {
//        VStack {
//            Text("Golf Finder")
//                .padding()
//            Divider()
//            Button(action: {
//                //currentView = "Search"
//            }) {
//                Text("Search Courses")
//            }
//            .background(Color.purple)
//
//            Spacer()
//
//            Button(action: {
//                //currentView = "Add"
//            }) {
//                Text("Add Course")
//            }
//            .background(Color.purple)
//
//            Spacer()
//        }
//        .background(Color.green)
//    }
//}
//
//struct SearchView: View {
//    @State private var searchText = ""
//    var body: some View {
//        NavigationView {
//            Text("Searching for \(searchText)")
//                .searchable(text: $searchText)
//                .navigationTitle("Searchable Example")
//        }
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(locationU: locationU)
    }
}
