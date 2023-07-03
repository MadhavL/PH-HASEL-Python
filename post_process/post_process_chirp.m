clc;
close all;
clear;

%%  Add path to raw data folder
addpath('raw_data/');

%%  Load data
loaded_data = load('60g__chirp_26-June-2023_17-46-23_V_0-5Hz_all_1mA');
data = loaded_data.data;
clear loaded_data

%%  Convert data to table
T = array2table(data, 'VariableNames', {'Time', 'CommandedVoltage', 'Position', 'MeasuredInputVoltage', 'MeasuredCurrent'});

%%  Scale data
T.CommandedVoltage = T.CommandedVoltage * 2000;
T.MeasuredInputVoltage = T.MeasuredInputVoltage * 2000;
T.MeasuredCurrent = T.MeasuredCurrent * 2 / 1000;

%%  Plot CommandedVoltage and MeasuredInputVoltage vs Time
fs = 1000;  % sampling frequency in Hz
figure;
plot(T.Time,T.CommandedVoltage);
hold on
plot(T.Time,T.MeasuredInputVoltage);
title('Commanded Voltage and Measured Input Voltage vs. Time','fontsize',14);
xlabel('Time (s)','fontsize',12);
ylabel('Voltage (V)','fontsize',12);

%%  Scale and plot Position (unfiltered) vs Time
T.Position = T.Position * 4 + 30;
T.Position = T.Position - mean(T.Position(1:1000));
figure;
plot(T.Time, T.Position);
title('Position (raw)','fontsize',14);
xlabel('Time (s)','fontsize',12);
ylabel('Position (mm)','fontsize',12);

%%  Compute and plot power spectrum of MeasuredCurrent
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
low_freq = 0.2;  % low cutoff frequency in Hz
high_freq = 6;  % high cutoff frequency in Hz

%%  Apply band pass filter to MeasuredCurrent
filtered_current = bandpass(T.MeasuredCurrent,[low_freq high_freq],fs);

%%  Plot MeasuredCurrent and filtered_current vs Time
figure;
plot(T.Time,T.MeasuredCurrent,'linestyle','-');
hold on;
plot(T.Time,filtered_current,'linestyle','-');
title('Measured Current vs. Time (unfiltered vs filtered)','fontsize',14);
xlabel('Time (s)','fontsize',12);
ylabel('Measured Current (A)','fontsize',12);


%%  Remove outliers from Position data
T.Position(T.Position < 0) = NaN;
T.Position = fillmissing(T.Position, 'previous');

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

%%  Select range of interest for chirp
PositionCrop = T.Position([1000:93000, 101000:193000, 201000:293000, 301000:393000, 401000:493000, 501000:593000]);
VoltageCrop = T.MeasuredInputVoltage([1000:93000, 101000:193000, 201000:293000, 301000:393000, 401000:493000, 501000:593000]);
CurrentCrop = filtered_current([1000:93000, 101000:193000, 201000:293000, 301000:393000, 401000:493000, 501000:593000]);

%% Downsample data to 100 Hz
PositionCrop = PositionCrop(1:20:end);
VoltageCrop = VoltageCrop(1:20:end);
CurrentCrop = CurrentCrop(1:20:end);

%%  Plot cropped data
TimeCrop = linspace(0, size(PositionCrop, 1) / 100, size(PositionCrop, 1));

figure;
plot(TimeCrop, VoltageCrop, '.');
title('Measured Input Voltage vs. Time','fontsize',14);
xlabel('Time (s)','fontsize',12);
ylabel('Voltage (V)','fontsize',12);

figure;
plot(TimeCrop, PositionCrop, '.');
title('Position vs. Time','fontsize',14);
xlabel('Time (s)','fontsize',12);
ylabel('Position (mm)','fontsize',12);

figure;
plot(TimeCrop, CurrentCrop, '.');
title('Measured Current vs. Time','fontsize',14);
xlabel('Time (s)','fontsize',12);
ylabel('Measured Current (A)','fontsize',12);

%%  Save cropped data to file
writematrix(VoltageCrop, "Chirp_Voltage.txt")
writematrix(PositionCrop, "Chirp.txt")
writematrix(CurrentCrop, "Chirp_Current.txt")
