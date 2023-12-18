//
//  FetchingData.swift
//  GuideWidgetsExtension
//
//  Created by SHREDDING on 16.12.2023.
//

import Foundation
import RealmSwift
import KeychainSwift

final class FetchingData{
    private var realm: Realm {
            let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Shredding.Tour-Manager")
            let realmURL = container?.appendingPathComponent("default.realm")
            let config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
            return try! Realm(configuration: config)
        }
    
    private let keychainService:KeychainSwift = {
        let keychain = KeychainSwift()
        keychain.accessGroup = "4FV5WJHF4V.keychain.group.Shredding.Tour-Manager"
        return keychain
    }()
        
    func fetchData(conf:ConfigurationAppIntent, date:Date) throws -> [WidgetTourDetail]{
        var res:[WidgetTourDetail] = []
        
        if conf.isAdmin{
            let userId = keychainService.get("localId") ?? ""
            let userRealm = realm.object(ofType: UserRealm.self, forPrimaryKey: userId)
            if userRealm?.accesslLevels?.canReadTourList != true{
                throw NSError(domain: "NotAdmin", code: -1, userInfo: [:])
            }
            
            let tours = self.realm.object(ofType: DatesExcursion.self, forPrimaryKey: date.birthdayToString())
            
            for tour in tours?.getTours() ?? []{

                if let result = compareTimes(time1: tour.dateAndTime.timeToString(), time2: date.timeToString()), result == .orderedDescending{
                    var guides = ""
                    if tour.guides.count > 0{
                        for guideIndex in 0..<tour.guides.count - 1{
                            guides += tour.guides[guideIndex].firstName + ", "
                        }
                        guides += tour.guides[tour.guides.count - 1].firstName
                    }
                    
                    res.append(
                        WidgetTourDetail(
                            id: tour.tourId,
                            title: tour.tourTitle,
                            route: tour.route,
                            time: tour.dateAndTime.timeToString(),
                            guides: guides,
                            numOfPeople: tour.numberOfPeople
                        )
                    )
                }
                
                if res.count == 3{
                    break
                }
            }
            
        }else{
            let tours = self.realm.object(ofType: DatesExcursionForGuide.self, forPrimaryKey: date.birthdayToString())
            
            for tour in tours?.getTours() ?? []{
                if let result = compareTimes(time1: tour.dateAndTime.timeToString(), time2: date.timeToString()), result == .orderedDescending{
                    var guides = ""
                    if tour.guides.count > 0{
                        for guideIndex in 0..<tour.guides.count - 1{
                            guides += tour.guides[guideIndex].firstName + ", "
                        }
                        guides += tour.guides[tour.guides.count - 1].firstName
                    }
                    
                    res.append(
                        WidgetTourDetail(
                            id: tour.tourId,
                            title: tour.tourTitle,
                            route: tour.route,
                            time: tour.dateAndTime.timeToString(),
                            guides: guides,
                            numOfPeople: tour.numberOfPeople
                        )
                    )
                }
                
                if res.count == 3{
                    break
                }
            }
        }
        return res
    }
    
    func placeholderData() -> [WidgetTourDetail]{
        [
            WidgetTourDetail(
                id: "TestId",
                title: "Экскурсия 1",
                route: "Маршрут",
                time: Date.now.formatted(date: .omitted, time: .shortened),
                guides: "Экскурсовод 1",
                numOfPeople: "10"
            ),
            WidgetTourDetail(
                id: "TestId",
                title: "Экскурсия 2",
                route: "Маршрут 2",
                time: Date.now.formatted(date: .omitted, time: .shortened),
                guides: "Экскурсовод 1",
                numOfPeople: "15"
            ),
            WidgetTourDetail(
                id: "TestId",
                title: "Экскурсия 3",
                route: "Маршрут 3",
                time: Date.now.formatted(date: .omitted, time: .shortened),
                guides: "Экскурсовод 1",
                numOfPeople: "30"
            ),
            
        ]
    }
    
    private func compareTimes(time1: String, time2: String) -> ComparisonResult? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        if let date1 = dateFormatter.date(from: time1), let date2 = dateFormatter.date(from: time2) {
            return date1.compare(date2)
        } else {
            // Обработка ошибок, если строки не удалось преобразовать в объекты Date
            return nil
        }
    }
    
}
