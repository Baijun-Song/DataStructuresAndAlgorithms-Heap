extension Heap {
  mutating func _heapify() {
    guard _storage.count > 1 else {
      return
    }
    let firstNonLeafIndex = _parentIndex(of: _storage.count - 1)!
    for i in stride(from: firstNonLeafIndex, through: 0, by: -1) {
      _trickleDown(from: i)
    }
  }
  
  func _leftChildIndex(of index: Int) -> Int? {
    precondition(index >= 0)
    let result = (2 * index) + 1
    if result < _storage.count {
      return result
    } else {
      return nil
    }
  }
  
  func _rightChildIndex(of index: Int) -> Int? {
    precondition(index >= 0)
    let result = (2 * index) + 2
    if result < _storage.count {
      return result
    } else {
      return nil
    }
  }
  
  func _childrenAndGrandchildrenIndices(
    of index: Int
  ) -> (children: [Int], grandchildren: [Int]) {
    precondition(index >= 0)
    var children: [Int] = []
    var grandchildren: [Int] = []
    if let l = _leftChildIndex(of: index) {
      children.append(l)
      if let ll = _leftChildIndex(of: l) {
        grandchildren.append(ll)
      }
      if let lr = _rightChildIndex(of: l) {
        grandchildren.append(lr)
      }
    }
    if let r = _rightChildIndex(of: index) {
      children.append(r)
      if let rl = _leftChildIndex(of: r) {
        grandchildren.append(rl)
      }
      if let rr = _rightChildIndex(of: r) {
        grandchildren.append(rr)
      }
    }
    return (children, grandchildren)
  }
  
  func _parentIndex(of index: Int) -> Int? {
    precondition(index < _storage.count)
    if index > 0 {
      return (index - 1) / 2
    } else {
      return nil
    }
  }
  
  func _grandParentIndex(of index: Int) -> Int? {
    if let parentIndex = _parentIndex(of: index),
       let grandParentIndex = _parentIndex(of: parentIndex) {
      return grandParentIndex
    } else {
      return nil
    }
  }
  
  func _level(of index: Int) -> Int {
    precondition(index >= 0 && index < _storage.count)
    return Int(log2(Double(index + 1)))
  }
  
  func _indexIsAtEvenLevel(_ index: Int) -> Bool {
    let level = _level(of: index)
    return (level % 2) == 0
  }
  
  mutating func _trickleDown(from index: Int) {
    precondition(index >= 0 && index < _storage.count)
    var currentIndex = index
    while true {
      let (children, grandchildren) =
        _childrenAndGrandchildrenIndices(of: currentIndex)
      guard !children.isEmpty else {
        break
      }
      
      if _indexIsAtEvenLevel(currentIndex) {
        var candidate = children.min { a, b in
          _areInAscendingOrder(_storage[a], _storage[b])
        }!
        var candidateIsGrandChild = false
        for grandchild in grandchildren {
          let a = _storage[grandchild]
          let b = _storage[candidate]
          if _areInAscendingOrder(a, b) {
            candidate = grandchild
            candidateIsGrandChild = true
          }
        }
        
        let a = _storage[candidate]
        let b = _storage[currentIndex]
        if _areInAscendingOrder(a, b) {
          _storage.swapAt(candidate, currentIndex)
          if candidateIsGrandChild {
            let childIndex = _parentIndex(of: candidate)!
            let a = _storage[childIndex]
            let b = _storage[candidate]
            if _areInAscendingOrder(a, b) {
              _storage.swapAt(candidate, childIndex)
            }
          }
          currentIndex = candidate
        } else {
          break
        }
      } else {
        var candidate = children.max { a, b in
          _areInAscendingOrder(_storage[a], _storage[b])
        }!
        var candidateIsGrandChild = false
        for grandchild in grandchildren {
          let a = _storage[candidate]
          let b = _storage[grandchild]
          if _areInAscendingOrder(a, b) {
            candidate = grandchild
            candidateIsGrandChild = true
          }
        }
        
        let a = _storage[currentIndex]
        let b = _storage[candidate]
        if _areInAscendingOrder(a, b) {
          _storage.swapAt(candidate, currentIndex)
          if candidateIsGrandChild {
            let childIndex = _parentIndex(of: candidate)!
            let a = _storage[candidate]
            let b = _storage[childIndex]
            if _areInAscendingOrder(a, b) {
              _storage.swapAt(candidate, childIndex)
            }
          }
          currentIndex = candidate
        } else {
          break
        }
      }
    }
  }
  
  mutating func _trickleUp(from index: Int) {
    precondition(index >= 0 && index < _storage.count)
    guard let parentIndex = _parentIndex(of: index) else {
      return
    }
    if _indexIsAtEvenLevel(index) {
      let a = _storage[parentIndex]
      let b = _storage[index]
      if _areInAscendingOrder(a, b) {
        _storage.swapAt(index, parentIndex)
        __trickleUpMax(from: parentIndex)
      } else {
        __trickleUpMin(from: index)
      }
    } else {
      let a = _storage[index]
      let b = _storage[parentIndex]
      if _areInAscendingOrder(a, b) {
        _storage.swapAt(index, parentIndex)
        __trickleUpMin(from: parentIndex)
      } else {
        __trickleUpMax(from: index)
      }
    }
  }
  
  private mutating func __trickleUpMin(from index: Int) {
    var currentIndex = index
    while let grandParentIndex = _grandParentIndex(of: currentIndex) {
      let a = _storage[currentIndex]
      let b = _storage[grandParentIndex]
      if _areInAscendingOrder(a, b) {
        _storage.swapAt(currentIndex, grandParentIndex)
        currentIndex = grandParentIndex
      }
    }
    
  }
  
  private mutating func __trickleUpMax(from index: Int) {
    var currentIndex = index
    while let grandParentIndex = _grandParentIndex(of: currentIndex) {
      let a = _storage[grandParentIndex]
      let b = _storage[currentIndex]
      if _areInAscendingOrder(a, b) {
        _storage.swapAt(currentIndex, grandParentIndex)
        currentIndex = grandParentIndex
      }
    }
  }
}
