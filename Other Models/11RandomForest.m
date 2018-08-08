clc;
clear;

XTrain = csvread('EqualTrainX.csv');
%YTrain = csvread('EqualTrainY.csv');
[~,~,YTrain] = xlsread('EqualTrainY.csv');
XTest = csvread('EqualTestX.csv');
%YTest = csvread('EqualTestY.csv');
[~,~,YTest] = xlsread('EqualTestY.csv');

sztrain = size(XTrain);
ntrain = sztrain(1);
sztest = size(XTest);
ntest = sztest(1);

bagsize = (70/100)*ntrain;
bagsize = int16(bagsize);

% training all 100 trees
for i = 1:100
	bagrows = [repelem(true, bagsize) repelem(false, ntrain-bagsize)];
	bagper = randperm(ntrain);
	bagrows = bagrows(bagper);
	bagTrainX = XTrain(bagrows, :);
	bagTrainY = YTrain(bagrows,:);
	DTModel{i} = fitctree(bagTrainX, bagTrainY);
end


%on the training data

%prediction on training data
for i = 1:100
	predicted2{i} = predict(DTModel{i}, XTrain);
end

%creating empty categorical array
cat = predicted2{1,1}(1,1);
cat(end) = [];

final_pred = categorical.empty(ntrain,0);

%taking mode of all predicted models
for i = 1:ntrain
	cat = [];
	for j = 1:100
		cat = [cat predicted2{1,j}(i,1)];
    end
    cat = categorical(cat);
	final_pred(i,1) = mode(cat);
end

%final_pred = table(final_pred)
%final_pred = table2array(final_pred)
%YTrain = table2array(YTrain);
%YTrain = cell2mat(YTrain);
%YTrain = table2cell(YTrain);
YTrain = categorical(YTrain);
C = confusionmat(YTrain, final_pred);

parameters = params(C(1,1), C(1,2), C(2,1), C(2,2));



%prediction on test data
for i = 1:100
	predicted{i} = predict(DTModel{i}, XTest);
end

%creating empty categorical array
cat = predicted{1,1}(1,1);
cat(end) = [];

final_pred = categorical.empty(ntest,0);

%taking mode of all predicted models
for i = 1:ntest
	cat = [];
	for j = 1:100
		cat = [cat predicted{1,j}(i,1)];
    end
    cat = categorical(cat);
	final_pred(i,1) = mode(cat);
end

%final_pred = table(final_pred)
%final_pred = table2array(final_pred)
%YTest = table2array(YTest);
%YTest = cell2mat(YTest);
YTest = categorical(YTest);
C = confusionmat(YTest, final_pred);

[sensitivity, specificity, recall, precision, fdr, accuracy] = params(C(1,1), C(1,2), C(2,1), C(2,2))


function [sensitivity, specificity, recall, precision, fdr, accuracy] = params(tp, fp, fn, tn)
	sensitivity = tp/(tp+fn)
	recall = sensitivity
	specificity = tn/(fp+tn)
	precision = tp/(tp+fp)
	fdr = fp/(fp+tp)
	accuracy = (tp+tn)/(tp+tn+fp+fn)
end
