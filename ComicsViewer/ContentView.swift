//
//  ContentView.swift
//  ComicsViewer
//
//  Created by Eric Jiang on 2025/5/17.
//

import SwiftUI

struct CachedImageView<Content: View, Placeholder: View, ErrorView: View>: View {
    let url: URL
    @Environment(DataModel.self) private var dataModel
    @State private var phase: AsyncImagePhase
    let placeholder: () -> Placeholder
    let content: (Image) -> Content
    let onError: () -> ErrorView
    
    init(url: URL,
         @ViewBuilder content: @escaping (Image) -> Content,
         @ViewBuilder placeholder: @escaping () -> Placeholder,
         @ViewBuilder onError: @escaping () -> ErrorView) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        self.onError = onError
        
        if let image = dataModel.cachedImage(for: url) {
            _phase = State(initialValue: .success(Image(uiImage: image)))
        } else {
            _phase = State(initialValue: .empty)
        }
    }
    
    var body: some View {
        Group {
            switch phase {
            case .empty:
                placeholder()
                    .task { await load() }
            case .success(let image):
                content(image)
            case .failure:
                onError()
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private func load() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                dataModel.imageCache.setObject(image, forKey: url as NSURL)
                phase = .success(Image(uiImage: image))
            } else {
                phase = .failure(NSError(domain: "ImageError", code: -1, userInfo: nil))
            }
        } catch {
            phase = .failure(error)
        }
    }
}

struct ContentView: View {
    @Environment(DataModel.self) private var dataModel
    @State private var isImporting = false
    
    var body: some View {
        NavigationStack {
            Group {
                if dataModel.comicPages.isEmpty {
                    Button("导入漫画") {
                        isImporting = true
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(dataModel.comicPages, id: \.self) { url in
                                CachedImageView(url: url) {
                                    ProgressView()
                                        .frame(height: 300)
                                } content: { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .zoomable()
                                } onError: {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .navigationTitle("漫画浏览器")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isImporting = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.image],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    dataModel.addPages(urls)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
@main
struct ComicsViewerApp: App {
    @State private var dataModel = DataModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataModel)
        }
    }
}

#Preview {
    ContentView()
        .environment(DataModel())
}
