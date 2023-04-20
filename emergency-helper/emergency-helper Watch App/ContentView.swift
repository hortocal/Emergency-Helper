//
//  ContentView.swift
//  emergency-helper Watch App
//
//  Created by Calob Horton on 4/10/23.
//

import SwiftUI
import MapKit
import CoreLocation
import Contacts

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: BookView()) {
                    FirstAidCellView()
                }
                NavigationLink(destination: EmergencyContactsView()) {
                    EmergencyContactsCellView()
                }
                NavigationLink(destination: NearestHospitalView()) {
                    NearestHospitalCellView()
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

struct BookView: View {
    var body: some View {
        List {
            NavigationLink(destination: CutsView()) {
                CutsCellView()
            }
            NavigationLink(destination: PoisoningView()) {
                PoisoningCellView()
            }
            NavigationLink(destination: BrokenBonesView()) {
                BrokenBonesCellView()
            }
        }
    }
}

struct EmergencyContactsView: View {
    
    // thank you https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getContacts() -> [CNContact]{
        let contacts = CNContactStore()
        var allContacts: [CNContact] = []
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as! [any CNKeyDescriptor]
        do {
            try allContacts = contacts.unifiedContacts(matching: NSPredicate(value: true), keysToFetch: keysToFetch)
        } catch {
            print("error")
        }
        return allContacts
    }
    
    var allContacts : [CNContact] {
        return getContacts()
    }
    
    @State var showsAlert = false
    @State var saveContactLabel:String = ""
    @State var saveContactToWrite:String = ""
    
    var path : URL {
        if !FileManager.default.fileExists(atPath: getDocumentsDirectory().appendingPathComponent("contacts.txt").absoluteString) {
            do {
                try "empty".write(to: getDocumentsDirectory().appendingPathComponent("contacts.txt"), atomically: true, encoding: .utf8)
            } catch {
                print(error.localizedDescription)
            }
        }
        return getDocumentsDirectory().appendingPathComponent("contacts.txt")
    }
    
    var savedContacts : [String] {
        var array : [String] = []
        do {
            try array = String(contentsOf: path).components(separatedBy: .newlines)
            print("the array \(array)")
            if array.count == 1 && array[0] == "empty" {
                array = []
            }
        } catch {
            print(error.localizedDescription)
        }
        return array
    }
    
    var body: some View {
        List {
            Section("Saved Contacts") {
                ForEach(savedContacts.indices, id: \.self) {
                    Text(savedContacts[$0])
                }
            }
            Section("Other Contacts") {
                ForEach(allContacts.indices, id: \.self) {
                    let int = $0
                    Text("\(allContacts[$0].givenName) \(allContacts[$0].familyName)").onTapGesture {
                        self.showsAlert = true
                        self.saveContactLabel = "\(allContacts[int].givenName) \(allContacts[int].familyName)"
                        self.saveContactToWrite = "\(allContacts[int].givenName) \(allContacts[int].familyName) \(allContacts[int].phoneNumbers[0].value.stringValue)\n"
                        print(saveContactToWrite)
                    }
                }
            }
        }.alert("Add \(saveContactLabel) to Saved Contacts?", isPresented: $showsAlert) {
            //TODO: actually add these to a SavedContacts file
            Button("OK", role: .cancel) {
                do {
                    try saveContactToWrite.write(to: path, atomically: true, encoding: .utf8)
                    try print(String(contentsOf: path))
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct NearestHospitalView: View {
    // originates to GVSU's Allendale Campus
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.96467, longitude: -85.88889), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow))
            .frame(width: 400, height: 300)
    }
}

struct FirstAidCellView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Image(systemName: "text.book.closed").resizable().aspectRatio(contentMode: .fit).foregroundColor(.red)
                Spacer()
                Text("Open First Aid Booklet")
                Spacer()
                Image(systemName: "arrow.right")
            }
        }
    }
}

struct EmergencyContactsCellView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Image(systemName: "person.crop.circle.badge.exclamationmark").resizable().aspectRatio(contentMode: .fit).foregroundColor(.red)
                Spacer()
                Text("Emergency Contacts")
                Spacer()
                Image(systemName: "arrow.right")
            }
        }
    }
}

struct NearestHospitalCellView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Image(systemName: "building.2").resizable().aspectRatio(contentMode: .fit).foregroundColor(.red)
                Spacer()
                Text("Find Hospital")
                Spacer()
                Image(systemName: "arrow.right")
            }
        }
    }
}

struct CutsCellView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Image(systemName: "scissors").resizable().aspectRatio(contentMode: .fit).foregroundColor(.red)
                Spacer()
                Text("Got a cut?")
            }
        }
    }
}

struct CutsView: View {
    var body: some View {
            TabView {
                Text("Step 1: Wash your hands.").fontWeight(Font.Weight.bold)
                Text("Step 2: Stop the bleeding.").fontWeight(Font.Weight.bold)
                Text("Step 3: Clean the cut/scrape.").fontWeight(Font.Weight.bold)
                Text("Step 4: Put antibiotic cream or petroleum jelly on (if available).").fontWeight(Font.Weight.bold)
                Text("Step 5: Cover the cut/scrape with something clean, if necessary.").fontWeight(Font.Weight.bold)
                Text("Step 6: If covered, change the covering daily.").fontWeight(Font.Weight.bold)
                Text("Step 7: If the cut seems infected, seek medical attention as soon as possible.").fontWeight(Font.Weight.bold)
                // https://www.mayoclinic.org/first-aid/first-aid-cuts/basics/art-20056711
                Text("All information found from the Mayo Clinic. Thank you!")
            }
            .tabViewStyle(PageTabViewStyle())
        }
}

struct PoisoningCellView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: "exclamationmark.triangle").resizable().aspectRatio(contentMode: .fit).foregroundColor(.red)
                Spacer()
                Text("Eat something bad?")
            }
        }
    }
}

struct PoisoningView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("You must contact emergency services.").fontWeight(Font.Weight.bold)
            Text("In a production app, this text would be labelled 911 with the ability to call for help.")
        }
    }
}

struct BrokenBonesCellView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: "figure.arms.open").resizable().aspectRatio(contentMode: .fit).foregroundColor(.red)
                Spacer()
                Text("Break a bone?")
            }
        }
    }
}

struct BrokenBonesView: View {
    var body: some View {
        VStack(alignment: .center) {
            TabView {
                Text("Step 1: Keep the bone from moving. Use sticks or many bandages to restrict movement.").fontWeight(Font.Weight.bold)
                Text("Step 2: IF NEEDED: put the appendage back into its anatomically correct position.").fontWeight(Font.Weight.bold)
                // https://www.outdoorsgeek.com/suffering-a-fracture-in-the-outdoors/
                Text("This information was provided by Outdoor Geek. Thank you!")
            }.tabViewStyle(PageTabViewStyle())
        }
    }
}

struct MapView: View {
    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))), interactionModes: [])
            .frame(width: 400, height: 300)
    }
}
