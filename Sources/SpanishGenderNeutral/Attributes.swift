import Foundation

/// An attribute to specify an alternative to a string when inflecting with an unspecified grammatical gender.
@available(macOS 12, *) @available(iOS 15, *) @available(tvOS 15, *) @available(watchOS 8, *)
public enum NoGrammaticalGenderAttribute : CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
    public typealias Value = String
    public static let name = "noGrammaticalGender"
}

@available(macOS 12, *) @available(iOS 15, *) @available(tvOS 15, *) @available(watchOS 8, *)
extension AttributeScopes {
    
    /// Attributes for `SpanishGenderNeutral`.
    public struct SpanishGenderNeutralAttributes : AttributeScope {
        public let noGrammaticalGender : NoGrammaticalGenderAttribute
    }
    
    /// Attributes for `SpanishGenderNeutral`.
    public var spanishGenderNeutral: SpanishGenderNeutralAttributes.Type { SpanishGenderNeutralAttributes.self }
}
