
%% Convert excel data to mat file
%Author: Hridoy

%%%
p=detectImportOptions("data.xlsx");
T = readtable("data.xlsx");


%  get the length 
len= length(T.latitude);
% data=T;
data.house_hold=cell(len,1);

data.house_hold=T.lastname;
%%get all data in the household

data.latitude=T.latitude;
data.longitude=T.longitude;
data.members=cell(1,len);
% data.biomarkers=
%% Assign name into data
for i=1:len
    m= T.Members(i);
%     data.members(i)=cell(1,m);
    data.members{1,i}=split(T.Name(i),',');
    
end
%%
data.biomarkers=cell(1,len);
%% Assign name into data
for j=1:len
    m= T.Members(j);
    for k=1:m
        data.biomarkers{k,j}=T(j,5+k);
    end
        
%     data.members(i)=cell(1,m);
%     data.members{1,i}=split(T.Name(i),',');
    
end

