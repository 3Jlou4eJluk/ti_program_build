FUNCTIONS = {
    "version": (
        "",
        """Func
:Return "1.0.0"
:EndFunc""",
    ),
    "steparea": (
        "edges,levels",
        """Func
:Local m,j,v,edge,prev,area
:If getType(edges)≠"LIST" or getType(levels)≠"LIST" Then
:Return "ERR: use two lists"
:EndIf
:dim(levels)→m
:If m<1 or dim(edges)≠m+1 Then
:Return "ERR: m heights, m+1 edges"
:EndIf
:If edges[1]≠0 or edges[m+1]≠1 Then
:Return "ERR: FPR must span 0 to 1"
:EndIf
:0→area
:0→prev
:For j,1,m
:levels[j]→v
:edges[j+1]→edge
:If getType(v)≠"NUM" or getType(edge)≠"NUM" Then
:Return "ERR: nonnumeric ROC data"
:EndIf
:If v<prev or v>1 or edges[j+1]≤edges[j] Then
:Return "ERR: invalid ROC steps"
:EndIf
:area+(edges[j+1]-edges[j])*v→area
:v→prev
:EndFor
:Return {area,2*area-1}
:EndFunc""",
    ),
    "groupauc": (
        "pos,neg",
        """Func
:Local n,j,np,nn,pairsum,pc,nc
:If getType(pos)≠"LIST" or getType(neg)≠"LIST" Then
:Return "ERR: use two count lists"
:EndIf
:dim(pos)→n
:If n<1 or dim(neg)≠n Then
:Return "ERR: count list sizes"
:EndIf
:0→np
:0→nn
:0→pairsum
:For j,n,1,−1
:pos[j]→pc
:neg[j]→nc
:If getType(pc)≠"NUM" or getType(nc)≠"NUM" Then
:Return "ERR: counts must be numeric"
:EndIf
:If pc<0 or nc<0 or int(pc)≠pc or int(nc)≠nc Then
:Return "ERR: use whole counts >=0"
:EndIf
:pairsum+pc*(nn+nc/2)→pairsum
:np+pc→np
:nn+nc→nn
:EndFor
:If np=0 or nn=0 Then
:Return "ERR: need both classes"
:EndIf
:pairsum/(np*nn)→pairsum
:Return {pairsum,2*pairsum-1}
:EndFunc""",
    ),
    "cutoff": (
        "y,scores,cfp,cfn",
        """Func
:Local pts,row,best,loss,low,np,nn,strict
:If cfp<0 or cfn<0 or cfp+cfn≤0 Then
:Return "ERR: bad costs"
:EndIf
:roc(y,scores)→pts
:If getType(pts)="STR" Then
:Return pts
:EndIf
:sum(y)→np
:dim(y)-np→nn
:1→best
:np*cfn→low
:For row,2,rowDim(pts)
:cfp*round(nn*pts[row,1])+cfn*(np-round(np*pts[row,2]))→loss
:If loss<low Then
:row→best
:loss→low
:EndIf
:EndFor
:0→strict
:If best=1 Then
:1→strict
:EndIf
:Return {pts[best,3],strict,pts[best,1],pts[best,2],low}
:EndFunc""",
    ),
    "auc": (
        "fpr,tpr",
        """Func
:Local n,j,fx,tx,lastf,lastt,area
:If getType(fpr)≠"LIST" or getType(tpr)≠"LIST" Then
:Return "ERR: use FPR and TPR lists"
:EndIf
:dim(fpr)→n
:If n<2 or n≠dim(tpr) Then
:Return "ERR: need paired ROC points"
:EndIf
:0→lastf
:0→lastt
:0→area
:For j,1,n
:fpr[j]→fx
:tpr[j]→tx
:If getType(fx)≠"NUM" or getType(tx)≠"NUM" Then
:Return "ERR: ROC coordinates must be numbers"
:EndIf
:If fx<0 or fx>1 or tx<0 or tx>1 Then
:Return "ERR: ROC coordinates outside [0,1]"
:EndIf
:If j=1 and (fx≠0 or tx≠0) Then
:Return "ERR: ROC must start at (0,0)"
:EndIf
:If fx<lastf or tx<lastt Then
:Return "ERR: ROC coordinates must not decrease"
:EndIf
:area+(fx-lastf)*(tx+lastt)/2→area
:fx→lastf
:tx→lastt
:EndFor
:If lastf≠1 or lastt≠1 Then
:Return "ERR: ROC must end at (1,1)"
:EndIf
:Return area
:EndFunc""",
    ),
    "gini": (
        "fpr,tpr",
        """Func
:Local area
:auc(fpr,tpr)→area
:If getType(area)="STR" Then
:Return area
:EndIf
:Return 2*area-1
:EndFunc""",
    ),
    "roc": (
        "y,scores",
        """Func
:Local n,i,j,gap,truth,vals,lab,score,pos,neg,rows,out,r,cut,fp,tp
:If getType(y)≠"LIST" or getType(scores)≠"LIST" Then
:Return "ERR: use label and score lists"
:EndIf
:dim(y)→n
:If n<2 or n≠dim(scores) Then
:Return "ERR: need paired labels and scores"
:EndIf
:0→pos
:For j,1,n
:y[j]→lab
:scores[j]→score
:If getType(lab)≠"NUM" Then
:Return "ERR: labels must be 0 or 1"
:EndIf
:If lab≠0 and lab≠1 Then
:Return "ERR: labels must be 0 or 1"
:EndIf
:If getType(score)≠"NUM" Then
:Return "ERR: scores must be finite real numbers"
:EndIf
:pos+lab→pos
:EndFor
:n-pos→neg
:If pos=0 or neg=0 Then
:Return "ERR: need both classes"
:EndIf
:y→truth
:scores→vals
:int(n/2)→gap
:While gap>0
:For i,gap+1,n
:vals[i]→score
:truth[i]→lab
:i→j
:While j>gap
:If vals[j-gap]≥score Then
:Exit
:EndIf
:vals[j-gap]→vals[j]
:truth[j-gap]→truth[j]
:j-gap→j
:EndWhile
:score→vals[j]
:lab→truth[j]
:EndFor
:int(gap/2)→gap
:EndWhile
:2→rows
:For j,2,n
:If vals[j]≠vals[j-1] Then
:rows+1→rows
:EndIf
:EndFor
:newMat(rows,3)→out
:vals[1]→out[1,3]
:1→j
:0→fp
:0→tp
:For r,2,rows
:vals[j]→cut
:While j≤n
:If vals[j]≠cut Then
:Exit
:EndIf
:fp+1-truth[j]→fp
:tp+truth[j]→tp
:j+1→j
:EndWhile
:fp/neg→out[r,1]
:tp/pos→out[r,2]
:cut→out[r,3]
:EndFor
:Return out
:EndFunc""",
    ),
    "aucpred": (
        "y,scores",
        """Func
:Local pts,j,n,fpr,tpr
:roc(y,scores)→pts
:If getType(pts)="STR" Then
:Return pts
:EndIf
:rowDim(pts)→n
:newList(n)→fpr
:newList(n)→tpr
:For j,1,n
:pts[j,1]→fpr[j]
:pts[j,2]→tpr[j]
:EndFor
:Return auc(fpr,tpr)
:EndFunc""",
    ),
    "ginipred": (
        "y,scores",
        """Func
:Local area
:aucpred(y,scores)→area
:If getType(area)="STR" Then
:Return area
:EndIf
:Return 2*area-1
:EndFunc""",
    ),
}
