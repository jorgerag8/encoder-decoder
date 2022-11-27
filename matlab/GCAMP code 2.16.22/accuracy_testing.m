GroupedGCAMP = GroupedGCAMP_OFC;
GroupedGCAMP = GroupedGCAMP_PV;
rng('default')

T = table(GroupedGCAMP.mouseID_name, GroupedGCAMP.sessionID_name, GroupedGCAMP.sessionID, GroupedGCAMP.Durations, GroupedGCAMP.isSuccess,...
    GroupedGCAMP.LPON_AUC, GroupedGCAMP.LPInterp_AUC, GroupedGCAMP.LPOFF_AUC,...
    GroupedGCAMP.LPON_AUCAbs, GroupedGCAMP.LPInterp_AUCAbs, GroupedGCAMP.LPOFF_AUCAbs,...
    GroupedGCAMP.LPON_Mean, GroupedGCAMP.LPInterp_Mean, GroupedGCAMP.LPOFF_Mean,...
    GroupedGCAMP.LPON_MeanAbs, GroupedGCAMP.LPInterp_MeanAbs, GroupedGCAMP.LPOFF_MeanAbs) ;
T.Properties.VariableNames = {'Mouse_Name', 'Session_Name', 'SessionID', 'Duration', 'isSuccess', 'LPON_AUC', 'LPInterp_AUC', 'LPOFF_AUC'...
    'LPON_AUCAbs', 'LPInterp_AUCAbs', 'LPOFF_AUCAbs', 'LPON_Mean', 'LPInterp_Mean', 'LPOFF_Mean'...
    'LPON_MeanAbs', 'LPInterp_MeanAbs', 'LPOFF_MeanAbs'};

PredictorNames = T.Properties.VariableNames(6:end); 
Accuracy_Holdout = array2table(zeros(1,length(PredictorNames)), 'VariableNames',PredictorNames);
KFold_kLoss = array2table(zeros(1,length(PredictorNames)), 'VariableNames',PredictorNames);
for session = 1:max(T.SessionID)
    for predictor = 1:length(PredictorNames)
    PredictorData = T.(PredictorNames{predictor});
    session_indices = find(session == T.SessionID);
    data = PredictorData(session_indices);
    target = T.isSuccess(session_indices);
    %% Split Data Crossvalidation
    [train,test] = crossvalind('holdOut',target,.2);
    svmStruct = fitcsvm(data(train),target(train));
    classes = predict(svmStruct,data(test));
    cp = classperf(target);
    cp2 = classperf(cp,classes,test);
    Accuracy_Holdout.(PredictorNames{predictor})(session) = cp2.CorrectRate*100;
    
    %% KFold Crossvalidation
    SVMModel = fitcsvm(data,target,'Standardize',true,'KernelFunction','RBF',...
    'KernelScale','auto');
    CVSVMModel = crossval(SVMModel, 'KFold', 10);
    classLoss = kfoldLoss(CVSVMModel);
    KFold_kLoss.(PredictorNames{predictor})(session) = classLoss*100;
    end
end


%% Fit Binary
PredictorNames = T.Properties.VariableNames(6:end);
KFold_Accuracy = array2table(zeros(1,length(PredictorNames)), 'VariableNames',PredictorNames);

for predictor = 1:length(PredictorNames)
    PredictorData = T.(PredictorNames{predictor});
    %session_indices = find(session == T.SessionID);
    data = PredictorData;
    target = T.isSuccess;
    rand_num = randperm(size(data,1));
    % training data set 70%, test set 30%,
    X_train = data(rand_num(1:round(0.7*length(rand_num))),:);
    X_test = data(rand_num(round(0.7*length(rand_num))+1:end),:);
    y_train = target(rand_num(1:round(0.7*length(rand_num))),:);
    y_test = target(rand_num(round(0.7*length(rand_num))+1:end),:);
    % This code specifies all the classifier options and trains the classifier.
    SVMModel = fitcsvm(X_train,y_train,'Standardize',true,'KernelFunction','RBF',...
    'KernelScale','auto');
    %% Perform cross-validation
    partitionedModel = crossval(SVMModel, 'KFold', 10);
    % Compute validation predictions
    [validationPredictions, validationScores] = kfoldPredict(partitionedModel);
    % Compute validation accuracy
    validation_error = kfoldLoss(partitionedModel, 'LossFun', 'ClassifError'); % validation error
    validationAccuracy = 1 - validation_error;
    %% test model
    oofLabel_n = predict(SVMModel,X_test);
    oofLabel_n = double(oofLabel_n); % chuyen tu categorical sang dang double
    test_accuracy_for_iter = sum((oofLabel_n == y_test))/length(y_test)*100;
    KFold_Accuracy.(PredictorNames{predictor}) = test_accuracy_for_iter;
end


%% Fit multiclass
PredictorNames = T.Properties.VariableNames(6:end);
KFold_Accuracy = array2table(zeros(1,length(PredictorNames)), 'VariableNames',PredictorNames);

for predictor = 1:length(PredictorNames)
    PredictorData = T.(PredictorNames{predictor});
    %session_indices = find(session == T.SessionID);
    data = PredictorData;
    target = T.isSuccess;
    rand_num = randperm(size(data,1));
    % training data set 70%, test set 30%,
    X_train = data(rand_num(1:round(0.7*length(rand_num))),:);
    X_test = data(rand_num(round(0.7*length(rand_num))+1:end),:);
    y_train = target(rand_num(1:round(0.7*length(rand_num))),:);
    y_test = target(rand_num(round(0.7*length(rand_num))+1:end),:);
    % This code specifies all the classifier options and trains the classifier.
    template = templateSVM(...
        'KernelFunction', 'linear', ...
        'PolynomialOrder', [], ...
        'KernelScale', 'auto', ...
        'BoxConstraint', 1, ...
        'Standardize', true);
    Mdl = fitcecoc(...
        X_train, ...
        y_train, ...
        'Learners', template, ...
        'Coding', 'onevsall',...
        'OptimizeHyperparameters','auto',...
        'HyperparameterOptimizationOptions',...
        struct('AcquisitionFunctionName',...
        'expected-improvement-plus'));
    %% Perform cross-validation
    partitionedModel = crossval(Mdl, 'KFold', 10);
    % Compute validation predictions
    [validationPredictions, validationScores] = kfoldPredict(partitionedModel);
    % Compute validation accuracy
    validation_error = kfoldLoss(partitionedModel, 'LossFun', 'ClassifError'); % validation error
    validationAccuracy = 1 - validation_error;
    %% test model
    oofLabel_n = predict(Mdl,X_test);
    oofLabel_n = double(oofLabel_n); % chuyen tu categorical sang dang double
    test_accuracy_for_iter = sum((oofLabel_n == y_test))/length(y_test)*100;
    KFold_Accuracy.(PredictorNames{predictor}) = test_accuracy_for_iter;
end



















T.(PredictorNames{1});
isSuccess = T.isSuccess;
accuracy_LPON = zeros(max(T.SessionID),1);
accuracy_Interp = zeros(max(T.SessionID),1);
accuracy_LPOFF = zeros(max(T.SessionID),1);
%% AUC
for session = 1:max(T.SessionID)
    %% Interp
    AUC = T.LPInterp_AUC;
    session_indices = find(session == T.SessionID);
    data = AUC(session_indices);
    target = isSuccess(session_indices);
    cp = classperf(target);
    [train,test] = crossvalind('holdOut',target,.9);
    svmStruct = fitcsvm(data(train),target(train));
    classes = predict(svmStruct,data(test));
    cp = classperf(cp,classes,test);
    accuracy_Interp(session) = cp.CorrectRate*100;
    
    %% LPON
    AUC = T.LPON_AUC;
    session_indices = find(session == T.SessionID);
    data = AUC(session_indices);
    target = isSuccess(session_indices);
    cp = classperf(target);
    [train,test] = crossvalind('holdOut',target,.9);
    svmStruct = fitcsvm(data(train),target(train));
    classes = predict(svmStruct,data(test));
    cp = classperf(cp,classes,test);
    accuracy_LPON(session) = cp.CorrectRate*100;
    
    %% LPOFF
    AUC = T.LPOFF_AUC;
    session_indices = find(session == T.SessionID);
    data = AUC(session_indices);
    target = isSuccess(session_indices);
    cp = classperf(target);
    [train,test] = crossvalind('holdOut',target,.9);
    svmStruct = fitcsvm(data(train),target(train));
    classes = predict(svmStruct,data(test));
    cp = classperf(cp,classes,test);
    accuracy_LPOFF(session) = cp.CorrectRate*100;
end
%% Mean Activity
for session = 1:max(T.SessionID)
    %% Interp
    AUC = T.LPInterp_Mean;
    session_indices = find(session == T.SessionID);
    data = AUC(session_indices);
    target = isSuccess(session_indices);
    cp = classperf(target);
    [train,test] = crossvalind('holdOut',target,.9);
    svmStruct = fitcsvm(data(train),target(train));
    classes = predict(svmStruct,data(test));
    cp = classperf(cp,classes,test);
    accuracy_Interp(session) = cp.CorrectRate*100;
end

for session = 1:max(T.SessionID)
    %% LPON
    AUC = T.LPON_Mean;
    session_indices = find(session == T.SessionID);
    data = AUC(session_indices);
    target = isSuccess(session_indices);
    cp = classperf(target);
    [train,test] = crossvalind('holdOut',target,.9);
    svmStruct = fitcsvm(data(train),target(train));
    classes = predict(svmStruct,data(test));
    cp = classperf(cp,classes,test);
    accuracy_LPON(session) = cp.CorrectRate*100;
end
    %% LPOFF
    AUC = T.LPOFF_Mean;
    session_indices = find(session == T.SessionID);
    data = AUC(session_indices);
    target = isSuccess(session_indices);
    cp = classperf(target);
    [train,test] = crossvalind('holdOut',target,.9);
    svmStruct = fitcsvm(data(train),target(train));
    classes = predict(svmStruct,data(test));
    cp = classperf(cp,classes,test);
    accuracy_LPOFF(session) = cp.CorrectRate*100;
end














GroupedGCAMP = GroupedGCAMP_OFC;
%GroupedGCAMP = GroupedGCAMP_PV;
T = table(GroupedGCAMP.mouseID_name, GroupedGCAMP.sessionID_name, GroupedGCAMP.sessionID, GroupedGCAMP.Durations, GroupedGCAMP.isSuccess,...
    GroupedGCAMP.LPON_AUC, GroupedGCAMP.LPInterp_AUC, GroupedGCAMP.LPOFF_AUC) ;
T.Properties.VariableNames = {'Mouse_Name', 'Session_Name', 'SessionID', 'Duration', 'isSuccess', 'LPON_AUC', 'LPInterp_AUC', 'LPOFF_AUC'};

rng default


isSuccess = T.isSuccess;
accuracy_LPON = zeros(max(T.SessionID),1);
accuracy_Interp = zeros(max(T.SessionID),1);
accuracy_LPOFF = zeros(max(T.SessionID),1);
for session = 1:max(T.SessionID)
    %% Interp
    AUC = T.LPInterp_AUC;
    session_indices = find(session == T.SessionID);
    data = AUC(session_indices);
    target = isSuccess(session_indices);
    SVMModel = fitcsvm(data,target,'Standardize',true,'KernelFunction','RBF',...
    'KernelScale','auto');
    CVSVMModel = crossval(SVMModel);
    classLoss = kfoldLoss(CVSVMModel);
    accuracy_Interp(session) = classLoss*100;
    
    %% LPON
    AUC = T.LPON_AUC;
    session_indices = find(session == T.SessionID);
    data = AUC(session_indices);
    target = isSuccess(session_indices);
    SVMModel = fitcsvm(data,target,'Standardize',true,'KernelFunction','RBF',...
    'KernelScale','auto');
    CVSVMModel = crossval(SVMModel);
    classLoss = kfoldLoss(CVSVMModel);
    accuracy_LPON(session) = classLoss*100;
    
    %% LPOFF
    AUC = T.LPOFF_AUC;
    session_indices = find(session == T.SessionID);
    data = AUC(session_indices);
    target = isSuccess(session_indices);
    SVMModel = fitcsvm(data,target,'Standardize',true,'KernelFunction','RBF',...
    'KernelScale','auto');
    CVSVMModel = crossval(SVMModel);
    classLoss = kfoldLoss(CVSVMModel);
    accuracy_LPOFF(session) = classLoss*100;
end









target_rand = target(randperm(length(target)));
data_rand = data (randperm(length(data )));
cp = classperf(target_rand );
for i = 1:10
[train,test] = crossvalind('holdOut',target_rand ,.9);
svmStruct = fitcsvm(data_rand(train),target_rand(train));
classes = predict(svmStruct,data_rand(test));
classperf(cp,classes,test);
cp.CorrectRate
end