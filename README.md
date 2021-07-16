# SpanishGenderNeutral

A Swift library that improves the neuter grammatical gender and supports neo pronouns in Spanish automatic grammar agreement.

WWDC21 introduced exciting new localization features. One of them is automatic grammar agreement, that can change the grammatical gender of words to match the user's term of address in Spanish.

For examples the Notes app has a welcome screen that says: 'Bienvenido' if the term of address of the user is masculine, 'Bienvenida' if it's feminine and 'Te damos la bienvenida' if it's neuter or not specified.

However I think that there's a difference between neuter (which is an actual (neo?)grammatical gender) and not specified.

This library provides a better implementation of automatic grammar agreement for neuter in Spanish. It works by default with the pronoun "elle", unlike the default "ello" used by Apple which less people use, and the gendered suffix "e", which Apple doesn't support.

See [What's new in Foundation](https://developer.apple.com/wwdc21/10109) from WWDC21 for more information about automatic grammar agreement.

## Foundation default behavior

```swift

import Foundation

var attributedString = AttributedString(localized: "Él es bienvenido!")
var morphology = Morphology()
morphology.grammaticalGender = .neuter
attributedString.inflect = InflectionRule(morphology: morphology)

attributedString.inflected() // == "Ello es bienvenido!"
```

It uses "ello" as a neuter pronoun and doesn't change "bienvenido" which is masculine.

```swift

import Foundation

var attributedString = AttributedString(localized: "^[Bienvenido](inflect: true, inflectionAlternative: 'Te damos la bienvenida')!")
var morphology = Morphology()

morphology.grammaticalGender = .neuter
attributedString.inflect = InflectionRule(morphology: morphology)

attributedString.inflected() // == "Te damos la bienvenida!"

morphology.grammaticalGender = .none
attributedString.inflect = InflectionRule(morphology: morphology)

attributedString.inflected() // == "Te damos la bienvenida!"
```

Here, the inflection alternative is used for both neuter grammatical gender and for a not specified grammatical gender.

## SpanishGenderNeutral behavior

```swift

import Foundation
import SpanishGenderNeutral

var attributedString = AttributedString(localized: "Él es bienvenido!")
var morphology = Morphology()
morphology.grammaticalGender = .neuter
attributedString.inflect = InflectionRule(morphology: morphology)

SpanishGenderNeutral.inflected(attributedString) // == "Elle es bienvenide!"
```

It uses "elle" as a neuter pronoun and changes "bienvenido" to "bienvenide".

```swift

import Foundation

var attributedString = AttributedString(localized: "^[Bienvenido](noGrammaticalGender: 'Te damos la bienvenida')!", including: \.spanishGenderNeutral)
var morphology = Morphology()

morphology.grammaticalGender = .neuter
attributedString.inflect = InflectionRule(morphology: morphology)

SpanishGenderNeutral.inflected(attributedString) // == "Bienvenide!"

morphology.grammaticalGender = .none
attributedString.inflect = InflectionRule(morphology: morphology)

SpanishGenderNeutral.inflected(attributedString) // == "Te damos la bienvenida!"
```

Here, the inflection alternative is only used when a grammatical gender is not specified. When neuter is specified, it automatically converts "Bienvenido" to "Bienvenide".

## Neo pronouns

Pronouns are not the only gendered thing in Spanish, adjectives and other words also are. So this library also supports custom suffixes and neo pronouns.

```swift

import Foundation
import SpanishGenderNeutral

let attributedString = AttributedString(localized: "Él es bienvenido!")
let customPronoun = try? SpanishGenderNeutral.CustomPronoun(thirdPerson: "ello", genderedSuffix: "a")

SpanishGenderNeutral.inflected(attributedString, customPronoun: customPronoun) // == "Ello es bienvenida!"
```

## C, G

This library converts the letter 'c' into 'qu' and 'g' into 'gu' when it's needed. For example:

```swift

import Foundation
import SpanishGenderNeutral

var attributedString = AttributedString(localized: "Hola chicos!")
var morphology = Morphology()

morphology.grammaticalGender = .neuter
attributedString.inflect = InflectionRule(morphology: morphology)

SpanishGenderNeutral.inflected(attributedString) // == "Hola chiques!"
```

## Attributes

Custom attributes of an `AttributedString` are kept.

## No grammatical gender

You can use this single string: `"^[Bienvenido](noGrammaticalGender: 'Te damos la bienvenida')!"` and it wil be converted to:

* `"Bienvenido!"` for masculine
* `"Bienvenida!"` for feminine
* `"Bienvenide!"` for neuter
* `"Te damos la bienvenida!"` for not specified.

Foundation doesn't make a difference between neuter and not specified when applying automatic grammar agreement, which means that you will need to provide two different strings if you want a different text for neuter and not specified.

You must include the SpanishGenderNeutral attributes for that:

```swift
var attributedString = AttributedString(localized: "^[Bienvenido](noGrammaticalGender: 'Te damos la bienvenida')!", including: \.spanishGenderNeutral)
```

If your string is `^[Bienvenido](inflect: true, inflectionAlternative: 'Te damos la bienvenida')`, this library will use the `inflectionAlternative` when no grammatical gender (Foundation will also use it for neuter). But it crashes for me so I created a custom attribute.

## Requirements

iOS 15+, iPadOS 15+, macOS 12+, tvOS 15+, watchOS 8+

## How it works?

The library produces two strings using the automatic grammar agreement from the input, one with a masculine grammatical gender and one with a feminine grammatical gender. It checks for an 'o' changed into an 'a' and replaces it by an 'e' or the passed custom suffix. Same thing for prounouns, it checks for an 'él' changed into an 'ella' and replaces it by an 'elle' or the passed custom pronoun.
