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


G = table(GroupedGCAMP.mouseID_name, GroupedGCAMP.sessionID_name, GroupedGCAMP.sessionID, GroupedGCAMP.Durations, GroupedGCAMP.isSuccess,...
    GroupedGCAMP.LPON, GroupedGCAMP.LPInterp, GroupedGCAMP.LPOFF) ;
G.Properties.VariableNames = {'Mouse_Name', 'Session_Name', 'SessionID', 'Duration', 'isSuccess', 'LPON', 'LPInterp', 'LPOFF'};


PredictorNames = T.Properties.VariableNames(6:end);
AUCsvm = array2table(zeros(1,length(PredictorNames)), 'VariableNames',PredictorNames);
%% 10-fold crossvalidation
resp = logical(T.isSuccess);
pred = T.LPOFF_AUC;


rand_num = randperm(size(pred,1));

iter_pred_train = pred(rand_num(1:round(0.9*length(rand_num))),:);
iter_resp_train = resp(rand_num(1:round(0.9*length(rand_num))),:);
iter_pred_test = pred(rand_num(round(0.9*length(rand_num))+1:end),:);
iter_resp_test = resp(rand_num(round(0.9*length(rand_num))+1:end),:);
%% Train an SVM classifier on training data. Standardize the data.
mdlSVM = fitcsvm(iter_pred_train, iter_resp_train,'Standardize',true,'KernelFunction','RBF',...
    'KernelScale','auto');
%% Test SVM
oofLabel_n = predict(mdlSVM,iter_pred_test);
oofLabel_n = double(oofLabel_n); % chuyen tu categorical sang dang double
test_accuracy_for_iter = sum((oofLabel_n == iter_resp_test))/length(iter_resp_test)*100;


% Compute the posterior probabilities (scores).
mdlSVM = fitPosterior(mdlSVM);
[~,score_svm] = resubPredict(mdlSVM);
%The second column of score_svm contains the posterior probabilities of bad radar returns.
%Compute the standard ROC curve using the scores from the SVM model.
[Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(resp,score_svm(:,mdlSVM.ClassNames),'true');
AUCsvm = ;



%%  https://in.mathworks.com/matlabcentral/answers/544784-how-to-obtain-a-roc-curve-through-cross-validation-on-the-out-of-fold-data-in-cross-validation
resp = logical(T.isSuccess);
pred = T.LPOFF_AUC;
k = 10;
%% Unshuffled Data
cvFolds = crossvalind('Kfold', resp, k);
AUCsvm_real = cell(1,1);
accuracy_real = cell(1,1);
figure
for fold = 1:k                                 
    testIdx = (cvFolds == fold);  % get indices of test instances
    trainIdx = ~testIdx;       % get indices training instances
    
    classificationSVM = fitcsvm(pred(trainIdx,:), resp(trainIdx), ...
        'KernelFunction', 'RBF', ...
        'Standardize', true);
    [predictions, score] = predict(classificationSVM, pred(testIdx,:));
    [Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(resp(testIdx), score(:,classificationSVM.ClassNames), 'true');
    hold on
    plot(Xsvm,Ysvm)
    xlabel('False positive rate'); ylabel('True positive rate')
    title('ROC curve')
    AUCsvm_real{1}(fold) = AUCsvm;
    %% test model
    predictions = double(predictions);
    accuracy_real{1}(fold) = sum((predictions == resp(testIdx)))/length( resp(testIdx))*100;
    
end

%% Null distribution
[m,n] = size(pred) ;
idx = randperm(m) ;
shuff_pred = pred(idx);
AUCsvm_shuffle = cell(10,1);
accuracy_shuffle = cell(10,1);
for shuffle_iter = 1:10
    [m,n] = size(pred) ;
    idx = randperm(m) ;
    shuff_pred = pred(idx);
    %% SVM
    cvFolds = crossvalind('Kfold', shuff_pred, k);
    for fold = 1:k
        testIdx = (cvFolds == fold);  % get indices of test instances
        trainIdx = ~testIdx;       % get indices training instances
        
        classificationSVM = fitcsvm(shuff_pred(trainIdx,:), resp(trainIdx), ...
            'KernelFunction', 'RBF', ...
            'Standardize', true);
        [predictions, score] = predict(classificationSVM, pred(testIdx,:));
        [Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(resp(testIdx), score(:,classificationSVM.ClassNames), 'true');
        AUCsvm_shuffle{shuffle_iter}(fold) = AUCsvm;
        %% test model
        predictions = double(predictions);
        accuracy_shuffle{shuffle_iter}(fold) = sum((predictions == resp(testIdx)))/length(resp(testIdx))*100;
    end
end


%% Compare real vs Null
accuracy_real_mean = mean(cell2mat(accuracy_real))
accuracy_real_std = std(cell2mat(accuracy_real))
AUCsvm_real_mean = mean(cell2mat(AUCsvm_real))
AUCsvm_real_std = std(cell2mat(AUCsvm_real))


accuracy_shuff_mean = mean(mean(cell2mat(accuracy_shuffle)))
accuracy_shuff_std = std(mean(cell2mat(accuracy_shuffle)))
AUCsvm_shuff_mean = mean(mean(cell2mat(AUCsvm_shuffle)))
AUCsvm_shuff_std = std(mean(cell2mat(AUCsvm_shuffle)))

%% Quartile Decoding
histogram_bin_indexs_all =[];
for session = 1:max(T.SessionID)
  session_indices = find(session == T.SessionID);
 Lengths =  T.Duration(session_indices);
edge_start = [0 0.25 0.50 0.75];
edge_end = [0.25 0.50 0.75 1];
Counts = [];
True_edges = zeros(4,2);
for quart = 1:4
    edges = quantile(Lengths,[edge_start(quart) edge_end(quart)]);
    if quart == 1
        quart_lenghts = Lengths(Lengths >= edges(1) & Lengths <= edges(2));
    else
        quart_lenghts = Lengths(Lengths > edges(1) & Lengths <= edges(2));
    end
    True_edges(quart,:) = edges;
    [N,~,bin]= histcounts(quart_lenghts, edges);
    Counts = [Counts N];
end

hist_edges =[ True_edges(:,1);True_edges(4,end)];
[histogram_counts,histogram_edges,histogram_bin_indexs] = histcounts( Lengths,[hist_edges]); 
histogram_bin_indexs_all = [histogram_bin_indexs_all; histogram_bin_indexs];
end
T.Quartile = histogram_bin_indexs_all;
%% SVM Real
resp = T.Quartile;
pred = T.LPOFF_AUC;
k = 10;
%% Unshuffled Data
cvFolds = crossvalind('Kfold', resp, k);
AUCsvm_real = cell(1,1);
accuracy_real = cell(1,1);
figure
template = templateSVM(...
    'KernelFunction', 'linear', ...
    'PolynomialOrder', [], ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', true);
for fold = 1:k                                 
    testIdx = (cvFolds == fold);  % get indices of test instances
    trainIdx = ~testIdx;       % get indices training instances
    
    classificationSVM = fitcecoc(pred(trainIdx,:), resp(trainIdx), ...
        'Learners', template);
    [predictions, score] = predict(classificationSVM, pred(testIdx,:));

    % Because multiclass
    diffscore=zeros;
    for i=1:size(score,1)
        temp=score(i,:); % a row vector holding the scores for the classes [A, B, C, D] for the ith observation out of the total.
        % score of +ve class minus the maximum of the scores of all the negative classes (similar to the example available via the webpage link)
        diffscore(i,:)=temp(1)-max([temp(2),temp(3),temp(4)]);
    end
    [Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(resp(testIdx), diffscore, '2');
    hold on
    plot(Xsvm,Ysvm)
    xlabel('False positive rate'); ylabel('True positive rate')
    title('ROC curve')
    AUCsvm_real{1}(fold) = AUCsvm;
    %% test model
    predictions = double(predictions);
    accuracy_real{1}(fold) = sum((predictions == resp(testIdx)))/length( resp(testIdx))*100;
    
end







%% train coec model on the 4 classes
%interp_all_AUC=46 
%base_offset_to1_AUC_raw = 38
%base_neg_1_to_onset_AUC_raw = 21
rng default
%n1 vars
%interp_all_AUC=60 
%base_offset_to1_AUC_raw = 66
%base_neg_1_to_onset_AUC_raw = 72

% PredictorNames = Grand_Regression_Table.Properties.VariableNames([21 46 38]); 
%n1 vars, optional instead
% PredictorNames = Grand_Regression_Table.Properties.VariableNames([66 60 72]); 
PredictorNames = Grand_Regression_Table.Properties.VariableNames({'base_neg_1_to_onset_AUC_raw','base_offset_to1_AUC_raw'}); 

sessions = length(1:max(Grand_Regression_Table.Mouse_ID));

Accuracy_Holdout = array2table(zeros(sessions,length(PredictorNames)), 'VariableNames',PredictorNames);
KFold_kLoss = array2table(zeros(sessions,length(PredictorNames)), 'VariableNames',PredictorNames);

template = templateSVM(...
    'KernelFunction', 'linear', ...
    'PolynomialOrder', [], ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', true);

Accuracy_Holdout_shuf = array2table(zeros(sessions,length(PredictorNames)), 'VariableNames',PredictorNames);


shuf_correct_cell ={};
for session = 1:max(Grand_Regression_Table.Mouse_ID)

    for predictor = 1:length(PredictorNames)
    PredictorData = Grand_Regression_Table.(PredictorNames{predictor});
    session_indices = find(session == Grand_Regression_Table.Mouse_ID);
    data = PredictorData(session_indices);
    target = Grand_Regression_Table.histogram_bin_indexs(session_indices);
    
    %Let's shuffle the order of the duration bins. Then we can see if we
    %predict better than shuffled data
%     Shuf_Act_Mat =[];
%         for shuf_it = 1:100
%       shuf_target = target(randperm(length(target)));
%         [train,test] = crossvalind('holdOut',shuf_target,.2);
%     svmStruct = fitcecoc(data(train),shuf_target(train),  'Learners', template);
%     classes = predict(svmStruct,data(test));
%     cp = classperf(shuf_target);
%     cp2 = classperf(cp,classes,test);
%     Shuf_Act_Mat = [Shuf_Act_Mat; cp2.CorrectRate*100]; 
%         end
%           
%           Accuracy_Holdout_shuf.(PredictorNames{predictor})(session) = mean(Shuf_Act_Mat);    
%   
    
    %% Split Data Crossvalidation
    [train,test] = crossvalind('holdOut',target,.2);
    svmStruct = fitcecoc(data(train),target(train),  'Learners', template);
    classes = predict(svmStruct,data(test));
    cp = classperf(target);
    cp2 = classperf(cp,classes,test);
    Accuracy_Holdout.(PredictorNames{predictor})(session) = cp2.CorrectRate*100;
%%   cross fold  
%       SVMModel = fitcecoc(data,target,  'Learners', template);
%     CVSVMModel = crossval(SVMModel, 'KFold', 10);
%     classLoss = kfoldLoss(CVSVMModel);
%     KFold_kLoss.(PredictorNames{predictor})(session) = 100-classLoss*100;

%% Bayesian kernal classifier
%     svmStruct = fitcnb(data,target,'DistributionNames',{'kernel'},...
%         'ClassNames',{'1','2','3','4'}, 'CrossVal','on'); 
%     classErr1 = kfoldLoss(svmStruct);
%     KFold_kLoss.(PredictorNames{predictor})(session) = 100-( classErr1*100);
    
% isLabels2 = kfoldPredict(svmStruct);
% ConfusionMat2 = confusionchart(target,isLabels2);

%% conf matrix graph
%       CVMdl = crossval(svmStruct);
% oofLabel = kfoldPredict(CVMdl);
% ConfMat = confusionchart(target(train),oofLabel,'RowSummary','total-normalized');  

    end
end
% x = target(train)