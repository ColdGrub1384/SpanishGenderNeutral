import Foundation

@available(macOS 12, *) @available(iOS 15, *) @available(tvOS 15, *) @available(watchOS 8, *)
func replace(masculine: String, feminine: String, customPronoun: SpanishGenderNeutral.CustomPronoun) -> String {
    
    let a = masculine
    let b = feminine
    
    var words = [String]()

    for word in a.words.enumerated() {
        let otherWord = b.words[word.offset]
        if word.element != otherWord {
            if word.element == "él" && otherWord == "ella" {
                
                words.append(customPronoun.thirdPerson)
            
            } else if word.element == "ÉL" && otherWord == "ELLA" {
                
                words.append(customPronoun.thirdPerson.uppercased())
                
            } else if word.element == "Él" && otherWord == "Ella" {
                
                words.append(customPronoun.thirdPerson.prefix(1).capitalized + customPronoun.thirdPerson.dropFirst())
                
            } else if word.element.count == otherWord.count {
                var characters = [Character]()
                for character in word.element.enumerated() {
                    let otherCharacter = otherWord[String.Index(utf16Offset: character.offset, in: otherWord)]
                    
                    if character.element.lowercased() == "o" && otherCharacter.lowercased() == "a" {
                        
                        if customPronoun.needsQU {
                            
                            if characters.last == "c" {
                                characters.removeLast()
                                characters.append("q")
                                characters.append("u")
                            } else if characters.last == "C" {
                                characters.removeLast()
                                characters.append("Q")
                                characters.append("U")
                            }
                        }
                        
                        if character.element == "o" && otherCharacter == "a" {
                            
                            characters.append(Character(customPronoun.genderedSuffix))
                            
                        } else if character.element == "O" && otherCharacter == "A" {
                            
                            characters.append(Character(customPronoun.genderedSuffix.uppercased()))
                            
                        }
                        
                    } else {
                        characters.append(character.element)
                    }
                }
                
                words.append(String(characters))
            }
        } else {
            words.append(word.element)
        }
    }

    return words.joined(separator: " ")
}

@available(macOS 12, *) @available(iOS 15, *) @available(tvOS 15, *) @available(watchOS 8, *)
func replace(masculine: AttributedString, feminine: AttributedString, customPronoun: SpanishGenderNeutral.CustomPronoun) -> AttributedString {
    
    var attrString = AttributedString()
    
    var feminineRuns = [AttributedString.Runs.Run]()
    for run in feminine.runs {
        feminineRuns.append(run)
    }
    
    for run in masculine.runs.enumerated() {
        let a = String(masculine[run.element.range].characters)
        let b = String(feminine[feminineRuns[run.offset].range].characters)
        
        attrString.append(AttributedString(replace(masculine: a, feminine: b, customPronoun: customPronoun), attributes: run.element.attributes))
    }
    
    return attrString
}
