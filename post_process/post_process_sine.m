clc;
close all;
clear;
%%  Add path to raw data folder
addpath('raw_data/');
%% Load table from raw data
loaded_data = load('60g__sin_26-June-2023_18-11-43_V_0-5Hz_all_1mA'); %Change file name here for each sine experiment
new_name = 'data';
assignin('base', new_name, loaded_data.data);
clear loaded_data

T = array2table(data, 'VariableNames', {'Time', 'CommandedVoltage', 'Position', 'MeasuredInputVoltage', 'MeasuredCurrent'});
% T(120002 : 180001,:) = []; %Only for 1st sine experiment, since the data has last 30s empty

T.CommandedVoltage = T.CommandedVoltage * 2000;
T.MeasuredInputVoltage = T.MeasuredInputVoltage * 2000;
T.MeasuredCurrent = T.MeasuredCurrent * 2 / 1000;

%%  Compute and plot power spectrum of MeasuredCurrent
fs = 1000;  % sampling frequency in Hz
y = fft(T.MeasuredCurrent);
n = length(T.MeasuredCurrent); % number of samples
f = (0:n-1)*(fs/n);      % frequency range
power = abs(y).^2/n;     % power of the DFT
figure;
plot(f,power)
xlabel('Frequency')
ylabel('Power')
title('Power Spectrum of Measured Current')

%%  Define filter coefficients
high_freq = 0.50;  % high cutoff frequency in Hz

%%  Apply band pass filter to MeasuredCurrent
filtered_current_ = lowpass(T.MeasuredCurrent,high_freq,fs);
filtered_current = movmean(filtered_current_,50);
%%  Compare MeasuredCurrent and filtered_current
figure;
plot(T.Time,T.MeasuredCurrent,'linestyle','-');
hold on;
plot(T.Time,filtered_current,'linestyle','-');
title('Measured Current (unfiltered vs filtered)','fontsize',14);
xlabel('Time (s)','fontsize',12);
ylabel('Measured Current (A)','fontsize',12);

%% Plot filtered current
figure;
plot(T.Time, filtered_current);
ylabel('Measured Current (A)','fontsize',12);
xlabel('Time (s)','fontsize',12);
title('Filtered Current','fontsize',14);

%% Plot measured vs commanded voltage
figure;
plot(T.Time,T.CommandedVoltage);
hold on
plot(T.Time,T.MeasuredInputVoltage);
ylabel('Voltage (V)','fontsize',12);
xlabel('Time (s)','fontsize',12);
title('Commanded vs Measured voltage','fontsize',14);

%% Scale and plot raw Position

T.Position = T.Position * 4 + 30;
T.Position = T.Position - mean(T.Position(1:1000));

figure;
plot(T.Time, T.Position);
ylabel('Position (mm)','fontsize',12);
xlabel('Time (s)','fontsize',12);
title('Position (raw)','fontsize',14);

%% Remove outliers from Position

T.Position(T.Position < 0) = NaN;
T.Position = fillmissing(T.Position, 'spline');

figure;
plot(T.Time, T.Position);
ylabel('Position (mm)','fontsize',12);
xlabel('Time (s)','fontsize',12);
title('Position (outliers removed)','fontsize',14);

%%  Plot Position and filtered_current vs Time
figure;
yyaxis left;
plot(T.Time,T.Position,'linestyle','-');
ylabel('Position (mm)','fontsize',12);
yyaxis right;
plot(T.Time,filtered_current,'linestyle','-');
ylabel('Measured Current (A)','fontsize',12);
xlabel('Time (s)','fontsize',12);
title('Position and Measured Current (filtered) vs. Time','fontsize',14);

%% Select range of interest for sine

%Range of interest for sine: %1s-12s, 13-24, 25-36... 37-48, 49-60
PositionCrop = T.Position([2000:24000, 26000:48000, 50000:72000, 74000:96000, 98000:120001]);
VoltageCrop = T.MeasuredInputVoltage([2000:24000, 26000:48000, 50000:72000, 74000:96000, 98000:120001]);
CurrentCrop = filtered_current([2000:24000, 26000:48000, 50000:72000, 74000:96000, 98000:120001]);

%% Downsample data to 100 Hz
PositionCrop = PositionCrop(1:20:end);
VoltageCrop = VoltageCrop(1:20:end);
CurrentCrop = CurrentCrop(1:20:end);

%%  Plot cropped data
TimeCrop = linspace(0, size(PositionCrop, 1) / 100, size(PositionCrop, 1));

figure;
plot(TimeCrop, VoltageCrop);
ylabel('Voltage (V)','fontsize',12);
xlabel('Time (s)','fontsize',12);
title('Voltage (filtered & cropped) vs. Time','fontsize',14);

figure;
plot(TimeCrop,CurrentCrop);
ylabel('Current (A)','fontsize',12);
xlabel('Time (s)','fontsize',12);
title('Current (filtered & cropped) vs. Time','fontsize',14);

figure;
plot(TimeCrop,PositionCrop);
ylabel('Position (mm)','fontsize',12);
xlabel('Time (s)','fontsize',12);
title('Position (filtered & cropped) vs. Time','fontsize',14);
%% Save cropped data to file
writematrix(VoltageCrop, "Sine_7_Voltage.txt") %Change output file name for each variation of sine experiment
writematrix(PositionCrop, "Sine_7.txt")
writematrix(CurrentCrop, "Sine_7_Current.txt")

% Time (s) | Commanded voltage (V) |  Position (mm) | Measured input
% voltage (V) | Measured current (mA)