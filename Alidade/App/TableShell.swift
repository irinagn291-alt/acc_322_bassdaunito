import SwiftUI
import UIKit

/// RootFace waits for the chart, then reads the launch key once onboarding is done.
struct RootFace: View {
    var board: TableBoard

    @State private var sheet: TableSheet?

    var body: some View {
        Group {
            if !board.isReady {
                MapScreen(sheet: $sheet, placeholder: true)
                    .redacted(reason: .placeholder)
                    .allowsHitTesting(false)
            } else if !board.archive.onboardingComplete {
                OnboardingView()
            } else if let sheet {
                cover(sheet)
                    .environment(\.coverDismiss, { self.sheet = nil })
            } else {
                MapScreen(sheet: $sheet, placeholder: false)
            }
        }
        .environment(board)
        .preferredColorScheme(.dark)
        .tint(DesignTokens.accent)
        .onAppear(perform: applyLaunch)
        .onChange(of: board.isReady) { _, _ in
            applyLaunch()
        }
        .onChange(of: board.archive.onboardingComplete) { _, _ in
            applyLaunch()
        }
        .onChange(of: sheet) { _, new in
            if new == nil {
                board.clearLaunchKey()
            }
        }
    }

    @ViewBuilder
    private func cover(_ item: TableSheet) -> some View {
        switch item {
        case .session:
            SessionLogScreen()
        case .pace:
            StatsScreen()
        case .shelf:
            CatalogueScreen()
        case .expedition:
            ExpeditionScreen()
        case .settings:
            SettingsScreen()
        }
    }

    private func applyLaunch() {
        guard board.isReady, board.archive.onboardingComplete else { return }
        board.consumeLaunchScreenIfNeeded()
        guard sheet == nil, let next = TableSheet.resolve(board.launchKey) else { return }
        sheet = next
    }
}

/// TableShellController is the UIKit shell. Its window scene hosts one UIHostingController.
final class TableShellController: UIViewController {
    private let host: UIHostingController<RootFace>

    init(board: TableBoard) {
        host = UIHostingController(rootView: RootFace(board: board))
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        // The shell is created from the SwiftUI scene. A coder path is a programmer error.
        fatalError("TableShellController does not decode from a coder.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        host.didMove(toParent: self)
        view.backgroundColor = UIColor(DesignTokens.bg)
        host.view.backgroundColor = UIColor(DesignTokens.bg)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let scene = view.window?.windowScene else { return }
        for window in scene.windows {
            window.backgroundColor = UIColor(DesignTokens.bg)
        }
    }
}

/// TableShell bridges the SwiftUI scene into the UIKit host.
struct TableShell: UIViewControllerRepresentable {
    @Environment(TableBoard.self) private var board

    func makeUIViewController(context: Context) -> TableShellController {
        TableShellController(board: board)
    }

    func updateUIViewController(_ uiViewController: TableShellController, context: Context) {}
}
