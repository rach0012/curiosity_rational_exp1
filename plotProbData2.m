%Plot probability plots from phase 2 here. Plots only for 1 condition, so
%need an outer for loop to plot both conditions
curiosity = trivia_responseAll(:,1);
confidence = trivia_responseAll(:,2);
reveal = trivia_responseAll(:,3);
% normalize confidence
maxValue = max(confidence);
minValue = min(confidence);
confidence =  (confidence - minValue)./(maxValue-minValue);
uncertainity = confidence.*(1-confidence);

mean_curiosity = []; %mean curiosity at each confidence level - this is to plot u-shape curve
error_reveal = [];
confs = unique(confidence);
mean_reveal = zeros(1,length(confs));
uncertains = confs.*(1-confs);

for i = 1:length(confs)
        a = find(confidence == confs(i)); %get index
        mean_curiosity(i) = mean(curiosity(a));
        mean_reveal(i) = mean(reveal(a)); %prob you will reveal answer given your confidence rating
        error_reveal(i) = std(reveal(a))/sqrt(length(a));
end

% % Probability plot from phase 2
x = confs';
y = mean_reveal;
[p,S] = polyfit(x,y,2); %do polyfit
x1 = linspace(0,1);
y1 = polyval(p,x1); %evaluate the fit
%[Y,DELTA] = polyconf(p,x1,S,'predopt','curve'); %get CI interval
errorbar(x,y,error_reveal) %plot data
hold on
plot(x1,y1) %plot the line
hold on
% ciplot(Y-DELTA, Y+DELTA, x1);
% hold on

opt = [];
c1 = [0.3020 0.7451 0.9333];
c2 = [0  0.4471 0.7412];
opt.YLabel = 'Probability of revealing answer'; % xlabel
opt.Colors = [c1;c1;c2;c2];
opt.LineStyle = {'none', '-', 'none', '-'}; 
opt.Markers = {'*', '', 's', ''};
opt.XLabel = 'Confidence'; %ylabel
opt.XLim = [0, 1]; % [min, max]
opt.YLim = [0, 1]; % [min, max]
opt.LineWidth = [1 5 1 5];
opt.ShowBox = 'on';
opt.FontSize = 20;
% opt.LegendBox = 'on';
% opt.LegendBoxColor = 'w';
opt.XMinorTick = 'off'; % 'on' or 'off'
opt.YMinorTick = 'off'; % 'on' or 'off'
opt.BoxDim = [5, 5];
% opt.Legend = {'','Confidence based sampling', '', 'Uniform sampling'};
opt.AxisLineWidth = 1;
opt.XGrid = 'on';
opt.YGrid = 'on';
opt.ShowBox = 'on';
% opt.FileName = 'Phase2.png';
setPlotProp(opt);       
legend({'Confidence based sampling', 'Uniform sampling'},'FontSize',12)

