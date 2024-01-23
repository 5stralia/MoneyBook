//
//  ChangingGraph.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/23/24.
//

import SwiftUI

struct DateEntity: Identifiable {
    let text: String
    let value: Double?
    let color: Color

    let id = UUID()
}
struct ChangingGraph: View {
    static let itemCount = 5

    let items: [DateEntity]

    init(items: [DateEntity]) {
        if items.count > ChangingGraph.itemCount {
            MyLogger.logger.warning(
                "ChangingGraph.items는 최대 \(ChangingGraph.itemCount)개까지 설정 가능. items.count: \(items.count)"
            )
            self.items = Array(items.prefix(5))
        } else {
            self.items = items
        }
    }

    var body: some View {
        VStack {
            EqualSizeHStack {
                ForEach(self.items) { entity in
                    VStack {
                        Text(entity.text)
                            .font(.Pretendard(size: 12, weight: .semiBold))
                        Text(entity.value?.formatted() ?? "-")
                            .font(.Pretendard(size: 12, weight: .medium))
                    }
                    .foregroundStyle(entity.color)
                }
            }
            .foregroundStyle(Color.dynamicWhite.opacity(0.5))

            if self.items.contains(where: { $0.value != nil }),
                let maxValue = self.items.compactMap(\.value).max(),
                let minValue = self.items.compactMap(\.value).min()
            {
                GeometryReader { geometry in

                    let range = maxValue - minValue
                    let w = geometry.size.width / CGFloat(ChangingGraph.itemCount)

                    Path { path in
                        for (offset, entity) in items.enumerated() {
                            guard let value = entity.value else { return }

                            if minValue == maxValue {
                                let x = (CGFloat(offset) + 0.5) * w
                                let y = (geometry.size.height - 20) * 0.5

                                if offset == 2 {
                                    path.addEllipse(in: CGRect(x: x - 5, y: y - 5, width: 10, height: 10))
                                } else {
                                    path.addEllipse(in: CGRect(x: x - 3, y: y - 3, width: 6, height: 6))
                                }

                                continue
                            }

                            let x = (CGFloat(offset) + 0.5) * w
                            let y =
                                (geometry.size.height - 20)
                                * (1 - ((CGFloat(value) - CGFloat(minValue)) / CGFloat(range))) + 10

                            if offset == 2 {
                                path.addEllipse(in: CGRect(x: x - 5, y: y - 5, width: 10, height: 10))
                            } else {
                                path.addEllipse(in: CGRect(x: x - 3, y: y - 3, width: 6, height: 6))
                            }
                        }

                    }

                    Path { path in
                        for (offset, entity) in items.enumerated() {
                            guard let value = entity.value else { return }

                            if minValue == maxValue {
                                let x = (CGFloat(offset) + 0.5) * w
                                let y = (geometry.size.height - 20) * 0.5

                                if offset == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }

                                continue
                            }

                            let x = (CGFloat(offset) + 0.5) * w
                            let y =
                                (geometry.size.height - 20)
                                * (1 - ((CGFloat(value) - CGFloat(minValue)) / CGFloat(range))) + 10

                            if offset == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [1.5]))
                }
                .foregroundStyle(Color.dynamicWhite)
            } else {
                Spacer()
            }
        }
    }
}

#Preview {
    Group {
        ChangingGraph(items: [
            .init(text: "2012.11", value: 5, color: Color.white.opacity(0.5)),
            .init(text: "2012.12", value: 2, color: Color.white.opacity(0.5)),
            .init(text: "2013.01", value: 3, color: .white),
            .init(text: "2013.02", value: 9, color: Color.white.opacity(0.5)),
            .init(text: "2013.03", value: 2, color: Color.white.opacity(0.5)),
        ])
        .padding([.top, .bottom], 20)
        .frame(height: 160)
        .background(Color(red: 244 / 255, green: 169 / 255, blue: 72 / 255))

        ChangingGraph(items: [
            DateEntity(text: "2012.11", value: 5, color: Color.white.opacity(0.5)),
            DateEntity(text: "2012.12", value: 2, color: Color.white.opacity(0.5)),
            DateEntity(text: "2013.01", value: 3, color: .white),
            DateEntity(text: "2013.02", value: nil, color: Color.white.opacity(0.5)),
            DateEntity(text: "2013.03", value: nil, color: Color.white.opacity(0.5)),
        ])
        .padding([.top, .bottom], 20)
        .frame(height: 160)
        .background(Color(red: 244 / 255, green: 169 / 255, blue: 72 / 255))
    }
}
