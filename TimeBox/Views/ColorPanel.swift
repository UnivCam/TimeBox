//
//  ColorPanel.swift
//  TimeBox
//
//  Created by junyng on 2023/08/20.
//

import SwiftUI

struct ColorPanel: View {
    @Binding var colors: [Color]
    @State private var selection: Color? = nil
    private var didColorSelected: ((Color) -> Void)?
    
    init(
        colors: Binding<[Color]>,
        didColorSelected: ((Color) -> Void)? = nil
    ) {
        self._colors = colors
        self.didColorSelected = didColorSelected
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .overlay(
                            Circle()
                                .strokeBorder(selection == color ? Color.secondary : Color.white, lineWidth: 3)
                        )
                        .onTapGesture {
                            self.selection = color
                            self.didColorSelected?(color)
                        }
                }
                Button {
                    colors.append(Color.random())
                } label: {
                    Circle()
                        .fill(Color.white)
                        .overlay(
                            Image(systemName: "plus")
                                .resizable()
                                .padding(8)
                        )
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .frame(height: 40)
    }
}

extension Array where Element == Color {
    static var `default` = Self([.blue, .red, .gray])
}

private extension Color {
    static func random() -> Self {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        return Color(red: red, green: green, blue: blue)
    }
}

struct ColorPanel_Previews: PreviewProvider {
    static var previews: some View {
        ColorPanel(colors: .constant(.default))
    }
}
