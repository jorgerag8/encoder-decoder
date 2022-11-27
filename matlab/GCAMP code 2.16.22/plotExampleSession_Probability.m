function [] = plotExampleSession_Probability(GCAMP)
%% Figure Properties
set(0,'defaultfigurecolor',[1 1 1])
FontSize = 8;
LineWidth = 2;
LineWidth_Legend = 3;
size_w = 300;
size_h = 150;
heat_size_w = 160;
heat_size_h = 135;
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

y1 = smoothdata(GCAMP.baseline_norm_LP_ON_Met_Reward,2,smooth_type,smooth_win);
y2 = smoothdata(GCAMP.baseline_norm_LP_ON_Met_No_Reward,2,smooth_type,smooth_win);
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

y1 = smoothdata(GCAMP.baseline_norm_LP_OFF_Met_Reward,2,smooth_type,smooth_win);
y2 = smoothdata(GCAMP.baseline_norm_LP_OFF_Met_No_Reward,2,smooth_type,smooth_win);
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
Grouped_interp_Met = rmmissing(GCAMP.baseline_norm_Duration_Met_Reward);
Grouped_interp_Fail = rmmissing(GCAMP.baseline_norm_Duration_Met_No_Reward);



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

end

