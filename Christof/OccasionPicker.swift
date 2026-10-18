import ChristofKit
import SwiftUI

struct OccasionPicker: View {
    @Binding var selection: OccasionSelection
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Picker("이벤트", selection: $selection) {
                    Section {
                        Text("자동").tag(OccasionSelection.automatic)
                    } footer: {
                        Text("날짜에 맞는 명절이 창문에 나타납니다.")
                    }
                    Section {
                        ForEach(Self.occasions) { Text($0.name).tag(OccasionSelection.manual(occasionID: $0.id)) }
                    } header: {
                        Text("수동")
                    } footer: {
                        Text("고른 명절을 날짜와 상관없이 보여줍니다. 일출·일몰·보름달은 계속 자동입니다.")
                        #if os(macOS)
                        // macOS 는 개발 팀 서명 없이 App Group 을 쓸 수 없어 위젯과 설정을 공유하지 못한다.
                        Text("macOS 위젯에는 아직 반영되지 않습니다. 이 미리보기에만 적용됩니다.")
                        #endif
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            .navigationTitle("이벤트")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { dismiss() }
                }
            }
        }
    }

    static let occasions = CountryRegistry.standard.profiles.flatMap(\.occasions)

    static func title(of selection: OccasionSelection) -> String {
        switch selection {
        case .automatic: "자동"
        case .manual(let id): occasions.first { $0.id == id }?.name ?? "자동"
        }
    }
}
