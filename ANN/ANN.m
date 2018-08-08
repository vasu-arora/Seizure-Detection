clc;
clear;

XTrain = csvread('EqualTrainX.csv');
%YTrain = csvread('EqualTrainY.csv');
[~,~,YTrain] = xlsread('EqualTrainY.csv');
XTest = csvread('EqualTestX.csv');
%YTest = csvread('EqualTestY.csv');
[~,~,YTest] = xlsread('EqualTestY.csv');

[Train_nrow, ncol] = size(XTrain);

n_hidden_layer = 2;

% w_op_layer[], w_hidden_layer[][][]
%no of neurons per hidden layer: n_neurons[]

n_neurons{0} = n_col;

for i = 1:n_hidden_layer
	n_neurons{i} = n_col;
end

for i = 1:n_hidden_layer
	for j = 1:n_neurons{i-1}
		for k = 1:n_neurons{i}
			w_hidden_layer{i,j,k} = 1;
		end
	end
end

