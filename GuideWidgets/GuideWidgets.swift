//
//  GuideWidgets.swift
//  GuideWidgets
//
//  Created by SHREDDING on 16.12.2023.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    
    let fetchingData = FetchingData()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            tourDetails: fetchingData.placeholderData()
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        if context.isPreview{
            SimpleEntry(
                date: Date(),
                configuration: ConfigurationAppIntent(),
                tourDetails: fetchingData.placeholderData()
            )
        }else{
            DispatchQueue.main.sync {
                do {
                    return SimpleEntry(
                        date: Date(),
                        configuration: ConfigurationAppIntent(),
                        tourDetails: try fetchingData.fetchData(conf:configuration, date: Date.now)
                    )
                }catch{
                    return SimpleEntry(
                        date: Date(),
                        configuration: ConfigurationAppIntent(),
                        tourDetails: [],
                        erorAdmin: true
                    )
                }
                
            }
        }
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for minuteMultiplier in 0 ..< 6 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteMultiplier * 30, to: currentDate)!
            
            DispatchQueue.main.sync {
                let entry:SimpleEntry = {
                    do {
                        return SimpleEntry(
                            date: Date(),
                            configuration: ConfigurationAppIntent(),
                            tourDetails: try fetchingData.fetchData(conf:configuration, date: entryDate)
                        )
                    }catch{
                        return SimpleEntry(
                            date: Date(),
                            configuration: ConfigurationAppIntent(),
                            tourDetails: [],
                            erorAdmin: true
                        )
                    }
                }()
                entries.append(entry)
            }
            
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    
    let tourDetails:[WidgetTourDetail]
    
    var erorAdmin:Bool = false
}

struct GuideWidgetsEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.erorAdmin{
            Text("Вы не администатор")
        }else{
            switch family{
            case .systemMedium:
                MediumWidget(
                    tourDetail: entry.tourDetails.first
                )
            case .systemLarge:
                LargeWidget(tourDetail: entry.tourDetails)
            case .systemSmall:
                SmallWidget(tourDetail: entry.tourDetails.first)
                
            default:
                Text("")
            }
        }
        
    }
}

struct GuideWidgets: Widget {
    let kind: String = "GuideWidgets"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            GuideWidgetsEntryView(entry: entry)
                .containerBackground(Color("WidgetBackground"), for: .widget)
        }
        .supportedFamilies([.systemLarge, .systemMedium, .systemSmall])
    }
}



#Preview(as: .systemSmall) {
    GuideWidgets()
} timeline: {
    SimpleEntry(
        date: Date(),
        configuration: ConfigurationAppIntent(),
        tourDetails: [
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
                numOfPeople: "10"
            ),
            WidgetTourDetail(
                id: "TestId",
                title: "Экскурсия 3",
                route: "Маршрут 3",
                time: Date.now.formatted(date: .omitted, time: .shortened),
                guides: "Экскурсовод 1",
                numOfPeople: "10"
            )
            
        ]
    )
    
    SimpleEntry(
        date: Date(),
        configuration: ConfigurationAppIntent(),
        tourDetails: []
    )
}
