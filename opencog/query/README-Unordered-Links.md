### Overview

This document explains some problems concerning pattern matching queries
that contain UnorderedLinks when it is required to finding all valid
groundings. Solutions to described problems are also discussed.

All examples below assume that the pattern query is compared to proposed 
grounding term. This corresponds to tree_compare method of the 
PatternMatchEngine class. Here we do not focus on how to find potential
grounding terms and how to traverse the knowlegde base (Atomspace) seeking
this terms. It seems to be an orthogonal problem. Here we just assume that
proposed grounding term is given as an input and we want to find all
permutations of UnorderedLinks in the pattern query that match given term.

### Problem 1. Searching for the first match

This is the simplest case properly solved by previous implementation
of pattern matcher. We show it only for illustrative purpose. Suppose we have
a query containing 3 unordered links that form a tree. No atom repeats.

```
UnorderedLink "A" (
  UnorderedLink "B" (
    Node "N1"
    Node "N2"
  )
  UnorderedLink "C" (
    Node "N3"
    Node "N4"
  )
)
```

For each unordered link there exist 2 permutations of its outgoing atoms.
So there are 8 possible mutations of the whole pattern in total.
Let us label this permutations counting from 0 to number all permutations - 1
for each unordered link independently.

Suppose that the only mutation that match proposed grounding term is
(A:1, B:0, C:1).

Assume for now that we decide to start searching from the top link A.
It is easy to find out that we just need to depth first search the following
tree until we find valid matching.

```
start
  A:0
    B:0
      C:0
      C:1
    B:1
      C:0
      C:1
  A:1
    B:0
      C:0
      C:1 (found!)
```

Usually many of the search branches may be pruned. For example when the types
of query atoms do not match the types of corresponding atoms in the grounding
term then we do not need to search down the tree. Though in this document
we treat this pruning only as obvious optimisation and do not focus on that.

### Problem 2. Searching for all matches

Suppose there are many mutations that match proposed grounding term:

```
(A:1, B:0, C:1).
(A:1, B:1, C:0).
(A:1, B:1, C:1).
```

Then we need to explore the whole tree until exhaustion.

```
start
  A:0
    B:0
      C:0
      C:1
    B:1
      C:0
      C:1
  A:1
    B:0
      C:0
      C:1 (found!)
    B:1
      C:0 (found!)
      C:1 (found!)
```

This case is problematic for the previous implementation of pattern matcher.
When the tree_compare method finds the first good mutation this matching
is reported to the caller for acceptance. Till that moment everything goes
right. But then it stops processing current proposed grounding term,
switches to another proposed term and continues to search next mutations.
This is the reason why it may miss some good mutations.

Instead it should search all remaining mutations and compare them to the 
original grounding term, then switch to another proposed term after exhaustion 
and search the query tree from the begining starting from the first mutation. 

The solution of this problem is depth first search the whole mutation tree
until exhaustion. Switch to another proposed grounding term must be
possible only after all mutations are explored for original grounding term.

We are aware that the new solution has much worse time complexity. Though
we treat this as an orthogonal optimisation problem. It seems that many
information may be cached and reused. We leave it now as an optimisation 
problem that still require more research and improved benchmarking.

### Problem 3. Bottom-up search

Previous examples assume that we explore the query term in top-down order.
Though in general the starting term position should be unrestricted,
because independently at the same time we traverse through the knowledge
base graph (Atomspace) and good heuristic for this traversing should be
allowed to choose any atom as starting term. For example it may choose the
best one among atoms with minimum size of its incoming set. So assume here
that the postion of starting term is unresticted and given as input to our 
procedure.

Let us explain following example:

```
UnorderedLink "A" (
  UnorderedLink "B" (
    UnorderedLink "D" (
      Node "N5"
      Node "N6"
    )
    Node "N1"
    Node "N2"
  )
  UnorderedLink "C" (
    Node "N3"
    Node "N4"
  )
)
```

Let unordered link B be a starting term. B has 6 permutations labeled
from 0 to 5. Suppose that following mutations match proposed grounding term:

```
(A:0, B:3, C:0, D:0)
(A:0, B:3, C:1, D:1)
(A:1, B:0, C:0, D:0)
(A:1, B:1, C:1, D:1)
```

We start from subterm B and depth first search following tree:

```
start B: (level 0)
  B:0
    D:0  (found, step up)
    D:1
  B:1
    D:0
    D:1  (found, step up)
  B:2
    D:0
    D:1
  B:3
    D:0  (found, step up)
    D:1  (found, step up)
  B:4
    D:0
    ....
```

Suppose we have found the first match (B:0, D:0) and stepped up to upper
term A. Now we are going to depth first search mutations of term A.
Notice that we should freeze current mutation of subterm B and do not search
other mutations of B until all mutations of A are exhausted. So when we are
in A we depth first search only the following tree:

```
start A: (level 1)
  A:0
    C:0
    C:1
  A:1
    C:0   (found!)
    C:1
... and backtrack to B at the end
```

The previous implementation of pattern matcher does not freeze current
mutation of B while processing upper term A. It restores the original
mutation while backtracking. This is less effictient and may bring
duplicated matches. However this does not cause any match to be missed.

### Problem 4. Repeated atom in the pattern query

```
UnorderedLink "A" (
  UnorderedLink "B" (
    Node "N1"
    Node "N2"
  )
  UnorderedLink "C" (
    Node "N3"
    Node "N4"
  )
  UnorderedLink "B" (
    Node "N1"
    Node "N2"
  )
)
```

Pattern query is a graph, so it may contain links repeated in many
positions in the tree. UnorderedLink B above is an example. Each link 
occurrence may have different permutations that match proposed grounding
term. We conclude that we have to process each link position separately.
The previous implementation of pattern matcher does not take this situations
into account. That way it may miss some good mutations.

This problem may be solved by preprocessing patern query tree and mapping
each link to unique term pointer. For example:
```
A => T1
B => T2
C => T3
B => T4
```

Then we can use the same depth first search algorithm as before applied
to the mapped tree structure:

```
T1
  T2
    N1
    N2
  T3
    N3
    N4
  T4
    N1
    N2
```
