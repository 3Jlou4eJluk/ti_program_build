# Gomory v3.0 - Lecture Version Algorithm Documentation

## Overview

This implementation follows the lecture version of the Gomory cutting plane algorithm with optimal mu selection and Z-row cuts. It represents a significant upgrade from v2.3.0, implementing the generalized cut formula that provides stronger cuts and better convergence.

## Algorithm Structure

### Input Parameters

```
mat: Matrix [[A|b], [c|0]]
  - A: constraint matrix (m × n)
  - b: right-hand side vector
  - c: objective function coefficients
  - Last row: [c1, c2, ..., cn, 0]

opt: Optimization direction
  - 1 = maximize
  - 0 = minimize

intvars: Integer variable flags [i1, i2, ..., in]
  - 1 = variable must be integer
  - 0 = variable can be continuous

ctypes: Constraint types [t1, t2, ..., tm]
  - 1 = ≤ constraint
  - -1 = ≥ constraint
  - 0 = = constraint
```

### Main Phases

## Phase 1: Tableau Construction

### 1.1 Variable Counting
```
realvars = n (original variables)
slackvars = count based on constraint types:
  - ≤ constraint: +1 (slack variable)
  - ≥ constraint: +2 (surplus + artificial)
  - = constraint: +1 (artificial)
totalvars = realvars + slackvars
```

### 1.2 Tableau Initialization
```
Tableau dimensions: (m+1) × (totalvars + m + 2)
  - m+1 rows: m constraints + 1 objective row
  - totalvars: original + slack/surplus variables
  - m: artificial variables
  - 2: basis column + RHS column

Structure:
[A | slack | artificial | RHS]
[c | 0     | 0          | 0  ]
```

### 1.3 Slack/Surplus Variable Setup
```
For each constraint i:
  If ctypes[i] = 1 (≤):
    Add slack: x_n+j = 1 at row i

  If ctypes[i] = -1 (≥):
    Add surplus: x_n+j = -1 at row i
    Add artificial: x_n+j+1 = 1 at row i

  If ctypes[i] = 0 (=):
    Add artificial: x_n+j = 1 at row i
```

### 1.4 Initial Basis
```
basis[i] = realvars + i (artificial variables)
for i = 1 to m
```

## Phase 2: Phase 1 Simplex

**Goal:** Find a feasible basic solution

### 2.1 Entering Variable Selection
```
For j = 1 to totalvars + m + 1:
  If tab[m+1, j] < -0.0001:
    pcol = j
    break
```

### 2.2 Leaving Variable Selection (Minimum Ratio Test)
```
prow = 0
minratio = infinity

For i = 1 to m:
  If tab[i, pcol] > 0.0001:
    ratio = tab[i, totalvars+m+2] / tab[i, pcol]
    If ratio < minratio:
      minratio = ratio
      prow = i
```

### 2.3 Pivot Operation
```
1. Normalize pivot row:
   piv = tab[prow, pcol]
   For j = 1 to totalvars + m + 2:
     tab[prow, j] = tab[prow, j] / piv

2. Eliminate pivot column:
   For i = 1 to m+1:
     If i ≠ prow:
       mult = tab[i, pcol]
       For j = 1 to totalvars + m + 2:
         tab[i, j] = tab[i, j] - mult * tab[prow, j]

3. Update basis:
   basis[prow] = pcol
```

### 2.4 Termination
```
If no negative coefficients in objective row:
  Feasible solution found

If unbounded (no positive pivot column):
  Return "Unbounded in Phase 1"

If max iterations (30) reached:
  Return "Phase 1: max iter"
```

## Phase 3: Phase 2 Simplex

**Goal:** Optimize the objective function

Same structure as Phase 1, but:
- Search only in columns 1 to totalvars (exclude artificial variables)
- Use original objective function coefficients

## Phase 4: Gomory Cutting Plane

### 4.1 Calculate D (Common Denominator)

```
maxd = 1
For i = 1 to rowDim(tab):
  For j = 1 to colDim(tab):
    d = getdenom(tab[i, j])
    If d > maxd:
      maxd = d

D = maxd
```

**getdenom(x) function:**
```
For k = 1 to 10:
  d = 10^k
  If |x*d - round(x*d)| < 0.0001:
    Return d
Return 1
```

This finds the smallest denominator d such that x*d is approximately an integer.

### 4.2 Check Z-row Fractionality

```
Z = tab[m+1, totalvars+m+2]
frac = Z - floor(Z)

If 0.0001 < frac < 0.9999:
  cutrow = m+1  (use Z-row)
  beta = Z
  Display "Z-row cut, Z=", Z
Else:
  Find first fractional basic variable (see 4.3)
```

**Why Z-row cuts?**
- If the objective value is fractional, cutting it directly often provides stronger cuts
- Z-row cuts can eliminate multiple fractional solutions at once
- Follows lecture methodology for maximum efficiency

### 4.3 Find Fractional Basic Variable (Fallback)

```
For i = 1 to m:
  If basis[i] ≤ realvars:  (is a real variable, not slack)
    If intvars[basis[i]] = 1:  (must be integer)
      val = tab[i, totalvars+m+2]
      frac = val - floor(val)
      If 0.0001 < frac < 0.9999:
        cutrow = i
        beta = val
        Display "Row", i, "cut, x", basis[i], "=", val
        break
```

### 4.4 Find Optimal mu

```
beta_num = floor(beta * D + 0.5)  (numerator of beta when denominator is D)
mu = findmu(beta_num, D)
```

**findmu(beta, d) function:**
```
mu = 1
maxf = 0

For i = 1 to d-1:
  g = gcd(i, d)
  If |g - 1| < 0.0001:  (i and d are coprime)
    f = modabs(i * beta, d)
    If f > maxf:
      maxf = f
      mu = i

Return mu
```

**Mathematical insight:**
- We want to maximize f_0 = |mu * beta|_D
- Subject to gcd(mu, D) = 1 (mu coprime with D)
- This makes the cut as strong as possible
- Coprimality ensures the cut is valid

### 4.5 Build Generalized Cut

```
1. Expand tableau by one row:
   newMat(rowDim(tab)+1, colDim(tab)) → tab

2. Calculate f_0:
   f0 = modabs(floor(beta*D + 0.5) * mu, D)

3. For each non-basic variable j (j = 1 to totalvars):
   If j is not in basis:
     alpha = tab[cutrow, j]
     alpha_num = floor(alpha * D + 0.5)
     f_j = modabs(alpha_num * mu, D)
     tab[m+1, j] = f_j
   Else:
     tab[m+1, j] = 0

4. Add slack variable for cut:
   tab[m+1, totalvars+m+1] = 1

5. Set RHS:
   tab[m+1, totalvars+m+2] = -f0
   (negative because we store as -f0 for slack form)

6. Update dimensions and basis:
   m = m + 1
   basis[m] = totalvars + m + 1
   cutcnt = cutcnt + 1
```

**Cut interpretation:**
```
Original form: Σ (f_j / D) * x_j ≥ f_0 / D

Multiply by D: Σ f_j * x_j ≥ f_0

Slack form: Σ f_j * x_j + s = f_0
           where s ≥ 0 is slack variable

Tableau form: -Σ f_j * x_j - s = -f_0
```

### 4.6 Restore Feasibility (Dual Simplex)

After adding a cut, the solution may become infeasible. Use dual simplex to restore feasibility.

**Dual simplex iteration:**
```
1. Find entering variable (same as primal):
   For j = 1 to totalvars + m:
     If tab[m+1, j] < -0.0001:
       pcol = j
       break

2. Find leaving variable (minimum ratio test):
   For i = 1 to m:
     If tab[i, pcol] > 0.0001:
       ratio = tab[i, totalvars+m+2] / tab[i, pcol]
       If ratio < minratio:
         minratio = ratio
         prow = i

3. Pivot operation (same as primal)

4. Repeat until no negative coefficients in objective row
```

### 4.7 Termination Conditions

```
1. All integer variables are integer:
   cutrow = 0
   Display "Optimal integer found!"
   Display "Z=", tab[m+1, totalvars+m+2]
   Display solution
   Return

2. Maximum cuts reached (20):
   Display "Max cuts reached"
   Return

3. Unbounded after cut:
   Display "Unbounded after cut"
   Return
```

## Helper Functions

### gcd(a, b) - Greatest Common Divisor
```
x = |a|
y = |b|

While y > 0.0001:
  temp = y
  y = mod(x, y)
  x = temp

Return x
```

**Euclidean algorithm** - standard implementation.

### modabs(y, d) - Modulo with Absolute Value
```
result = y - d * floor(y / d)
Return result
```

**Mathematical definition:** |y|_d = y mod d, always returns value in [0, d).

### getdenom(x) - Extract Denominator
```
For k = 1 to 10:
  d = 10^k
  If |x*d - round(x*d)| < 0.0001:
    Return d

Return 1
```

**Purpose:** Find smallest denominator d such that x = numerator/d.

**Limitation:** Only checks denominators 10, 100, ..., 10^10. For fractions with larger denominators, returns 1.

### findmu(beta, d) - Find Optimal mu
```
mu = 1
maxf = 0

For i = 1 to d-1:
  g = gcd(i, d)
  If |g - 1| < 0.0001:
    f = modabs(i * beta, d)
    If f > maxf:
      maxf = f
      mu = i

Return mu
```

**Optimization problem:**
```
maximize: f = |mu * beta|_d
subject to: gcd(mu, d) = 1
           1 ≤ mu < d
```

## Implementation Notes

### Variable Naming Conventions
```
m: number of constraints
n: number of original variables
realvars: number of original variables (= n)
slackvars: number of slack/surplus variables
totalvars: realvars + slackvars
tab: tableau matrix
basis: basis vector (which variable is basic in each row)
pcol: pivot column (entering variable)
prow: pivot row (leaving variable)
piv: pivot element
cutrow: row used for generating cut
beta: RHS value of cut row
D (bigg): common denominator
mu: optimal multiplier
f0: RHS of cut (after mu multiplication and modulo)
```

### Tolerance Values
```
0.0001: Used for:
  - Checking if coefficient is negative/positive
  - Checking if value is fractional
  - Checking if value is approximately zero
  - GCD convergence

0.9999: Upper bound for fractionality
  - frac > 0.9999 is considered integer (frac ≈ 1)
```

### Iteration Limits
```
Phase 1 simplex: 30 iterations
Phase 2 simplex: 30 iterations
Dual simplex (per cut): 30 iterations
Maximum cuts: 20
```

**Rationale:** These limits prevent infinite loops while being generous enough for most practical problems on TI-Nspire.

### Basis Management
```
basis[i] stores the variable number that is basic in row i

Variable numbering:
  1 to n: original variables (x1, x2, ..., xn)
  n+1 to n+slackvars: slack/surplus variables
  n+slackvars+1 to n+slackvars+m: artificial variables
  n+slackvars+m+1 onwards: cut slack variables
```

## Comparison with v2.3.0

### v2.3.0 Algorithm
```
1. Two-phase simplex (same)
2. For each fractional basic variable:
   - frac = value - floor(value)
   - For each non-basic j:
     f_j = tab[i,j] - floor(tab[i,j])
   - Cut: Σ f_j * x_j ≥ frac
```

**Issues:**
- No mu optimization
- No Z-row cuts
- Weaker cuts (slower convergence)
- Implicit D = 1

### v3.0.0 Algorithm
```
1. Two-phase simplex (same)
2. Calculate D = LCM of all denominators
3. Check Z-row fractionality first
4. Find optimal mu for chosen row
5. Build generalized cut with mu
6. Restore feasibility with dual simplex
```

**Improvements:**
- Stronger cuts (optimal mu)
- Z-row cuts (more effective)
- Explicit LCM calculation
- Better convergence

## Example: Step-by-Step

**Problem:**
```
max Z = 3x1 + 4x2
s.t.
  x1 + 2x2 ≤ 8
  3x1 + 2x2 ≤ 12
  x1, x2 ≥ 0, integer
```

**Step 1: Tableau Construction**
```
realvars = 2
slackvars = 2 (one slack per constraint)
totalvars = 4

Initial tableau:
[1  2  1  0  | 8 ]
[3  2  0  1  | 12]
[3  4  0  0  | 0 ]
```

**Step 2: Phase 1 Simplex**
(Skipped if all constraints are ≤, as we already have feasible basis)

**Step 3: Phase 2 Simplex**
```
Entering: x2 (most negative in Z-row)
Leaving: x3 (slack 1)
Pivot: tab[1,2] = 2

After pivoting:
[0.5  1  0.5  0  | 4 ]
[2    0  -1   1  | 4 ]
[1    0  -2   0  | -16]

Entering: x1
Leaving: x4 (slack 2)
Pivot: tab[2,1] = 2

After pivoting:
[0   1  1   -0.25 | 3  ]
[1   0  -0.5  0.5 | 2  ]
[0   0  -1.5  -0.5| -18]

Optimal LP: x1=2, x2=3, Z=18
All values are integer → DONE!
```

In this case, no cuts are needed because the LP optimal is already integer.

**Example with cuts:**
```
max Z = x1 + x2
s.t.
  2x1 + 2x2 ≤ 5
  x1, x2 ≥ 0, integer

LP optimal: x1=x2=1.25, Z=2.5 (fractional)

D calculation:
  1.25 = 5/4 → denominator = 4
  All other values: check similarly
  D = 4

Z-row cut:
  beta = 2.5, beta_num = floor(2.5*4+0.5) = 10
  mu = findmu(10, 4)
    Check i=1: gcd(1,4)=1, f=|1*10|_4=2
    Check i=2: gcd(2,4)=2 (skip)
    Check i=3: gcd(3,4)=1, f=|3*10|_4=2
  mu = 1 or 3 (both give f=2)

  f_0 = 2

  For x1: alpha=1.25, alpha_num=5, f_j=|1*5|_4=1
  For x2: alpha=1.25, alpha_num=5, f_j=|1*5|_4=1

  Cut: (1/4)x1 + (1/4)x2 ≥ 2/4
  Or: x1 + x2 ≥ 2

Add cut to tableau and resolve with dual simplex.
```

## File Locations

- **Implementation:** `/Users/mkalinin/Documents/Code/ti_program_build/libs/gomory/Problem1.xml`
- **Build script:** `/Users/mkalinin/Documents/Code/ti_program_build/scripts/build.sh`
- **Test plan:** `/Users/mkalinin/Documents/Code/ti_program_build/test_gomory_v3.md`
- **This document:** `/Users/mkalinin/Documents/Code/ti_program_build/docs/gomory_v3_algorithm.md`

## References

1. Gomory, R.E. (1958). "Outline of an algorithm for integer solutions to linear programs"
2. Lecture notes on cutting plane methods
3. Schrijver, A. "Theory of Linear and Integer Programming"
