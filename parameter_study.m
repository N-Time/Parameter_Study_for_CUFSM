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
%    _____b_____
%   |           |d
%   |
%   |
%   |
%   |
%   h
%   |
%   |
%   |
%   |
%   |_____b_____|d
%
%h = the web height
%b = the flange width
%d = the lip length
%t = thickness
%
%
%
h=100; %mm
b=30; %mm
d=5; %mm
t=1; %mm
r=0; %mm
%
%Define the material properties
%These are the same inputs that are required in the graphical version of CUFSM
%prop: [matnum Ex Ey vx vy G] 6 x nmats
prop=[1 2.0E5 2.0E5 0.3 0.3 2.0E5/(2*(1+0.3))];
%
%Define the lengths
% could choose lengths, like lengths=[10:10:100 150:50:1000];, or even easier
lengths=logspace(1,3,50); %evenly space 50 points in logspace from 10^1 to 10^3
%m_all: m_all{length#}=[longitudinal_num# ... longitudinal_num#],longitudinal terms m for all the lengths in cell notation
% each cell has a vector including the longitudinal terms for this length
for j = 1:length(lengths)
    m_all{j} = 1;
end
%GBTcon
GBTcon.glob = 0;
GBTcon.dist = 0;
GBTcon.local = 0;
GBTcon.other = 0;
%
%No springs or constraints.
springs=0;
constraints=0;
%
%-----------------------------------------------------------------
%Enter in a loop where the lip length is varied and analysis is run
for i=1:length(d)
    %node: [node# x z dofx dofz dofy dofrot stress] nnodes x 8;
    %elem: [elem# nodei nodej t matnum] nelems x 5;
   if r == 0
        node=[1 b   d   1 1 1 1 1.0
            2 b   0.0    1 1 1 1 1.0
            3 0.0 0.0    1 1 1 1 1.0
            4 0.0 h      1 1 1 1 1.0
            5 b   h      1 1 1 1 1.0
            6 b   h-d 1 1 1 1 1.0];
        elem=[1 1 2 t 1
            2 2 3 t 1
            3 3 4 t 1
            4 4 5 t 1
            5 5 6 t 1];
    else
        node=[1  b+2*r   d+r   1 1 1 1 1.0
            2  b+2*r   r        1 1 1 1 1.0
            3  b+r*(1+cos(pi/8))    r*(1-sin(pi/8)) 1 1 1 1 1.0
            4  b+r*(1+cos(pi/4))    r*(1-cos(pi/4)) 1 1 1 1 1.0
            5  b+r*(1+sin(pi/8))    r*(1-cos(pi/8)) 1 1 1 1 1.0
            6  b+r     0.0      1 1 1 1 1.0
            7  r       0.0      1 1 1 1 1.0
            8  r*(1-sin(pi/8))      r*(1-cos(pi/8)) 1 1 1 1 1.0
            9  r*(1-cos(pi/4))      r*(1-cos(pi/4)) 1 1 1 1 1.0
            10 r*(1-cos(pi/8))      r*(1-sin(pi/8)) 1 1 1 1 1.0
            11 0.0     r        1 1 1 1 1.0
            12 0.0     r+h      1 1 1 1 1.0
            13 r*(1-cos(pi/8))      h+r*(1+sin(pi/8)) 1 1 1 1 1.0
            14 r*(1-cos(pi/4))      h+r*(1+cos(pi/4)) 1 1 1 1 1.0
            15 r*(1-sin(pi/8))      2*r+h-r*(1-cos(pi/8)) 1 1 1 1 1.0
            16 r       2*r+h    1 1 1 1 1.0
            17 r+b     2*r+h    1 1 1 1 1.0
            18 b+r*(1+sin(pi/8))    2*r+h-r*(1-cos(pi/8)) 1 1 1 1 1.0
            19 b+r*(1+cos(pi/4))    h+r*(1+cos(pi/4)) 1 1 1 1 1.0
            20 b+r*(1+cos(pi/8))    h+r*(1+sin(pi/8)) 1 1 1 1 1.0
            21 b+2*r   r+h      1 1 1 1 1.0
            22 b+2*r   r+h-d 1 1 1 1 1.0];
        elem=[1 1 2 t 1
            2 2 3 t 1
            3 3 4 t 1
            4 4 5 t 1
            5 5 6 t 1
            6 6 7 t 1
            7 7 8 t 1
            8 8 9 t 1
            9 9 10 t 1
            10 10 11 t 1
            11 11 12 t 1
            12 12 13 t 1
            13 13 14 t 1
            14 14 15 t 1
            15 15 16 t 1
            16 16 17 t 1
            17 17 18 t 1
            18 18 19 t 1
            19 19 20 t 1
            20 20 21 t 1
            21 21 22 t 1];
    end
   %double the number of elements to improve the discretization
   %this is the same as using the Double Elem button in the graphical version
   [node,elem]=doubler(node,elem);
   [node,elem]=doubler(node,elem); % Quattour Elem
   %perform the finite strip analysis
   [curve,shapes]=strip(prop,node,elem,lengths,springs,constraints,GBTcon,'S-S',m_all,10);
   %[curve,shapes]=strip(prop,node,elem,lengths,1,springs,constraints);
   %Save all the inputs and the resuls for analysis "i"
   data(i).prop=prop;
   data(i).node=node;
   data(i).elem=elem;
   data(i).lengths=lengths;
   data(i).springs=springs;
   data(i).constraints=constraints;
   data(i).curve=curve;
   data(i).shapes=shapes;
   %
   save datafile data
   %save within the loop in case of abnormal termination of param study
end
toc

tic
%POST-PROCESSING AND PLOTTING
%Let's take a look at our cross-sections
figure(1)
%flags:[node# element# mat# stress# stresspic coord constraints springs origin] 1 means show
flags=[0 0 0 0 0 0 1 1 1]; %these flags control what is plotted, node#, elem#
for i=1:length(d)
    axesnum=subplot(2,2,i);
    crossect(data(i).node,data(i).elem,axesnum,data(i).springs,data(i).constraints,flags)
    title(['d=',num2str(d(i))])
end

%
%Let's plot our buckling curve results
modeindex=1;
for i=1:length(d)
    for j = 1:length(lengths)
        curvedata{i}(j,1) = lengths(j); % half-wavelength
        curvedata{i}(j,2) = data(i).curve{1,j}(modeindex,2); % sigma cr
    end
end

figure(2)
for i=1:length(d)
    semilogx(curvedata{i}(:,1),curvedata{i}(:,2),'-x')
    str{i}=['d=',num2str(d(i))];%plot solid lines w/ symbols
    hold on
    Critical(i,:) = Pcrmin(curvedata{i}(:,1),curvedata{i}(:,2));
end
legend(str)
axis([40 1000 0 400])
title('Buckling Curves from Parameter Study')
xlabel('half-wavelength (mm)')
ylabel('Buckling Stress (MPa)') %because a refernec load of 1MPa was used this is
                                %the buckling stress instead of just the load factor

%%
%Let's look at some mode shapes too.
modeindex=1;
undefv=1;
scale=1;
springs=0;
%%%% find the minimum

local_lengthindex=[23 23 23 23]; %this is the step that has the local minimum
dist_lengthindex=[33 37 40 42]; %this is the step that has the distortional minimum
%%%%
figure(3)
for i=1:4
    axesshape=subplot(2,2,i);
    lengthindex=local_lengthindex(i);
    dispshap(undefv,data(i).node,data(i).elem, ...
        data(i).shapes{1,lengthindex}(:,modeindex),axesshape,scale,springs);
    title(['LB, d=',num2str(d(i)),'mm \lambda=',num2str(data(i).curve{1,lengthindex}(modeindex,1)), ...
        'mm, P_{cr}=',num2str(data(i).curve{1,lengthindex}(modeindex,2)),'MPa'])
end

figure(4)
for i=1:4
    axesshape=subplot(2,2,i);
    lengthindex=dist_lengthindex(i);
    dispshap(undefv,data(i).node,data(i).elem, ...
        data(i).shapes{1,lengthindex}(:,modeindex),axesshape,scale,springs);
    title(['DB, d=',num2str(d(i)),'mm \lambda=',num2str(data(i).curve{1,lengthindex}(modeindex,1)), ...
        'mm, P_{cr}=',num2str(data(i).curve{1,lengthindex}(modeindex,2)),'MPa'])
end
toc