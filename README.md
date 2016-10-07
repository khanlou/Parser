# Parser

![](https://travis-ci.org/khanlou/Parser.svg)

The `Parser` struct acts like a dictionary, but throws errors. This makes JSON parsing much easier. Let's look at an example type: 

```
struct Coordinate: JSONInitializable {
    let latitude: Double
    let longitude: Double
}
```

Because these types are not optional, we have to use an initializer to parse from a dictionary:

```
init(optionalDictionary: [String: AnyObject]?) {
	guard
	    let latitude = dictionary?["latitude"] as? Double,
	    let latitude = dictionary?["longitude"] as? Double
	else { return nil }
	self.latitude = latitude
	self.longitude = longitude
}
```

This code has duplicated components. The types are duplicated between the property declarations and the casting from the dictionary, and there are unnecessary intermediate variables created by the guard statement. 

`Parser` simplifies all of that. It's initialized with an optional dictionary, and handles all the logic of nilness inside it. Any properties that are expected to be non-optional but are missing will throw an error, halting execution and preventing objects that are in an invalid state.

```
init(optionalDictionary: [String: AnyObject]?) throws {
    let parser = Parser(dictionary: dictionary)
    self.latitude = try parser.fetch("latitude")
    self.longitude = try parser.fetch("longitude")
}
```

In addition, a protocol called `JSONInitializable` is included. `JSONInitializable` requires that you create an initializer with the signature

```
init(parser: Parser) throws
```

And it will implement two other initializers for you:

```
init?(dictionary: [String: AnyObject])
init?(optionalDictionary: [String: AnyObject]?)
```

These initializers handle creating the `Parser` and catch errors for you, so all you have to do is define one initializer and grab the objects out of the `Parser`:

```
init(parser: Parser) throws {
    self.latitude = try parser.fetch("lat")
    self.longitude = try parser.fetch("lon")
}
```

As the number of properties increases, this approach scales more easily.

The errors that `Parser` generates are rich: they include details about which key was missing, what type it expected them to be, and what type they were. This makes tracking down bad JSON much faster.

### `fetch`

```
func fetch<T>(_ key: String) throws -> T
```

`fetch(_:)` gets a key from the dictionary. It will throw if the key is missing or does not match the type that was expected. The error it throws includes details about what the key was, what the type that was expected was, and what the actual type was.

```
func fetch<T, U>(_ key: String, transformation: (T) -> U?) throws -> U
```

`fetch(_: transformation:)` lets you pass a block to transform the object that was extracted to any other type. For example, using trailing closure syntax,

```
self.postDate = try parser.fetchOptional("postDate") { Date(timeIntervalSince1970: $0) }
```

It will throw any errors that `fetch(_:)` throws, as well as an error if the transformation returns nil.

### fetchOptional

```
func fetchOptional<T>(_ key: String) throws -> T?
```

`fetchOptional(_:)` acts like `fetch(_:)` but it doesn't throw if the key is missing or null. It **will**, however, throw if the object can't be casted to the inferred type. This is helpful for catching issues with malformed JSON.

```
func fetchOptional<T, U>(_ key: String, transformation: (T) -> U?) throws -> U?
```

`fetchOptional(_: transformation:)` lets you pass a block to transform the object that was extracted to any other type, but returns an optional. It only throws an error if the object can't be casted to the inferred type.

### fetchArray

```
func fetchArray<T, U>(_ key: String, transformation: (T) -> U?) throws -> [U] {
```

`fetchArray(_: transformation:)` fetches an array and transforms each element in the array using the provided block. Elements that can't be transformed are removed from the array and don't throw an error. If you need to fetch an array of primitive JSON types, you can use `fetch(_:)`.

### fetchOptionalArray

```
func fetchOptionalArray<T>(_ key: String) throws -> [T]
```

`fetchOptionalArray(_:)` acts like `fetch(_:)` but returns an empty array if the key is missing or null. Elements that can't be transformed are removed from the array and don't throw an error.


```
    func fetchOptionalArray<T, U>(_ key: String, transformation: (T) -> U?) throws -> [U] {
```

`fetchOptionalArray(_: transformation:)` returns an empty array if the key is missing or null. It transforms each element in the array using the provided block. Elements that can't be transformed are removed from the array and don't throw an error.

