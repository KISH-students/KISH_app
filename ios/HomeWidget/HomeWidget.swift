//
//  HomeWidget.swift
//  HomeWidget
//
//  Created by 유정욱 on 6/15/21.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

/*
 아직 수정하지 마세요!
 
 
 */

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let data = UserDefaults.init(suiteName:"group.com.Hancho.KISH.kish2019.HomeWidget");
        return SimpleEntry(date: Date(), content: data?.string(forKey: "lunch_content") ?? "정보 없음", configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = UserDefaults.init(suiteName:"group.com.Hancho.KISH.kish2019.HomeWidget")
        let entry = SimpleEntry(date: Date(), content: data?.string(forKey: "lunch_content") ?? "정보 없음", configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let current = Date();
        let refreshDate = Calendar.current.date(byAdding: .second, value: 20, to: current)!
        var entries: [SimpleEntry] = []
        let data = UserDefaults.init(suiteName:"group.com.Hancho.KISH.kish2019.HomeWidget")
        
        let entry = SimpleEntry(date: Date(), content: data?.string(forKey: "lunch_content") ?? "정보 없음", configuration: configuration)
        entries.append(entry)
        
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let content: String
    let configuration: ConfigurationIntent
}

struct LunchWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        let t = Date();
        VStack.init(alignment: .leading, spacing: 6, content: {
            //Text(entry.content)
            Text("급식")
                .font(.system(size: 13))
            Text("로제 스파게티\n순살 후라이드\n오이 피클\n김치\n팽이미소국\n쌀밥\n모닝빵&딸기잼" + t.description)
                .font(.system(size: 12)).fontWeight(.ultraLight).minimumScaleFactor(0.5)
            ZStack(alignment: .bottomTrailing, content: {
                Text("클릭하여 새로고침").font(.system(size: 10)).minimumScaleFactor(0.5).foregroundColor(.accentColor)
            })
        }).padding(5)
    }
}

@main
struct HomeWidget: WidgetBundle {
    var body: some Widget {
        LunchWidget()
        DinnerWidget()
    }
}

struct LunchWidget: Widget {
    let kind: String = "HomeWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            LunchWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("급식")
        .description("급식을 홈 화면에서 확인하는 쉬운 방법")
    }
}

struct DinnerWidget: Widget {
    let kind: String = "HomeWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            LunchWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("석식")
        .description("석식을 홈 화면에서 확인하는 쉬운 방법")
    }
}
/*
struct HomeWidget_Previews: PreviewProvider {
    static var previews: some View {
        HomeWidgetEntryView(entry: SimpleEntry(date: Date(), content: "참깨빵\n순 쇠고기 패티\n특별한 소스\n양상추", configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
*/
