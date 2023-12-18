//
//  MediumWidget.swift
//  GuideWidgetsExtension
//
//  Created by SHREDDING on 16.12.2023.
//

import SwiftUI

struct MediumWidget: View {
    
    let tourDetail:WidgetTourDetail?
    
    var body: some View {
        if let tour = tourDetail{
            HStack{
                Text(tour.time)
                    .padding(30)
                    .background(.fill, in: .circle)
                    
                VStack(alignment: .leading, content: {
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
                Spacer()
            }
        }else{
            Text("Сегодня экскурсий нет")
                .multilineTextAlignment(.center)
        }

    }
}
