clear all;
close all;
clc;
load('mazumdar');
figure(1);
[x1,y1] = plotmf(fis1,'input',1);
plot(x1,y1,'LineWidth',2);
grid on;
set(gca,'GridLineStyle','--');
ylabel('Degree of membership','FontWeight','bold','FontAngle','italic');
xlabel('Energy Level','FontWeight','bold','FontAngle','italic');
legend('Small','Average','High');
figure(2);
[x2,y2] = plotmf(fis1,'input',2);
plot(x2,y2,'LineWidth',2);
ylabel('Degree of membership','FontWeight','bold','FontAngle','italic');
xlabel('Distance to Base station(BS)','FontWeight','bold','FontAngle','italic');
legend('Near','Modarate','Distant');
grid on;
set(gca,'GridLineStyle','--');
figure(3);
[x3,y3] = plotmf(fis1,'output',1);
plot(x3,y3,'LineWidth',2);
ylabel('Degree of membership','FontWeight','bold','FontAngle','italic');
xlabel('Fuzzy fitness1','FontWeight','bold','FontAngle','italic');
legend('Very weak','Weak','Medium','Strong','Very strong');
grid on;
set(gca,'GridLineStyle','--');