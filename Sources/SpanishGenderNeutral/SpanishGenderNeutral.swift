import Foundation

/// `SpanishGenderNeutral` implements Spanish neo pronouns and gendered suffixes for the new `AttributedString` API.
@available(macOS 12, *) @available(iOS 15, *) @available(tvOS 15, *) @available(watchOS 8, *)
public struct SpanishGenderNeutral {
    
    /// This type is composed of a third person pronoun and the suffix to use in gendered words.
    ///
    /// For example, the pronoun "elle" would be: `CustomPronoun(thirdPerson: "elle", genderedSuffix: "e")`.
    public struct CustomPronoun {
        
        /// An error during the initialization of a `CustomPronoun`.
        enum Error: Swift.Error {
            
            /// The suffix is not pronounceable.
            case notPronounceable
        }
        
        /// The third person pronoun.
        public var thirdPerson: String
        
        /// The suffix for gendered words.
        public var genderedSuffix: String
        
        var needsQU: Bool {
            return genderedSuffix == "e"  || genderedSuffix == "i"
        }
        
        /// Initializes a `CustomPronoun` instance.
        ///
        /// - Parameters:
        ///     - thirdPerson: A third person pronoun.
        ///     - genderedSuffix: The letter to use as a suffix in gendered word.
        ///
        /// `genderedSuffix` must be a vowell if not, `Error.notPronounceable`will be thrown as this could cause some accessibility issues.
        public init(thirdPerson: String, genderedSuffix: Character) throws {
            self.thirdPerson = thirdPerson.lowercased()
            self.genderedSuffix = String(genderedSuffix).lowercased()
            
            switch genderedSuffix {
            case "a", "e", "i", "o", "u":
                break
            default:
                throw Error.notPronounceable
            }
        }
    }
    
    /// Applies automatic grammar agreement to an attributed string in Spanish for gendered words. If the string or the app is not in Spanish, or if the `Morphology` associated with the given attributed string doesn't have a neuter grammatical gender and no custom pronoun is passed, the default `Foundation` inflection behavior will be used.
    ///
    /// You need to set `attributedString.inflect` to an `InflectionRule` with a morphology that has a grammatical gender specified or to pass a `CustomPronoun` to this function.
    ///
    /// - Parameters:
    ///     - attributedString: An attributed string containing gendered words.
    ///     - customPronoun: A custom pronoun to use. The default value is [ elle - e ] for a neuter grammatical gender. However, you can set this parameter to apply the custom pronoun regardless of the morphology's grammatical gender.
    public static func inflected(_ attributedString: AttributedString, customPronoun: CustomPronoun? = nil) -> AttributedString {
        
        guard Locale.preferredLanguages.first == "es" || Locale.preferredLanguages.first?.hasPrefix("es-") == true || attributedString.languageIdentifier == "es" else { // Spanish only
            var attr = attributedString
            if attr.languageIdentifier == ".lproj" {
                attr.languageIdentifier = Locale.preferredLanguages.first
            }
            return attr.inflected()
        }
        
        var morphology: Morphology?
        
        switch attributedString.inflect {
        case .explicit(let _morphology):
            morphology = _morphology
        default:
            break
        }
        
        guard morphology?.grammaticalGender == .neuter || customPronoun != nil  else { // Default Apple implementation for anything else
            
            var attr = attributedString
            
            if attr.languageIdentifier == ".lproj" {
                attr.languageIdentifier = Locale.preferredLanguages.first
            }
            
            if morphology?.grammaticalGender == .none {
                
                var newAttr = AttributedString()
                for run in attr.runs {
                    if let alternative = run.spanishGenderNeutral.noGrammaticalGender, var attr = try? AttributedString(markdown: alternative, including: \.spanishGenderNeutral) {
                        attr.setAttributes(run.attributes)
                        newAttr.append(attr)
                    } else {
                        newAttr.append(attr[run.range])
                    }
                }
                
                attr = newAttr
            }
            
            return attr.inflected()
        }
        
        var masculine = attributedString
        var masculineMorphology = morphology ?? Morphology()
        masculineMorphology.grammaticalGender = .masculine
        masculine.morphology = masculineMorphology
        masculine.inflect = InflectionRule(morphology: masculineMorphology)
        
        if masculine.languageIdentifier == ".lproj" {
            masculine.languageIdentifier = Locale.preferredLanguages.first
        }
        
        masculine = masculine.inflected()
        
        var feminine = attributedString
        var feminineMorphology = morphology ?? Morphology()
        feminineMorphology.grammaticalGender = .feminine
        feminine.morphology = feminineMorphology
        feminine.inflect = InflectionRule(morphology: feminineMorphology)
        
        if feminine.languageIdentifier == ".lproj" {
            feminine.languageIdentifier = Locale.preferredLanguages.first
        }
        
        feminine = feminine.inflected()
        
        let result = replace(masculine: masculine, feminine: feminine, customPronoun: customPronoun ?? (try! CustomPronoun(thirdPerson: "elle", genderedSuffix: "e")))
        
        return result
    }
    
    private init() {}
}
