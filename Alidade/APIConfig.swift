import Alamofire

enum APIConfig {
    private static let host = "https://api.alidade-table.pro"
    private static let path = "/api/v1/users/register"

    static func apply() {
        AppConfiguration.configure(host: host, path: path)
    }
}
