import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingItem: Feeding?

    @State private var newPlantName: String = ""
    @State private var newProduct: String = ""
    @State private var newDose: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if store.items.isEmpty {
                    ContentUnavailableView(
                        "No entries yet",
                        systemImage: "leaf",
                        description: Text("Tap + to add your first entry.")
                    )
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                editingItem = item
                                loadEdit(item)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.plantName)
                                        .font(Theme.headlineFont)
                                        .foregroundStyle(.primary)
                                    Text(item.product + " · " + item.dose)
                                        .font(Theme.captionFont)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .accessibilityIdentifier("itemRow_\(item.id.uuidString)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Feedcycle")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAdd = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAdd) {
                addSheet
            }
            .sheet(item: $editingItem) { item in
                editSheet(for: item)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var addSheet: some View {
        NavigationStack {
            Form {
                TextField("PlantName", text: $newPlantName)
                    .accessibilityIdentifier("addPlantNameField")
                TextField("Product", text: $newProduct)
                    .accessibilityIdentifier("addProductField")
                TextField("Dose", text: $newDose)
                    .accessibilityIdentifier("addDoseField")
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("Add Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAdd = false
                    }
                    .accessibilityIdentifier("addCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = Feeding(plantName: newPlantName, product: newProduct, dose: newDose)
                        store.add(item)
                        resetNew()
                        showAdd = false
                    }
                    .accessibilityIdentifier("addSaveButton")
                    .disabled(newPlantName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func editSheet(for item: Feeding) -> some View {
        NavigationStack {
            Form {
                TextField("PlantName", text: $editPlantName)
                    .accessibilityIdentifier("editPlantNameField")
                TextField("Product", text: $editProduct)
                    .accessibilityIdentifier("editProductField")
                TextField("Dose", text: $editDose)
                    .accessibilityIdentifier("editDoseField")
                Button("Delete Entry", role: .destructive) {
                    store.delete(item)
                    editingItem = nil
                }
                .accessibilityIdentifier("editDeleteButton")
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        editingItem = nil
                    }
                    .accessibilityIdentifier("editCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = item
        updated.plantName = editPlantName
        updated.product = editProduct
        updated.dose = editDose
                        store.update(updated)
                        editingItem = nil
                    }
                    .accessibilityIdentifier("editSaveButton")
                }
            }
        }
    }

    private func resetNew() {
        newPlantName = ""
        newProduct = ""
        newDose = ""
    }

    private func loadEdit(_ item: Feeding) {
        editPlantName = item.plantName
        editProduct = item.product
        editDose = item.dose
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
