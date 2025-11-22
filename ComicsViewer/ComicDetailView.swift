import SwiftUI
import UIKit

struct ComicDetailView: View {
    @Bindable var comic: ComicProject
    @State private var isEditing = false
    @State private var tempTitle: String
    @State private var showSettings = false
    
    init(comic: ComicProject) {
        self.comic = comic
        self.tempTitle = comic.title
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(comic.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 350)
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(isEditing ? "" : comic.title)
        .toolbar {
            // 设置按钮
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                        .font(.title2)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    // 完成编辑按钮
                    Button("完成") {
                        comic.title = tempTitle
                        isEditing = false
                    }
                } else {
                    // 进入编辑按钮
                    Button("编辑") {
                        tempTitle = comic.title
                        isEditing = true
                    }
                }
            }
        }
        .overlay {
            if isEditing {
                // 编辑输入框覆盖层
                VStack {
                    TextField("输入漫画名称", text: $tempTitle)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.9))
                .cornerRadius(12)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}