%% analysis of Exp 1-- comes in the main paper i.e. shows the existence of 
% u-curve for both phases and non-existence for condition 2 (in Phase 2), subsequent regression analysis similar to Kang et. al. also part of this code

clear all; 
data = loadjson('curiosity3.json'); %read data in a big cell here

% This code is for experiment with 40 questions 

%%

Phase = 2; %This is a variable that you can change -- phase == 1 for phase 1 results, phase == 2 for phase 2 results

probReveal = []; %store probability of revealing an answer for both conditions 
errorReveal = []; %store standard error of same
allReveal = []; %store all values of reveal for both conditions
allConf = []; %store all values of confidence for both conditions
allUncertain = []; %store all values of uncertainity for both conditions
allCur = []; %store curiosity ratings from phase 1 here for both conditions

for cond = 1:2 %conditions 1-2
    trivia_responseAll = []; %response for all subjects within a condition
    numThrown = 0;
    numSub = 0; %total number of subjects for each condition
    n = length(data); %number of subjects
    bad = zeros(1,n); %array to flag a bad subject
    
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
                [trivia_response] = normalize_matrix(trivia_response);
                trivia_responseAll = [trivia_response; trivia_responseAll]; %trivia response contains curiosity (1st column), and confidence (2nd column)
            end
        else
            continue;
        end
    
    end
    disp(numSub)
    disp(numThrown)
    trivia_responseAll = trivia_responseAll(all(~isnan(trivia_responseAll),2),:); %remove NaNs

    if(Phase == 1)
        plotProbData1;
    else
        plotProbData2;
    end
    
    probReveal = [probReveal; mean_reveal];
    errorReveal = [errorReveal; error_reveal];
    allReveal = [allReveal; reveal];
    allConf = [allConf; confidence];
    allUncertain = [allUncertain; uncertainity];
    allCur = [allCur; curiosity];
end

%% statistical significance test for Phase 2 (Follows the template of Kang et al (2009))

conf = [confs; confs];
uncertain = [uncertains; uncertains];
mdl3 = fitlm([confs uncertains],probReveal(1,:)'); %Phase 2, condition 1 regression result
mdl3
mdl4 = fitlm([confs uncertains],probReveal(2,:)'); %Phase 2, condition 2 regression result
mdl4

%% statistical significance test with normalized Curiosity for phase 1 - we want to test if they are both u-shape and same 
mdl1 = fitlm([allConf(1:numCond1,:) allUncertain(1:numCond1,:)],allCur(1:numCond1,:));
mdl1 %Phase 1, condition 1 regression result
mdl2 = fitlm([allConf(numCond1+1:end,:) allUncertain(numCond1+1:end,:)],allCur(numCond1+1:end,:));
mdl2 %Phase 1, condition 2 regression result