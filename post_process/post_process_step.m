clc;
close all;
clear;
%%  Add path to raw data folder
addpath('raw_data/');
%% Load table from raw data
loaded_data = load('60g__step_26-June-2023_17-50-32_V_0-5Hz_all_1mA');
new_name = 'data';
assignin('base', new_name, loaded_data.data);
clear loaded_data

T = array2table(data, 'VariableNames', {'Time', 'CommandedVoltage', 'Position', 'MeasuredInputVoltage', 'MeasuredCurrent'});
T(226002 : 230001,:) = [];

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

%%  Apply band pass filter to MeasuredCurrent
filtered_current = movmean(T.MeasuredCurrent ,400);
%%  Compare MeasuredCurrent and filtered_current
figure;
plot(T.Time,T.MeasuredCurrent,'linestyle','-');
hold on;
plot(T.Time,filtered_current,'linestyle','-');
title('Measured Current vs. Time','fontsize',14);
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
title('Position and Measured Current vs. Time','fontsize',14);

%% Downsample data to 100 Hz
PositionCrop = T.Position(1:20:end);
VoltageCrop = T.MeasuredInputVoltage(1:20:end);
CurrentCrop = filtered_current(1:20:end);

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
writematrix(VoltageCrop, "Step_Voltage.txt") %Change output file name for each variation of sine experiment
writematrix(PositionCrop, "Step.txt")
writematrix(CurrentCrop, "Step_Current.txt")

% Time (s) | Commanded voltage (V) |  Position (mm) | Measured input
% voltage (V) | Measured current (mA)