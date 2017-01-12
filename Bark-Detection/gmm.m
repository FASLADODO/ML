% Qiao Huang - GMM Simulation - OCT.25,2016
% function mfcc: Vector Matrix = mfcc(filename, N_fft)
clear all; close all;

% Training Set
DOG = zeros(1,39);
BELL = zeros(1,39);
DOOR = zeros(1,39);
WALK = zeros(1,39);
for i = 1:20
    % Dog training 1~20
    DOG = [DOG;mfcc(['Dog',num2str(i),'.wav'])];
    
    % Bell training 1~15
    if (i < 8)
        BELL = [BELL;mfcc(['Bell',num2str(i),'.mp3'])];
    elseif (9 < i && i < 16)
        BELL = [BELL;mfcc(['Bell',num2str(i),'.wav'])];
    end
    
    % Door and walk training 1~4
    if (i < 5)
        DOOR = [DOOR;;mfcc(['Door',num2str(i),'.wav'])];
        WALK = [WALK;;mfcc(['Walk',num2str(i),'.wav'])];
    end
end


% Train GMM
k = 15;
BELLmodel = fitgmdist(BELL, k, 'CovarianceType', 'diagonal', 'RegularizationValue', 0.1);
DOGmodel = fitgmdist(DOG, k, 'CovarianceType', 'diagonal', 'RegularizationValue', 0.1);
DOORmodel = fitgmdist(DOOR, k, 'CovarianceType', 'diagonal', 'RegularizationValue', 0.1);
WALKmodel = fitgmdist(WALK, k, 'CovarianceType', 'diagonal', 'RegularizationValue', 0.1);

% Test GMM
DOGtest_1 = mfcc('Dog21.wav');
DOGtest_2 = mfcc('Dog22.wav');
DOGtest_3 = mfcc('Dog23.wav');
DOGtest_4 = mfcc('Dog24.wav');
DOGtest_5 = mfcc('Dog25.wav');
DOGtest_6 = mfcc('Dog26.wav');
DOGtest_7 = mfcc('Dog27.wav');
DOGtest_8 = mfcc('Dog28.wav');
DOGtest_9 = mfcc('Dog29.wav');
DOGtest_10 = mfcc('Dog30.wav');
DOGtest_11 = mfcc('Dog31.wav');
DOGtest_12 = mfcc('Dog32.wav');
DOGtest_13 = mfcc('Dog33.wav');
DOGtest_14 = mfcc('Dog34.wav');
DOGtest_15 = mfcc('Dog35.wav');
DOGtest_16 = mfcc('Dog36.wav');
DOGtest_17 = mfcc('Dog37.wav');
DOGtest_18 = mfcc('Dog38.wav');
DOGtest_19 = mfcc('Dog39.wav');
DOGtest_20 = mfcc('Dog40.wav');

Belltest_1 = mfcc('Bell16.wav');
Belltest_2 = mfcc('Bell17.wav');
Belltest_3 = mfcc('Bell18.wav');
Belltest_4 = mfcc('Bell19.wav');
Belltest_5 = mfcc('Bell20.wav');
Belltest_6 = mfcc('Bell21.wav');
Belltest_7 = mfcc('Bell22.wav');
Belltest_8 = mfcc('Bell23.wav');

Doortest_1 = mfcc('Door5.wav')
Doortest_2 = mfcc('Door6.wav')

Walktest_1 = mfcc('Walk5.wav');
Walktest_2 = mfcc('Walk6.mp3');
Walktest_3 = mfcc('Walk7.mp3');
test = Walktest_3;

[testlength,y] = size(test);

countbell = 0;
countdog = 0;
countwalk = 0;
countdoor = 0;

prob_bell = log10(pdf(BELLmodel, test));
prob_dog = log10(pdf(DOGmodel, test));
prob_walk = log10(pdf(WALKmodel, test));
prob_door = log10(pdf(DOORmodel, test));

for i = 1:testlength
    [M, index] = max([prob_bell(i), prob_dog(i), prob_walk(i), prob_door(i)]);
    switch index
        case 1
            countbell = countbell + 1;
        case 2
            countdog = countdog + 1;
        case 3
            countwalk = countwalk + 1;
        case 4
            countdoor = countdoor + 1;
    end
end

[M, index_decision] = max([countbell, countdog, countwalk, countdoor]);
    switch index_decision
        case 1
            display('Bell!');
        case 2
            display('Dog!');
        case 3
            display('Walk!');
        case 4
            display('Door!');
    end
