import Foundation

extension Date
{
    public static func fromString(stringValue: String) -> Date
    {
        return SQLDateFormatter.date(from: stringValue)!
    }
    public var dateToString : String
    {
        return SQLDateFormatter.string(from: self)
    }
}

let SQLDateFormatter : DateFormatter =
{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
    return formatter
}()
