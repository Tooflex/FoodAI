//
//  PieChartView.swift
//
//
//  Created by Nazar Ilamanov on 4/23/21.
//

import SwiftUI

@available(OSX 10.15, *)
public struct PieChartView: View {

	@State private var animationValue: CGFloat = 1

	@State public var pieChartData: [PieChartData] = []
	@State public var formatter: (Double) -> String

	public var colors: [Color]
	public var backgroundColor: Color
	public var labelColor: Color
	public var totalLabel: String

	private var values: [Double] = []
	private var names: [String] = []

	public var widthFraction: CGFloat
	public var innerRadiusFraction: CGFloat

	@State private var activeIndex: Int = -1
	@State private var contentSize: CGSize = .zero

	var slices: [PieSliceData] {
		let values = pieChartData.map { item in
			item.value
		}
		let sum = values.reduce(0, +)

		var endDeg: Double = 0
		var tempSlices: [PieSliceData] = []

		for (counter, value) in values.enumerated() {
			let degrees: Double = value * 360 / sum
			tempSlices.append(PieSliceData(
				startAngle: Angle(degrees: endDeg),
				endAngle: Angle(degrees: endDeg + degrees),
				text: String(format: "%.0f%%", value * 100 / sum),
				color: self.colors[counter]))
			endDeg += degrees
		}
		return tempSlices
	}

	public init(
		pieChartData: [PieChartData],
		formatter: @escaping (Double) -> String,
		colors: [Color] = [Color.blue, Color.green, Color.orange],
		backgroundColor: Color = .clear,
		labelColor: Color = Color.black,
		totalLabel: String = "Total",
		widthFraction: CGFloat = 0.75,
		innerRadiusFraction: CGFloat = 0.60) {

		self.pieChartData = pieChartData
		self.formatter = formatter

		self.values = pieChartData.map { item in
				item.value
		}
		self.names = pieChartData.map { item in
				item.name
		}

		self.colors = colors
		self.backgroundColor = backgroundColor
		self.labelColor = labelColor
		self.totalLabel = totalLabel
		self.widthFraction = widthFraction
		self.innerRadiusFraction = innerRadiusFraction
	}

	public var body: some View {
		GeometryReader { geometry in
			VStack {
				ZStack {
					ForEach(0..<values.count, id: \.self) { value in
						PieSlice(pieSliceData: self.slices[value])
							.scaleEffect(self.activeIndex == value ? 1.03 : 1)
							.animation(Animation.spring(), value: animationValue)
					}
					.frame(width: widthFraction * geometry.size.width, height: widthFraction * geometry.size.width)
					.gesture(
						DragGesture(minimumDistance: 0)
							.onChanged { value in
								let radius = 0.5 * widthFraction * geometry.size.width
								let diff = CGPoint(x: value.location.x - radius, y: radius - value.location.y)
								let dist = pow(pow(diff.x, 2.0) + pow(diff.y, 2.0), 0.5)
								if dist > radius || dist < radius * innerRadiusFraction {
									self.activeIndex = -1
									return
								}
								var radians = Double(atan2(diff.x, diff.y))

								if radians < 0 {
									radians = 2 * Double.pi + radians
								}

								for (counter, slice) in slices.enumerated() where radians < slice.endAngle.radians {
										self.activeIndex = counter
										break
								}
							}
							.onEnded { _ in
								self.activeIndex = -1
							}
					)
					Circle()
						.fill(self.backgroundColor)
						.frame(
							width: widthFraction * geometry.size.width * innerRadiusFraction,
							height: widthFraction * geometry.size.width * innerRadiusFraction)

					if self.pieChartData.count != 0 {
						VStack {
							Text(self.activeIndex == -1 ? totalLabel : names[self.activeIndex])
								.font(.title)
								.foregroundColor(Color.gray)
							Text(self.formatter(self.activeIndex == -1 ? values.reduce(0, +) : values[self.activeIndex]))
								.font(.title)
						}
					}
				}
				PieChartRows(
					colors: self.colors,
					names: self.names,
					values: self.values.map { self.formatter($0) },
					percents: self.values.map { String(format: "%.0f%%", $0 * 100 / self.values.reduce(0, +)) })
					.padding(.top, 20)

			}
			.background(
				GeometryReader { geo -> Color in
					DispatchQueue.main.async {
						contentSize = geo.size
					}
					return self.backgroundColor
				}
			)
			.foregroundColor(self.labelColor)

		}.frame(height: contentSize.height)
	}
}

@available(OSX 10.15, *)
struct PieChartRows: View {
	var colors: [Color]
	var names: [String]
	var values: [String]
	var percents: [String]

	var body: some View {
		VStack {
			ForEach(0..<self.values.count, id: \.self) { value in
				HStack {
					RoundedRectangle(cornerRadius: 5.0)
						.fill(self.colors[value])
						.frame(width: 20, height: 20)

					HStack {
						Text(self.names[value])
						Text("(\(self.percents[value]))")
							.foregroundColor(Color.gray)
					}
					Spacer()
					Text(self.values[value])
				}
			}
		}
	}
}

@available(OSX 10.15, *)
public struct PieChartData {
	var value: Double
	var name: String
}

@available(OSX 10.15.0, *)
struct PieChartView_Previews: PreviewProvider {
	static var previews: some View {

		let pieData1 = PieChartData(value: 1300, name: "Rent")
		let pieData2 = PieChartData(value: 500, name: "Transport")
		let pieData3 = PieChartData(value: 300, name: "Education")

		var pieChartData: [PieChartData] = []
		pieChartData.append(pieData1)
		pieChartData.append(pieData2)
		pieChartData.append(pieData3)

		return PieChartView(
			pieChartData: pieChartData,
			formatter: {value in String(format: "$%.2f", value)})
	}
}
