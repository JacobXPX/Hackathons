k = 5;
ktype = 'l';
kparam = 2;
C = 2;
lambda = 0.002;
traindata = csvread('ABMD_pmood_3yr.csv')-csvread('ABMD_nmood_3yr.csv');
trainprice = csvread('ABMD_price_3yr.csv');
% siz = size(traindata);
preX = [traindata(1:end,2)';trainprice(1:end,2)'];
pX=zeros(2*k,size(preX,2)-k);
for i = 1:size(pX,2)
    pX(:,i) = [preX(1,i:i+k-1)';preX(2,i:i+k-1)'];
end
trainprice = trainprice(k:end,:);
trainreturn = trainprice(2:end,2)./trainprice(1:end-1,2);
pY = (trainreturn'<1)*1.0;
pY(pY ==0) =-1;
X = pX(:,1:650);
Y = pY(:,1:650);
T = size(X,2);
n = size(X,1);
A = -[X',ones(T,1),eye(T);-X',-ones(T,1),eye(T)];
Q = blkdiag(lambda*eye(n),zeros(T+1));
c = [zeros(n+1,1);ones(T,1)]/500;
b = [-Y'*1.00;Y'*1.00];
lb = [-inf;-inf;-inf;zeros(T,1)];
ub = [ones(n+1+T,1)*inf];
sol = svm(X,Y',C,ktype,kparam)
% [sol,v] = quadprog(Q,c,A,b,[],[],lb,ub);
% disp(sol(1:3))
% disp(v)
%================================================
alpha = sol{1};
b = sol{2};
supvec = sol{3};
ay = sol{4};
Xt = pX(:,651:end);
Yt = pY(:,651:end);
func_pred = @(x) ay'*kernel(X,x,ktype,kparam)+b;
pret = [];
for i = 1:size(Xt,2)
    pret = [pret, func_pred(Xt(:,i))];
end
epsilon = (-Yt).*pret+1;
hingeloss = max(0,epsilon);
hingelosssum = sum(hingeloss);
binloss = (sign(pret)~=Yt);
binlosssum = sum(binloss);
accuracy = (1-binlosssum/size(Xt,2))*100
sensitivity = 100*sum(sign(pret)==1 & Yt ==1)/sum(Yt ==1)
result = [hingelosssum binlosssum accuracy sensitivity];
