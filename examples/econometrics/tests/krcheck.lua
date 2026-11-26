platform.apiLevel = "2.0"
-- Numeric integration tests for the installed MyLib files, evaluated by TI OS.
local x = "[[1,-3][1,-2][1,-1][1,0][1,1][1,2][1,3]]"
local y = "[[2][1][4][3][6][8][6]]"
local xy = y..","..x
local moment = "{1,7},{-5,-1,1,5},[[0,1/4,1/4,0][0,1/4,1/4,0]],0"
local runs = "{-5,-4.5,-1.2,-3,-5,1,5.5,5,3,4,2.1,8,-1.2,-2,-1,1,1.5,2,3,-1}"
local scores = "{1,0,0,1},{.5,.5,.1,.9}"
local system = "[[1,-2,-1,0,0,0,0,-2][0,1,-1,-1,-2,-3,-4,0][-1,0,1,-2,0,0,-1,0]]"
local groups = {
 {
  {"AUC, .3", [=[krroc\auc({0,0,.3,.3,1},{0,.3,.3,1,1})]=], .79},
  {"Gini, 2/5", [=[krroc\gini({0,0,2/5,2/5,1},{0,2/5,2/5,1,1})]=], .52},
  {"ROC with ties", "(krroc\\roc("..scores.."))[3,1]", .5},
  {"Tied AUC", "krroc\\aucpred("..scores..")", .875},
  {"Tied Gini", "krroc\\ginipred("..scores..")", .75},
  {"E(error|x)", "(krdiag\\jcond("..moment.."))[1,3]", 0},
  {"Var(error)", "(krdiag\\jmom("..moment.."))[5]", 1},
  {"Slope shift", "(krdiag\\biases("..moment.."))[1]", 0},
  {"Runs observed", "(krdiag\\runs("..runs..",0))[3]", 5},
  {"Runs decision", "krdiag\\rdecision("..runs..",6,16,0)", -1},
 },
 {
  {"Order", [=[krsys\idord(0,1)]=], -1},
  {"Matrix rank", [=[krsys\mrank([[1,2][2,4]],10^(-10))]=], 1},
  {"Rank test", [=[krsys\idrank([[1,0][0,1]],2,10^(-10))]=], 1},
  {"Identification", [=[krsys\idall(1,1,[[1,0][0,1]],2,10^(-10))]=], 0},
  {"2SLS stage 1", "(krsys\\firststg("..x..","..x.."))[1,2]", -3},
  {"2SLS slope", "(krsys\\tsls("..xy..","..x.."))[2,1]", 1},
  {"2SLS SE", "(krsys\\tslsfull("..xy..","..x.."))[2,2]", .259513},
  {"White LM (R2)", [=[(krdiag\white(40,.25,5,11.07))[1]]=], 10},
  {"DF from rho", [=[krdiag\dfstat(.65,.1)]=], -3.5},
  {"ADF decision", [=[(krdiag\adftest(-.35,.1,-2.95))[2]]=], 1},
 },
 {
  {"OLS slope", "(krextra\\ols("..xy.."))[2,1]", 1},
  {"Residual", "(krextra\\resid("..xy.."))[1,1]", 5/7},
  {"R squared", "(krextra\\olssum("..xy.."))[5]", .748092},
  {"HC3 variance", "(krextra\\vcov("..x..",krextra\\resid("..xy.."),3))[2,2]", .366576^2},
  {"Student p", [=[(krextra\tstat(1,0,.259513,5,.05))[2]]=], .011960},
  {"Classic OLS CI", "(krextra\\olstab("..xy..",-1,.05))[2,5]", .332901},
  {"Robust OLS CI", "(krextra\\olstab("..xy..",3,.05))[2,5]", .281524},
  {"F tail", [=[(krextra\ftest(262/7,66/7,1,5))[4]]=], .011960},
  {"LM tail", [=[(krextra\lm(10,.2,2))[3]]=], .367879},
 },
 {
  {"White raw", "(krextra\\het("..xy..",1))[1]", 1.853104},
  {"Durbin-Watson", [=[krextra\dw({1,-1,1,-1})]=], 3},
  {"BG(1)", "(krextra\\bg("..xy..",1))[1]", 2.437425},
  {"ADF raw", [=[(krextra\adf({1,2,1,3,2,4,2,5,4,3},1,1))[1]]=], -1.099172},
  {"Binary counts", "(krextra\\binary("..scores..",.5))[8]", .75},
  {"Logit", [=[krextra\binprob(1,0)]=], .731059},
  {"Probit", [=[krextra\binprob(1,1)]=], .841345},
 },
 {
  {"Step Gini KR", [=[(krroc\steparea({0,2/5,1},{2/5,1}))[2]]=], .52},
  {"Grouped AUC", [=[(krroc\groupauc({1,1,0},{0,1,1}))[1]]=], .875},
  {"Threshold cost", "(krroc\\cutoff("..scores..",3,1))[5]", 1},
  {"All-negative threshold", [=[(krroc\cutoff({0,1},{2,1},3,1))[2]]=], 1},
  {"Predict mean low", "(krextra\\predint("..xy..",[[1,0]],.05))[2]", 2.951516},
  {"Predict obs high", "(krextra\\predint("..xy..",[[1,0]],.05))[5]", 8.059397},
  {"Wald F", "(krextra\\wald("..xy..",[[0,1]],[[0]],-1))[1]", 14.848485},
  {"Wald HC3", "(krextra\\wald("..xy..",[[0,1]],[[0]],3))[1]", 2592100/348321},
  {"LR test", [=[(krextra\lrtest(-55,-49,3))[1]]=], 12},
 },
 {
  {"First-stage F", "(krextra\\firstf("..y..",[[1][1][1][1][1][1][1]],[[-3][-2][-1][0][1][2][3]]))[1]", 14.848485},
  {"Sargan J", [=[(krextra\sargan([[-1][0][1][-1][1]],[[1,-2][1,-1][1,0][1,1][1,2]],1))[1]]=], 1.125},
  {"Runs exact p", "(krdiag\\rexact("..runs..",.05,0))[6]", 41/4199},
  {"Runs upper tail", [=[(krdiag\rexact({1,-1,1,-1,1,-1,1,-1,1,-1},.05,0))[7]]=], 1},
  {"Total variance", [=[(krdiag\jvar({1,7,9},{-2,0,2},[[1,0,1][0,0,2][0,0,0]],0))[1]]=], 3},
  {"Hetero flag", [=[(krdiag\jvar({1,7,9},{-2,0,2},[[1,0,1][0,0,2][0,0,0]],0))[6]]=], 1},
  {"System, common 1", "(krsys\\idstruct("..system..",3,1,0,10^(-10)))[2,6]", -1},
  {"System, explicit 1", "(krsys\\idstruct("..system..",3,0,0,10^(-10)))[4,6]", 1},
  {"System rank failure", [=[(krsys\idstruct([[1,1,1,0,0][0,1,0,1,2][0,0,1,2,4]],3,0,0,10^(-10)))[1,6]]=], -2},
  {"System with mask", [=[(krsys\idstruct([[1,0,1,0][.5,1,0,1]],2,0,[[1,1,1,0][1,1,0,1]],10^(-10)))[1,6]]=], 0},
 },
}
local page, results, count, passes = 1, {}, 0, 0
function on.enterKey()
    results, passes, count = {}, 0, 0
    for k,group in ipairs(groups) do
        results[k] = {}
        for i,test in ipairs(group) do
            local ok,value,err = pcall(math.eval,test[2])
            local pass = ok and type(value)=="number" and math.abs(value-test[3])<0.00001
            results[k][i] = pass and "OK" or ("FAIL "..tostring(err or value))
            count=count+1
            if pass then passes=passes+1 end
        end
    end
    platform.window:invalidate()
end
function on.arrowKey(key)
    if key=="left" then page=math.max(1,page-1) end
    if key=="right" then page=math.min(#groups,page+1) end
    platform.window:invalidate()
end
function on.paint(gc)
    gc:setFont("sansserif","b",10)
    gc:drawString(count==0 and "MyLib tests: press Enter" or ("Passed "..passes.."/"..count.."     < "..page.."/"..#groups.." >"),3,0,"top")
    gc:setFont("sansserif","r",9)
    for i,test in ipairs(groups[page]) do
        gc:drawString(test[1].."   "..(results[page] and results[page][i] or "--"),4,18+16*(i-1),"top")
    end
end
