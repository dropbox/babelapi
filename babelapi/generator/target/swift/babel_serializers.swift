protocol JSONSerializer {
	typealias ValueType
	func serialize(ValueType) -> String
}

class ArraySerializer<T : JSONSerializer> : JSONSerializer {

	var elementSerializer : T

	init(elementSerializer : T) {
		self.elementSerializer = elementSerializer
	}

	func serialize(arr : Array<T.ValueType>) -> String {
		let s = ", ".join(arr.map { self.elementSerializer.serialize($0) })
		return "[\(s)]"
	}
}

class StringSerializer : JSONSerializer {
    func serialize(value : String) -> String {
        return "\"\(value)\""
    }
}

class NSDateSerializer : JSONSerializer {

	var dateFormatter : NSDateFormatter

	init(dateFormat: String) {
		self.dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = dateFormat
	}
    func serialize(value: NSDate) -> String {
		return "\"\(self.dateFormatter.stringFromDate(value))\""
    }
}

class BoolSerializer : JSONSerializer {
    func serialize(value : Bool) -> String {
        return value ? "true" : "false"
    }
}

class UInt64Serializer : JSONSerializer {
    func serialize(value : UInt64) -> String {
        return String(value)
    }
}

struct Serialization {
	static var _NSDateSerializer = NSDateSerializer(dateFormat: "EEE, dd MMM yyyy HH:mm:ss '+0000'")
	static var _StringSerializer = StringSerializer()
	static var _BoolSerializer = BoolSerializer()
	static var _UInt64Serializer = UInt64Serializer()
}

