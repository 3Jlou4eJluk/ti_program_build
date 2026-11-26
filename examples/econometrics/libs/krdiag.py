"""TI-BASIC sources for the econometrics diagnostics library."""

FUNCTIONS = {
    "version": (
        "",
        """Func
:Return "1.0.0"
:EndFunc""",
    ),
    "jcond": (
        "xv,ev,p,tol",
        """Func
:Local nr,nc,i,j,sp,px,me,ve,out
:If getType(xv)≠"LIST" or getType(ev)≠"LIST" or getType(p)≠"MAT" or getType(tol)≠"NUM" Then
: Return undef
:EndIf
:dim(ev)→nr
:dim(xv)→nc
:If nr<1 or nc<1 or rowDim(p)≠nc or colDim(p)≠nr or tol<0 Then
: Return undef
:EndIf
:0→sp
:For j,1,nc
: For i,1,nr
:  If p[j,i]<0 Then
:   Return undef
:  EndIf
:  sp+p[j,i]→sp
: EndFor
:EndFor
:If sp≤tol Then
: Return undef
:EndIf
:newMat(nc,4)→out
:For j,1,nc
: 0→px
: 0→me
: For i,1,nr
:  px+p[j,i]→px
:  me+ev[i]*p[j,i]→me
: EndFor
: xv[j]→out[j,1]
: px/sp→out[j,2]
: If px>0 Then
:  me/px→me
:  0→ve
:  For i,1,nr
:   ve+(ev[i]-me)^2*p[j,i]→ve
:  EndFor
:  me→out[j,3]
:  ve/px→out[j,4]
: Else
:  0→out[j,3]
:  0→out[j,4]
: EndIf
:EndFor
:Return out
:EndFunc""",
    ),
    "jvar": (
        "xv,ev,p,tol",
        """Func
:Local tab,i,px,em,wm,bv,wv,vmin,vmax,npos,hm,mz
:If getType(tol)≠"NUM" Then
: Return undef
:EndIf
:If tol<0 Then
: Return undef
:EndIf
:jcond(xv,ev,p,0)→tab
:If getType(tab)≠"MAT" Then
: Return undef
:EndIf
:0→em
:0→wv
:0→npos
:0→vmin
:0→vmax
:1→mz
:For i,1,rowDim(tab)
: tab[i,2]→px
: If px>0 Then
:  tab[i,3]→wm
:  em+px*wm→em
:  wv+px*tab[i,4]→wv
:  If npos=0 Then
:   tab[i,4]→vmin
:   tab[i,4]→vmax
:  Else
:   min(vmin,tab[i,4])→vmin
:   max(vmax,tab[i,4])→vmax
:  EndIf
:  npos+1→npos
:  If abs(wm)>tol Then
:   0→mz
:  EndIf
: EndIf
:EndFor
:0→bv
:For i,1,rowDim(tab)
: If tab[i,2]>0 Then
:  bv+tab[i,2]*(tab[i,3]-em)^2→bv
: EndIf
:EndFor
:0→hm
:If vmax-vmin>tol Then
: 1→hm
:EndIf
:Return {wv+bv,wv,bv,vmin,vmax,hm,mz}
:EndFunc""",
    ),
    "jmom": (
        "xv,ev,p,tol",
        """Func
:Local nr,nc,i,j,sp,mx,me,ex2,ee2,exe,vx,ve,cv,px,cme,cve,vmin,vmax,got
:If getType(xv)≠"LIST" or getType(ev)≠"LIST" or getType(p)≠"MAT" or getType(tol)≠"NUM" Then
: Return undef
:EndIf
:dim(ev)→nr
:dim(xv)→nc
:If nr<1 or nc<1 or rowDim(p)≠nc or colDim(p)≠nr or tol<0 Then
: Return undef
:EndIf
:0→sp
:0→mx
:0→me
:0→ex2
:0→ee2
:0→exe
:For j,1,nc
: For i,1,nr
:  If p[j,i]<0 Then
:   Return undef
:  EndIf
:  sp+p[j,i]→sp
:  mx+xv[j]*p[j,i]→mx
:  me+ev[i]*p[j,i]→me
:  ex2+xv[j]^2*p[j,i]→ex2
:  ee2+ev[i]^2*p[j,i]→ee2
:  exe+xv[j]*ev[i]*p[j,i]→exe
: EndFor
:EndFor
:If sp≤tol Then
: Return undef
:EndIf
:mx/sp→mx
:me/sp→me
:ex2/sp-mx^2→vx
:ee2/sp-me^2→ve
:exe/sp-mx*me→cv
:0→got
:For j,1,nc
: 0→px
: 0→cme
: For i,1,nr
:  px+p[j,i]→px
:  cme+ev[i]*p[j,i]→cme
: EndFor
: If px>0 Then
:  cme/px→cme
:  0→cve
:  For i,1,nr
:   cve+(ev[i]-cme)^2*p[j,i]→cve
:  EndFor
:  cve/px→cve
:  If got=0 Then
:   cve→vmin
:   cve→vmax
:   1→got
:  Else
:   If cve<vmin Then
:    cve→vmin
:   EndIf
:   If cve>vmax Then
:    cve→vmax
:   EndIf
:  EndIf
: EndIf
:EndFor
:Return {sp,mx,me,vx,ve,cv,exe/sp,vmin,vmax}
:EndFunc""",
    ),
    "biases": (
        "xv,ev,p,tol",
        """Func
:Local nr,nc,i,j,sp,mx,me,ex2,exe,vx,cv,b0,bc
:If getType(xv)≠"LIST" or getType(ev)≠"LIST" or getType(p)≠"MAT" or getType(tol)≠"NUM" Then
: Return undef
:EndIf
:dim(ev)→nr
:dim(xv)→nc
:If nr<1 or nc<1 or rowDim(p)≠nc or colDim(p)≠nr or tol<0 Then
: Return undef
:EndIf
:0→sp
:0→mx
:0→me
:0→ex2
:0→exe
:For j,1,nc
: For i,1,nr
:  If p[j,i]<0 Then
:   Return undef
:  EndIf
:  sp+p[j,i]→sp
:  mx+xv[j]*p[j,i]→mx
:  me+ev[i]*p[j,i]→me
:  ex2+xv[j]^2*p[j,i]→ex2
:  exe+xv[j]*ev[i]*p[j,i]→exe
: EndFor
:EndFor
:If sp≤tol Then
: Return undef
:EndIf
:mx/sp→mx
:me/sp→me
:ex2/sp→ex2
:exe/sp→exe
:ex2-mx^2→vx
:exe-mx*me→cv
:If abs(ex2)≤tol Then
: Return undef
:EndIf
:exe/ex2→b0
:If abs(vx)≤tol Then
: Return {b0,undef}
:EndIf
:cv/vx→bc
:Return {b0,bc}
:EndFunc""",
    ),
    "runs": (
        "e,tol",
        """Func
:Local i,s,last,np,nm,r,n,mu,vr,z,nz
:If getType(e)≠"LIST" or getType(tol)≠"NUM" Then
: Return undef
:EndIf
:If dim(e)<1 or tol<0 Then
: Return undef
:EndIf
:0→last
:0→np
:0→nm
:0→r
:0→nz
:For i,1,dim(e)
: If e[i]>tol Then
:  1→s
:  np+1→np
: ElseIf e[i]<−tol Then
:  −1→s
:  nm+1→nm
: Else
:  0→s
:  nz+1→nz
: EndIf
: If s≠0 Then
:  If last=0 or s≠last Then
:   r+1→r
:  EndIf
:  s→last
: EndIf
:EndFor
:np+nm→n
:If np=0 or nm=0 or n<2 Then
: Return {np,nm,r,undef,undef,undef,nz}
:EndIf
:1+2*np*nm/n→mu
:2*np*nm*(2*np*nm-n)/(n^2*(n-1))→vr
:If vr≤0 Then
: Return {np,nm,r,mu,vr,undef,nz}
:EndIf
:(r-mu)/sqrt(vr)→z
:Return {np,nm,r,mu,vr,z,nz}
:EndFunc""",
    ),
    # Use masses relative to P(R=2) and add both tails directly.
    "rexact": (
        "e,alpha,tol",
        """Func
:Local a,np,nm,n,r,k,rr,pe,po,pl,ph,pt,p2,d
:If getType(alpha)≠"NUM" Then
: Return undef
:EndIf
:If alpha≤0 or alpha≥1 Then
: Return undef
:EndIf
:runs(e,tol)→a
:If getType(a)≠"LIST" Then
: Return undef
:EndIf
:a[1]→np
:a[2]→nm
:np+nm→n
:a[3]→r
:If np=0 or nm=0 or n>200 Then
: Return undef
:EndIf
:1→pe
:0→pl
:0→ph
:0→pt
:For k,1,min(np,nm)
: 2*k→rr
: pe*(n-rr)/rr→po
: pt+pe+po→pt
: If rr≤r Then
:  pl+pe→pl
: EndIf
: If rr+1≤r Then
:  pl+po→pl
: EndIf
: If rr≥r Then
:  ph+pe→ph
: EndIf
: If rr+1≥r Then
:  ph+po→ph
: EndIf
: pe*(np-k)*(nm-k)/k^2→pe
:EndFor
:pl/pt→pl
:ph/pt→ph
:min(1,2*min(pl,ph))→p2
:0→d
:If p2≤alpha Then
: If pl<ph Then
:  −1→d
: Else
:  1→d
: EndIf
:EndIf
:Return {np,nm,r,pl,ph,p2,d,a[7]}
:EndFunc""",
    ),
    "rdecision": (
        "e,k1,k2,tol",
        """Func
:Local a,r
:If getType(e)≠"LIST" or getType(k1)≠"NUM" or getType(k2)≠"NUM" or getType(tol)≠"NUM" Then
: Return undef
:EndIf
:If dim(e)<1 or tol<0 or k1≥k2 Then
: Return undef
:EndIf
:runs(e,tol)→a
:If getType(a)≠"LIST" Then
: Return undef
:EndIf
:If a[1]=0 or a[2]=0 Then
: Return undef
:EndIf
:a[3]→r
:If r≤k1 Then
: Return −1
:EndIf
:If r≥k2 Then
: Return 1
:EndIf
:Return 0
:EndFunc""",
    ),
    "white": (
        "n,r2,m,crit",
        """Func
:Local lm,rej
:If getType(n)≠"NUM" or getType(r2)≠"NUM" or getType(m)≠"NUM" or getType(crit)≠"NUM" Then
: Return undef
:EndIf
:If n≤0 or r2<0 or r2>1 or m<1 or crit≤0 Then
: Return undef
:EndIf
:n*r2→lm
:0→rej
:If lm>crit Then
: 1→rej
:EndIf
:Return {lm,m,rej}
:EndFunc""",
    ),
    "dfstat": (
        "rho,se",
        """Func
:If getType(rho)≠"NUM" or getType(se)≠"NUM" Then
: Return undef
:EndIf
:If se≤0 Then
: Return undef
:EndIf
:Return (rho-1)/se
:EndFunc""",
    ),
    "adftest": (
        "gamma,se,crit",
        """Func
:Local tau,rej
:If getType(gamma)≠"NUM" or getType(se)≠"NUM" or getType(crit)≠"NUM" Then
: Return undef
:EndIf
:If se≤0 or crit≥0 Then
: Return undef
:EndIf
:gamma/se→tau
:0→rej
:If tau<crit Then
: 1→rej
:EndIf
:Return {tau,rej}
:EndFunc""",
    ),
}
