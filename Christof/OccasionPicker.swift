import ChristofKit
import SwiftUI
import WidgetKit

struct OccasionPicker: View {
    @Binding var selection: OccasionSelection
    @State private var draft: OccasionSelection
    @Environment(\.dismiss) private var dismiss

    init(selection: Binding<OccasionSelection>) {
        _selection = selection
        _draft = State(initialValue: selection.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    row("자동", .automatic)
                } footer: {
                    Text("날짜에 맞는 명절이 창문에 나타납니다.")
                }
                Section {
                    ForEach(Self.occasions) { row($0.name, .manual(occasionID: $0.id)) }
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
            .navigationTitle("이벤트")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: save)
                }
            }
        }
    }

    private func row(_ title: String, _ value: OccasionSelection) -> some View {
        Button {
            draft = value
        } label: {
            HStack {
                Text(title)
                Spacer()
                if draft == value {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private func save() {
        OccasionSelectionStore().save(draft)
        WidgetCenter.shared.reloadAllTimelines()
        selection = draft
        dismiss()
    }

    static let occasions = CountryRegistry.standard.profiles.flatMap(\.occasions)

    static func title(of selection: OccasionSelection) -> String {
        switch selection {
        case .automatic: "자동"
        case .manual(let id): occasions.first { $0.id == id }?.name ?? "자동"
        }
    }
}
