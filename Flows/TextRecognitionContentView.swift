//
//  TextRecognitionContentView.swift
//  PDFScanner
//
//  Created by Apps4World on 10/3/21.
//

import SwiftUI

/// Shows recognized string from image
struct TextRecognitionContentView: View {
    
    @EnvironmentObject var manager: TaptokDataManager
    @Environment(\.presentationMode) var presentation
    @State private var didCopyText: Bool = false
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack(spacing: 15) {
                /// Header view
                HeaderTitleView
                
                /// Recognized string
                ScrollView(.vertical, showsIndicators: false, content: {
                    Text(manager.textRecognitionString)
                        .padding([.leading, .trailing])
                        .font(.system(size: 20))
                })
                
                /// Copy text
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    UIPasteboard.general.string = manager.textRecognitionString
                    didCopyText = true
                }, label: {
                    ZStack {
                        Color.accentColor.cornerRadius(40)
                        Text("Copy Text").bold().font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }).frame(height: 60).padding().disabled(didCopyText)
            }
        }
    }
    
    /// Header title view
    private var HeaderTitleView: some View {
        HStack {
            Text("Image to Text").bold().font(.largeTitle)
            Spacer()
            Button {
                UIImpactFeedbackGenerator().impactOccurred()
                presentation.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 25, weight: .bold))
            }
        }
        .padding(.top).padding([.leading, .trailing])
        .foregroundColor(Color("ExtraDarkGrayColor"))
    }
}

// MARK: - Preview UI
struct TextRecognitionContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = TaptokDataManager()
        manager.textRecognitionString = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
        return TextRecognitionContentView().environmentObject(manager)
    }
}
