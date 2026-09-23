import Foundation
import CryptoKit

enum CryptoService {
    private static let service = "com.zzoutuo.Pillownote.crypto"
    private static let account = "note-encryption-key"

    private static var key: SymmetricKey {
        if let data = KeychainHelper.read(service: service, account: account) {
            return SymmetricKey(data: data)
        }
        let key = SymmetricKey(size: .bits256)
        let data = key.withUnsafeBytes { Data($0) }
        KeychainHelper.save(data, service: service, account: account)
        return key
    }

    static func encrypt(_ text: String) -> Data? {
        guard let data = text.data(using: .utf8) else { return nil }
        let sealed = try? AES.GCM.seal(data, using: key)
        return sealed?.combined
    }

    static func decrypt(_ combined: Data) -> String? {
        guard let box = try? AES.GCM.SealedBox(combined: combined),
              let data = try? AES.GCM.open(box, using: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
