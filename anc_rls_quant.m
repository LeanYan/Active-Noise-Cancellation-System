close all
clear all

Mp=8;
Ms=8;
I = 25;
N=5000;
Br =32;
load('channel_8.mat');
SNR = 30;
var_v = 10^(-SNR/10);
mu=0.01;
lambda = 0.995;
epsilon = 1e-2;
learn_rls = zeros(1,N);

for l=1:I
    l
    input = rand(1,N);
    quantize_v(input, Br);
    mod_input = wgn(1,N,0);
    
    w_lms = zeros(Mp,1);
    s_rls = zeros(Ms,1);
    
    g = zeros(1,N);
    f = zeros(1,N);
    u  = zeros(1,Mp);
    v  = zeros(1,Ms);
    yw = zeros(1,Ms);
    f_u = zeros(1,Mp);
    
   %for rls
   P = (1/epsilon)*eye(Ms,Ms); 
    P1 = (1/epsilon)*eye(Mp,Mp); 
    for i=1:N
        u = [input(i) u(1:Mp-1)];
        v = [mod_input(i) v(1:Ms-1)];
        y = quantize(u*w_lms, Br);
        yw = [y yw(1:Ms-1)];
        
        filt_u = quantize(u*channels, Br);
        f_u = [filt_u f_u(1:Mp-1)];
        g(i)= quantize(u*channelp, Br)+quantize(var_v*randn, Br) - quantize(yw*channels, Br);% v*channels;
        g(i)= quantize(g(i), Br);
        aa = quantize_v(P1*f_u',Br);
        bb = quantize((1/lambda)*f_u*aa,Br);
        gamma1 = 1/(1+bb);
        cc = quantize_v(f_u'*gamma1, Br);
        gg1 = quantize_v((1/lambda)*P1*cc, Br);
        w_lms = w_lms + quantize_v(gg1*g(i), Br);
         P1 = quantize_v((1/lambda)*P1, Br) - quantize_v((gg1*gg1'/gamma1), Br);
    end
      learn_rls = learn_rls + abs(g).^2;
end

learn_rls = 10*log10(learn_rls/I);
plot(1:N,learn_rls,'r');
title('Mean Square Error (M=8)')
xlabel('Iterations')
ylabel('MSE (dB)')
grid
axis tight