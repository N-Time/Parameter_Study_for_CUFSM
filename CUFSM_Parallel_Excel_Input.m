tic
%BWS
%6 December 2001
%Matlab Parameter Study Example Problem
%
%Objective:
%To show how CUFSM's routine can be called from within your own m-files, in order to perform
%specialized plotting, parameter studies, simulations, etc...
%
%
%Consider a channel section with varying lip length in pure compression
%Millimeters are selected for length, Newtons for force, MPa = N/mm^2 for stress
%the reference compression stress is 1.0MPa is examined
%
%
%The basic variables will be
%    r_____b_____r
%   |             |d
%   |
%   |
%   |
%   |
%   h
%   |
%   |
%   |
%   |             
%   |             |d
%    r_____b_____r
%h = the web height
%b = the flange width
%d = the lip length
%t = thickness
%r = conner radius
%
%File
Filename = 'test.xlsx';
Sheet = 1;
%
%Read range
%Columns out-line
Rh = 'A'; Rb = 'B'; Rd = 'C'; Rt = 'D'; Rr = 'E';
RE = 'G'; Rv = 'H';
%Rows----numbers of specimens
RWstart = '3';
RWend = '6';
%
%Write range
%Columns
WA = 'O';
WlambdaL = 'P';
WPcrL = 'Q';
WlambdaD = 'R';
WPcrD = 'S';
%
%Boundary Conditions
%BC: ['S-S'] a string specifying boundary conditions to be analyzed:
%'S-S' simply-pimply supported boundary condition at loaded edges
%'C-C' clamped-clamped boundary condition at loaded edges
%'S-C' simply-clamped supported boundary condition at loaded edges
%'C-F' clamped-free supported boundary condition at loaded edges
%'C-G' clamped-guided supported boundary condition at loaded edges
BC = 'C-C';
%
h=xlsread(Filename,Sheet,[Rh,RWstart,':',Rh,RWend]); %mm
b=xlsread(Filename,Sheet,[Rb,RWstart,':',Rb,RWend]); %mm
d=xlsread(Filename,Sheet,[Rd,RWstart,':',Rd,RWend]); %mm
t=xlsread(Filename,Sheet,[Rt,RWstart,':',Rt,RWend]); %mm
r=xlsread(Filename,Sheet,[Rr,RWstart,':',Rr,RWend]); %mm
EE = xlsread(Filename,Sheet,[RE,RWstart,':',RE,RWend]); %mm
vv = xlsread(Filename,Sheet,[Rv,RWstart,':',Rv,RWend]); %mm
%
%middle profile
for i = 1:length(h)
    if r(i)==0
        h(i) = h(i)-t(i);
        b(i) = b(i)-t(i);
        d(i) = d(i)-t(i)/2;
    else
        r(i) = r(i)-t(i)/2;
        h(i) = h(i)-2*r(i);
        b(i) = b(i)-2*r(i);
        d(i) = d(i)-r(i);
    end
end
%
%Area
AA = (h+2.*b+2*d+2.*pi.*r).*t;
%
%Define the lengths
% could choose lengths, like lengths=[10:10:100 150:50:1000];, or even easier
lengths=1:10:1500; %evenly space 50 points in logspace from 10^1 to 10^3
%
%Define the material properties
%These are the same inputs that are required in the graphical version of CUFSM
%
%No springs or constraints.
springs=0;
constraints=0;
%
%GBTcon
GBTcon.glob = 0;
GBTcon.dist = 0;
GBTcon.local = 0;
GBTcon.other = 0;
%
%m_all: m_all{length#}=[longitudinal_num# ... longitudinal_num#],longitudinal terms m for all the lengths in cell notation
% each cell has a vector including the longitudinal terms for this length
for j = 1:length(lengths)
    m_all{j} = 1;
end
%
%neigs - the number of eigenvalues to be determined at length (default=10)
num_eig = 1;
%Calculation
Pcr = zeros(length(h),4);
parfor i = 1:length(h)
    %prop: [matnum Ex Ey vx vy G] 6 x nmats
    prop=[1 EE(i) EE(i) vv(i) vv(i) EE(i)/(2*(1+vv(i)))];
    Pcr(i,:) = CUFSM_Parallel_Excel( ...
        h(i),b(i),d(i),t(i),r(i),prop,lengths, ...
        springs,constraints,GBTcon,BC,m_all,num_eig);
end
xlswrite(Filename,Pcr,Sheet,[WlambdaL,RWstart,':',WPcrD,RWend])
xlswrite(Filename,AA,Sheet,[WA,RWstart,':',WA,RWend])
toc