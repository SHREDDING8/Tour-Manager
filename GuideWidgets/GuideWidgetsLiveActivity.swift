//
//  GuideWidgetsLiveActivity.swift
//  GuideWidgets
//
//  Created by SHREDDING on 16.12.2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GuideWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GuideWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GuideWidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension GuideWidgetsAttributes {
    fileprivate static var preview: GuideWidgetsAttributes {
        GuideWidgetsAttributes(name: "World")
    }
}

extension GuideWidgetsAttributes.ContentState {
    fileprivate static var smiley: GuideWidgetsAttributes.ContentState {
        GuideWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GuideWidgetsAttributes.ContentState {
         GuideWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GuideWidgetsAttributes.preview) {
   GuideWidgetsLiveActivity()
} contentStates: {
    GuideWidgetsAttributes.ContentState.smiley
    GuideWidgetsAttributes.ContentState.starEyes
}
