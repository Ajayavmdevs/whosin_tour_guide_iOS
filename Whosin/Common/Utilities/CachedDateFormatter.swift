import UIKit

let DATEFORMATTER = CachedDateFormatter.shared

class CachedDateFormatter: NSObject {
	private let kDateFormatterCacheLimit = 15
	private var _loadedDateFormatter: NSCache<AnyObject, AnyObject>!

	// --------------------------------------
	// MARK: Singleton
	// --------------------------------------

	class var shared: CachedDateFormatter {
		struct Static {
			static let instance = CachedDateFormatter()
		}
		return Static.instance
	}

	override init() {
		super.init()
		_loadedDateFormatter = NSCache()
		_loadedDateFormatter.countLimit = kDateFormatterCacheLimit
	}

	// --------------------------------------
	// MARK: Singleton
	// --------------------------------------

	func dateFormatterWith(format: String, locale: Locale) -> DateFormatter {
		let key = String(format: "%@|%@", format, locale.identifier)
		var dateFormatter = _loadedDateFormatter.object(forKey: key as AnyObject) as? DateFormatter
		if dateFormatter == nil {
			dateFormatter = DateFormatter(withFormat: format, locale: locale.identifier)
            dateFormatter?.timeZone = TimeZone.init(secondsFromGMT: 0)
			_loadedDateFormatter.setObject(dateFormatter!, forKey: key as AnyObject)
		}
		return dateFormatter!
	}

	func dateFormatterWith(format: String, localeIdentifier: String) -> DateFormatter {
		return dateFormatterWith(format: format, locale: Locale(identifier: localeIdentifier))
	}

	func dateFormatterWith(format: String) -> DateFormatter {
		return dateFormatterWith(format: format, locale: Locale.current)
	}
}
