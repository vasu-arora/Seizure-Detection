clc;
clear;

XTrain = csvread('EqualTrainX.csv');
%YTrain = csvread('EqualTrainY.csv');
[~,~,YTrain] = xlsread('EqualTrainY.csv');
XTest = csvread('EqualTestX.csv');
%YTest = csvread('EqualTestY.csv');
[~,~,YTest] = xlsread('EqualTestY.csv');
tic;
[r, c] = size(YTrain);
for i = 1:r
	if YTrain{i} == 'I'
		YT{i} = 1;
	end
	if YTrain{i} == 'N'
		YT{i} = -1;
	end
end

net = feedforwardnet(10, 'trainbr');
XT = XTrain';
YT = cell2mat(YT);
net = train(net,XT,YT);
Y = net(XT);
perf = perform(net,Y,YT);


for i = 1:r
	if Y(1,i)>=0
		YPred(i,1) = 'I';
	end
	if Y(1,i)<0
		YPred(i,1) = 'N';
	end
end

YPred = cellstr(YPred);

YPred = categorical(YPred);
YTrain = categorical(YTrain);
C = confusionmat(YTrain, YPred);

XT2 = XTest';
Y2 = net(XT2);
[r, c] = size(YTest);

for i = 1:r
	if Y2(1,i)>=0
		YPred2(i,1) = 'I';
	end
	if Y2(1,i)<0
		YPred2(i,1) = 'N';
	end
end


YPred2 = cellstr(YPred2);

YPred2 = categorical(YPred2);
YTest = categorical(YTest);
C = confusionmat(YTest, YPred2);

[sensitivity, specificity, recall, precision, fdr, accuracy] = params(C(1,1), C(1,2), C(2,1), C(2,2));

toc;

function [sensitivity, specificity, recall, precision, fdr, accuracy] = params(tp, fp, fn, tn)
	sensitivity = tp/(tp+fn)
	recall = sensitivity
	specificity = tn/(fp+tn)
	precision = tp/(tp+fp)
	fdr = fp/(fp+tp)
	accuracy = (tp+tn)/(tp+tn+fp+fn)
end


%sensitivity =0.9138
%recall =0.9138
%specificity =1
%precision = 1
%fdr =0
%accuracy = 0.9528
