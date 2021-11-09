%% analysis of Exp 1 at individual level-- by doing binned histogram of the data and comparing difference across conditions for phase 2 -- complementary to main analysis (appeared in the Appendix in the final paper)
clear all; 
data = loadjson('curiosity3.json'); %read data in a big cell here

%the below code builds up three matrixes for each condition -- bin_low, bin_medium and bin_high matrix s.t each item
%corresponds to each subject's mean P(Reveal|Condition) for that bin. 

%%
clc
close all

phase = 1; %which phase here (1 or 2) -- user variable change here
cond = 2 %conditions 1-2 -- user variable change here
    
numThrown = 0;
numSub = 0; %total number of subjects for each condition
n = length(data); %number of subjects
bad = zeros(1,n); %array to flag a bad subject

bin_low = [];
bin_medium = [];
bin_high = [];

for i = 1:n %number of subjects

    subject = data{1,i};  %store data of subject in a single struct
    a = length(subject.data);
    condition = 0;     
    c = 0;

    for j = 1:length(subject.data) %first get condition of that subject
        if(strcmp(subject.data{1,j}.trial_type,'survey-multi-choice')==1)
            c = j; %first get index of the quiz answer (get the last response of the quiz, subjects could take quiz multiple times)
        end
    end
    if(strfind(subject.data{1,c}.responses, 'CORRECTNESS') > 0)
        condition = 1; %condition 1 if correct response had more in it
    elseif(strfind(subject.data{1,c}.responses, 'RANDOMLY') > 0)
        condition = 2; %condition 2 if correct response had random in it
    end
    
    if(condition == cond) %only analyze for that condition
    
        d = 1;
        numSub = numSub+1;
        trivia_response = []; %store responses in phase 1
        answer_reveal = zeros(1,40); %store whether subject revealed answer or not
    
        for j = 4:2:82 %now extract responses for all trivia questions in phase 1
            a = subject.data{1,j}.responses; 
            a = extractNum(a);
            trivia_response(d,:) = a(2:2:4)';
            d = d+1;
        end
    
        counter = c+1; %c+1 is starting index for phase 2, where c was index of multi-stim-response i.e. the quiz
        for j = 1:40
            if(subject.data{1,counter}.key_press == 86) %if subject choose to reveal the answer
                answer_reveal(j)=1;
                counter = counter+2; %skip the next trial because answer is revealed there
            else %if subject didn't reveal answer
                answer_reveal(j)=0;
                counter = counter+1;
            end
        end
    
        trivia_response(:,2) = (trivia_response(:,2)+1)*10; %confidence
        trivia_response(:,1) = trivia_response(:,1)+1; %curiosity
        trivia_response(:,3) = answer_reveal; %reveal
        bad(i) = check_badSubject(trivia_response);

        if(bad(i)>=4)
            numThrown = numThrown+1;
            continue %if subject is bad then skip it
        else
            [trivia_response] = normalize_matrix(trivia_response); %trivia response contains curiosity (1st column), and confidence (2nd column)
            trivia_response = trivia_response(all(~isnan(trivia_response),2),:); %remove NaNs     
            curiosity = trivia_response(:,1);
            confidence = trivia_response(:,2);
            reveal = trivia_response(:,3);
            
            if phase == 1
                dv = curiosity;
            elseif phase == 2
                dv = reveal;
            end
            
            %replace by curiosity or reveal based on whether phase 1 or phase 2
            a = find(confidence >= 0 & confidence <= 30); %get index between low range
            bin_low = [bin_low; mean(dv(a))]; %prob you will reveal answer given your confidence rating        

            a = find(confidence > 30 & confidence <= 70); %get index between medium range
            bin_medium =  [bin_medium; mean(dv(a))]; %prob you will reveal answer given your confidence rating        

            a = find(confidence > 70 & confidence <= 100); %get index for high range
            bin_high =  [bin_high; mean(dv(a))]; %prob you will reveal answer given your confidence rating 
            %note that we don't normalize the probability distribution
            %here because of NAN problems i.e often times an individual
            %may not have given the full range of confidence values
        end
    else
        continue;
    end

end

% analysis
%remove NaNs
bin_low(isnan(bin_low))=0.5;
bin_medium(isnan(bin_medium))=0.5;
bin_high(isnan(bin_high))=0.5;

% collect how many participants in each possible bin

 bins_subject = zeros(13,1);
 
 for i = 1:length(bin_low)
     if(bin_low(i)>bin_medium(i)) 
         if(bin_medium(i)>bin_high(i))
             bins_subject(1) = bins_subject(1)+1; %decreasing
         elseif(bin_medium(i)==bin_high(i))
             bins_subject(2) = bins_subject(2)+1; %decreasing
         elseif(bin_medium(i)<bin_high(i))
             if(bin_high(i)<bin_low(i))
                bins_subject(12) = bins_subject(12)+1; %other
             elseif(bin_high(i)>bin_low(i))
                bins_subject(11) = bins_subject(11)+1; %other
             elseif(bin_high(i)==bin_low(i))
                bins_subject(10) = bins_subject(10)+1; %other
             end             
         end
     elseif(bin_low(i)<bin_medium(i))
         if(bin_medium(i)>bin_high(i))
             if(bin_high(i)<bin_low(i))
                bins_subject(3) = bins_subject(3)+1; %u-shape
             elseif(bin_high(i)>bin_low(i))
                bins_subject(4) = bins_subject(4)+1; %u-shape
             elseif(bin_high(i)==bin_low(i))
                bins_subject(5) = bins_subject(5)+1; %u-shape
             end
         elseif(bin_medium(i)==bin_high(i))
             bins_subject(6) = bins_subject(6)+1; %u-shape
         elseif(bin_medium(i)<bin_high(i))
             bins_subject(7) = bins_subject(7)+1; %other
         end
     elseif(bin_low(i)==bin_medium(i))
         if(bin_medium(i)==bin_high(i))
             bins_subject(8) = bins_subject(8)+1; %other
         elseif(bin_medium(i)<bin_high(i))
             bins_subject(9) = bins_subject(9)+1; %other
         elseif(bin_medium(i)>bin_high(i))
             bins_subject(13) = bins_subject(13)+1; %other
         end
     end
 end
 
% Plot it

if(cond == 1)
    col = [0.3020 0.7451 0.9333];
else
    col = [0  0.4471 0.7412];
end

fig_handle = figure; 
bins_subject2 = bins_subject([1 2 3 4 6 5 7 11 12 8 9 10 13]);
bar(bins_subject2/length(bin_low), 'FaceColor',col,'EdgeColor','k', 'LineWidth',1.5)
plt = Plot(fig_handle, true);
% plt.XLabel = 'Bins'; %ylabel
% plt.YLabel = 'Proportion of participants'; %ylabel
plt.ShowBox = 'off';
plt.FontSize = 15;
plt.XMinorTick = 'off'; % 'on' or 'off'
plt.YMinorTick = 'off'; % 'on' or 'off'
plt.BoxDim = [4, 4];
plt.AxisLineWidth = 1;
plt.XLim = [0,13.8];
plt.YLim = [0,0.25];
plt.XGrid = 'off';
plt.YGrid = 'off';
xlabels = {'!:.','!::', ':!.', '.!:', ':!:', ':!!', '.:!','!!!','::!','!:!',':.!','!.:','!!:'};
xlabels = xlabels([1 2 3 4 6 5 7 11 12 8 9 10 13]);
set(gca,'XTickLabel',xlabels)

hold on;
% plt.FileName = 'Cond1_bins.png';
% % setPlotProp(plt); 

% Compute empirical uniform distribution below

total_bins = []; %store each shuffled output here
for k = 1:1000 %repeat this n times

bins_shuffle = [];
for i = 1:length(bin_low) %go thru each row
    a = [bin_low(i) bin_medium(i) bin_high(i)];
    b = a(:,randperm(size(a,2))); %randomly shuffle column wise
    bins_shuffle = [bins_shuffle; b];
end

%get the new bins here after shuffling
bin_low = bins_shuffle(:,1);
bin_medium = bins_shuffle(:,2);
bin_high = bins_shuffle(:,3);

%do the same analysis as before i.e. get how many participants in each bin
%after the shuffling has happened
bins = zeros(13,1);
 
 for i = 1:length(bin_low)
     if(bin_low(i)>bin_medium(i)) 
         if(bin_medium(i)>bin_high(i))
             bins(1) = bins(1)+1; %decreasing
         elseif(bin_medium(i)==bin_high(i))
             bins(2) = bins(2)+1; %decreasing
         elseif(bin_medium(i)<bin_high(i))
             if(bin_high(i)<bin_low(i))
                bins(12) = bins(12)+1; %other
             elseif(bin_high(i)>bin_low(i))
                bins(11) = bins(11)+1; %other
             elseif(bin_high(i)==bin_low(i))
                bins(10) = bins(10)+1; %other
             end             
         end
     elseif(bin_low(i)<bin_medium(i))
         if(bin_medium(i)>bin_high(i))
             if(bin_high(i)<bin_low(i))
                bins(3) = bins(3)+1; %u-shape
             elseif(bin_high(i)>bin_low(i))
                bins(4) = bins(4)+1; %u-shape
             elseif(bin_high(i)==bin_low(i))
                bins(5) = bins(5)+1; %u-shape
             end
         elseif(bin_medium(i)==bin_high(i))
             bins(6) = bins(6)+1; %u-shape
         elseif(bin_medium(i)<bin_high(i))
             bins(7) = bins(7)+1; %other
         end
     elseif(bin_low(i)==bin_medium(i))
         if(bin_medium(i)==bin_high(i))
             bins(8) = bins(8)+1; %other
         elseif(bin_medium(i)<bin_high(i))
             bins(9) = bins(9)+1; %other
         elseif(bin_medium(i)>bin_high(i))
             bins(13) = bins(13)+1; %other
         end
     end
 end
 total_bins = [bins total_bins]; %store here
end

empirical_uniform = mean(total_bins,2)/length(bin_low);
empirical_uniform2 = empirical_uniform([1 2 3 4 6 5 7 11 12 8 9 10 13]); %arrange for plotting
plot(empirical_uniform2, 'ks', 'MarkerSize',6, 'MarkerFaceColor', 'k');

% chi-square test

o = bins_subject; %observed distribution
e = mean(total_bins,2); %expected distribution

chi2stat = sum((o-e).^2 ./ e)
p = 1 - chi2cdf(chi2stat,1)

% binomial-test significance here
n = ones(size(bins_subject2,1),1)*length(bin_low);
myBinomTest(bins_subject2, n, empirical_uniform2, 'one')
%% % individual analysis of how many u-shape vs. decreasing vs. random - complementary to above analysis

ushape = 0;
decreasing = 0;
random = 0;

for i = 1:length(bin_low)
    if(bin_low(i)>bin_medium(i) && bin_medium(i)>=bin_high(i))
        decreasing = decreasing+1;
    elseif(bin_low(i)<bin_medium(i) && bin_medium(i)>=bin_high(i))
        ushape = ushape+1;
    else
        random = random+1;
    end
end

disp(ushape/length(bin_low))
disp(decreasing/length(bin_low))
disp(random/length(bin_low))