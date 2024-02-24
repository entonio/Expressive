Expressive
==========

The purpose of this package is to model mathematical expressions.
Expressions can be entirely numerical or they may contain variables, represented by strings of letters.

This being Swift, expressions may be written using number and string literals connected using the normal mathematical operators, or they can be parsed from strings, or mixing the two approaches.

The numerical value of expressions can be calculated by providing a map of values for the variables, if there are any. Values can be numerical, or other expressions.

This enables a program to treat mathematical formulae as data that can be passed around, read dynamically, or combined.

Expressions can be simplified. This is not an objective transformation, so the result may or may not suit your intent.
Expressions can provide a notationally correct description of their contents. 

Goals of this package:
- expressiveness
- ease of use
- correctness

Not goals:
- performance
- completeness of mathematical API

Examples
========

```swift
let VIG: Expression = "VIG"
let NEX: Expression = "NEX"

let E1 = 16 + VIG + (3 + VIG) * (NEX - 5) / 5

let E2 = "16+VIG+(3+VIG)*(NEX-5)/5" as Expression

let E3 = "16 + VIG" as Expression + "(3 + VIG) * (NEX - 5) / 5"

XCTAssertEqual(E1, E2)
XCTAssertEqual(E1, E3)
```

License
-------
Except where/if otherwise specified, all the files in this package are copyright of the package contributors mentioned in the `NOTICE` file and licensed under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0), which is permissive for business use.
