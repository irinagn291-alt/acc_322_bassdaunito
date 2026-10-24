import SwiftUI

struct ContentView: View {
    @Environment(TableBoard.self) private var board
    @State private var showSpinner = false

    var body: some View {
        TableShell()
            .task {
                try? await Task.sleep(for: .milliseconds(150))
                if !board.isReady {
                    showSpinner = true
                }
            }
            .overlay {
                if showSpinner && !board.isReady {
                    ProgressView()
                        .controlSize(.large)
                        .tint(DesignTokens.accent)
                }
            }
    }
}

#Preview {
    ContentView()
        .environment(
            TableBoard(
                store: TableStore(
                    directory: URL(fileURLWithPath: NSTemporaryDirectory()),
                    suiteName: "preview.alidade",
                    debounce: .milliseconds(300)
                ),
                seedsOnSimulator: false
            )
        )
}
