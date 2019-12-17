function [best_fitness, best, improvement, standd_mean, average_distance, average_numequals] = run_ga_return_path(x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, MUTATION, LOCALLOOP, STOP_EPOCHS, CROWDING)
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
%
%{NIND MAXGEN NVAR ELITIST STOP_PERCENTAGE PR_CROSS PR_MUT CROSSOVER LOCALLOOP}

    if CROWDING
        ELITIST = 0;
    end
    GGAP = 1 - ELITIST;
    mean_fits=zeros(1,MAXGEN+1);
    worst=zeros(1,MAXGEN+1);
    improvement=zeros(1,MAXGEN);
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
    % number of individuals of equal fitness needed to stop
    stopN=ceil(STOP_PERCENTAGE*NIND);
    % evaluate initial population
    ObjV = tspfun_path(Chrom,Dist);
    best=NaN(1,MAXGEN);
    standd =NaN(1,MAXGEN);
    average_distance_vector = NaN(1,MAXGEN);
    numEquals = NaN(1,MAXGEN);
    % counter of epochs without chenge in the fittest
    change_cont = 0;
    
    % generational loop
    while gen<MAXGEN
        
        %sObjV=sort(ObjV);
        best(gen+1)=min(ObjV);
        standd(gen+1)=std(ObjV);
        minimum=best(gen+1);
        mean_fits(gen+1)=mean(ObjV);
        worst(gen+1)=max(ObjV);
        %
        %for t=1:size(ObjV,1)
        %    if (ObjV(t)==minimum)
        %        break;
        %    end
        %end
        
        % visualizeTSP(x,y,Chrom(t,:), minimum, ah1, gen, best, mean_fits, worst, ah2, ObjV, NIND, ah3);
        %
        %if (sObjV(stopN)-sObjV(1) <= 1e-15)
        %        break;
        %end          
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
        
        %Check average distance between paths
        [average_distance_vector(gen+1), numEquals(gen+1)] = average_distance_chromosomes(Chrom); %%Erasable
        
        [Chrom, improvement(gen+1)] = tsp_ImprovePopulation_path(NIND, ObjV, Chrom,LOCALLOOP,Dist);
        %increment generation counter
        gen=gen+1;    
        
    end
    best_fitness = min(best);
    standd_mean = mean(standd);
    average_distance = mean(average_distance_vector);
    average_numequals = mean(numEquals);
end