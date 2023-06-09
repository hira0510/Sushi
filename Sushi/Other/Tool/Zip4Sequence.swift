//
//  Zip4Sequence.swift
//  Sushi
//
//  Created by admin on 2023/4/25.
/// https://github.com/amomchilov/ZipNsequence/blob/master/Zip5Sequence.swift

/// Creates a sequence of tuples built out of 3 underlying sequences.
///
/// In the `Zip3Sequence` instance returned by this function, the elements of
/// the *i*th tuple are the *i*th elements of each underlying sequence. The
/// following example uses the `zip(_:_:)` function to iterate over an array
/// of strings and a countable range at the same time:
///
///     let words = ["one", "two", "three", "four"]
///     let numbers = 1...4
///
///     for (word, number) in zip(words, numbers) {
///         print("\(word): \(number)")
///     }
///     // Prints "one: 1"
///     // Prints "two: 2
///     // Prints "three: 3"
///     // Prints "four: 4"
///
/// If the 3 sequences passed to `zip(_:_:_:)` are different lengths, the
/// resulting sequence is the same length as the shortest sequence. In this
/// example, the resulting array is the same length as `words`:
///
///     let naturalNumbers = 1...Int.max
///     let zipped = Array(zip(words, naturalNumbers))
///     // zipped == [("one", 1), ("two", 2), ("three", 3), ("four", 4)]
///
/// - Parameters:
///   - sequence1: The sequence or collection in position 1 of each tuple.
///   - sequence2: The sequence or collection in position 2 of each tuple.
///   - sequence3: The sequence or collection in position 3 of each tuple.
/// - Returns: A sequence of tuple pairs, where the elements of each pair are
///   corresponding elements of `sequence1` and `sequence2`.
public func zip<
Sequence1 : Sequence,
Sequence2 : Sequence,
Sequence3 : Sequence
>(
  _ sequence1: Sequence1,
  _ sequence2: Sequence2,
  _ sequence3: Sequence3

) -> Zip3Sequence<
Sequence1,
Sequence2,
Sequence3
> {
  return Zip3Sequence(
    _sequence1: sequence1,
    _sequence2: sequence2,
    _sequence3: sequence3
  )
}

/// An iterator for `Zip3Sequence`.
public struct Zip3Iterator<
  Iterator1 : IteratorProtocol,
  Iterator2 : IteratorProtocol,
  Iterator3 : IteratorProtocol
> : IteratorProtocol {
  /// The type of element returned by `next()`.
  public typealias Element = (
      Iterator1.Element,
      Iterator2.Element,
      Iterator3.Element
  )

  /// Creates an instance around the underlying iterators.
  internal init(
      _ iterator1: Iterator1,
      _ iterator2: Iterator2,
      _ iterator3: Iterator3
  ) {
    _baseStream1 = iterator1
    _baseStream2 = iterator2
    _baseStream3 = iterator3
  }

  /// Advances to the next element and returns it, or `nil` if no next element
  /// exists.
  ///
  /// Once `nil` has been returned, all subsequent calls return `nil`.
  public mutating func next() -> Element? {
    // The next() function needs to track if it has reached the end.  If we
    // didn't, and the first sequence is longer than the second, then when we
    // have already exhausted the second sequence, on every subsequent call to
    // next() we would consume and discard one additional element from the
    // first sequence, even though next() had already returned nil.
    if _reachedEnd {
      return nil
    }

    guard
        let element1 = _baseStream1.next(),
        let element2 = _baseStream2.next(),
        let element3 = _baseStream3.next()
    else {
      _reachedEnd = true
      return nil
    }

    return (
        element1,
        element2,
        element3
    )
  }

  internal var _baseStream1: Iterator1
  internal var _baseStream2: Iterator2
  internal var _baseStream3: Iterator3
  internal var _reachedEnd: Bool = false
}

/// A sequence of pairs built out of two underlying sequences.
///
/// In a `Zip3Sequence` instance, the elements of the *i*th pair are the *i*th
/// elements of each underlying sequence. To create a `Zip3Sequence` instance,
/// use the `zip(_:_:_:)` function.
///
/// The following example uses the `zip(_:_:)` function to iterate over an
/// array of strings and a countable range at the same time:
///
///     let words = ["one", "two", "three", "four"]
///     let numbers = 1...4
///
///     for (word, number) in zip(words, numbers) {
///         print("\(word): \(number)")
///     }
///     // Prints "one: 1"
///     // Prints "two: 2
///     // Prints "three: 3"
///     // Prints "four: 4"
///
/// - SeeAlso: `zip(_:_:_:)`
public struct Zip3Sequence<
Sequence1 : Sequence,
Sequence2 : Sequence,
Sequence3 : Sequence
>
  : Sequence {

  public typealias Stream1 = Sequence1.Iterator
  public typealias Stream2 = Sequence2.Iterator
  public typealias Stream3 = Sequence3.Iterator

  /// A type whose instances can produce the elements of this
  /// sequence, in order.
  public typealias Iterator = Zip3Iterator<
    Stream1,
    Stream2,
    Stream3
>

  @available(*, unavailable, renamed: "Iterator")
  public typealias Generator = Iterator

  /// Creates an instance that makes pairs of elements from `sequence1` and
  /// `sequence2`.
  public // @testable
  init(
    _sequence1 sequence1: Sequence1,
    _sequence2 sequence2: Sequence2,
    _sequence3 sequence3: Sequence3
  ) {
    _sequence1 = sequence1
    _sequence2 = sequence2
    _sequence3 = sequence3
  }

  /// Returns an iterator over the elements of this sequence.
  public func makeIterator() -> Iterator {
    return Iterator(
      _sequence1.makeIterator(),
      _sequence2.makeIterator(),
      _sequence3.makeIterator()
    )
  }

  internal let _sequence1: Sequence1
  internal let _sequence2: Sequence2
  internal let _sequence3: Sequence3
}
