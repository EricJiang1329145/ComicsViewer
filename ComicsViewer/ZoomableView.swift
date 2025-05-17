import SwiftUI

struct Zoomable: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var anchor: UnitPoint = .center
    @State private var offset: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = value.magnitude
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
            )
    }
}

extension View {
    func zoomable() -> some View {
        modifier(Zoomable())
    }
}