import Foundation

public extension String {
    var hasVisibleContent: Bool {
        !trimmingInvisibles.isEmpty
    }

    var trimmingInvisibles: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var withVisibleContent: String? {
        hasVisibleContent ? self : nil
    }

    func asURL() -> URL? {
        URL(string: self)
    }

    var capitalizedSentence: String {
        let firstLetter = self.prefix(1).capitalized
        let remainingLetters = self.dropFirst().lowercased()
        return firstLetter + remainingLetters
    }

    func localized(
        bundle: Bundle = .main,
        tableName: String = "Localizable",
        arguments: CVarArg...
    ) -> String {
        let localized = NSLocalizedString(self, tableName: tableName, bundle: bundle, value: "**\(self)**", comment: "")

        return arguments.isEmpty
        ? localized
        : String(format: localized, arguments: arguments)
    }

    var mutableAttributedString: NSMutableAttributedString {
        .init(string: self)
    }

    var isValidEmail: Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
        "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}
