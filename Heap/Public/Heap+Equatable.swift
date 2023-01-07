extension Heap: Equatable where Element: Equatable {
  @inlinable @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.storage == rhs.storage
  }
}
