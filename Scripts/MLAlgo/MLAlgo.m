% Fit ML model to patient apnea data using power spectra 
% Author: Joe Byrne
% Revise subsampling 

function MLAlgo(model_label, category, split, verbose) 

    if nargin <= 3;  verbose = false; end
    if nargin <= 2;   split = "POOL"; end
    if nargin == 1; category = "ALL"; end

    %% Setup
    cprintf("black*", "*%s-%s* Model\n\n", model_label, category);
    if verbose; disp("Setting Up Workspace..."); end
    
    addpath Func
        
    % Make output reproducible
    rng(42)
    
    % Get all data
    dataDir = sprintf("../../Prod/MLData/%sData%s.mat", category, split);
    data = load(dataDir).all_data;
    
    %% Data split
    
    if verbose; disp("Splitting Data..."); end
   
    if split == "PWISE"
        % Split data patient-wise
        % ----------------------- %
    else
        % Pool data split
        % ------------------- %
        % Divide into apnea/no-apnea for subsampling
        data_apnea = data(data.LABEL == 1, :);
        data_noapn = data(data.LABEL == 0, :);
        
        % Partition the data into testing and training data
        [apnea_train, apnea_test] = SubSampleSplit(data_apnea);
        [noapn_train, noapn_test] = SubSampleSplit(data_noapn);
        
        % Combine into overall data
        train = [apnea_train; noapn_train];
        train_labels = train.LABEL;
        train.LABEL = [];
        
        test  = [apnea_test; noapn_test];
        test_labels = test.LABEL;
        test.LABEL = [];
    end
    
    %% Train model
    
    if verbose; fprintf("Training Base %s Model...\n", model_label); end
    
    if model_label == "SVM"
        % Define SVM object
        model = fitcsvm(train, train_labels, 'KernelFunction', 'linear');
    elseif model_label == "RFC"
        % Define RFC object
        model = fitensemble(train, train_labels, 'Bag', 100, 'Tree', 'Type', 'classification');
    end
    
    %% Test model
    
    if verbose; disp("Cross-Validating Base Model..."); end
    
    % Cross-validate model - 10-fold
    CVModel = crossval(model, 'KFold', 10);
    
    % Retrieve percentage success rate
    f = kfoldLoss(CVModel);
    fprintf("CrossVal Success Rate:");
    cprintf("blue", " \t%.2f%%\n", 100*(1 - f));
    
    % Use model to predict on test set
    prediction = predict(model,test);
    fprintf("Matthews Correlation:");
    cprintf("blue", " \t%.2f%%\n\n", 100*MCC(prediction, test_labels));
    
    %% Shuffle test
    
    if verbose; disp("Shuffling Data for Model..."); end
    % Shuffle training labels up
    train_labels_shuff = train_labels(randperm(length(train_labels)));
    
    if verbose; fprintf("Training Shuffled %s Model...\n", model_label); end
    if model_label == "SVM"
        % Define shuffled SVM model
        model_shuf = fitcsvm(train, train_labels_shuff, 'KernelFunction', 'linear');
    elseif model_label == "RFC"
        % Define shuffled SVM model
        model_shuf = fitensemble(train, train_labels_shuff, 'Bag', 100, 'Tree', 'Type', 'classification');
    end
    
    if verbose; disp("Cross-Validating Shuffled Model..."); end
    
    % Cross-validate model - 10-fold
    cv_model_shuff = crossval(model_shuf, 'KFold', 10);
    
    % Retrieve percentage success rate
    f = kfoldLoss(cv_model_shuff);
    fprintf("Shuffle CrossVal Success:");
    cprintf("blue", " \t%.2f%%\n", 100*(1 - f));
    
    % Use model to predict on test set
    prediction = predict(model_shuf,test);
    fprintf("Matthews Correlation:");
    cprintf("blue", " \t\t%.2f%%\n\n", 100*MCC(prediction, test_labels));
    
    %% Save Model Setup

    % Save model and results
%     usr_save = input(sprintf("Save %s model and associated data? (y/n): ", model_label), "s");
    usr_save = "n";
   
    if usr_save == "y"
        clear usr_save data
        
        saveDir = sprintf("../Prod/MLModels");
        saveFile = sprintf("%s-model_%s.mat", model_label, datestr(now,'mm-dd'));
        try
            save(saveFile, "-mat");
        catch
            fprintf("Making Directory:\t%s\n", saveDir);
            mkdir(saveDir)
            save(saveFile, "-mat");
        end
        fprintf("\nSaved model and associated data to:")
        cprintf("magenta", " \t%s\n", saveDir)
    end
end