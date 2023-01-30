extension Heap {
  @inlinable
  mutating func heapify() {
    guard storage.count > 1 else {
      return
    }
    let firstNonLeafIndex = parentIndex(of: storage.count - 1)!
    for i in stride(from: firstNonLeafIndex, through: 0, by: -1) {
      trickleDown(from: i)
    }
  }
  
  @inline(__always)
  func leftChildIndex(of index: Int) -> Int? {
    precondition(index >= 0)
    let result = (2 * index) + 1
    if result < storage.count {
      return result
    } else {
      return nil
    }
  }
  
  @inline(__always)
  func rightChildIndex(of index: Int) -> Int? {
    precondition(index >= 0)
    let result = (2 * index) + 2
    if result < storage.count {
      return result
    } else {
      return nil
    }
  }
  
  @inline(__always)
  func childrenAndGrandchildrenIndices(
    of index: Int
  ) -> (children: [Int], grandchildren: [Int]) {
    precondition(index >= 0)
    var children: [Int] = []
    var grandchildren: [Int] = []
    if let l = leftChildIndex(of: index) {
      children.append(l)
      if let ll = leftChildIndex(of: l) {
        grandchildren.append(ll)
      }
      if let lr = rightChildIndex(of: l) {
        grandchildren.append(lr)
      }
    }
    if let r = rightChildIndex(of: index) {
      children.append(r)
      if let rl = leftChildIndex(of: r) {
        grandchildren.append(rl)
      }
      if let rr = rightChildIndex(of: r) {
        grandchildren.append(rr)
      }
    }
    return (children, grandchildren)
  }
  
  @inlinable @inline(__always)
  func parentIndex(of index: Int) -> Int? {
    precondition(index < storage.count)
    if index > 0 {
      return (index - 1) / 2
    } else {
      return nil
    }
  }
  
  @inline(__always)
  func grandParentIndex(of index: Int) -> Int? {
    precondition(index < storage.count)
    if index > 2 {
      return (index - 3) / 4
    } else {
      return nil
    }
  }
  
  @inline(__always)
  func level(of index: Int) -> Int {
    precondition(index >= 0 && index < storage.count)
    return Int(log2(Double(index + 1)))
  }
  
  @inline(__always)
  func indexIsAtEvenLevel(_ index: Int) -> Bool {
    let level = level(of: index)
    return (level % 2) == 0
  }
  
  @usableFromInline
  mutating func trickleDown(from index: Int) {
    precondition(index >= 0 && index < storage.count)
    var currIndex = index
    while true {
      let (children, grandchildren) =
        childrenAndGrandchildrenIndices(of: currIndex)
      guard !children.isEmpty else {
        break
      }
      
      if indexIsAtEvenLevel(currIndex) {
        var candidate = children.min { a, b in
          areInAscendingOrder(storage[a], storage[b])
        }!
        var candidateIsGrandChild = false
        for grandchild in grandchildren {
          let a = storage[grandchild]
          let b = storage[candidate]
          if areInAscendingOrder(a, b) {
            candidate = grandchild
            candidateIsGrandChild = true
          }
        }
        
        let a = storage[candidate]
        let b = storage[currIndex]
        if areInAscendingOrder(a, b) {
          storage.swapAt(candidate, currIndex)
          if candidateIsGrandChild {
            let childIndex = parentIndex(of: candidate)!
            let a = storage[childIndex]
            let b = storage[candidate]
            if areInAscendingOrder(a, b) {
              storage.swapAt(candidate, childIndex)
            }
          }
          currIndex = candidate
        } else {
          break
        }
      } else {
        var candidate = children.max { a, b in
          areInAscendingOrder(storage[a], storage[b])
        }!
        var candidateIsGrandChild = false
        for grandchild in grandchildren {
          let a = storage[candidate]
          let b = storage[grandchild]
          if areInAscendingOrder(a, b) {
            candidate = grandchild
            candidateIsGrandChild = true
          }
        }
        
        let a = storage[currIndex]
        let b = storage[candidate]
        if areInAscendingOrder(a, b) {
          storage.swapAt(candidate, currIndex)
          if candidateIsGrandChild {
            let childIndex = parentIndex(of: candidate)!
            let a = storage[candidate]
            let b = storage[childIndex]
            if areInAscendingOrder(a, b) {
              storage.swapAt(candidate, childIndex)
            }
          }
          currIndex = candidate
        } else {
          break
        }
      }
    }
  }
  
  @usableFromInline
  mutating func trickleUp(from index: Int) {
    precondition(index >= 0 && index < storage.count)
    guard let parentIndex = parentIndex(of: index) else {
      return
    }
    if indexIsAtEvenLevel(index) {
      let a = storage[parentIndex]
      let b = storage[index]
      if areInAscendingOrder(a, b) {
        storage.swapAt(index, parentIndex)
        trickleUpMax(from: parentIndex)
      } else {
        trickleUpMin(from: index)
      }
    } else {
      let a = storage[index]
      let b = storage[parentIndex]
      if areInAscendingOrder(a, b) {
        storage.swapAt(index, parentIndex)
        trickleUpMin(from: parentIndex)
      } else {
        trickleUpMax(from: index)
      }
    }
  }
  
  private mutating func trickleUpMin(from index: Int) {
    var currIndex = index
    while let grandParentIndex = grandParentIndex(of: currIndex) {
      let a = storage[currIndex]
      let b = storage[grandParentIndex]
      if areInAscendingOrder(a, b) {
        storage.swapAt(currIndex, grandParentIndex)
        currIndex = grandParentIndex
      }
    }
  }
  
  private mutating func trickleUpMax(from index: Int) {
    var currIndex = index
    while let grandParentIndex = grandParentIndex(of: currIndex) {
      let a = storage[grandParentIndex]
      let b = storage[currIndex]
      if areInAscendingOrder(a, b) {
        storage.swapAt(currIndex, grandParentIndex)
        currIndex = grandParentIndex
      }
    }
  }
}
