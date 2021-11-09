function Num = extractNum(A)

%function extracts numbers from the survey_likert stored responses

B = regexp(A,'\d*','Match');
for ii= 1:length(B)
  if ~isempty(B{ii})
      Num(ii,1)=str2double(B{ii}(end));
  else
      Num(ii,1)=NaN;
  end
end

end