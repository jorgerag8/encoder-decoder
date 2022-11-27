function [] = extract_PeriEventAnalysis_Probability(base_time_start, base_time_end, time_end)
%% Select Location of GCAMP .Mat File Directories
PathName_Folder = uigetdir();
cd(PathName_Folder);
indiv_sessions = dir;
indiv_sessions = indiv_sessions(3:end);
total_sessions = length(indiv_sessions);
for session = 1:total_sessions
    %% Load each session's GCAMP.mat file
    filename = indiv_sessions(session).name;
    load(filename)
    Name = ['Loaded ' filename]
    %% Extract Event Timestamps
    [GCAMP] = extract_EventTimestamps(GCAMP);
    %% Plot perievent (lever press) GCAMP data (WITH BASELINE) and extract variables for regression analysis
    GCAMP.base_time_start = base_time_start;
    GCAMP.base_time_end = base_time_end;
    GCAMP.time_end = time_end;
    [GCAMP] = baselineNormalized_PeriEventTraces_Probability(GCAMP);
    %[GCAMP] = GCAMP_plot_with_baseline_10_quants(GCAMP, base_time_start, base_time_end, time_end);
    %[GCAMP] = GCAMP_Linear_Regressions_updated(GCAMP, base_time_start, base_time_end, time_end);
    close all
    %% Save GCAMP Data Structure
    save(['GCAMP_' GCAMP.mouseID '_' GCAMP.training_day], 'GCAMP');
end
end
