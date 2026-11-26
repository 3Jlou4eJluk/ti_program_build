"""Numeric TI-BASIC routines for nearby econometrics exercises."""

FUNCTIONS = {
    "version": (
        "",
        """Func
:Return "1.0.0"
:EndFunc""",
    ),
    "ols": (
        "y,x",
        """Func
:Local gram
:If colDim(y)≠1 or rowDim(y)≠rowDim(x) or rowDim(x)<colDim(x) Then
: Return "ERR: OLS dimensions"
:EndIf
:x\uf002*x→gram
:If det(gram)=0 Then
: Return "ERR: rank of X"
:EndIf
:Return gram^(−1)*x\uf002*y
:EndFunc""",
    ),
    "predint": (
        "y,x,xnew,a",
        """Func
:Local b,e,sq,gram,h,point,crit,sem,sep,df
:If rowDim(xnew)≠1 or colDim(xnew)≠colDim(x) or a≤0 or a≥1 Then
:Return "ERR: use a row xnew and 0<alpha<1"
:EndIf
:rowDim(x)-colDim(x)→df
:If df≤0 Then
:Return "ERR: no residual df"
:EndIf
:ols(y,x)→b
:If getType(b)="STR" Then
:Return b
:EndIf
:y-x*b→e
:e\uf002*e→sq
:x\uf002*x→gram
:xnew*gram^(−1)*xnew\uf002→h
:xnew*b→point
:sqrt(sq[1,1]*h[1,1]/df)→sem
:sqrt(sq[1,1]*(1+h[1,1])/df)→sep
:invt(1-a/2,df)→crit
:Return {point[1,1],point[1,1]-crit*sem,point[1,1]+crit*sem,point[1,1]-crit*sep,point[1,1]+crit*sep}
:EndFunc""",
    ),
    "wald": (
        "y,x,r,target,hc",
        """Func
:Local b,v,d,sv,quad,q,df,stat
:rowDim(r)→q
:rowDim(x)-colDim(x)→df
:If colDim(r)≠colDim(x) or rowDim(target)≠q or colDim(target)≠1 or q>colDim(x) Then
:Return "ERR: R and target dimensions"
:EndIf
:ols(y,x)→b
:If getType(b)="STR" Then
:Return b
:EndIf
:vcov(x,y-x*b,hc)→v
:If getType(v)="STR" Then
:Return v
:EndIf
:r*b-target→d
:r*v*r\uf002→sv
:If det(sv)=0 Then
:Return "ERR: singular restrictions"
:EndIf
:d\uf002*sv^(−1)*d→quad
:quad[1,1]→stat
:If hc=−1 Then
:Return {stat/q,q,df,fCdf(stat/q,10^99,q,df)}
:EndIf
:Return {stat,q,0,chi2Cdf(stat,10^99,q)}
:EndFunc""",
    ),
    "lrtest": (
        "llrest,llfull,q",
        """Func
:Local stat
:If llfull<llrest or q<1 or q≠int(q) Then
:Return "ERR: likelihoods or df"
:EndIf
:2*(llfull-llrest)→stat
:Return {stat,q,chi2Cdf(stat,10^99,q)}
:EndFunc""",
    ),
    "resid": (
        "y,x",
        """Func
:Local b
:ols(y,x)→b
:If getType(b)="STR" Then
: Return b
:EndIf
:Return y-x*b
:EndFunc""",
    ),
    "olssum": (
        "y,x",
        """Func
:Local n,k,i,err,rss,avg,tss,rsq
:resid(y,x)→err
:If getType(err)="STR" Then
: Return err
:EndIf
:rowDim(x)→n
:colDim(x)→k
:0→avg
:0→rss
:For i,1,n
: If x[i,1]≠1 Then
:  Return "ERR: first column must be 1"
: EndIf
: avg+(y[i,1]-y[1,1])/n→avg
: rss+err[i,1]^2→rss
:EndFor
:If n≤k Then
: Return "ERR: no residual df"
:EndIf
:0→tss
:For i,1,n
: tss+(y[i,1]-y[1,1]-avg)^2→tss
:EndFor
:If tss=0 Then
: Return "ERR: constant response"
:EndIf
:1-rss/tss→rsq
:If rsq<(−10^(−10)) Then
: Return "ERR: ill-conditioned X"
:EndIf
:max(0,rsq)→rsq
:Return {n,k,rss,rss/(n-k),rsq,1-(1-rsq)*(n-1)/(n-k)}
:EndFunc""",
    ),
    "vcov": (
        "x,err,hc",
        """Func
:Local n,k,g,iv,rss,i,j,l,h,w,xe
:rowDim(x)→n
:colDim(x)→k
:If n≤k or rowDim(err)≠n or colDim(err)≠1 Then
: Return "ERR: covariance dimensions"
:EndIf
:If hc<(−1) or hc>3 or hc≠int(hc) Then
: Return "ERR: HC code"
:EndIf
:x\uf002*x→g
:If det(g)=0 Then
: Return "ERR: rank of X"
:EndIf
:g^(−1)→iv
:If hc=−1 Then
: err\uf002*err→rss
: Return rss[1,1]*iv/(n-k)
:EndIf
:newMat(n,k)→xe
:For i,1,n
: err[i,1]→w
: If hc≥2 Then
:  0→h
:  For j,1,k
:   For l,1,k
:    h+x[i,j]*iv[j,l]*x[i,l]→h
:   EndFor
:  EndFor
:  If 1-h≤10^(−12) Then
:   Return "ERR: leverage = 1"
:  EndIf
:  w/(1-h)^((hc-1)/2)→w
: EndIf
: For j,1,k
:  w*x[i,j]→xe[i,j]
: EndFor
:EndFor
:If hc=1 Then
: Return n/(n-k)*iv*(xe\uf002*xe)*iv
:EndIf
:Return iv*(xe\uf002*xe)*iv
:EndFunc""",
    ),
    "tstat": (
        "b,b0,se,df,a",
        """Func
:Local ts,crit
:If se≤0 or df<1 or df≠int(df) or a≤0 or a≥1 Then
: Return "ERR: SE, df or alpha"
:EndIf
:(b-b0)/se→ts
:invt(1-a/2,df)→crit
:Return {ts,2*tCdf(−(10^99),−abs(ts),df),b-crit*se,b+crit*se}
:EndFunc""",
    ),
    "olstab": (
        "y,x,hc,a",
        """Func
:Local b,v,tab,n,k,i,se,ts,crit,pv
:If a≤0 or a≥1 Then
: Return "ERR: alpha"
:EndIf
:ols(y,x)→b
:If getType(b)="STR" Then
: Return b
:EndIf
:vcov(x,y-x*b,hc)→v
:If getType(v)="STR" Then
: Return v
:EndIf
:rowDim(x)→n
:colDim(x)→k
:If hc=−1 Then
: invt(1-a/2,n-k)→crit
:Else
: invNorm(1-a/2,0,1)→crit
:EndIf
:newMat(k,6)→tab
:For i,1,k
: If v[i,i]≤0 Then
:  Return "ERR: nonpositive SE variance"
: EndIf
: sqrt(v[i,i])→se
: b[i,1]/se→ts
: If hc=−1 Then
:  2*tCdf(−(10^99),−abs(ts),n-k)→pv
: Else
:  2*normCdf(−(10^99),−abs(ts),0,1)→pv
: EndIf
: b[i,1]→tab[i,1]
: se→tab[i,2]
: ts→tab[i,3]
: pv→tab[i,4]
: b[i,1]-crit*se→tab[i,5]
: b[i,1]+crit*se→tab[i,6]
:EndFor
:Return tab
:EndFunc""",
    ),
    "ftest": (
        "rr,ru,q,df",
        """Func
:Local fs
:If rr<ru or ru≤0 or q≤0 or df≤0 or q≠int(q) or df≠int(df) Then
: Return "ERR: RSS or df"
:EndIf
:(rr-ru)*df/(q*ru)→fs
:Return {fs,q,df,fCdf(fs,10^99,q,df)}
:EndFunc""",
    ),
    "firstf": (
        "endog,base,omit",
        """Func
:Local n,q,df,full,er,eu,ssr,ssu,res
:rowDim(endog)→n
:colDim(omit)→q
:If colDim(endog)≠1 or rowDim(base)≠n or rowDim(omit)≠n Then
:Return "ERR: design dimensions"
:EndIf
:augment(base,omit)→full
:n-colDim(full)→df
:If df≤0 Then
:Return "ERR: no unrestricted df"
:EndIf
:resid(endog,base)→er
:If getType(er)="STR" Then
:Return er
:EndIf
:resid(endog,full)→eu
:If getType(eu)="STR" Then
:Return eu
:EndIf
:er\uf002*er→ssr
:eu\uf002*eu→ssu
:ftest(ssr[1,1],ssu[1,1],q,df)→res
:If getType(res)="STR" Then
:Return res
:EndIf
:Return {res[1],res[2],res[3],res[4],1-ssu[1,1]/ssr[1,1]}
:EndFunc""",
    ),
    "sargan": (
        "err,z,k",
        """Func
:Local aux,q
:colDim(z)-k→q
:If k<1 or k≠int(k) or q<1 Then
:Return "ERR: need excess instruments"
:EndIf
:olssum(err,z)→aux
:If getType(aux)="STR" Then
:Return aux
:EndIf
:Return lm(rowDim(z),aux[5],q)
:EndFunc""",
    ),
    "lm": (
        "n,rsq,df",
        """Func
:Local s
:If n≤0 or df<1 or n≠int(n) or df≠int(df) or rsq<0 or rsq>1 Then
: Return "ERR: n, R2 or df"
:EndIf
:n*rsq→s
:Return {s,df,chi2Cdf(s,10^99,df)}
:EndFunc""",
    ),
    "het": (
        "y,x,kind",
        """Func
:Local err,n,k,p,i,j,l,idx,z,ss
:If kind≠0 and kind≠1 Then
: Return "ERR: kind 0 or 1"
:EndIf
:rowDim(x)→n
:colDim(x)→k
:If k≤1 Then
: Return "ERR: need regressors"
:EndIf
:k+kind*k*(k-1)/2→p
:If n≤p Then
: Return "ERR: no auxiliary df"
:EndIf
:resid(y,x)→err
:If getType(err)="STR" Then
: Return err
:EndIf
:newMat(n,p)→z
:For i,1,n
: err[i,1]^2→err[i,1]
: For j,1,k
:  x[i,j]→z[i,j]
: EndFor
: If kind=1 Then
:  k→idx
:  For j,2,k
:   For l,j,k
:    idx+1→idx
:    x[i,j]*x[i,l]→z[i,idx]
:   EndFor
:  EndFor
: EndIf
:EndFor
:olssum(err,z)→ss
:If getType(ss)="STR" Then
: Return ss
:EndIf
:Return lm(n,ss[5],p-1)
:EndFunc""",
    ),
    "dw": (
        "err",
        """Func
:Local i,num,den
:If dim(err)<2 Then
: Return "ERR: need 2 residuals"
:EndIf
:0→num
:err[1]^2→den
:For i,2,dim(err)
: num+(err[i]-err[i-1])^2→num
: den+err[i]^2→den
:EndFor
:If den=0 Then
: Return undef
:EndIf
:Return num/den
:EndFunc""",
    ),
    "bg": (
        "y,x,p",
        """Func
:Local n,k,err,z,i,j,ss
:rowDim(x)→n
:colDim(x)→k
:If p<1 or p≠int(p) or n≤k+p Then
: Return "ERR: lag count"
:EndIf
:resid(y,x)→err
:If getType(err)="STR" Then
: Return err
:EndIf
:newMat(n,k+p)→z
:For i,1,n
: For j,1,k
:  x[i,j]→z[i,j]
: EndFor
: For j,1,p
:  If i>j Then
:   err[i-j,1]→z[i,k+j]
:  EndIf
: EndFor
:EndFor
:olssum(err,z)→ss
:If getType(ss)="STR" Then
: Return ss
:EndIf
:Return lm(n,ss[5],p)
:EndFunc""",
    ),
    "adf": (
        "y,p,d",
        """Func
:Local n,k,i,j,t,dy,x,b,v,se
:If p<0 or p≠int(p) or d<0 or d>2 or d≠int(d) Then
: Return "ERR: ADF lag or trend"
:EndIf
:dim(y)-p-1→n
:1+p+d→k
:If n≤k Then
: Return "ERR: no ADF df"
:EndIf
:newMat(n,1)→dy
:newMat(n,k)→x
:For i,1,n
: i+p+1→t
: y[t]-y[t-1]→dy[i,1]
: y[t-1]→x[i,1]
: If d≥1 Then
:  1→x[i,2]
: EndIf
: If d=2 Then
:  t→x[i,3]
: EndIf
: For j,1,p
:  y[t-j]-y[t-j-1]→x[i,1+d+j]
: EndFor
:EndFor
:ols(dy,x)→b
:If getType(b)="STR" Then
: Return b
:EndIf
:vcov(x,dy-x*b,−1)→v
:If getType(v)="STR" Then
: Return v
:EndIf
:If v[1,1]≤0 Then
: Return undef
:EndIf
:sqrt(v[1,1])→se
:Return {b[1,1]/se,b[1,1],se,n}
:EndFunc""",
    ),
    "binary": (
        "y,s,c",
        """Func
:Local n,i,tp,fp,tn,fn,tpr,fpr,ppv,f1
:dim(y)→n
:If n<1 or dim(s)≠n Then
: Return "ERR: list sizes"
:EndIf
:0→tp
:0→fp
:0→tn
:0→fn
:For i,1,n
: If y[i]=1 Then
:  If s[i]≥c Then
:   tp+1→tp
:  Else
:   fn+1→fn
:  EndIf
: ElseIf y[i]=0 Then
:  If s[i]≥c Then
:   fp+1→fp
:  Else
:   tn+1→tn
:  EndIf
: Else
:  Return "ERR: labels 0 or 1"
: EndIf
:EndFor
:undef→tpr
:undef→fpr
:undef→ppv
:undef→f1
:If tp+fn>0 Then
: tp/(tp+fn)→tpr
:EndIf
:If fp+tn>0 Then
: fp/(fp+tn)→fpr
:EndIf
:If tp+fp>0 Then
: tp/(tp+fp)→ppv
:EndIf
:If 2*tp+fp+fn>0 Then
: 2*tp/(2*tp+fp+fn)→f1
:EndIf
:Return {tp,fp,tn,fn,tpr,fpr,ppv,(tp+tn)/n,f1}
:EndFunc""",
    ),
    "binprob": (
        "s,kind",
        """Func
:Local z
:If kind=0 Then
: exp(−abs(s))→z
: If s≥0 Then
:  Return 1/(1+z)
: EndIf
: Return z/(1+z)
:EndIf
:If kind=1 Then
: Return normCdf(−(10^99),s,0,1)
:EndIf
:Return "ERR: kind 0 or 1"
:EndFunc""",
    ),
}
