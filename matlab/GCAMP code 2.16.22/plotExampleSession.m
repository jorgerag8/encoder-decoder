function [] = plotExampleSession(GCAMP)
%% Figure Properties
set(0,'defaultfigurecolor',[1 1 1])
FontSize = 12;
LineWidth = 2;
LineWidth_Legend = 3;
size_w = 150;
size_h = 300;
heat_size_w = 250;
heat_size_h = 125;
blue = [0, 0.4470, 0.7410];
red = [0.8500, 0.3250, 0.0980];
green = [0.4660, 0.6740, 0.1880];
purple = [0.4940, 0.1840, 0.5560];
black = [0.25, 0.25, 0.25];
smooth_win = 20;
smooth_win_limited = 10;
interp_smooth_win = 1;
smooth_type = 'sgolay';
%% Plot Single Session Data from GCAMP .mat
%% LP Onset
%% Mean LP ON Delta F Plot

y1 = smoothdata(GCAMP.baseline_norm_LP_ON_Met,2,smooth_type,smooth_win);
y2 = smoothdata(GCAMP.baseline_norm_LP_ON_Fail,2,smooth_type,smooth_win);
n1 = size(y1,1);
n2 = size(y2,1);

figure('Name',[GCAMP.training_day(1:4) ' Z Criteria LPON'],'NumberTitle','off','rend','painters','pos',[100 100 size_w size_h])
hold on
%Plot mean with shaded standard error
s = shadedErrorBar(GCAMP.plot_time, y1, {@mean, @(x) std(x) / sqrt(n1)}, 'lineprops', '-b', 'transparent',1);
set(s.edge,'LineWidth',6,'LineStyle','none')
set(s.mainLine,'Color',blue)
s.mainLine.LineWidth = LineWidth;
s.patch.FaceColor = blue;

t = shadedErrorBar(GCAMP.plot_time, y2, {@mean, @(x) std(x) / sqrt(n2)}, 'lineprops', '-r', 'transparent',1);
set(t.edge,'LineWidth',6,'LineStyle','none')
set(t.mainLine,'Color',red)
t.mainLine.LineWidth = LineWidth;
t.patch.FaceColor = red;

title(['Training Days: ' GCAMP.training_day(1:4) ', n = ' num2str(n1)])
h = zeros(2, 1);
h(1) = plot(NaN,NaN,'-', 'Color', blue);
h(2) = plot(NaN,NaN,'-', 'Color', red);
axis tight
legend(h,{'Success', 'Failure'})
set(h,'LineWidth',LineWidth_Legend);
legend boxoff
xlabel('Time from Lever Press Onset (S)')
ylabel('Z-scored \Delta F / F')
set(gca,'FontSize',FontSize)
set(gca, 'FontName', 'Arial')
ylim([-0.5 2.0])

%% Mean LP OFF Delta F Plot

y1 = smoothdata(GCAMP.baseline_norm_LP_OFF_Met,2,smooth_type,smooth_win);
y2 = smoothdata(GCAMP.baseline_norm_LP_OFF_Fail,2,smooth_type,smooth_win);
n1 = size(y1,1);
n2 = size(y2,1);

figure('Name',[GCAMP.training_day(1:4) ' Z Criteria LPOFF'],'NumberTitle','off','rend','painters','pos',[100 100 size_w size_h])
hold on
%Plot mean with shaded standard error
s = shadedErrorBar(GCAMP.plot_time, y1, {@mean, @(x) std(x) / sqrt(n1)}, 'lineprops', '-b', 'transparent',1);
set(s.edge,'LineWidth',6,'LineStyle','none')
set(s.mainLine,'Color',blue)
s.mainLine.LineWidth = LineWidth;
s.patch.FaceColor = blue;

t = shadedErrorBar(GCAMP.plot_time, y2, {@mean, @(x) std(x) / sqrt(n2)}, 'lineprops', '-r', 'transparent',1);
set(t.edge,'LineWidth',6,'LineStyle','none')
set(t.mainLine,'Color',red)
t.mainLine.LineWidth = LineWidth;
t.patch.FaceColor = red;

title(['Training Days: ' GCAMP.training_day(1:4) ', n = ' num2str(n1)])
h = zeros(2, 1);
h(1) = plot(NaN,NaN,'-', 'Color', blue);
h(2) = plot(NaN,NaN,'-', 'Color', red);
axis tight
legend(h,{'Success', 'Failure'})
set(h,'LineWidth',LineWidth_Legend);
legend boxoff
xlabel('Time from Lever Press Offset (S)')
ylabel('Z-scored \Delta F / F')
set(gca,'FontSize',FontSize)
set(gca, 'FontName', 'Arial')
ylim([-0.5 2.0])


%% Mean First Head Entry After Reward Delta F Plot

y1 = smoothdata(GCAMP.baseline_norm_First_HE_After_RE,2,smooth_type,smooth_win);
n1 = size(y1,1);

figure('Name',[GCAMP.training_day(1:4) ' Z Criteria FirstHE'],'NumberTitle','off','rend','painters','pos',[100 100 size_w size_h])
hold on
%Plot mean with shaded standard error
s = shadedErrorBar(GCAMP.plot_time, y1, {@mean, @(x) std(x) / sqrt(n1)}, 'lineprops', '-b', 'transparent',1);
set(s.edge,'LineWidth',6,'LineStyle','none')
set(s.mainLine,'Color',blue)
s.mainLine.LineWidth = LineWidth;
s.patch.FaceColor = blue;

title(['Training Days: ' GCAMP.training_day(1:4) ', n = ' num2str(n1)])
h = zeros(1, 1);
h(1) = plot(NaN,NaN,'-', 'Color', blue);
axis tight
xlabel('Time from First Head Entry (S)')
ylabel('Z-scored \Delta F / F')
set(gca,'FontSize',FontSize)
set(gca, 'FontName', 'Arial')
ylim([-1.5 2.0])

%% Interpolated Duration Activity

% prior to plotting, remove any NaNs (which are LPs withouth at least 2
% samples)

Grouped_interp_All = rmmissing(GCAMP.baseline_norm_Duration);
Grouped_interp_Met = rmmissing(GCAMP.baseline_norm_Duration_Met);
Grouped_interp_Fail = rmmissing(GCAMP.baseline_norm_Duration_Fail);



y1 = smoothdata(Grouped_interp_Met,2,smooth_type,interp_smooth_win);
y2 = smoothdata(Grouped_interp_Fail,2,smooth_type,interp_smooth_win);
y3 = smoothdata(Grouped_interp_All,2,smooth_type,interp_smooth_win);
n1 = size(y1,1);
n2 = size(y2,1);
n3 = size(y3,1);

percent_of_press = (100/GCAMP.interp_length)*(1:GCAMP.interp_length);

figure('Name',[GCAMP.training_day(1:4) ' Z Criteria Duration'],'NumberTitle','off','rend','painters','pos',[100 100 size_w size_h])
hold on
%Plot mean with shaded standard error
s = shadedErrorBar(percent_of_press, y1, {@mean, @(x) std(x) / sqrt(n1)}, 'lineprops', '-b', 'transparent',1);
set(s.edge,'LineWidth',6,'LineStyle','none')
set(s.mainLine,'Color',blue)
s.mainLine.LineWidth = LineWidth;
s.patch.FaceColor = blue;

t = shadedErrorBar(percent_of_press, y2, {@mean, @(x) std(x) / sqrt(n2)}, 'lineprops', '-r', 'transparent',1);
set(t.edge,'LineWidth',6,'LineStyle','none')
set(t.mainLine,'Color',red)
t.mainLine.LineWidth = LineWidth;
t.patch.FaceColor = red;

p = shadedErrorBar(percent_of_press, y3, {@mean, @(x) std(x) / sqrt(n3)}, 'lineprops', '-r', 'transparent',1);
set(p.edge,'LineWidth',6,'LineStyle','none')
set(p.mainLine,'Color',black)
p.mainLine.LineWidth = LineWidth;
p.patch.FaceColor = black;

title(['Training Days: ' GCAMP.training_day(1:4) ', n = ' num2str(n1)])
h = zeros(2, 1);
h(1) = plot(NaN,NaN,'-', 'Color', blue);
h(2) = plot(NaN,NaN,'-', 'Color', red);
axis tight
legend(h,{'Success', 'Failure'})
set(h,'LineWidth',LineWidth_Legend);
legend boxoff
xlabel('Lever Press Duration (%)')
ylabel('Z-scored \Delta F / F')
set(gca,'FontSize',FontSize)
set(gca, 'FontName', 'Arial')

%% Plot Behavior example
session_start = GCAMP.beh_data(2,1);
session_end = GCAMP.beh_data(length(GCAMP.beh_data(:,1)),1);
LP_ON_ts = ((GCAMP.LP_ON_timestamps - session_start)/1000)/60 ;
RE_ON_ts =  ((GCAMP.LP_ON_timestamps - session_start)/1000)/60;
HE_ON_ts =  ((GCAMP.HE_ON_timestamps - session_start)/1000)/60 ;
RE_ON_durations = ones(length(RE_ON_ts),1)*3;
HE_ON_durations = GCAMP.HE_Times / 1000;
LP_ON_durations = GCAMP.HoldDown_times / 1000;
RE_LP_ON_ts = LP_ON_ts(LP_ON_durations>=1.600);
RE_LP_ON_durations = LP_ON_durations(LP_ON_durations>=1.600);
noRE_LP_ON_ts = LP_ON_ts(LP_ON_durations<1.600);
noRE_LP_ON_durations = LP_ON_durations(LP_ON_durations<1.600);

%% Plot Entire Session
%PV GCAMP_4269_1600-3
figure
hold on
for lever_press = 1:length(noRE_LP_ON_ts)
    plot([noRE_LP_ON_ts(lever_press) noRE_LP_ON_ts(lever_press)], [0 noRE_LP_ON_durations(lever_press)], 'color', black, 'LineWidth', 2)
end
for lever_press = 1:length(RE_LP_ON_ts)
    plot([RE_LP_ON_ts(lever_press) RE_LP_ON_ts(lever_press)], [0 RE_LP_ON_durations(lever_press)], 'color', blue, 'LineWidth', 2)
end
for head_entry = 1:length(HE_ON_ts)
    plot([HE_ON_ts(head_entry) HE_ON_ts(head_entry)], [0 HE_ON_durations(head_entry)], 'color', purple, 'LineWidth', 2)
end
yline(1.6)
h = zeros(3, 1);
h(1) = plot(NaN,NaN,'-', 'Color', black);
h(2) = plot(NaN,NaN,'-', 'Color', blue);
h(3) = plot(NaN,NaN,'-','Color', purple);
legend(h,{'Unrewarded Lever Press', 'Rewarded Lever Press', 'Head Entry'})
set(h,'LineWidth',4);
legend boxoff
ylabel({'Duration (s)'})
xlim([0 90])
ylim([0 8])
set(gca,'TickDir','out')
set(gca,'FontSize',8)
set(gca, 'FontName', 'Arial')
%% Zoom in 5 seconds
%PV GCAMP_4269_1600-3
% figure
% hold on
% for lever_press = 1:length(noRE_LP_ON_ts)
%     plot([noRE_LP_ON_ts_sec(lever_press) noRE_LP_ON_ts_sec(lever_press)], [0 noRE_LP_ON_durations(lever_press)], 'color', black, 'LineWidth', 2)
% end
% for lever_press = 1:length(RE_LP_ON_ts)
%     plot([RE_LP_ON_ts_sec(lever_press) RE_LP_ON_ts_sec(lever_press)], [0 RE_LP_ON_durations(lever_press)], 'color', blue, 'LineWidth', 2)
% end
% for head_entry = 1:length(HE_ON_ts)
%     plot([HE_ON_ts_sec(head_entry) HE_ON_ts_sec(head_entry)], [0 HE_ON_durations(head_entry)], 'color', purple, 'LineWidth', 2)
% end
% yline(1.6)
% h = zeros(3, 1);
% h(1) = plot(NaN,NaN,'-', 'Color', black);
% h(2) = plot(NaN,NaN,'-', 'Color', blue);
% h(3) = plot(NaN,NaN,'-','Color', purple);
% legend(h,{'Unrewarded Lever Press', 'Rewarded Lever Press', 'Head Entry'})
% set(h,'LineWidth',4);
% legend boxoff
% ylabel({'Duration (s)'})
% xlim([1460 1520])
% ylim([0 3])
% set(gca,'TickDir','out')
% set(gca,'FontSize',8)
% set(gca, 'FontName', 'Arial')
% 


% %% Plot Single Event Example
% seconds_before_reinforcer = -10;
% seconds_after_reinforcer = 5;
% k = 1;
% % 23:24
% % Find indices of events and create data window
% figure 
% % Tye lab meeting examples
% %5:10 CamKII GCAMP_2967_1600-13
% %seconds_before_reinforcer = -5;
% %seconds_after_reinforcer = 20;
% 
% %1:5 PV GCAMP_4269_1600-3
% %seconds_before_reinforcer = -20;
% %seconds_after_reinforcer = 20;
% for reinforcer_delivered = 1:5 % index of RE delivery event %31 32 34 Mouse 1
%     time_window = [(GCAMP.RE_ON_timestamps(reinforcer_delivered) + seconds_before_reinforcer*1000)...
%         (GCAMP.RE_ON_timestamps(reinforcer_delivered) + seconds_after_reinforcer*1000)];
%     lever_presess_in_window_ts = GCAMP.LP_ON_timestamps(find(GCAMP.LP_ON_timestamps <= time_window(2) ...
%         & GCAMP.LP_ON_timestamps > time_window(1)));
%     reinforcers_earned_in_window_ts = GCAMP.RE_ON_timestamps(find(GCAMP.RE_ON_timestamps <= time_window(2) ...
%         & GCAMP.RE_ON_timestamps > time_window(1)));
%     lever_presess_off_in_window_ts = GCAMP.LP_OFF_timestamps(find(GCAMP.LP_OFF_timestamps <= time_window(2) ...
%         & GCAMP.LP_OFF_timestamps > time_window(1)));
%      %he's, maybe comment out if needed
%     he_on_in_winbdow_ts = GCAMP.HE_ON_timestamps(find(GCAMP.HE_ON_timestamps <= time_window(2)...
%         & GCAMP.HE_ON_timestamps > time_window(1)));
%     
%     he_off_in_window_ts = GCAMP.HE_OFF_timestamps(find(GCAMP.HE_OFF_timestamps <= time_window(2)...
%         & GCAMP.HE_OFF_timestamps > time_window(1)));
%     
%     Closest_RE_ON_idx = nearestpoint(reinforcers_earned_in_window_ts,GCAMP.gcampdata_timestamps);
%     Closest_LP_ON_idx = nearestpoint(lever_presess_in_window_ts,GCAMP.gcampdata_timestamps);
%     Closest_LP_OFF_idx = nearestpoint(lever_presess_off_in_window_ts,GCAMP.gcampdata_timestamps);
%     %HE
%     Closest_HE_ON_idx = nearestpoint(he_on_in_winbdow_ts,GCAMP.gcampdata_timestamps);
%     Closest_HE_OFF_idx = nearestpoint(he_off_in_window_ts,GCAMP.gcampdata_timestamps);
%     
%     index_window = (Closest_RE_ON_idx + seconds_before_reinforcer * GCAMP.SR) : (Closest_RE_ON_idx + seconds_after_reinforcer * GCAMP.SR);
%     time_window = ((GCAMP.gcampdata_timestamps(index_window) - GCAMP.gcampdata_timestamps(index_window(1))) ./ 1000) + seconds_before_reinforcer;
%     data_window = GCAMP.gcampdata(Closest_RE_ON_idx + seconds_before_reinforcer * GCAMP.SR : Closest_RE_ON_idx + seconds_after_reinforcer * GCAMP.SR)';
%     
%     % Plot events along data window
%     
%     subplot(5,1,k)
%     hold on
%     plot(time_window, smoothdata(data_window, 'gaussian', 5), 'k', 'LineWidth', 1)
%     axis_limits = ylim;
%     for lever_press = 1:length(Closest_LP_ON_idx)
%         plot([time_window(find(Closest_LP_ON_idx(lever_press) == index_window)) time_window(find(Closest_LP_ON_idx(lever_press) == index_window))], [axis_limits(1) axis_limits(2)], 'r', 'LineWidth', 2)
%         ha = area([time_window(find(Closest_LP_ON_idx(lever_press) == index_window)) time_window(find(Closest_LP_OFF_idx(lever_press) == index_window))], [axis_limits(1) axis_limits(1)], 'FaceAlpha', 0.20, 'EdgeAlpha', 0);
%         he = area([time_window(find(Closest_LP_ON_idx(lever_press) == index_window)) time_window(find(Closest_LP_OFF_idx(lever_press) == index_window))], [axis_limits(2) axis_limits(2)], 'FaceAlpha', 0.20, 'EdgeAlpha', 0);
%         
%     end
%     
%     for reinforcer = 1:length(Closest_RE_ON_idx)
%         plot([time_window(find(Closest_RE_ON_idx(reinforcer) == index_window)) time_window(find(Closest_RE_ON_idx(reinforcer) == index_window))], [axis_limits(1) axis_limits(2)], 'b', 'LineWidth', 2)
%     end
%     for HE = 1:length(Closest_HE_ON_idx)
%         plot([time_window(find(Closest_HE_ON_idx(HE) == index_window)) time_window(find(Closest_HE_ON_idx(HE) == index_window))], [axis_limits(1) axis_limits(2)], 'g', 'LineWidth', 2)
%     end
%     
%     if k == 1
%         title('OFC Activity (\Delta F / F) during Hold Down Task') 
%         h = zeros(3, 1);
%         h(1) = plot(NaN,NaN,'-r');
%         h(2) = plot(NaN,NaN,'-b');
%         h(3) = plot(NaN,NaN,'-g');
%         legend(h,{'Lever Press Onset', 'Reinforcement Delivery', 'Head Entry'})
%         set(h,'LineWidth',4);
%         legend boxoff
%     end
%     if k == 5
%         xlabel('Time from Reinforcement Delivery (Seconds)')
%     end
%     ylabel('\Delta F / F', 'FontWeight','bold')
%     set(gca,'FontSize',20)
%     set(gca, 'FontName', 'Arial')
%     ylim([axis_limits]);
%     k = k+1;
% end
% 
% 
% 

%% Heatmap LP ON
[out,idx] = sort(GCAMP.HoldDown_times);
data = GCAMP.baseline_norm_LP_ON(idx,:);

subplot(2,2,[2 4])
minValue = min(data(:,41));
maxValue = max(data(:,41));
% Scale the data to between -1 and +1.
data = (data-minValue) * 2 / (maxValue - minValue) - 1;

imagesc(data);
colormap('viridis')
h = colorbar;
ylabel(h,'Normalized \Delta F / F0 (%)', 'FontWeight','bold')
xticks(1:GCAMP.SR:length(GCAMP.plot_time));
caxis([-1 2]) % change colorbar limits

title('\Delta F / F0 for each Lever Press')
xlabel('Time from Lever Press Onset (S)')
ylabel('Lever Presses (Descending in Length)', 'FontWeight','bold')
xticklabels({'-2', '-1', '0', '1','2', '3', '4', '5'})
set(gca,'FontSize',12)
set(gca, 'FontName', 'Arial')

% Overlay Onset, Criteria, and LP Offsets
adjustedtimes = GCAMP.HoldDown_times(idx)/((1/GCAMP.SR)*1000);
shifted = adjustedtimes + (GCAMP.SR*abs(GCAMP.base_time_end)+1);
idx_re = find(out > 1600);
idx_no_re = find(out < 1600);
hold on
plot(shifted(idx_no_re),idx_no_re , 'Color', red,'LineWidth', 2);
plot(shifted(idx_re),idx_re, 'Color', blue,'LineWidth', 2);
shiftedCriteria = (GCAMP.Criteria/((1/GCAMP.SR)*1000)) + (GCAMP.SR*abs(GCAMP.base_time_end)+1);
shiftedCriteriaMatrix = 1:length(idx);
shiftedCriteriaMatrix(:,:) = shiftedCriteria;
%plot(shiftedCriteriaMatrix,1:length(idx), 'w','LineWidth',2);
zeroline = 1:length(idx); 
zeroline(:,:) = (GCAMP.SR*abs(GCAMP.base_time_end)+1);
plot(zeroline,1:length(idx),'w','LineWidth',2);
hold off


end

