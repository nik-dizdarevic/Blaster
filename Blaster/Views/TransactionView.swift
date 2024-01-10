//
//  TransactionView.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI
import CoreData

struct TransactionView: View {
    
    @ObservedObject var coin: Coin
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var context
    
    @AppStorage("currency") var currency: Currency = .usd
    
    @State private var transaction: MyTransaction
    @State private var invalid = false
    
    init(coin: Coin) {
        self.coin = coin
        let transaction = MyTransaction(coinPrice: coin.currentPrice, quantity: 1, date: Date(), type: .buy, notes: "")
        _transaction = State(initialValue: transaction)
    }
        
    var body: some View {
        NavigationStack {
            Form {
                Picker("Transaction", selection: $transaction.type) {
                    Text("Buy").tag(TransactionType.buy)
                    Text("Sell").tag(TransactionType.sell)
                }
                .pickerStyle(.segmented)
                .listRowInsets(.init())
                .listRowBackground(Color(.systemGray6))
                priceSection
                quantitySection
                if transaction.type == .buy {
                    totalSpentSection
                } else {
                    totalReceivedSection
                }
                dateTimeSection
                notesSection
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if textFieldsInvalid() {
                            invalid = true
                        } else {
                            Transaction.create(from: transaction, for: coin, in: context)
                            try? context.save()
                            dismiss()
                        }
                    }
                    .alert("Cannot Create Transaction", isPresented: $invalid) {
                        
                    } message: {
                        Text("Values should not be negative.")
                    }
                }
            }
        }
    }
    
    var currencyFormat: Decimal.FormatStyle.Currency {
        .currency(code: currency.rawValue).precision(.fractionLength(0...8))
    }
    
    var priceSection: some View {
        Section {
            TextField("Price", value: $transaction.coinPrice, format: currencyFormat)
        } header: {
            Text("Price Per Coin")
        }
    }
    
    var quantitySection: some View {
        Section {
            TextField("Quantity", value: $transaction.quantity, format: .number.precision(.fractionLength(0...8)))
        } header: {
            Text("Quantity")
        }
    }
    
    var totalSpentSection: some View {
        Section {
            TextField("", value: $transaction.total, format: currencyFormat)
                .disabled(true)
                .foregroundColor(.gray)
        } header: {
            Text("Total Spent")
        }
    }
    
    var totalReceivedSection: some View {
        Section {
            TextField("", value: $transaction.total, format: currencyFormat)
                .disabled(true)
                .foregroundColor(.gray)
        } header: {
            Text("Total Received")
        }
    }
    
    var dateTimeSection: some View {
        Section {
            DatePicker(selection: $transaction.date, displayedComponents: [.date]) {
                Label {
                    Text("Date")
                } icon: {
                    FormIcon(image: "calendar", color: .red)
                }
            }
            DatePicker(selection: $transaction.date, displayedComponents: [.hourAndMinute]) {
                Label {
                    Text("Time")
                } icon: {
                    FormIcon(image: "clock.fill", color: .blue)
                }
            }
        } header: {
            Text("Date and Time")
        }
    }
    
    @State private var notes = false
    
    var notesSection: some View {
        Section {
            Toggle("Add notes", isOn: $notes.animation())
            if notes {
                TextField("Enter notes here", text: $transaction.notes, axis: .vertical)
                    .lineLimit(7, reservesSpace: true)
            }
        } header: {
            Text("Notes")
        }
    }
    
    private func textFieldsInvalid() -> Bool {
        transaction.coinPrice < 0 || transaction.quantity < 0
    }
    
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView(coin: Coin())
    }
}
