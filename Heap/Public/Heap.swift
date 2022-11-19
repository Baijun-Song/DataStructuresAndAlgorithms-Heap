public struct Heap<Element> {
  var _storage: [Element] = []
  var _areInAscendingOrder: (Element, Element) -> Bool
  
  public init(
    orderedBy areInAscendingOrder:
      @escaping (Element, Element) -> Bool
  ) {
    _areInAscendingOrder = areInAscendingOrder
  }
  
  public init(
    _ elements: [Element],
    orderedBy areInAscendingOrder:
      @escaping (Element, Element) -> Bool
  ) {
    _storage = elements
    _areInAscendingOrder = areInAscendingOrder
    _heapify()
  }
}

extension Heap where Element: Comparable {
  public init() {
    self.init { a, b in
      a < b
    }
  }
  
  public init(_ elements: [Element]) {
    self.init(elements) { a, b in
      a < b
    }
  }
}

extension Heap {
  public var isEmpty: Bool {
    _storage.isEmpty
  }
  
  public var count: Int {
    _storage.count
  }
  
  public var min: Element? {
    _storage.first
  }
  
  public var max: Element? {
    if _storage.count > 2 {
      let a = _storage[1]
      let b = _storage[2]
      return _areInAscendingOrder(a, b) ? b : a
    } else {
      return _storage.last
    }
  }
  
  public var unorderedElements: [Element] {
    _storage
  }
  
  public mutating func insert(_ newElement: Element) {
    _storage.append(newElement)
    _trickleUp(from: _storage.count - 1)
  }
  
  public mutating func insert(contentsOf newElements: [Element]) {
    if (newElements.count * 2) > _storage.count {
      _storage += newElements
      _heapify()
    } else {
      _storage.reserveCapacity(newElements.count)
      for newElement in newElements {
        insert(newElement)
      }
    }
  }
  
  public mutating func popMin() -> Element? {
    if _storage.count > 1 {
      _storage.swapAt(0, _storage.count - 1)
      let removedElement = _storage.removeLast()
      _trickleDown(from: 0)
      return removedElement
    } else {
      return _storage.popLast()
    }
  }
  
  public mutating func popMax() -> Element? {
    if _storage.count > 2 {
      let maxElementIndex =
        _areInAscendingOrder(_storage[1], _storage[2]) ? 2 : 1
      _storage.swapAt(maxElementIndex, _storage.count - 1)
      let removedElement = _storage.removeLast()
      if maxElementIndex < _storage.count {
        _trickleDown(from: maxElementIndex)
      }
      return removedElement
    } else {
      return _storage.popLast()
    }
  }
  
  @discardableResult
  public mutating func remove(at index: Int) -> Element {
    precondition(index >= 0 && index < _storage.count)
    _storage.swapAt(index, _storage.count - 1)
    let removedElement = _storage.removeLast()
    if index < _storage.count {
      _trickleDown(from: index)
      _trickleUp(from: index)
    }
    return removedElement
  }
}
