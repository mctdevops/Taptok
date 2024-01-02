//
//  SignuWebView.swift
//  TaptopDev
//
//  Created by Mehul Nahar on 19/07/22.
//

import SwiftUI
import WebKit

struct SignuWebView: View {
    @StateObject var model = WebViewModel(requestURL: URL(string: "\(AppConfig.DevURL)/register")!)
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
            Group {
                Spacer().frame(width: 0, height: 36.0, alignment: .topLeading)
                HStack {
                    Image("iconBack")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                        .padding(.leading, 30.0)
                    
                    Spacer()
                }
            }
        }
        WebView(webView: model.webView, viewModel: model)
    }
}

struct SignuWebView_Previews: PreviewProvider {
    static var previews: some View {
        SignuWebView()
    }
}
