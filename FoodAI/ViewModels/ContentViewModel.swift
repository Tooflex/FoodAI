//
//  CustomCameraView.swift
//  FoodAI
//
//  Created by Otourou Da Costa on 23/05/2022.
//

import CoreImage
import CoreML
import Combine
import SwiftUI

class ContentViewModel: ObservableObject {
	@Environment(\.managedObjectContext) private var viewContext

	@Published var error: Error?
	@Published var frame: CGImage?
	@Published var predictionResultString = ""

	var publisher: AnyPublisher<Void, Never>! = nil

	private let context = CIContext()

	private let cameraManager = CameraManager.shared
	private let frameManager = FrameManager.shared

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
		animation: .default)
	private var items: FetchedResults<Item>

	init() {
		setupSubscriptions()
	}

	func setupSubscriptions() {
		// swiftlint:disable:next array_init
		cameraManager.$error
			.receive(on: RunLoop.main)
			.map { $0 }
			.assign(to: &$error)

		frameManager.$current
			.receive(on: RunLoop.main)
			.compactMap { [weak self] buffer in
				guard let image = CGImage.create(from: buffer) else {
					return nil
				}

				let ciImage = CIImage(cgImage: image)

				return self?.context.createCGImage(ciImage, from: ciImage.extent)
			}
			.assign(to: &$frame)

		publisher = Timer.publish(every: 0.5, on: RunLoop.main, in: .common).autoconnect().map {_ in
			if let frame = self.frame {
				self.findFood(capturedImage: frame)
			}
		}.eraseToAnyPublisher()
	}

	func findFood(capturedImage: CGImage) {

		DispatchQueue.global(qos: .default).async {
			do {
				let config = MLModelConfiguration()
				let model = try FoodClassifier(configuration: config)
				let prediction = try model.prediction(input: FoodClassifierInput(imageWith: capturedImage))
				DispatchQueue.main.async {
					self.predictionResultString = prediction.classLabel
				}
			} catch {
				print("oh oh")
			}
		}
	}

	private func addItem() {
		withAnimation {
			let newItem = Item(context: viewContext)
			newItem.timestamp = Date()

			do {
				try viewContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate.
				// You should not use this function in a shipping application, although it may be useful during development.
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}

	private func deleteItems(offsets: IndexSet) {
		withAnimation {
			offsets.map { items[$0] }.forEach(viewContext.delete)

			do {
				try viewContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to // generate a crash log and terminate.
				// You should not use this function in a shipping application, although it may be useful during development.
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}
	private let itemFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .medium
		return formatter
	}()
}
