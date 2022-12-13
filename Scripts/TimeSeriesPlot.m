clear, clc
close all

db = load('C:\Users\joeby\Proj-SleepAnalysisSRS\Database\P1\Data.mat');

EKG = db.EKG;
EKG_r = reshape(EKG, [1, size(EKG,1)*size(EKG,2)]);
TIME = linspace(0, size(db.TimeStep,2)*10, size(EKG,1)*size(EKG,2));

plot(TIME, EKG_r)
xlabel('Time (s)')
ylabel('EKG Reading (V)')