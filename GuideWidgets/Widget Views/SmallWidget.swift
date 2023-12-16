//
//  SmallWidget.swift
//  GuideWidgetsExtension
//
//  Created by SHREDDING on 16.12.2023.
//

import SwiftUI

struct SmallWidget: View {
    
    let tourDetail:WidgetTourDetail?
    
    var body: some View {
        if let tour = tourDetail{
            VStack(alignment: .leading, content: {
                Text(tour.time)
                    .fontWeight(.heavy)
                
                Text(tour.title)
                    .lineLimit(1)
                    .bold()
                    .padding([.bottom], 5)
                Text(tour.route)
                    .lineLimit(1)
                Text(tour.guides)
                    .lineLimit(1)
                Text(tour.numOfPeople)
                    .lineLimit(1)
            })
        }else{
            Text("Сегодня экскурсий нет")
                .multilineTextAlignment(.center)
        }
    }
}
