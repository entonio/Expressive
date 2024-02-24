Expressive
----------

The purpose of this package is to model mathematical expressions.
Expressions can be entirely numerical or they may contain variables, represented by strings.
The numerical value of expressions can be calculated by providing values for the variables, if there are any. Values can be numerical, or other expressions.

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
