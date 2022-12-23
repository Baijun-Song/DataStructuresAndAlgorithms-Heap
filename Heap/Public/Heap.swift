public struct Heap<Element> {
  @usableFromInline
  var storage: [Element] = []
  
  @usableFromInline
  var areInAscendingOrder: (Element, Element) -> Bool
  
  @inlinable @inline(__always)
  public init(
    orderedBy areInAscendingOrder:
      @escaping (Element, Element) -> Bool
  ) {
    self.areInAscendingOrder = areInAscendingOrder
  }
  
  @inlinable @inline(__always)
  public init(
    _ elements: [Element],
    orderedBy areInAscendingOrder:
      @escaping (Element, Element) -> Bool
  ) {
    storage = elements
    self.areInAscendingOrder = areInAscendingOrder
    heapify()
  }
}

extension Heap where Element: Comparable {
  @inlinable @inline(__always)
  public init() {
    self.init { a, b in
      a < b
    }
  }
  
  @inlinable @inline(__always)
  public init(_ elements: [Element]) {
    self.init(elements) { a, b in
      a < b
    }
  }
}

extension Heap {
  @inlinable @inline(__always)
  public var isEmpty: Bool {
    storage.isEmpty
  }
  
  @inlinable @inline(__always)
  public var count: Int {
    storage.count
  }
  
  @inlinable @inline(__always)
  public var min: Element? {
    storage.first
  }
  
  @inlinable
  public var max: Element? {
    if storage.count > 2 {
      let a = storage[1]
      let b = storage[2]
      return areInAscendingOrder(a, b) ? b : a
    } else {
      return storage.last
    }
  }
  
  @inlinable @inline(__always)
  public var unorderedElements: [Element] {
    storage
  }
  
  @inlinable @inline(__always)
  public mutating func insert(_ newElement: Element) {
    storage.append(newElement)
    trickleUp(from: storage.count - 1)
  }
  
  @inlinable
  public mutating func insert(contentsOf newElements: [Element]) {
    if (newElements.count * 2) > storage.count {
      storage += newElements
      heapify()
    } else {
      storage.reserveCapacity(newElements.count)
      for newElement in newElements {
        insert(newElement)
      }
    }
  }
  
  @inlinable
  public mutating func popMin() -> Element? {
    if storage.count > 1 {
      storage.swapAt(0, storage.count - 1)
      let removedElement = storage.removeLast()
      trickleDown(from: 0)
      return removedElement
    } else {
      return storage.popLast()
    }
  }
  
  @inlinable
  public mutating func popMax() -> Element? {
    if storage.count > 2 {
      let maxElementIndex =
        areInAscendingOrder(storage[1], storage[2]) ? 2 : 1
      storage.swapAt(maxElementIndex, storage.count - 1)
      let removedElement = storage.removeLast()
      if maxElementIndex < storage.count {
        trickleDown(from: maxElementIndex)
      }
      return removedElement
    } else {
      return storage.popLast()
    }
  }
  
  @inlinable
  @discardableResult
  public mutating func remove(at index: Int) -> Element {
    precondition(index >= 0 && index < storage.count)
    storage.swapAt(index, storage.count - 1)
    let removedElement = storage.removeLast()
    if index < storage.count {
      trickleDown(from: index)
      trickleUp(from: index)
    }
    return removedElement
  }
}
