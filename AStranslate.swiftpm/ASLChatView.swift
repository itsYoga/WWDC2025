import SwiftUI
import UIKit
import AVFoundation

struct ASLChatView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        ZStack {
            CameraView() // 實時相機預覽
            
            HandSkeletonOverlayView(points: appModel.handKeypoints)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("Detected Letter: \(appModel.stablePrediction)")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                    .padding()
                
                Text("Sentence: \(appModel.sentence)")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding()
                
                Text("Translated: \(appModel.translatedSentence)")
                    .font(.title2)
                    .foregroundColor(.purple)
                    .padding()
                
                // 語言選擇器：包含英文、中文、日文、西班牙文、法文、德文
                Picker("Language", selection: $appModel.selectedLanguage) {
                    Text("English").tag("en")
                    Text("Mandarin").tag("zh")
                    Text("Japanese").tag("ja")
                    Text("Spanish").tag("es")
                    Text("French").tag("fr")
                    Text("German").tag("de")
                }
                .pickerStyle(.segmented)
                .padding()
                
                HStack {
                    Button("Translate") {
                        Task {
                            appModel.translateSentence()
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button {
                        let textToSpeak = appModel.translatedSentence.isEmpty ? appModel.sentence : appModel.translatedSentence
                        appModel.speak(textToSpeak)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                
                HStack {
                    Button("Clear Predictions") {
                        appModel.immediatePrediction = "..."
                        appModel.stablePrediction = "..."
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Clear Sentence") {
                        appModel.clearSentence()
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .task {
            await appModel.camera.startAsync()
        }
    }
}

struct ASLChatView_Previews: PreviewProvider {
    static var previews: some View {
        ASLChatView().environmentObject(AppModel.shared)
    }
}
