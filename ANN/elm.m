clc;
clear;

XTrain = csvread('EqualTrainX.csv');
XTrain = XTrain(:,1:11);
%YTrain = csvread('EqualTrainY.csv');
[~,~,YTrain] = xlsread('EqualTrainY.csv');
XTest = csvread('EqualTestX.csv');
XTest = XTest(:,1:11);
%YTest = csvread('EqualTestY.csv');
[~,~,YTest] = xlsread('EqualTestY.csv');
tic;
[r, c] = size(YTrain);
for i = 1:r
	if YTrain{i} == 'I'
		YT{i} = 100;
	end
	if YTrain{i} == 'N'
		YT{i} = -100;
	end
end

XT = XTrain';

YT = cell2mat(YT);

n_hidden_neurons = 100;

for i = 1:11
	for j = 1:n_hidden_neurons
		const_wt{i,j} = 100*rand(1);
	end
end

for i = 1:r
	for j = 1:n_hidden_neurons
		XT2(i,j) = 0;
		for k = 1:11
			XT2(i,j) = XT2(i,j) + XTrain(i,k)*const_wt{k,j};
		end
		%activation function can be changed
	end
end

net = fitnet([]);

XT2 = XT2';

net = train(net, XT2, YT);
Y = net(XT2);
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


%On testing data

[r2, c2] = size(YTest);

for i = 1:r2
	for j = 1:n_hidden_neurons
		XT3(i,j) = 0;
		for k = 1:11
			XT3(i,j) = XT3(i,j) + XTest(i,k)*const_wt{k,j};
		end
		%activation function can be changed
	end
end

XT3 = XT3';
Y3 = net(XT3);

for i = 1:r2
	if Y3(1,i)>=0
		YPred3(i,1) = 'I';
	end
	if Y3(1,i)<0
		YPred3(i,1) = 'N';
	end
end

YPred3 = cellstr(YPred3);

YPred3 = categorical(YPred3);
YTest = categorical(YTest);
C2 = confusionmat(YTest, YPred3);

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
