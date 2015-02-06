protocol Validator {
	typealias ValueType
    func validate(value: ValueType)
}

class ArrayValidator<T: Validator>: Validator {
    let elementValidator : T
    let minItems : Int?
    let maxItems : Int?

    init(elementValidator : T, minItems : Int?, maxItems : Int?) {
        self.elementValidator = elementValidator
        self.minItems = minItems
        self.maxItems = maxItems
    }

    func validate(value : Array<T.ValueType>) {

        if let min = self.minItems {
            assert (value.count >= min, "\(value) must have at least \(min) items")
        }

        if let max = self.maxItems {
            assert (value.count <= max, "\(value) must have at most \(max) items")
        }

        for el in value {
            el.validate()
        }
    }
}

class StringValidator : Validator {
    func validate(value : String) {
        let length = countElements(value)
        if let min = self.minLength {
            assert(length >= min, "\"\(value)\" must be at least \(min) characters")
        }

        if let max = self.maxLength {
            assert (length <= max, "\"\(value)\" must be at most \(max) characters")
        }

        if let re = self.regex {
            let matches = re.matchesInString(value, options: nil, range: NSMakeRange(0, length))
            assert(matches.count > 0, "\"\(value) must match pattern \"\(re.pattern)\"")
        }
    }
}

class EmptyValidator<T> : Validator {
    func validate(value : T) { }
}
