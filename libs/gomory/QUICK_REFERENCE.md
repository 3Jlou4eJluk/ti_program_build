# Gomory v3.0 - Quick Reference Guide

## Installation

1. Copy `build/gomory.tns` to calculator's `/MyLib` folder
2. Press **Ctrl+Home** → **Refresh Libraries**
3. Library is now available as `gomory\`

## Functions

### Main Function
```
gomory\gomory(mat, opt, intvars, ctypes)
```

**Parameters:**
- `mat` - Problem matrix [[A|b], [c|0]]
- `opt` - 1 for maximize, 0 for minimize
- `intvars` - List [1,1,...] where 1=integer, 0=continuous
- `ctypes` - List [1,-1,0,...] where 1=≤, -1=≥, 0==

### Helper Functions
```
gomory\gcd(a, b)        - Greatest common divisor
gomory\modabs(y, d)     - Modulo: |y|_d = y mod d
gomory\findmu(beta, d)  - Optimal mu for cuts
gomory\getdenom(x)      - Extract denominator
gomory\lcm2(a, b)       - LCM of two numbers
gomory\version()        - Returns "3.0.0"
gomory\help()           - Display help
```

## Problem Format

### Matrix Structure
```
mat = [[constraint_1],
       [constraint_2],
       ...
       [constraint_m],
       [objective_function]]

Each constraint row: [a1, a2, ..., an, b]
Objective row: [c1, c2, ..., cn, 0]
```

### Constraint Types
```
ctypes[i] = 1   →  constraint i is ≤
ctypes[i] = -1  →  constraint i is ≥
ctypes[i] = 0   →  constraint i is =
```

### Integer Variables
```
intvars[j] = 1  →  variable j must be integer
intvars[j] = 0  →  variable j can be continuous
```

## Example 1: Basic Integer LP

**Problem:**
```
max Z = 3x₁ + 4x₂
s.t.
  x₁ + 2x₂ ≤ 8
  3x₁ + 2x₂ ≤ 12
  x₁, x₂ ≥ 0, integer
```

**Calculator Input:**
```
{{1,2,8},{3,2,12},{3,4,0}} → mat
1 → opt
{1,1} → intvars
{1,1} → ctypes
gomory\gomory(mat,opt,intvars,ctypes)
```

**Output:**
```
=== GOMORY v3.0 ===
Lecture version
with optimal mu

Variables: 2
Constraints: 2

PHASE 1: Find feasible
Phase 1 done, iter= 0

PHASE 2: Optimize
Phase 2 done, iter= 2
Z= 18

GOMORY CUTS:
Optimal integer found!
Z= 18

Solution:
x 1 = 2
x 2 = 3
```

## Example 2: Mixed Integer LP

**Problem:**
```
max Z = 2x₁ + 3x₂
s.t.
  x₁ + x₂ ≤ 5
  x₁ ≥ 0 (continuous)
  x₂ ≥ 0, integer
```

**Calculator Input:**
```
{{1,1,5},{2,3,0}} → mat
1 → opt
{0,1} → intvars    ← x₁ continuous, x₂ integer
{1} → ctypes
gomory\gomory(mat,opt,intvars,ctypes)
```

## Example 3: Greater-Than Constraints

**Problem:**
```
min Z = x₁ + 2x₂
s.t.
  x₁ + x₂ ≥ 5
  2x₁ + x₂ ≥ 8
  x₁, x₂ ≥ 0, integer
```

**Calculator Input:**
```
{{1,1,5},{2,1,8},{1,2,0}} → mat
0 → opt           ← minimize
{1,1} → intvars
{-1,-1} → ctypes  ← both ≥ constraints
gomory\gomory(mat,opt,intvars,ctypes)
```

## Example 4: Equality Constraints

**Problem:**
```
max Z = x₁ + x₂
s.t.
  x₁ + x₂ = 5    ← equality
  x₁ ≤ 3
  x₁, x₂ ≥ 0, integer
```

**Calculator Input:**
```
{{1,1,5},{1,0,3},{1,1,0}} → mat
1 → opt
{1,1} → intvars
{0,1} → ctypes    ← first = , second ≤
gomory\gomory(mat,opt,intvars,ctypes)
```

## Example 5: Z-row Cut Demo

**Problem:**
```
max Z = x₁ + x₂
s.t.
  2x₁ + 2x₂ ≤ 5
  x₁, x₂ ≥ 0, integer
```

**Calculator Input:**
```
{{2,2,5},{1,1,0}} → mat
1 → opt
{1,1} → intvars
{1} → ctypes
gomory\gomory(mat,opt,intvars,ctypes)
```

**Expected:**
- LP optimal: Z = 2.5 (fractional)
- Should generate Z-row cut
- Output shows: "Z-row cut, Z=2.5"
- Final: Z = 2

## Understanding Output

### Phase Messages
```
PHASE 1: Find feasible
  - Adding artificial variables
  - Finding initial feasible solution
  - "Phase 1 done, iter=N"

PHASE 2: Optimize
  - Optimizing objective function
  - "Phase 2 done, iter=N"
  - "Z=<value>" shows optimal LP value

GOMORY CUTS:
  - "Z-row cut, Z=<value>" → using objective row
  - "Row i cut, xi=<value>" → using variable row
  - "D=<D>, mu=<mu>" → shows parameters
  - "Cut added, total=<N>" → cut count

Optimal integer found!
  - All integer variables are integer
  - "Z=<value>" final objective
  - Solution: lists all basic variables
```

### Error Messages
```
"Unbounded in Phase 1" → Problem is unbounded
"Unbounded in Phase 2" → Problem is unbounded
"Unbounded after cut" → Cut caused unboundedness (rare)
"Phase 1: max iter" → Too many iterations in Phase 1
"Phase 2: max iter" → Too many iterations in Phase 2
"Dual simplex: max iter" → Too many iterations after cut
"Max cuts reached" → 20 cuts added, may not be optimal
```

## Tips

### Problem Size
- **Small (2-5 vars):** Fast, <1 minute
- **Medium (6-10 vars):** 1-5 minutes
- **Large (>10 vars):** May be slow or timeout

### Iteration Limits
- Phase 1/2: 30 iterations each
- Dual simplex: 30 iterations per cut
- Max cuts: 20

### Troubleshooting

**Problem: "Variable is not defined"**
- Solution: Refresh Libraries (Ctrl+Home)

**Problem: "Unbounded" message**
- Solution: Check problem formulation
- Ensure constraints are correct

**Problem: "Max iter" message**
- Solution: Problem may be too large
- Try simplifying or reducing variables

**Problem: "Max cuts" but not optimal**
- Solution: Try different formulation
- May need more cuts (edit source to increase limit)

### Best Practices

1. **Start small:** Test with 2-3 variables first
2. **Check LP relaxation:** Verify LP solution makes sense
3. **Watch output:** Monitor which cuts are generated
4. **Z-row cuts:** Indicate strong objective function cuts
5. **Iteration counts:** High counts suggest problem difficulty

## Advanced Features

### D (Common Denominator)
- Automatically calculated from tableau
- Shows LCM of all denominators
- Larger D → more precise cuts

### Optimal mu
- Maximizes cut strength
- Selected from {1, 2, ..., D-1}
- Must be coprime with D
- Higher mu often (not always) → stronger cut

### Z-row Cuts vs Variable Cuts
- **Z-row:** Cuts on objective function
  - Used when Z is fractional
  - Often eliminates multiple solutions
  - Preferred when available

- **Variable cut:** Cuts on basic variable
  - Used when Z is integer but variables fractional
  - Targets specific fractional variable
  - Standard Gomory cut

## Version Information

**Current version:** 3.0.0
**Release date:** 2025-12-22

**New in v3.0:**
- Optimal mu selection
- Z-row cuts
- Generalized cut formula
- Explicit D calculation

**Check version:**
```
gomory\version()
→ "3.0.0"
```

**Show help:**
```
gomory\help()
```

## References

- Full algorithm: `docs/gomory_v3_algorithm.md`
- Test cases: `test_gomory_v3.md`
- Implementation: `GOMORY_V3_IMPLEMENTATION.md`

## Support

For questions or issues:
1. Check documentation in `docs/` folder
2. Review test cases in `test_gomory_v3.md`
3. Verify problem format matches examples
4. Check calculator has sufficient memory

---

**Quick Start:**
```
1. Copy gomory.tns to /MyLib
2. Ctrl+Home → Refresh Libraries
3. {{1,2,8},{3,2,12},{3,4,0}}→mat
4. gomory\gomory(mat,1,{1,1},{1,1})
```
