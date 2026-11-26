"""TI-Nspire CX II-T routines for identification and 2SLS.

The build script imports ``FUNCTIONS`` and converts each TI-Basic body into a
public MyLib function.  All linear algebra is numeric and works without CAS.
"""


FUNCTIONS = {
    "version": (
        "",
        """Func
:Return "1.0.0"
:EndFunc""",
    ),
    "mrank": (
        "a,tol",
        """Func
:Local b,n,p,i,j,k,r,pr,best,piv,tmp,f
:If tol≤0 Then
:10^(−10)→tol
:EndIf
:a→b
:rowDim(b)→n
:colDim(b)→p
:0→r
:For j,1,p
:0→best
:0→pr
:For i,r+1,n
:If abs(b[i,j])>best Then
:abs(b[i,j])→best
:i→pr
:EndIf
:EndFor
:If best>tol Then
:r+1→r
:If pr≠r Then
:For k,1,p
:b[r,k]→tmp
:b[pr,k]→b[r,k]
:tmp→b[pr,k]
:EndFor
:EndIf
:b[r,j]→piv
:For k,j,p
:b[r,k]/piv→b[r,k]
:EndFor
:For i,1,n
:If i≠r Then
:b[i,j]→f
:For k,j,p
:b[i,k]-f*b[r,k]→b[i,k]
:EndFor
:EndIf
:EndFor
:EndIf
:EndFor
:Return r
:EndFunc""",
    ),
    "idord": (
        "kex,nrhs",
        """Func
:If kex<0 or nrhs<0 Then
:Return "ERR: negative count"
:EndIf
:Return kex-nrhs
:EndFunc""",
    ),
    "idrank": (
        "m,need,tol",
        """Func
:Local r
:If need<0 Then
:Return "ERR: need<0"
:EndIf
:mrank(m,tol)→r
:If r≥need Then
:Return 1
:EndIf
:Return 0
:EndFunc""",
    ),
    "idall": (
        "kex,nrhs,m,need,tol",
        """Func
:Local s,r
:If kex<0 or nrhs<0 or need<0 Then
:Return "ERR: bad count"
:EndIf
:kex-nrhs→s
:mrank(m,tol)→r
:If s<0 Then
:Return −1
:EndIf
:If r<need Then
:Return −2
:EndIf
:If s=0 Then
:Return 0
:EndIf
:Return 1
:EndFunc""",
    ),
    "idstruct": (
        "h,g,cm,mask,tol",
        """Func
:Local w,lastcol,used,infz,b,out,m,ex,ne,i,j,k,src,kex,nrhs,gap,r,rb,code,last,hv,mv
:If getType(h)≠"MAT" or getType(g)≠"NUM" or getType(cm)≠"NUM" or getType(tol)≠"NUM" Then
: Return undef
:EndIf
:colDim(h)→w
:If g<1 or g≠rowDim(h) or w<g or tol≤0 Then
: Return undef
:EndIf
:If cm≠0 and cm≠1 Then
: Return undef
:EndIf
:w-cm→lastcol
:If lastcol<g Then
: Return undef
:EndIf
:0→infz
:If getType(mask)="MAT" Then
: If rowDim(mask)≠g or colDim(mask)≠w Then
:  Return undef
: EndIf
: mask→used
:ElseIf getType(mask)="NUM" Then
: If mask≠0 Then
:  Return undef
: EndIf
: 1→infz
: newMat(g,w)→used
:Else
: Return undef
:EndIf
:newMat(g,g)→b
:For i,1,g
: For j,1,w
:  h[i,j]→hv
:  If getType(hv)≠"NUM" Then
:   Return undef
:  EndIf
:  If infz=1 Then
:   If hv≠0 Then
:    1→used[i,j]
:   EndIf
:  Else
:   used[i,j]→mv
:   If getType(mv)≠"NUM" Then
:    Return undef
:   EndIf
:   If mv≠0 and mv≠1 Then
:    Return undef
:   EndIf
:   If mv=0 and hv≠0 Then
:    Return undef
:   EndIf
:  EndIf
:  If j≤g Then
:   hv→b[i,j]
:  EndIf
: EndFor
: If b[i,i]=0 Then
:  Return undef
: EndIf
:EndFor
:g+1→last
:newMat(last,6)→out
:newList(lastcol)→ex
:For i,1,g
: 0→kex
: −1→nrhs
: 0→ne
: For j,1,lastcol
:  If used[i,j]=0 Then
:   ne+1→ne
:   j→ex[ne]
:   If j>g Then
:    kex+1→kex
:   EndIf
:  ElseIf j≤g Then
:   nrhs+1→nrhs
:  EndIf
: EndFor
: 0→r
: If g>1 and ne>0 Then
:  newMat(g-1,ne)→m
:  For k,1,g-1
:   k→src
:   If k≥i Then
:    k+1→src
:   EndIf
:   For j,1,ne
:    h[src,ex[j]]→m[k,j]
:   EndFor
:  EndFor
:  mrank(m,tol)→r
: EndIf
: kex-nrhs→gap
: If gap<0 Then
:  −1→code
:  out[last,1]+1→out[last,1]
: ElseIf r<g-1 Then
:  −2→code
:  out[last,2]+1→out[last,2]
: ElseIf gap=0 Then
:  0→code
:  out[last,3]+1→out[last,3]
: Else
:  1→code
:  out[last,4]+1→out[last,4]
: EndIf
: kex→out[i,1]
: nrhs→out[i,2]
: gap→out[i,3]
: r→out[i,4]
: g-1→out[i,5]
: code→out[i,6]
:EndFor
:mrank(b,tol)→rb
:rb→out[last,5]
:If rb<g Then
: −1→out[last,6]
:ElseIf out[last,1]+out[last,2]=0 Then
: 1→out[last,6]
:EndIf
:Return out
:EndFunc""",
    ),
    "tsls": (
        "y,x,z",
        """Func
:Local n,p,l,zz,xh,q,b
:rowDim(y)→n
:colDim(x)→p
:colDim(z)→l
:If colDim(y)≠1 Then
:Return "ERR: y must be n*1"
:EndIf
:If rowDim(x)≠n or rowDim(z)≠n Then
:Return "ERR: row mismatch"
:EndIf
:If l<p Then
:Return "ERR: too few instruments"
:EndIf
:z\uf002*z→zz
:z*zz^(−1)*z\uf002*x→xh
:xh\uf002*xh→q
:q^(−1)*xh\uf002*y→b
:Return b
:EndFunc""",
    ),
    "tslsfull": (
        "y,x,z",
        """Func
:Local n,p,l,zz,xh,q,b,e,s2,v,out,i
:rowDim(y)→n
:colDim(x)→p
:colDim(z)→l
:If colDim(y)≠1 Then
:Return "ERR: y must be n*1"
:EndIf
:If rowDim(x)≠n or rowDim(z)≠n Then
:Return "ERR: row mismatch"
:EndIf
:If l<p Then
:Return "ERR: too few instruments"
:EndIf
:If n≤p Then
:Return "ERR: no residual df"
:EndIf
:z\uf002*z→zz
:z*zz^(−1)*z\uf002*x→xh
:xh\uf002*xh→q
:q^(−1)*xh\uf002*y→b
:y-x*b→e
:(e\uf002*e)[1,1]/(n-p)→s2
:s2*q^(−1)→v
:newMat(p,3)→out
:For i,1,p
:b[i,1]→out[i,1]
:sqrt(v[i,i])→out[i,2]
:b[i,1]/out[i,2]→out[i,3]
:EndFor
:Return out
:EndFunc""",
    ),
    "firststg": (
        "x,z",
        """Func
:If rowDim(x)≠rowDim(z) Then
:Return "ERR: row mismatch"
:EndIf
:Return z*(z\uf002*z)^(−1)*z\uf002*x
:EndFunc""",
    ),
}
