//
//  URLImageView.swift
//  WidgetExtension
//
//  Created by Pawel Wiszenko on 15.10.2020.
//  Copyright © 2020 Pawel Wiszenko. All rights reserved.
//

import SwiftUI

struct URLImageView: View {
    let data: Data

    var body: some View {
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "photo")
        }
    }
}



struct URLImageViewLarge: View {
    let data: Data

    var body: some View {
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .clipShape(Circle())
                .shadow(radius: 10)
                .frame(width: 150.0, height: 150.0)
        } else {
            Image(systemName: "photo")
        }
    }
}


struct URLImageViewLook: View {
    let data: Data
    var body: some View {
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "photo")
        }
    }
}

struct URLImageViewInline: View {
    let data: Data
    var body: some View {
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 50.0, height: 50.0)
        } else {
            Image(systemName: "photo")
        }
    }
}
