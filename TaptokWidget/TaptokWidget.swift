//
//  TaptokWidget.swift
//  TaptokWidget
//
//  Created by Mehul Nahar on 29/10/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), percent: 67)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), percent: 67)
        completion(entry)
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let nextDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        
        let hoursPassedSinceMidnight = Calendar.current.dateComponents([.hour], from: midnight, to: currentDate).hour ?? 0
        let passedFractionOfDay = hoursPassedSinceMidnight * 100 / 24
        
        let entries = [SimpleEntry(date: currentDate, percent: passedFractionOfDay)]
        let timeline = Timeline(entries: entries, policy: .after(nextDate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let percent: Int
}

struct TaptokWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    var fontStyle:Font{
        if family == .systemSmall{
            return .system(.footnote,design: .rounded)
        }else {
            return .system(.headline,design: .rounded)
        }
    }
    
    var body: some View {
        switch family {
        case .accessoryInline:
            InlineSmallView
        case .accessoryRectangular:
            LoockSmallView
        case .accessoryCircular:
            CirculeSmallView
        default:
            systemSmallView
        }
    }
    private var systemSmallView: some View {
        GeometryReader { geometry in
             ZStack {
                 if let imageURLQR, let data = try? Data(contentsOf: imageURLQR) {
                                 URLImageView(data: data)
                         .aspectRatio(contentMode: .fit)
                }
                 Image("login")
                     .resizable()
                     .clipShape(Capsule())
                     .frame(width: family != .systemSmall ? 56 : 36,
                            height: family != .systemSmall ? 56 : 36
                     )
                     .offset(
                         x: (geometry.size.width / 2) - 20,
                         y:(geometry.size.height / -2) + 20
                 )
                     .padding(.top,family != .systemSmall ? 32 :12)
                     .padding(.trailing,family != .systemSmall ? 32 :12)
                 HStack {
                     Text("Scan QR")
                         .foregroundColor(.white)
                         .font(fontStyle)
                         .fontWeight(.bold)
                         .padding(.horizontal,12)
                         .padding(.vertical,4)
                         .background(Color(red: 0, green: 0, blue: 0,opacity: 0.5)
                         ).clipShape(Capsule())
                     if family != .systemSmall{
                         Spacer()
                     }
                 }//:Hstack
                 .padding()
                 .offset( y:(geometry.size.height / 2) - 24)
             }//: Zstack
        }//:Geometry
    }
    
    private var LoockSmallView: some View {
        GeometryReader { geometry in
             ZStack {
                 HStack {
                     if let imageURLQR, let data = try? Data(contentsOf: imageURLQR) {
                         URLImageViewLook(data: data)
                             .aspectRatio(contentMode: .fit)
                    }
                     Text("Taptok").font(.system(size: 18))
                     Spacer()
                 }.foregroundColor(Color("ExtraDarkGrayColor")).padding()
                 
             }//: Zstack
        }//:Geometry
    }
    
    private var CirculeSmallView: some View {
        GeometryReader { geometry in
             ZStack {
                 if let imageURLQR, let data = try? Data(contentsOf: imageURLQR) {
                     URLImageViewLook(data: data)
                         .aspectRatio(contentMode: .fit)
                }
             }//: Zstack
        }//:Geometry
    }
    private var InlineSmallView: some View {
        HStack {
            Text("Taptok").font(.system(size: 18))
            Spacer()
        }.foregroundColor(Color("ExtraDarkGrayColor")).padding()
    }
    
    private var imageURL: URL? {
        let path = "https://i.postimg.cc/9XPF7wjh/Wegitlogo.png"
        return URL(string: path)
    }
    
    private var imageURLLock: URL? {
        let path = "https://i.postimg.cc/9XPF7wjh/Wegitlogo.png"
        return URL(string: path)
    }
    
    private var imageURLQR: URL? {
        let path = "https://i.postimg.cc/P5kRRZMj/website-QRCode-no-Frame.png"
        return URL(string: path)
    }
    


}

@main
struct TaptokWidget: Widget {
    let kind: String = "TaptokWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TaptokWidgetEntryView(entry: entry)
        }
//        .configurationDisplayName("Lock Screen Widget")
//        .description("A Widget that can be displayed on both the lock screen and the home screen.")
//        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .systemSmall,.systemLarge,.systemMedium,.systemExtraLarge])
    }
}

struct TaptokWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group{
//            TaptokWidgetEntryView(entry: SimpleEntry(date: Date(), percent: 67))
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
          //  TaptokWidgetEntryView(entry: SimpleEntry(date: Date(), percent: 67))
             //   .previewContext(WidgetPreviewContext(family: .systemMedium))
          //  TaptokWidgetEntryView(entry: SimpleEntry(date: Date(), percent: 67))
             //   .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
       
    }
}
