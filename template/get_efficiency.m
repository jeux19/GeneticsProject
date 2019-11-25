function Eff= get_efficiency(test_run,NIND)
%myFun - Description
%
% Syntax: output = myFun(input)
%   Eff=Efficiency metric 
% Long description

%%Transform fitness into maximization fitness (each fitness f_i is trasnformed into 1/(f_i))
test_run_transf=1./test_run;
Eff=zeros(1,length(test_run));
timesteps=length(test_run);

for t = 1:timesteps
    sub_run=test_run_transf(1:t);
    Eff(t)=((t*NIND)^-1)*max(sub_run);
end

    
end