function [GroupedGCAMP] = groupGCAMPData_Stats_Probability(GroupedGCAMP)


%% LP Onset
[p_val, observeddifference] = permTest_array(GroupedGCAMP.LPON_Met_Reward, GroupedGCAMP.LPON_Met_No_Reward, 1000);
threshold = .05;
sample_span = 5;
aboveThreshold = p_val <= threshold;

%aboveThreshold is a logical array, where 1 when above threshold, 0, below.
%we thus want to calculate the difference between rising and falling edges
aboveThreshold = [false, aboveThreshold, false];  %pad with 0's at ends
edges = diff(aboveThreshold);
rising = find(edges==1);     %rising/falling edges
falling = find(edges==-1);
spanWidth = falling - rising;  %width of span of 1's (above threshold)
wideEnough = spanWidth >= sample_span;
startPos = rising(wideEnough);    %start of each span
endPos = falling(wideEnough)-1;   %end of each span
%all points which are in the sample span (i.e. between startPos and endPos).
allInSpan = cell2mat(arrayfun(@(x,y) x:1:y, startPos, endPos, 'uni', false));

%now use that to index into the p_val thing and turn the significant
%consecutive ones into 0s, and all others into Nans so that we can plot
%that into the original graph to show where sig. diff exist.
p_val_for_graph = p_val;
p_val_for_graph(allInSpan) =0;
%    log_pval = p_val_for_graph
%    log_pval = p_val_for_graph(~allInSpan)
non_sig_idx =p_val_for_graph > 0;
p_val_for_graph(non_sig_idx) = NaN;

GroupedGCAMP.Stats.LPON.p_val = p_val;
GroupedGCAMP.Stats.LPON.p_val_for_graph = p_val_for_graph;

%% LP Offset
[p_val, observeddifference] = permTest_array(GroupedGCAMP.LPOFF_Met_Reward, GroupedGCAMP.LPOFF_Met_No_Reward, 1000);
threshold = .05;
sample_span = 5;
aboveThreshold = p_val <= threshold;

%aboveThreshold is a logical array, where 1 when above threshold, 0, below.
%we thus want to calculate the difference between rising and falling edges
aboveThreshold = [false, aboveThreshold, false];  %pad with 0's at ends
edges = diff(aboveThreshold);
rising = find(edges==1);     %rising/falling edges
falling = find(edges==-1);
spanWidth = falling - rising;  %width of span of 1's (above threshold)
wideEnough = spanWidth >= sample_span;
startPos = rising(wideEnough);    %start of each span
endPos = falling(wideEnough)-1;   %end of each span
%all points which are in the sample span (i.e. between startPos and endPos).
allInSpan = cell2mat(arrayfun(@(x,y) x:1:y, startPos, endPos, 'uni', false));

%now use that to index into the p_val thing and turn the significant
%consecutive ones into 0s, and all others into Nans so that we can plot
%that into the original graph to show where sig. diff exist.
p_val_for_graph = p_val;
p_val_for_graph(allInSpan) =0;
%    log_pval = p_val_for_graph
%    log_pval = p_val_for_graph(~allInSpan)
non_sig_idx =p_val_for_graph > 0;
p_val_for_graph(non_sig_idx) = NaN;

GroupedGCAMP.Stats.LPOFF.p_val = p_val;
GroupedGCAMP.Stats.LPOFF.p_val_for_graph = p_val_for_graph;


%% LP Interp
[p_val, observeddifference] = permTest_array(GroupedGCAMP.LPInterp_Met_Reward, GroupedGCAMP.LPInterp_Met_No_Reward, 1000);
threshold = .05;
sample_span = 3;
aboveThreshold = p_val <= threshold;

%aboveThreshold is a logical array, where 1 when above threshold, 0, below.
%we thus want to calculate the difference between rising and falling edges
aboveThreshold = [false, aboveThreshold, false];  %pad with 0's at ends
edges = diff(aboveThreshold);
rising = find(edges==1);     %rising/falling edges
falling = find(edges==-1);
spanWidth = falling - rising;  %width of span of 1's (above threshold)
wideEnough = spanWidth >= sample_span;
startPos = rising(wideEnough);    %start of each span
endPos = falling(wideEnough)-1;   %end of each span
%all points which are in the sample span (i.e. between startPos and endPos).
allInSpan = cell2mat(arrayfun(@(x,y) x:1:y, startPos, endPos, 'uni', false));

%now use that to index into the p_val thing and turn the significant
%consecutive ones into 0s, and all others into Nans so that we can plot
%that into the original graph to show where sig. diff exist.
p_val_for_graph = p_val;
p_val_for_graph(allInSpan) =0;
%    log_pval = p_val_for_graph
%    log_pval = p_val_for_graph(~allInSpan)
non_sig_idx =p_val_for_graph > 0;
p_val_for_graph(non_sig_idx) = NaN;

GroupedGCAMP.Stats.LPInterp.p_val = p_val;
GroupedGCAMP.Stats.LPInterp.p_val_for_graph = p_val_for_graph;

%% Head Entry (Success Rewarded vs Unrewarded)
[p_val, observeddifference] = permTest_array(GroupedGCAMP.FirstHE_RE, GroupedGCAMP.FirstHE_Met_noRE, 1000);
threshold = .05;
sample_span = 5;
aboveThreshold = p_val <= threshold;

%aboveThreshold is a logical array, where 1 when above threshold, 0, below.
%we thus want to calculate the difference between rising and falling edges
aboveThreshold = [false, aboveThreshold, false];  %pad with 0's at ends
edges = diff(aboveThreshold);
rising = find(edges==1);     %rising/falling edges
falling = find(edges==-1);
spanWidth = falling - rising;  %width of span of 1's (above threshold)
wideEnough = spanWidth >= sample_span;
startPos = rising(wideEnough);    %start of each span
endPos = falling(wideEnough)-1;   %end of each span
%all points which are in the sample span (i.e. between startPos and endPos).
allInSpan = cell2mat(arrayfun(@(x,y) x:1:y, startPos, endPos, 'uni', false));

%now use that to index into the p_val thing and turn the significant
%consecutive ones into 0s, and all others into Nans so that we can plot
%that into the original graph to show where sig. diff exist.
p_val_for_graph = p_val;
p_val_for_graph(allInSpan) =0;
%    log_pval = p_val_for_graph
%    log_pval = p_val_for_graph(~allInSpan)
non_sig_idx =p_val_for_graph > 0;
p_val_for_graph(non_sig_idx) = NaN;

GroupedGCAMP.Stats.HE_Met.p_val = p_val;
GroupedGCAMP.Stats.HE_Met.p_val_for_graph = p_val_for_graph;


%% Head Entry (Success Rewarded vs Failure)
[p_val, observeddifference] = permTest_array(GroupedGCAMP.FirstHE_RE, GroupedGCAMP.FirstHE_Fail, 1000);
threshold = .05;
sample_span = 5;
aboveThreshold = p_val <= threshold;

%aboveThreshold is a logical array, where 1 when above threshold, 0, below.
%we thus want to calculate the difference between rising and falling edges
aboveThreshold = [false, aboveThreshold, false];  %pad with 0's at ends
edges = diff(aboveThreshold);
rising = find(edges==1);     %rising/falling edges
falling = find(edges==-1);
spanWidth = falling - rising;  %width of span of 1's (above threshold)
wideEnough = spanWidth >= sample_span;
startPos = rising(wideEnough);    %start of each span
endPos = falling(wideEnough)-1;   %end of each span
%all points which are in the sample span (i.e. between startPos and endPos).
allInSpan = cell2mat(arrayfun(@(x,y) x:1:y, startPos, endPos, 'uni', false));

%now use that to index into the p_val thing and turn the significant
%consecutive ones into 0s, and all others into Nans so that we can plot
%that into the original graph to show where sig. diff exist.
p_val_for_graph = p_val;
p_val_for_graph(allInSpan) =0;
%    log_pval = p_val_for_graph
%    log_pval = p_val_for_graph(~allInSpan)
non_sig_idx =p_val_for_graph > 0;
p_val_for_graph(non_sig_idx) = NaN;

GroupedGCAMP.Stats.HE_Fail.p_val = p_val;
GroupedGCAMP.Stats.HE_Fail.p_val_for_graph = p_val_for_graph;


end

