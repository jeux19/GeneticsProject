
%%Parameters definitions
% % NIND=50;		% Number of individuals
% MAXGEN=100;		% Maximum no. of generations
% NVAR=26;		% No. of variables
% % ELITIST=0.05;    % percentage of the elite population
% % GGAP=1-ELITIST;		% Generation gap
% STOP_PERCENTAGE=.95;    % percentage of equal fitness individuals for stopping
% % PR_CROSS=.95;     % probability of crossover
% % PR_MUT=.05;       % probability of mutation
% % LOCALLOOP=0;      % local loop removal
% CROSSOVER = 'xalt_edges';  % default crossover operator

%%Loading all datasets
datasets=load_datasets;

%Getting the tables for each dataset
for index = 1:5
    x,y,NVAR=load_data(index); %%Getting Dataset (Index) to perform test
    perform_tests(x,y,NVAR,index);
end