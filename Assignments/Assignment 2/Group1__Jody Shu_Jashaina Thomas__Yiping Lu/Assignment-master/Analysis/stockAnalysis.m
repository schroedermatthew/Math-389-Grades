close all;clear;clc
stock=readtable("stockData.xlsx");
stock=table2cell(stock);

for i=1:size(stock,1)
    date(i)=stock{i,2};
end
%date=datetime(stock{:,2},'InputFormat','dd-MMM-yyyy');

stock_num=cell2mat(stock(:,[6,7,8,15,16,17,24,25,26]));
data1=stock_num(:,1:3);
data2=stock_num(:,4:6);
data3=stock_num(:,7:9);
P1=data1(:,1);%price
V1=data1(:,2);%volume
S1=data1(:,3);%split_coeff
P2=data2(:,1);%price
V2=data2(:,2);%volume
S2=data2(:,3);%split_coeff
P3=data3(:,1);%price
V3=data3(:,2);%volume
S3=data3(:,3);%split_coeff
X1=[diff(P1)]./(P1(1:end-1)+eps);%get relative increase/decrease from the current value
Y1=[diff(V1)]./(V1(1:end-1)+eps);
Z1=[diff(S1)]./(S1(1:end-1)+eps);
X2=[diff(P2)]./(P2(1:end-1)+eps);%get relative increase/decrease from the current value
Y2=[diff(V2)]./(V2(1:end-1)+eps);
Z2=[diff(S2)]./(S2(1:end-1)+eps);
X3=[diff(P3)]./(P3(1:end-1)+eps);%get relative increase/decrease from the current value
Y3=[diff(V3)]./(V3(1:end-1)+eps);
Z3=[diff(S3)]./(S3(1:end-1)+eps);
com1=[X1,Y1,Z1];
com2=[X2,Y2,Z2];
com3=[X3,Y3,Z3];
%find the idx for the trading days of each month
i=1;
for y=2010:2019
    for m=1:12
        idx{i,:}=find(month(date)==m & year(date)==y);
    i=i+1;
    end
    
end
idx{119}=idx{119}(1:end-1);%count one less because of the percentage equation


%apply the idx to the data to get X matrix for each company
for i=1:length(idx)
    c1{i}=com1(idx{i},:);
    c2{i}=com2(idx{i},:);
    c3{i}=com3(idx{i},:);
end
%Find X'X
for i=1:length(idx)
A1{i}=transpose(c1{i})*c1{i};
A2{i}=transpose(c2{i})*c2{i};
A3{i}=transpose(c3{i})*c3{i};
end
%apply svd to get p (eignevectors) and s (eigenvalues)
[U1,S1,VT1]=cellfun(@svd,A1,'uniformOutput',false);
[U2,S2,VT2]=cellfun(@svd,A2,'uniformOutput',false);
[U3,S3,VT3]=cellfun(@svd,A3,'uniformOutput',false);
%get sigma values by sqrt the eigenvalues
for i=1:length(idx)
sigma1{i}=diag(sqrt(S1{i}));
sigma2{i}=diag(sqrt(S2{i}));
sigma3{i}=diag(sqrt(S3{i}));
end
figure
for i=1:length(idx)
    plot3(sigma1{i}(1),sigma1{i}(2),sigma1{i}(3),'r*')    
    hold on    

    plot3(sigma2{i}(1),sigma2{i}(2),sigma2{i}(3),'ko')
  
    plot3(sigma3{i}(1),sigma3{i}(2),sigma3{i}(3),'m+')
    
end
xlabel('Price')
ylabel('Volume')
zlabel('Split\_Coeff')
grid on
hold off
legend('Boeing','Lockheed','BlackRock','Centroids','Location','NE')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
Data=[cell2mat(sigma1)';cell2mat(sigma2)';cell2mat(sigma3)'];
opts=statset('Display','final');
[idex,C]=kmeans(Data,3,'Distance','cityblock','Replicates',5,'Options',opts);
figure;
cla;gca;
plot3(Data(idex==1,1),Data(idex==1,2),Data(idex==1,3),'r.','Markersize',12)
hold on;
plot3(Data(idex==2,1),Data(idex==2,2),Data(idex==2,3),'b.','Markersize',12)
plot3(Data(idex==3,1),Data(idex==3,2),Data(idex==3,3),'g.','Markersize',12)
plot3(C(:,1),C(:,2),C(:,3),'mx','MarkerSize',15,'Linewidth',3)
legend('Cluster 1','Cluster 2','Cluster 3','Centroids','Location','NE')
title('Kmeans Cluster SVD Assignment')
hold off
grid on