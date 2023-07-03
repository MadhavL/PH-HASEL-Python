All_Data = [readmatrix("Chirp.txt"); readmatrix('Sine_1.txt'); readmatrix('Sine_2.txt'); 
    readmatrix('Sine_3.txt'); readmatrix('Sine_4.txt'); readmatrix('Sine_5.txt'); 
    readmatrix('Sine_6.txt'); readmatrix('Sine_7.txt'); readmatrix("Step.txt")];
All_Data = fillmissing(All_Data, 'constant', 0); %In case there are any NaN values

All_Voltage = [readmatrix("Chirp_Voltage.txt"); readmatrix('Sine_1_Voltage.txt'); 
    readmatrix('Sine_2_Voltage.txt'); readmatrix('Sine_3_Voltage.txt'); 
    readmatrix('Sine_4_Voltage.txt'); readmatrix('Sine_5_Voltage.txt'); 
    readmatrix('Sine_6_Voltage.txt'); readmatrix('Sine_7_Voltage.txt'); 
    readmatrix("Step_Voltage.txt")];
All_Voltage = fillmissing(All_Voltage, 'constant', 0); %In case there are any NaN values

All_Current = [readmatrix("Chirp_Current.txt"); readmatrix('Sine_1_Current.txt'); 
    readmatrix('Sine_2_Current.txt'); readmatrix('Sine_3_Current.txt'); 
    readmatrix('Sine_4_Current.txt'); readmatrix('Sine_5_Current.txt'); 
    readmatrix('Sine_6_Current.txt'); readmatrix('Sine_7_Current.txt'); 
    readmatrix("Step_Current.txt")];
All_Current = fillmissing(All_Current, 'constant', 0); %In case there are any NaN values

Time = linspace(0, size(All_Data, 1) / 100, size(All_Data, 1));

figure;
plot(Time,All_Data);
title('Position vs. Time','fontsize',14);
xlabel('Time (s)','fontsize',12);
ylabel('Position (mm)','fontsize',12);

figure;
plot(Time,All_Voltage);
title('Voltage vs. Time','fontsize',14);
xlabel('Time (s)','fontsize',12);
ylabel('Voltage (V)','fontsize',12);

figure;
plot(Time,All_Current);
title('Current vs. Time','fontsize',14);
xlabel('Time (s)','fontsize',12);
ylabel('Current (A)','fontsize',12);