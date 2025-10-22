import Foundation
import PhoneNumberKit

@objcMembers
final class TrubkaContactsImpl: NSObject {
  private static let instance = TrubkaContactsImpl()

  @objc class var shared: TrubkaContactsImpl {
    return instance
  }

  private let phoneNumberKit = PhoneNumberKit()

  private override init() {
    super.init()
  }

  @objc(processWithContacts:options:)
  func process(contacts: [[String: Any]], options: [String: Any]) -> [[String: Any]] {
    let regionHint = (options["regionHint"] as? String)?.uppercased()
    let formatInternational = options["formatInternational"] as? Bool ?? false

    var deduplication = Set<String>()
    var rows: [[String: Any]] = []

    for contact in contacts {
      let firstName = (contact["firstName"] as? String) ?? ""
      let lastName = (contact["lastName"] as? String) ?? ""
      let name = (contact["name"] as? String) ?? ""
      let phones = contact["phones"] as? [Any] ?? []

      for phone in phones {
        guard let rawPhone = phone as? String else { continue }
        let normalized = normalize(rawPhone: rawPhone)
        guard !normalized.isEmpty else { continue }

        guard let parsed = parseNumber(normalized: normalized, regionHint: regionHint) else { continue }

        let e164 = phoneNumberKit.format(parsed, toType: .e164)
        guard e164.hasPrefix("+") else { continue }
        let identifier = String(e164.dropFirst())
        guard !identifier.isEmpty else { continue }
        if deduplication.contains(identifier) { continue }
        deduplication.insert(identifier)

        var row: [String: Any] = [
          "id": identifier,
          "first_name": firstName,
          "last_name": lastName,
          "name": name,
          "phone_number": identifier
        ]

        if formatInternational {
          let formatted = phoneNumberKit.format(parsed, toType: .international)
          row["phone_number_formatted"] = formatted
        } else {
          row["phone_number_formatted"] = NSNull()
        }

        rows.append(row)
      }
    }

    return rows
  }

  private func normalize(rawPhone: String) -> String {
    var digits = rawPhone.filter { $0.isNumber }

    while digits.hasPrefix("00") {
      digits.removeFirst(2)
    }

    if digits.count == 11, digits.hasPrefix("8") {
      digits.removeFirst()
      digits = "7" + digits
    }

    return digits
  }

  private func parseNumber(normalized: String, regionHint: String?) -> PhoneNumber? {
    if normalized.isEmpty {
      return nil
    }

    if let phone = try? phoneNumberKit.parse("+" + normalized, ignoreType: true) {
      return phone
    }

    if let region = regionHint, let phone = try? phoneNumberKit.parse(normalized, withRegion: region, ignoreType: true) {
      return phone
    }

    if let defaultRegion = phoneNumberKit.defaultRegionCode(), let phone = try? phoneNumberKit.parse(normalized, withRegion: defaultRegion, ignoreType: true) {
      return phone
    }

    return nil
  }
}
