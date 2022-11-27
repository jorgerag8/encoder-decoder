function [GroupedGCAMP] = groupGCAMPData_Probability()
%% Select Location of GCAMP .Mat File Directories
PathName_Folder = uigetdir('J:\MEDPC\Paper Code\GCAMP Data');
cd(PathName_Folder);
indiv_sessions = dir;
indiv_sessions = indiv_sessions(3:end);
total_sessions = length(indiv_sessions);
% Initiate empty grouped data structure
GroupedGCAMP = struct([]);
% Durations For Probability
GroupedGCAMP(1).Met_Reward_LP_Idx = [];
GroupedGCAMP(1).Met_Reward_Durations = [];
GroupedGCAMP(1).Met_No_Reward_LP_Idx = [];
GroupedGCAMP(1).Met_No_Reward_Durations = [];


% Lever Press Onset
    GroupedGCAMP(1).LPON =  [];
    GroupedGCAMP(1).LPON_Met_Reward =  [];
    GroupedGCAMP(1).LPON_Met_No_Reward =  [];
    GroupedGCAMP(1).LPON_Fail =  [];
    % Lever Press Offset
    GroupedGCAMP(1).LPOFF =  [];
    GroupedGCAMP(1).LPOFF_Met_Reward =  [];
    GroupedGCAMP(1).LPOFF_Met_No_Reward =  [];
    GroupedGCAMP(1).LPOFF_Fail =  [];
    % Lever Press Interpolated Duration
    GroupedGCAMP(1).LPInterp =  [];
    GroupedGCAMP(1).LPInterp_Met_Reward =  [];
    GroupedGCAMP(1).LPInterp_Met_No_Reward =  [];
    GroupedGCAMP(1).LPInterp_Fail =  [];
    % First Head Entry
    GroupedGCAMP(1).FirstHE_RE =  [];
    GroupedGCAMP(1).FirstHE_Met_noRE =  [];
    GroupedGCAMP(1).FirstHE_Fail =  [];
    % Table for SVM
    GroupedGCAMP(1).LPON_AUC = [];
    GroupedGCAMP(1).LPInterp_AUC = [];
    GroupedGCAMP(1).LPOFF_AUC = [];
    GroupedGCAMP(1).LPON_AUCAbs = [];
    GroupedGCAMP(1).LPInterp_AUCAbs = [];
    GroupedGCAMP(1).LPOFF_AUCAbs = [];
    GroupedGCAMP(1).LPON_Mean = [];
    GroupedGCAMP(1).LPInterp_Mean = [];
    GroupedGCAMP(1).LPOFF_Mean = [];
    GroupedGCAMP(1).LPON_MeanAbs = [];
    GroupedGCAMP(1).LPInterp_MeanAbs = [];
    GroupedGCAMP(1).LPOFF_MeanAbs = [];
    GroupedGCAMP(1).Durations = [];
    GroupedGCAMP(1).isSuccess = [];
    GroupedGCAMP(1).mouseID_name = [];
    GroupedGCAMP(1).sessionID_name = [];
    GroupedGCAMP(1).sessionID = [];
        % Unique mouseID iteration counter
        mouseID = 1;
for session = 1:total_sessions
    %% Load each session's GCAMP.mat file
    filename = indiv_sessions(session).name;
    load(filename)
    Name = ['Loaded ' filename]
    % Durations
    GroupedGCAMP.Met_Reward_LP_Idx = [GroupedGCAMP.Met_Reward_LP_Idx; GCAMP.Met_Reward];
    GroupedGCAMP.Met_Reward_Durations = [GroupedGCAMP.Met_Reward_Durations; GCAMP.HoldDown_times(GCAMP.Met_Reward)];
    GroupedGCAMP.Met_No_Reward_LP_Idx = [GroupedGCAMP.Met_No_Reward_LP_Idx; GCAMP.Met_No_Reward];
    GroupedGCAMP.Met_No_Reward_Durations = [GroupedGCAMP.Met_No_Reward_Durations; GCAMP.HoldDown_times(GCAMP.Met_No_Reward)];
    % Lever Press Onset
    GroupedGCAMP.LPON = [GroupedGCAMP.LPON; GCAMP.baseline_norm_LP_ON];
    GroupedGCAMP.LPON_Met_Reward = [GroupedGCAMP.LPON_Met_Reward; GCAMP.baseline_norm_LP_ON_Met_Reward];
    GroupedGCAMP.LPON_Met_No_Reward = [GroupedGCAMP.LPON_Met_No_Reward; GCAMP.baseline_norm_LP_ON_Met_No_Reward];
    GroupedGCAMP.LPON_Fail = [GroupedGCAMP.LPON_Fail; GCAMP.baseline_norm_LP_ON_Fail];
    % Lever Press Offset
    GroupedGCAMP.LPOFF = [GroupedGCAMP.LPOFF; GCAMP.baseline_norm_LP_OFF];
    GroupedGCAMP.LPOFF_Met_Reward = [GroupedGCAMP.LPOFF_Met_Reward; GCAMP.baseline_norm_LP_OFF_Met_Reward];
    GroupedGCAMP.LPOFF_Met_No_Reward = [GroupedGCAMP.LPOFF_Met_No_Reward; GCAMP.baseline_norm_LP_OFF_Met_No_Reward];
    GroupedGCAMP.LPOFF_Fail = [GroupedGCAMP.LPOFF_Fail; GCAMP.baseline_norm_LP_OFF_Fail];
    % Lever Press Interpolated Duration
    GroupedGCAMP.LPInterp = [GroupedGCAMP.LPInterp; GCAMP.baseline_norm_Duration];
    GroupedGCAMP.LPInterp_Met_Reward = [GroupedGCAMP.LPInterp_Met_Reward; GCAMP.baseline_norm_Duration_Met_Reward];
    GroupedGCAMP.LPInterp_Met_No_Reward = [GroupedGCAMP.LPInterp_Met_No_Reward; GCAMP.baseline_norm_Duration_Met_No_Reward];
    GroupedGCAMP.LPInterp_Fail = [GroupedGCAMP.LPInterp_Fail; GCAMP.baseline_norm_Duration_Fail];
    % First Head Entry
    GroupedGCAMP.FirstHE_RE = [GroupedGCAMP.FirstHE_RE; GCAMP.baseline_norm_First_HE_After_RE];
    GroupedGCAMP.FirstHE_Met_noRE = [GroupedGCAMP.FirstHE_Met_noRE; GCAMP.baseline_norm_First_HE_After_Met_noRE];
    GroupedGCAMP.FirstHE_Fail = [GroupedGCAMP.FirstHE_Fail; GCAMP.baseline_norm_First_HE_After_Fail];
    % Make Table for SVM
    LP_ON_window = [find(GCAMP.base_time_end == GCAMP.plot_time) : find(0 == GCAMP.plot_time)];
    LP_OFF_window = [find(0 == GCAMP.plot_time) : find(GCAMP.time_end == GCAMP.plot_time)];
    % Area under curve
    GroupedGCAMP.LPON_AUC = [GroupedGCAMP.LPON_AUC; trapz(GCAMP.baseline_norm_LP_ON(:,LP_ON_window),2)];
    GroupedGCAMP.LPInterp_AUC = [GroupedGCAMP.LPInterp_AUC; trapz(GCAMP.baseline_norm_Duration(:,:),2)];
    GroupedGCAMP.LPOFF_AUC = [GroupedGCAMP.LPOFF_AUC; trapz(GCAMP.baseline_norm_LP_OFF(:,LP_OFF_window),2)];
    GroupedGCAMP.LPON_AUCAbs = [GroupedGCAMP.LPON_AUCAbs; abs(trapz(GCAMP.baseline_norm_LP_ON(:,LP_ON_window),2))];
    GroupedGCAMP.LPInterp_AUCAbs = [GroupedGCAMP.LPInterp_AUCAbs; abs(trapz(GCAMP.baseline_norm_Duration(:,:),2))];
    GroupedGCAMP.LPOFF_AUCAbs = [GroupedGCAMP.LPOFF_AUCAbs; abs(trapz(GCAMP.baseline_norm_LP_OFF(:,LP_OFF_window),2))];
    % Mean activity of trace
    GroupedGCAMP.LPON_Mean = [GroupedGCAMP.LPON_Mean; mean(GCAMP.baseline_norm_LP_ON(:,LP_ON_window),2)];
    GroupedGCAMP.LPInterp_Mean = [GroupedGCAMP.LPInterp_Mean; nanmean(GCAMP.baseline_norm_Duration(:,:),2)];
    GroupedGCAMP.LPOFF_Mean = [GroupedGCAMP.LPOFF_Mean; mean(GCAMP.baseline_norm_LP_OFF(:,LP_OFF_window),2)];
    GroupedGCAMP.LPON_MeanAbs = [GroupedGCAMP.LPON_MeanAbs; abs(mean(GCAMP.baseline_norm_LP_ON(:,LP_ON_window),2))];
    GroupedGCAMP.LPInterp_MeanAbs = [GroupedGCAMP.LPInterp_MeanAbs; abs(nanmean(GCAMP.baseline_norm_Duration(:,:),2))];
    GroupedGCAMP.LPOFF_MeanAbs = [GroupedGCAMP.LPOFF_MeanAbs; abs(mean(GCAMP.baseline_norm_LP_OFF(:,LP_OFF_window),2))];
    % Classification labels
    GroupedGCAMP.Durations = [GroupedGCAMP.Durations; GCAMP.HoldDown_times];
    GroupedGCAMP.isSuccess = [GroupedGCAMP.isSuccess; (GCAMP.HoldDown_times >= GCAMP.Criteria)];
    % Session Identifying Information
    mouseID_name = cell(size(GCAMP.HoldDown_times));
    mouseID_name(:) = {GCAMP.mouseID};
    GroupedGCAMP.mouseID_name = [GroupedGCAMP.mouseID_name; mouseID_name];
    sessionID_name = cell(size(GCAMP.HoldDown_times));
    sessionID_name(:) = {GCAMP.training_day};
    GroupedGCAMP.sessionID_name = [GroupedGCAMP.sessionID_name; sessionID_name];
    sessionID = ones(size((GCAMP.HoldDown_times)))*session;
    GroupedGCAMP.sessionID = [GroupedGCAMP.sessionID; sessionID];
end
GroupedGCAMP.plot_time = GCAMP.plot_time;
GroupedGCAMP.training_day = GCAMP.training_day(1:4);
GroupedGCAMP.interp_length = GCAMP.interp_length;




end

