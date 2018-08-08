clear;
clc;

TrainX = csvread('EqualTrainX.csv');
%YTrain = csvread('EqualTrainY.csv');
[~,~,TrainY] = xlsread('EqualTrainY.csv');
TestX = csvread('EqualTestX.csv');
%YTest = csvread('EqualTestY.csv');
[~,~,TestY] = xlsread('EqualTestY.csv');

NaiveBaeysMdl = fitcnb(TrainX,TrainY);

Prediction = predict(NaiveBaeysMdl, TestX);

tp = 0;
fp = 0;
tn = 0;
fn = 0;
for i = 1:106
    if char(Prediction{i,1}) == char(TestY{i,1})
        if(char(Prediction{i,1}) == 'N')
            tp = tp+1;
        end
        if(char(Prediction{i,1}) == 'I')
            tn = tn+1;
        end
    end
    if char(Prediction{i,1}) ~= char(TestY{i,1})
        if(char(Prediction{i,1}) == 'N')
            fn = fn+1;
        end
        if(char(Prediction{i,1}) == 'I')
            fp = fp+1;
        end
    end
end

[sensitivity, specificity, recall, precision, fdr, accuracy] = params(tp, fp, fn, tn);

function [sensitivity, specificity, recall, precision, fdr, accuracy] = params(tp, fp, fn, tn)
	sensitivity = tp/(tp+fn)
	recall = sensitivity
	specificity = tn/(fp+tn)
	precision = tp/(tp+fp)
	fdr = fp/(fp+tp)
	accuracy = (tp+tn)/(tp+tn+fp+fn)
end
