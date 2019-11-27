function test_stop(x,y,NVAR,dataset_file,test_table,STOP_CRIT)
    %myFun - Description
    %
    % Syntax: output = myFun(input)
    %   test_table =parameter combinations to test the stopping criterion i
    % Long description
    

    %%Fixed parameters 
    MAXGEN=100;% Maximum no. of generations
    LOCALLOOP = 0;    %%Quitar local loop
    N_EXPERIMENTS = 20;

  
    %%Name of the file to save table from experiment i
    [ ~,filename, ~]=fileparts(dataset_file);
    table_path=['Results/Results_stop' filename '.csv'];
    
    eff_path=sprintf("Results/Eff_stop_str%s.mat", filename);
    
    
    %%Structure to save efficiency curves
    Eff_structure=struct;
    Eff_vector_1=zeros(N_EXPERIMENTS,MAXGEN);
    Eff_vector_2=zeros(N_EXPERIMENTS,MAXGEN);
    Best_vector=zeros(1,N_EXPERIMENTS);
    
    %%Read table with parameter combinations
    %%Read the normalised table and extract the parameter to perform anova
    table_path= ['Results/' test_table];
    assert(isfile(table_path),"Wrong table path");
    par_comb=readtable(table_path);

    %%Table
    Initialization=zeros(1,7);
    Results = array2table(Initialization,'VariableNames',{'Test_id',...
                            'Av_Best_eq','Av_Best_eff','Av_Best_div','Last_eq','Last_eff','Last_div'});
    %%Performing Tests
    for i=1:length(par_table)
        %%Loading parameter combination i from structure par_comb
        NIND=par_comb.NIND(i);
        ELITIST=par_comb.ELITIST(i);
        PR_CROSS=par_comb.NIND(i);
        PR_MUT=par_comb.NIND(i);
        %%Performing n set of equal experiments
        for n=1:N_EXPERIMENTS
            [Best_vector(n), best,last_gen(n),best_stop(n)] = run_ga_return(x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, LOCALLOOP, STOP_EPOCHS,STOP_CRIT);
            [Eff_vector_1(n,:),Eff_vector_2(n,:)]=get_efficiency(best,NIND);

        end

        %%Updating table
        Results.Test_id(i)=i;
        Results.Last_eq(i)=mean(last_gen(1));
        Results.Av_Best_eq(i)=mean(best_stop(1));  
        Results.Last_eff(i)=mean(last_gen(2));
        Results.Av_Best_eff(i)=mean(best_stop(2));
        Results.Last_div(i)=mean(last_gen(3));
        Results.Av_Best_div(i)=mean(best_stop(3)); 
        %%Computing Av.results
        Av_Best=mean(Best_vector);
        Peak_Best=min(Best_vector); %The lower the fitness, the better
        Best_vector_inv=1./(Best_vector); %%Transforming fitness
        Fit_var=var(Best_vector_inv);
        Eff_vector_final_1=mean(Eff_vector_1); %%Final gr. efficiency haciendo av. efficiency de cada experimento
        Eff_vector_final_2=mean(Eff_vector_2); %%Final gr. efficiency haciendo av. efficiency de cada experimento
        %%Saving curvas efficiency
        Eff_structure.curve_1{cont}=Eff_vector_final_1;
        Eff_structure.curve_2{cont}=Eff_vector_final_2;

        % %%Updating Results Table
        % Results.NIND(cont)=NIND;
        % Results.ELITIST(cont)=ELITIST;
        % Results.PR_CROSS(cont)=PR_CROSS;
        % Results.PR_MUT(cont)=PR_MUT;
        % Results.Av_Best(cont)=Av_Best;
        % Results.Peak_Best(cont)=Peak_Best; %%Me olvidaria del peak best
        % Results.Fit_var(cont)=Fit_var;
        % Results.Eff_1(cont)=sum(Eff_vector_final_1); %%Area bajo la curva eff1

        fprintf("Finished iter no. %d , %d iter remaining \n",(i,length(par_table)))
    end


    %%Saving Table to file
    writetable(Results,table_path)
    %%Saving efficiency curves
    save(eff_path,'Eff_structure')
    end
    