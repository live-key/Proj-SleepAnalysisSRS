% Fit ML model to patient apnea data using power spectra 
% Author: Joe Byrne
% Revise subsampling 

function performance = MLAlgo(model_label, run) 
    
    sp          = run.start_patient;
    ep          = run.end_patient;
    category    = run.category;
    split       = run.split;
    verbose     = run.verbose;

    performance = [];

    %% Setup
    cprintf("black*", "Training and Testing *%s-%s* Model\n\n", model_label, category);
    if verbose; disp("Setting Up Workspace..."); end
    
    addpath Func
        
    % Make output reproducible
    rng(42)
    
    % Get all data
    dataDir = sprintf("../%s", run.filePath);

    try 
        data = load(dataDir).all_data;
    catch 
        fprintf("Couldn't find file: %s\nQuitting MLAlgo.m...\n", dataDir);
        return
    end
    
    %% Data split
    
    if verbose; disp("Splitting Data..."); end
   
    if split == "PWISE"
        % Split data patient-wise
        % ----------------------- %
        [train, test] = SubSampleSplit(data);
        
        if iscell(train); train = CellCat(train); end
        if iscell(test); test  = CellCat(test); end
    else
        % Pool data split
        % ------------------- %
        % Divide into apnea/no-apnea for subsampling
        data_apnea = data(data.LABEL == 1, :);
        data_noapn = data(data.LABEL == 0, :);
        
        % Partition the data into testing and training data
        [apnea_train, apnea_test] = SubSampleSplit(data_apnea);
        [noapn_train, noapn_test] = SubSampleSplit(data_noapn);

        train = [apnea_train; noapn_train];
        test  = [apnea_test; noapn_test];
    end

    % Combine into overall data
    train_labels = train.LABEL;
    train.LABEL = [];
    
    test_labels = test.LABEL;
    test.LABEL = [];
    
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
    perf = 100*(1 - f);

    if verbose
        fprintf("CrossVal Success Rate:");
        cprintf("blue", " \t%.2f%%\n", perf);
    end
    
    % Use model to predict on test set
    prediction = predict(model,test);
    mcc = 100*MCC(prediction, test_labels);

    if verbose
        fprintf("Matthews Correlation:");
        cprintf("blue", " \t%.2f%%\n\n", mcc);
    end
    
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
    perf_shuff = 100*(1 - f);

    if verbose
        fprintf("Shuffle CrossVal Success:");
        cprintf("blue", " \t%.2f%%\n", perf_shuff);
    end
    
    % Use model to predict on test set
    prediction = predict(model_shuf,test);
    mcc_shuff = 100*MCC(prediction, test_labels);

    if verbose
        fprintf("Matthews Correlation:");
        cprintf("blue", " \t\t%.2f%%\n\n", mcc_shuff);
    end

    % Function output
    performance = [perf, mcc, perf_shuff, mcc_shuff];
    
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