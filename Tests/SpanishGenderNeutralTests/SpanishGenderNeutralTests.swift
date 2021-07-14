import XCTest
@testable import SpanishGenderNeutral

@available(macOS 12, *) @available(iOS 15, *) @available(tvOS 15, *) @available(watchOS 8, *)
final class SpanishGenderNeutralTests: XCTestCase {
    
    func test(_ string: String? = nil, attributedString: AttributedString? = nil, expected: String? = nil, expectedAttributedString: AttributedString? = nil, grammaticalGender: Morphology.GrammaticalGender? = nil, customPronoun: SpanishGenderNeutral.CustomPronoun? = nil) throws {
        
        var attrString = attributedString ?? AttributedString(string!)
        attrString.languageIdentifier = "es"
        
        if let grammaticalGender = grammaticalGender {
            var morphology = Morphology()
            morphology.grammaticalGender = grammaticalGender
            attrString.inflect = InflectionRule(morphology: morphology)
        }
                
        if let expected = expected {
            XCTAssertEqual(String(SpanishGenderNeutral.inflected(attrString, customPronoun: customPronoun).characters), String(AttributedString(expected).characters))
        } else if let expectedAttributedString = expectedAttributedString {
            XCTAssertEqual(SpanishGenderNeutral.inflected(attrString, customPronoun: customPronoun), expectedAttributedString)
        }
    }
    
    func testNeuterSuffix() throws {
        try test("Eres bienvenido!", expected: "Eres bienvenide!", grammaticalGender: .neuter)
        try test("Eres BIENVENIDO!", expected: "Eres BIENVENIDE!", grammaticalGender: .neuter)
    }
    
    func testElle() throws {
        try test("Él es bienvenido!", expected: "Elle es bienvenide!", grammaticalGender: .neuter)
        try test("él es bienvenido", expected: "elle es bienvenide", grammaticalGender: .neuter)
        try test("ÉL es BIENVENIDO", expected: "ELLE es BIENVENIDE", grammaticalGender: .neuter)
    }
    
    func testNotSpecified() throws {
        try test(attributedString: AttributedString(localized: "^[Bienvenido](inflect: true, inflectionAlternative: 'Te damos la bienvenida')!"), expected: "Te damos la bienvenida!", grammaticalGender: .none)
    }
    
    func testEllo() throws {
        
        let ello_o = try SpanishGenderNeutral.CustomPronoun(thirdPerson: "ello", genderedSuffix: "o")
        
        let ello_e = try SpanishGenderNeutral.CustomPronoun(thirdPerson: "ello", genderedSuffix: "e")
        
        let ello_a = try SpanishGenderNeutral.CustomPronoun(thirdPerson: "ello", genderedSuffix: "a")
        
        try test("Él es bienvenido!", expected: "Ello es bienvenido!", customPronoun: ello_o)
        try test("él es bienvenido", expected: "ello es bienvenide", customPronoun: ello_e)
        try test("ÉL es BIENVENIDO", expected: "ELLO es BIENVENIDA", customPronoun: ello_a)
    }
    
    func testUnchanged() throws {
        try test("Eres bienvenido!", expected: "Eres bienvenido!", grammaticalGender: .masculine)
        try test("Él es bienvenido!", expected: "Él es bienvenido!", grammaticalGender: .masculine)
    }
    
    func testFeminine() throws {
        try test("Eres bienvenido!", expected: "Eres bienvenida!", grammaticalGender: .feminine)
        try test("Él es bienvenido!", expected: "Ella es bienvenida!", grammaticalGender: .feminine)
    }
    
    func testChiques() throws {
        try test("Hola chicos!", expected: "Hola chiques!", grammaticalGender: .neuter)
    }
    
    func testWithAttributes() throws {
        
        var morphology = Morphology()
        morphology.grammaticalGender = .neuter
        
        var input = AttributedString(localized: "**Él** es **bienvenido**!")
        input.languageIdentifier = "es"
        input.inflect = InflectionRule(morphology: morphology)
        
        var expected = AttributedString(localized: "**Elle** es **bienvenide**!")
        expected.languageIdentifier = "es"
        expected.morphology = .none
        
        input = SpanishGenderNeutral.inflected(input)
        input.morphology = .none
        
        XCTAssertEqual(input, expected)
    }
}
