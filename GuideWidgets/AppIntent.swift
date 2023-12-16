//
//  AppIntent.swift
//  Guide Widgets
//
//  Created by SHREDDING on 16.12.2023.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Tour manager"
    static var description = IntentDescription("Показывает все экскурсии на сегодня")
    
    @Parameter(title: "Администатор", default: false)
    var isAdmin: Bool
}
