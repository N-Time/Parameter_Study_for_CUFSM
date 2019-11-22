%Consider a channel section with varying lip length in pure compression
%Millimeters are selected for length, Newtons for force, MPa = N/mm^2 for stress
%the reference compression stress is 1.0MPa is examined
%
%
function Critical = CUFSM_Parallel_Excel(h,b,d,t,r,prop,lengths, ...
    springs,constraints,GBTcon,BC,m_all,num_eig)
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
    %-----------------------------------------------------------------
    %Enter in a loop where the lip length is varied and analysis is run
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
    [curve,shapes]=strip(prop,node,elem,lengths,springs,constraints,GBTcon,BC,m_all,num_eig);
    %[curve,shapes]=strip(prop,node,elem,lengths,1,springs,constraints);
    %Save all the inputs and the resuls for analysis "i"
    data.prop=prop;
    data.node=node;
    data.elem=elem;
    data.lengths=lengths;
    data.springs=springs;
    data.constraints=constraints;
    data.curve=curve;
    data.shapes=shapes;
    %
    %save within the loop in case of abnormal termination of param study
    %deleted in order to parallel

    %POST-PROCESSING AND PLOTTING
    %Let's plot our buckling curve results
    modeindex=1;
    curvedata = zeros(length(lengths),2);
    for j = 1:length(lengths)
        curvedata(j,1) = lengths(j); % half-wavelength
        curvedata(j,2) = data.curve{1,j}(modeindex,2); % sigma cr
    end
    %[lambda Pcr]
    Critical = Pcrmin(curvedata(:,1),curvedata(:,2));