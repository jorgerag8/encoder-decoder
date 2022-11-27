%% GCAMP Analysis Master Script
% Christian Cazares, Drew Schreiner, Christina Gremel
% University of California, San Diego
% 2/16/21
%% Loop through each Excel File in Selected Folder to extract raw behavioral events and fluorescent signals
% Saves each session as a .mat containing that data
GCAMP_Save_Dir = '/Users/jorgerag/Documents/UCSD/courses/capstone/matlab/GCAMP code 2.16.22/';
extractData(GCAMP_Save_Dir)
%% Loops through each .mat GCAMP session and peforms peri-event GCaMP trace analysis
% Function:
        % extract_PeriEventAnalysis(base_time_start, base_time_end, time_end)
    % Parameters:
    %   base_time_start: time (in seconds) before onset of lever press for
    %       start of baseline window
    %   base_time_end: time (in seconds) before onset of lever press for
    %       end of baseline window
    %   time_end: time (in seconds) after onset of event for
    %       end of analys window
    
    base_time_start = -10; % old -15
    base_time_end = -2;   % old -5
    time_end = 5;
    extract_PeriEventAnalysis(base_time_start, base_time_end, time_end)
    
% 1. Extracts timestamps of each behavioral event (Onset, Offset, Head Entry, Reward)
    % Subfunction: 
            % extract_EventTimestamps(GCAMP)
        % Parameters:
            % GCAMP: Session including extract raw excel timestamps of
            % events and photometry signals
% 2. Baseline normalization of each session's peri-event GCAMP traces (Onset, Offset, Head Entry, Reward, Quantile, Interpolated)
    % Subfunction: 
            % baselineNormalized_PeriEventTraces(GCAMP)
        % Parameters:
            % GCAMP: Session including extract raw excel timestamps of
            % events and photometry signals
% 3. Performs Linear Mixed Effect Model (LME) Analysis on each session's peri-event GCAMP
%       traces (pre-Onset, post-Onset, post-Offset)

%% Plots example session peri-event GCAMP traces (onset, offset, first head entry after reward, duration)
plotExampleSession(GCAMP)
%% Group GCAMP data
[GroupedGCAMP_OFC] = groupGCAMPData();
[Grouped_GCAMP] = groupGCAMPData();
[GroupedGCAMP_PV] = groupGCAMPData();
%% Probability
base_time_start = -5; % old -15
    base_time_end = -2;   % old -5
    time_end = 5;
extract_PeriEventAnalysis_Probability(base_time_start, base_time_end, time_end)

[GroupedGCAMP_OFC_Prob] = groupGCAMPData_Probability();
[GroupedGCAMP_OFC_Prob] = groupGCAMPData_Stats_Probability(GroupedGCAMP_OFC_Prob);
plotGroupedSessions_Probability(GroupedGCAMP_OFC_Prob);

[GroupedGCAMP_PV_Prob] = groupGCAMPData_Probability();
[GroupedGCAMP_PV_Prob] = groupGCAMPData_Stats_Probability(GroupedGCAMP_PV_Prob);
plotGroupedSessions_Probability(GroupedGCAMP_PV_Prob);
plotExampleSession_Probability(GCAMP)

%% Regression
[OFC_Model] = GCAMP_grand_regression_indivshuffles_r(GroupedGCAMP_OFC);
save('OFC_Model','OFC_Model' , '-v7.3')
[PV_Model] = GCAMP_grand_regression_indivshuffles_r(GroupedGCAMP_PV);
save('PV_Model','PV_Model' , '-v7.3')
%% Decoder
accuracy_testing_new
%% N-1
% If N-1 is Rewarded or not
GroupedGCAMP_OFC = nBackReward(GroupedGCAMP_OFC);
GroupedGCAMP_PV = nBackReward(GroupedGCAMP_PV);
% What duration distribution quartile does N-1 belong to?
GroupedGCAMP_OFC = nBackQuartile(GroupedGCAMP_OFC);
GroupedGCAMP_PV = nBackQuartile(GroupedGCAMP_PV);
%% Perform Statistical Comparisons in Grouped GCAMP data
[GroupedGCAMP_OFC] = groupGCAMPData_Stats(GroupedGCAMP_OFC);
[GroupedGCAMP_PV] = groupGCAMPData_Stats(GroupedGCAMP_PV);
%% Plots grouped session peri-event GCAMP traces (onset, offset, first head entry after reward, duration)
% Loops through each individual GCAMP session in folder and places
% peri-event data traces into a cohort-sized data structure
plotGroupedSessions(GroupedGCAMP_OFC);
plotGroupedSessions(GroupedGCAMP_PV);
plotGroupedSessions_n1Reward(GroupedGCAMP_OFC);
plotGroupedSessions_n1Reward(GroupedGCAMP_PV);
plotGroupedSessions_n1Quartile(GroupedGCAMP_OFC);
plotGroupedSessions_n1Quartile(GroupedGCAMP_PV);
%% Random
% Activity vs Lever presses
experience(GroupedGCAMP)

%% OFC-M2
[GroupedGCAMP_Air] = groupGCAMPData();
[GroupedGCAMP_CIE] = groupGCAMPData();
GroupedGCAMP_Air = nBackReward(GroupedGCAMP_Air);
GroupedGCAMP_CIE = nBackReward(GroupedGCAMP_CIE);

GroupedGCAMP_Air = nBackQuartile(GroupedGCAMP_Air);
GroupedGCAMP_CIE = nBackQuartile(GroupedGCAMP_CIE);

[GroupedGCAMP_Air] = groupGCAMPData_Stats(GroupedGCAMP_Air);
[GroupedGCAMP_CIE] = groupGCAMPData_Stats(GroupedGCAMP_CIE);


[Air_Model] = GCAMP_grand_regression_indivshuffles_r(GroupedGCAMP_Air);
save('Air_Model','Air_Model' , '-v7.3')

[CIE_Model] = GCAMP_grand_regression_indivshuffles_r(GroupedGCAMP_CIE);
save('CIE_Model','CIE_Model' , '-v7.3')

plotGroupedSessions(GroupedGCAMP_Air);
plotGroupedSessions(GroupedGCAMP_CIE);

plotGroupedSessions_n1Quartile(GroupedGCAMP_Air);
plotGroupedSessions_n1Quartile(GroupedGCAMP_CIE);