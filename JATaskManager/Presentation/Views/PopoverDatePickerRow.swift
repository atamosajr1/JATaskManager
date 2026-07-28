import SwiftUI

struct PopoverDatePickerRow: View {
    let label: String
    @Binding var date: Date
    @State private var isPresented = false

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Button {
                isPresented = true
            } label: {
                Text(date.formatted(date: .abbreviated, time: .omitted))
            }
            .popover(isPresented: $isPresented) {
                DatePicker(label, selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                    .frame(minWidth: 320, minHeight: 360)
                    .onChange(of: date) {
                        isPresented = false
                    }
            }
        }
    }
}
