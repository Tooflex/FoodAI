//
//  ChartItem.swift
//  FoodAI
//
//  Created by Otourou Da Costa on 24/05/2022.
//

import Foundation
import SwiftUI

struct ChartItem {
	var values: [Double]
	var names: [String]
	var formatter: (Double) -> String
	var colors: [Color] = [Color.blue, Color.green, Color.orange]
	var backgroundColor: Color = Color(red: 21 / 255, green: 24 / 255, blue: 30 / 255, opacity: 1.0)
	var labelColor: Color = Color.black
	var totalLabel: String = "Total"
	var widthFraction: CGFloat = 0.75
	var innerRadiusFraction: CGFloat = 0.60
}
