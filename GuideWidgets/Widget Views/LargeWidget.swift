//
//  LargeWidget.swift
//  GuideWidgetsExtension
//
//  Created by SHREDDING on 16.12.2023.
//

import SwiftUI

struct LargeWidget: View {
    
    let tourDetail:[WidgetTourDetail]
    
    var body: some View {
        if tourDetail.count != 0{
            VStack{
                ForEach(0..<3){ tourIndex in
                    if tourIndex < tourDetail.count{
                        HStack{
                            Text(tourDetail[tourIndex].time)
                                .padding(30)
                                .background(.fill, in: .circle)
                            
                            VStack(alignment: .leading, content: {
                                Text(tourDetail[tourIndex].title)
                                    .lineLimit(1)
                                    .bold()
                                    .padding([.bottom], 5)
                                Text(tourDetail[tourIndex].route)
                                    .lineLimit(1)
                                Text(tourDetail[tourIndex].guides)
                                    .lineLimit(1)
                                Text(tourDetail[tourIndex].numOfPeople)
                                    .lineLimit(1)
                            })
                            
                            Spacer()
                        }
                    }
                    if tourIndex < tourDetail.count - 1{
                        Divider()
                    }
                    
                }
            }
            Spacer()
        }else{
            Text("Сегодня экскурсий нет")
                .multilineTextAlignment(.center)
        }
        
    }
}
