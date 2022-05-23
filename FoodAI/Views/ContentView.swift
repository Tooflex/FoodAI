//
//  CustomCameraView.swift
//  FoodAI
//
//  Created by Otourou Da Costa on 23/05/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {

	@StateObject private var model = ContentViewModel()

	var body: some View {

		//        NavigationView {
		//            List {
		//                ForEach(items) { item in
		//                    NavigationLink {
		//                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
		//                    } label: {
		//                        Text(item.timestamp!, formatter: itemFormatter)
		//                    }
		//                }
		//                .onDelete(perform: deleteItems)
		//            }
		//            .toolbar {
		//                ToolbarItem(placement: .navigationBarTrailing) {
		//                    EditButton()
		//                }
		//                ToolbarItem {
		//                    Button(action: addItem) {
		//                        Label("Add Item", systemImage: "plus")
		//                    }
		//                }
		//            }
		//            Text("Select an item")
		//        }

		ZStack {
			FrameView(image: model.frame)
				.edgesIgnoringSafeArea(.all)

			ErrorView(error: model.error)

			Text(model.predictionResultString)
				.onReceive(model.publisher) {
				}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
	}
}
