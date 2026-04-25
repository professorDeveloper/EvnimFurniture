import Flutter
import UIKit
import WebKit
import QuickLook

public class GlbToUsdzConverter: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.evim/ar", binaryMessenger: registrar.messenger())
        let instance = GlbToUsdzConverter()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "openAR",
              let args = call.arguments as? [String: Any],
              let glbUrl = args["glbUrl"] as? String,
              let title = args["title"] as? String else {
            result(FlutterMethodNotImplemented)
            return
        }
        let locale = args["locale"] as? String ?? "en"
        DispatchQueue.main.async {
            self.convertAndOpenAR(glbUrl: glbUrl, title: title, locale: locale, result: result)
        }
    }

    private func convertAndOpenAR(glbUrl: String, title: String, locale: String, result: @escaping FlutterResult) {
        guard let topVC = Self.topViewController() else {
            result(FlutterError(code: "NO_VC", message: nil, details: nil))
            return
        }

        let loadingVC = LoadingViewController(title: title, locale: locale)
        loadingVC.modalPresentationStyle = .fullScreen
        topVC.present(loadingVC, animated: true) {
            loadingVC.startConversion(glbUrl: glbUrl) { usdzURL in
                if let usdzURL = usdzURL {
                    let qlVC = QLPreviewController()
                    let ds = UsdzDataSource(url: usdzURL, title: title)
                    qlVC.dataSource = ds
                    objc_setAssociatedObject(qlVC, "ds", ds, .OBJC_ASSOCIATION_RETAIN)
                    loadingVC.present(qlVC, animated: true)
                } else {
                    loadingVC.showError()
                }
            }
        }
        result(nil)
    }

    private static func topViewController() -> UIViewController? {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }),
              let root = window.rootViewController else { return nil }
        return top(from: root)
    }

    private static func top(from vc: UIViewController) -> UIViewController {
        if let p = vc.presentedViewController { return top(from: p) }
        if let n = vc as? UINavigationController, let t = n.topViewController { return top(from: t) }
        if let t = vc as? UITabBarController, let s = t.selectedViewController { return top(from: s) }
        return vc
    }
}

// MARK: - Loading screen with conversion
class LoadingViewController: UIViewController, WKScriptMessageHandler {
    private let titleText: String
    private let locale: String
    private var webView: WKWebView!
    private var statusLabel: UILabel!
    private var completion: ((URL?) -> Void)?

    private var l10n: [String: String] {
        switch locale {
        case "uz": return [
            "preparing": "AR tayyorlanmoqda...",
            "loading": "3D model yuklanmoqda...",
            "converting": "USDZ ga aylantirilmoqda...",
            "opening": "AR ochilmoqda...",
            "error": "Yuklab bo'lmadi",
        ]
        case "ru": return [
            "preparing": "Подготовка AR...",
            "loading": "Загрузка 3D модели...",
            "converting": "Конвертация в USDZ...",
            "opening": "Открытие AR...",
            "error": "Не удалось загрузить",
        ]
        default: return [
            "preparing": "Preparing AR...",
            "loading": "Loading 3D model...",
            "converting": "Converting to USDZ...",
            "opening": "Opening AR...",
            "error": "Failed to load",
        ]
        }
    }

    init(title: String, locale: String) {
        self.titleText = title
        self.locale = locale
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupHiddenWebView()
    }

    private func setupUI() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)

        statusLabel = UILabel()
        statusLabel.text = l10n["preparing"]
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        let closeBtn = UIButton(type: .system)
        closeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn.tintColor = .label
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeBtn)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            statusLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            closeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeBtn.widthAnchor.constraint(equalToConstant: 32),
            closeBtn.heightAnchor.constraint(equalToConstant: 32),
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func setupHiddenWebView() {
        let config = WKWebViewConfiguration()
        let proxy = WeakScriptHandler(delegate: self)
        config.userContentController.add(proxy, name: "converter")
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), configuration: config)
        webView.isHidden = true
        view.addSubview(webView)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView?.configuration.userContentController.removeAllScriptMessageHandlers()
    }

    func startConversion(glbUrl: String, completion: @escaping (URL?) -> Void) {
        self.completion = completion
        let html = Self.conversionHTML(glbUrl: glbUrl, l10n: l10n)
        webView.loadHTMLString(html, baseURL: URL(string: "https://cdn.azamov.me"))
    }

    func showError() {
        statusLabel.text = l10n["error"]
    }

    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let type = body["type"] as? String else { return }

        DispatchQueue.main.async { [weak self] in
            switch type {
            case "status":
                self?.statusLabel.text = body["msg"] as? String
            case "usdz":
                guard let b64 = body["data"] as? String,
                      let data = Data(base64Encoded: b64) else {
                    self?.completion?(nil)
                    return
                }
                let tmp = FileManager.default.temporaryDirectory
                    .appendingPathComponent("ar_furniture.usdz")
                try? data.write(to: tmp)
                self?.completion?(tmp)
            case "error":
                print("Conversion error: \(body["msg"] ?? "")")
                self?.completion?(nil)
            default: break
            }
        }
    }

    private static func conversionHTML(glbUrl: String, l10n: [String: String]) -> String {
        let loading = l10n["loading"] ?? "Loading..."
        let converting = l10n["converting"] ?? "Converting..."
        let opening = l10n["opening"] ?? "Opening..."
        return """
        <!DOCTYPE html><html><head>
        <script type="importmap">
        {"imports":{
          "three":"https://cdn.jsdelivr.net/npm/three@0.162.0/build/three.module.js",
          "three/addons/":"https://cdn.jsdelivr.net/npm/three@0.162.0/examples/jsm/"
        }}
        </script>
        </head><body>
        <script type="module">
        import * as THREE from 'three';
        import {GLTFLoader} from 'three/addons/loaders/GLTFLoader.js';
        import {USDZExporter} from 'three/addons/exporters/USDZExporter.js';

        const post = (type, data) => window.webkit.messageHandlers.converter.postMessage({type, ...data});

        post('status', {msg: '\(loading)'});

        const loader = new GLTFLoader();
        loader.load('\(glbUrl)',
          async (gltf) => {
            try {
              post('status', {msg: '\(converting)'});

              const scene = new THREE.Scene();
              scene.add(gltf.scene);

              const exporter = new USDZExporter();
              const arraybuffer = await exporter.parse(scene);

              post('status', {msg: '\(opening)'});

              const bytes = new Uint8Array(arraybuffer);
              let binary = '';
              for (let i = 0; i < bytes.length; i += 4096) {
                binary += String.fromCharCode(...bytes.subarray(i, Math.min(i + 4096, bytes.length)));
              }
              post('usdz', {data: btoa(binary)});
            } catch(e) {
              post('error', {msg: e.message});
            }
          },
          (p) => {
            if (p.total > 0) {
              const pct = Math.round(p.loaded / p.total * 100);
              post('status', {msg: 'Yuklanmoqda... ' + pct + '%'});
            }
          },
          (e) => post('error', {msg: e.message || 'Yuklab bolmadi'})
        );
        </script></body></html>
        """
    }
}

// MARK: - QLPreviewController data source
class UsdzDataSource: NSObject, QLPreviewControllerDataSource {
    let url: URL
    let title: String
    init(url: URL, title: String) { self.url = url; self.title = title }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let item = UsdzPreviewItem(url: url, title: title)
        return item
    }
}

class UsdzPreviewItem: NSObject, QLPreviewItem {
    let url: URL
    let titleText: String
    init(url: URL, title: String) { self.url = url; self.titleText = title }
    var previewItemURL: URL? { url }
    var previewItemTitle: String? { titleText }
}

class WeakScriptHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    init(delegate: WKScriptMessageHandler) { self.delegate = delegate }
    func userContentController(_ c: WKUserContentController, didReceive m: WKScriptMessage) {
        delegate?.userContentController(c, didReceive: m)
    }
}
