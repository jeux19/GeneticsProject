function [time, gen, best, av_best] = run_ga_benchmark_performance(x, y, NIND, MAXGEN, NVAR, ELITIST, PR_CROSS, PR_MUT, CROSSOVER, MUTATION, LOCALLOOP, CROWDING, MAX_TIME, OBJECTIVE)
% usage: run_ga(x, y, 
%               NIND, MAXGEN, NVAR, 
%               ELITIST, STOP_PERCENTAGE, 
%               PR_CROSS, PR_MUT, CROSSOVER)
%               
%
%
% x, y: coordinates of the cities
% NIND: number of individuals
% MAXGEN: maximal number of generations
% ELITIST: percentage of elite population
% STOP_PERCENTAGE: percentage of equal fitness (stop criterium)
% PR_CROSS: probability for crossover
% PR_MUT: probability for mutation
% CROSSOVER: the crossover operator
% STOP_EPOCHS: number of epochs to stop if the best fitness does not improve
% LOCALLOOP: name of the improvement function (or "" if none)
% CROWDING: determines if deterministic crowding will be used. if
% activated, deactivates ELITISM
% calculate distance matrix between each pair of cities
% MAXTIME: the maximum time the algorithm may run. If 0, infinite
% MEASURE_DIST: wether we must measure the distance among paths or not
%{NIND MAXGEN NVAR ELITIST STOP_PERCENTAGE PR_CROSS PR_MUT CROSSOVER LOCALLOOP}

    if CROWDING
        ELITIST = 0;
    end
    GGAP = 1 - ELITIST;
    % dist has the values of the distances between cities
    Dist=zeros(NVAR,NVAR);
    for i=1:size(x,1)
        for j=1:size(y,1)
            Dist(i,j)=sqrt((x(i)-x(j))^2+(y(i)-y(j))^2);
        end
    end
    % initialize population
    Chrom=zeros(NIND,NVAR);
    for row=1:NIND
        Chrom(row,:)=randperm(NVAR);
    end
    gen=0;
    % evaluate initial population
    ObjV = tspfun_path(Chrom,Dist);
    best=NaN(1,MAXGEN);

    
    tic
    stop = 0;

    % generational loop
    while stop ~= 1
        
        %sObjV=sort(ObjV);
        best(gen+1)=min(ObjV);
     
        %assign fitness values to entire population
        FitnV=ranking(ObjV);
        %select individuals for breeding
        if CROWDING
            Parents = select_mix(Chrom);
        else
            Parents=select('sus', Chrom, FitnV, GGAP);
        end
        %recombine individuals (crossover)
        SelCh = recombin_path(CROSSOVER,Parents,PR_CROSS,Dist);
        %mutate individuals
        SelCh=mutateTSP(MUTATION,SelCh,PR_MUT);
        %evaluate offspring, call objective function
        ObjVSel = tspfun_path(SelCh,Dist);
        if nnz(~ObjVSel)
            fprintf('something went really bad\n');      
        end
        %reinsert offspring into population
        if CROWDING
            ParentsV = tspfun_path(Parents,Dist);
            [Chrom, ObjV] = crowding(Parents, SelCh, ParentsV, ObjVSel);
        else
            [Chrom, ObjV]=reins(Chrom,SelCh,1,1,ObjV,ObjVSel);
        end
      
        Chrom = tsp_ImprovePopulation_path(NIND, ObjV, Chrom,LOCALLOOP,Dist);
        
        %increment generation counter
        gen=gen+1; 

        time = toc;
        if MAX_TIME > 0 && toc > MAX_TIME
            stop = 1;
        end
        best_fitness = min(best);
        if best_fitness <= OBJECTIVE
            stop = 1;
        end
        
    end
    
    av_best = mean(ObjV);

end
