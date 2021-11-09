%Plot data from phase 1 here. Plots only for 1 condition, so
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
error_curiosity = [];
confs = unique(confidence);
 
for i = 1:length(confs)
        a = find(confidence == confs(i)); %get index
        mean_curiosity(i) = mean(curiosity(a));
        error_curiosity(i) = std(curiosity(a))/sqrt(length(a));
end


% Scatter plot from phase 1
figure;
% plot(confidence,curiosity);
hold on;
mdl = fitlm([confidence uncertainity],curiosity); %do regression
y = mdl.Fitted;
[confidence2,in] = sort(confidence);
plot(confidence2, y(in));
hold on;
errorbar(confs, mean_curiosity',error_curiosity'); %plot mean curiosity at each confidence level
a = sqrt(mdl.Rsquared.Ordinary);
xlabel(strcat('corr: ', num2str(a)));
title('Confidence based sampling');

opt = [];
c1 = [0.3020 0.7451 0.9333];
c2 = [0  0.4471 0.7412];
opt.YLabel = 'Normalized Curiosity'; % xlabel
opt.Colors = [c1;c1];
opt.LineWidth = [3 1];
opt.LineStyle = {'-', 'none'}; 
opt.Markers = {'', '*'};
opt.YLim = [-1 1];
opt.XLim = [0 1];
opt.XLabel = 'Confidence'; %ylabel
opt.ShowBox = 'off';
opt.FontSize = 15;
opt.XMinorTick = 'off'; % 'on' or 'off'
opt.YMinorTick = 'off'; % 'on' or 'off'
opt.BoxDim = [4, 4];
opt.AxisLineWidth = 1;
opt.XGrid = 'on';
opt.YGrid = 'on';
opt.ShowBox = 'on';

opt.FileName = 'Phase1_1.png';
setPlotProp(opt);   
