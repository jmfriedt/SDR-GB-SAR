clear all
more off
Nfreq=11                % channels 1 to 11
total_length=70000*2;
fs=6.25;                 % acquisition sampling freq (MHz)
finc=5.0;
switch_control=0;
error_threshold=0.05;
error_number=100;
disp_curv=0;

pkg load zeromq
pkg load signal
pkg load sockets
pkg load instrument-control   % switch control

if (exist("serial") != 3)
    disp("No Serial Support");
endif   

s1 = serial("/dev/ttyACM1");  % Open the port
pause(.1);                    % Optional wait for device to wake up 
set(s1, 'baudrate', 115200);  % communication speed
set(s1, 'bytesize', 8);       % 5, 6, 7 or 8
set(s1, 'parity', 'n');       % 'n' or 'y'
set(s1, 'stopbits', 1);       % 1 or 2
set(s1, 'timeout', 123);      % 12.3 Seconds as an example here

sck=socket(AF_INET, SOCK_STREAM, 0); 
server_info=struct("addr","127.0.0.1","port",5556);
connect(sck,server_info);

error_vector=ones(error_number,1);

for m=1:44
	m
% pause
tic 
send(sck,'s');                   % reset frequency to min value
for frequence=1:Nfreq
 printf("\n");
 system(['/sbin/iwconfig wlx00c0ca95e17c channel ',num2str(1+(frequence-1)*finc/5)]);
 system('/sbin/iwconfig wlx00c0ca95e17c | grep Fre');
 tmpmes1=[];
 tmpmes2=[];
 while (length(tmpmes1)<(total_length))
   sock1 = zmq_socket(ZMQ_SUB);  % socket-connect-opt-close = 130 us
   zmq_connect   (sock1,"tcp://127.0.0.1:5555");
   zmq_setsockopt(sock1, ZMQ_SUBSCRIBE, "");
   recv=zmq_recv(sock1, total_length*8*2, 0); % *2: interleaved channels
   value=typecast(recv,"single complex"); % char -> float
   tmpv1=value(1:2:length(value));
   tmpv2=value(2:2:length(value));
   zmq_close (sock1);
   toolow=findstr(abs(tmpv2)<error_threshold*max(abs(tmpv2)),error_vector');
   if (!isempty(toolow)) 
        if ((toolow(1)>100)&&(max(abs(tmpv2))>0.05))
           tmpmes1=[tmpmes1 tmpv1(1:toolow(1)-99)];
           tmpmes2=[tmpmes2 tmpv2(1:toolow(1)-99)];
           printf("+");
        end
        if ((toolow(end)<length(tmpv2)-100)&&(max(abs(tmpv2))>0.05))
           tmpmes1=[tmpmes1 tmpv1(toolow(end)+99:end)];
           tmpmes2=[tmpmes2 tmpv2(toolow(end)+99:end)];
           printf("-");
        end
   else 
        if (max(abs(tmpv2))>0.05) 
           tmpmes1=[tmpmes1 tmpv1];
           tmpmes2=[tmpmes2 tmpv2];
           printf("!");
	else
   	   printf("*");   % transmitter shutdown
	end
   end
   clear tmpv1 tmpv2
 end
 if (disp_curv==1)
    subplot(211);plot(real(tmpmes1))
    subplot(212);plot(real(tmpmes2))
    pause(1)
 end
 mes1(:,frequence)=tmpmes1(1:total_length);
 mes2(:,frequence)=tmpmes2(1:total_length);
 send(sck,'+');
 pause(0.07)
end
toc
eval(['save -v6 ',num2str(m),'rtol.mat mes1 mes2']);
srl_write(s1,"-"); pause(32);
L=size(mes1)(1);
t=[0:L-1]/fs;
tplot=[-10:10]/fs;  % time for plotting individual spectra
binwidth=fs*1e6/L;    % 135 Hz bin width
span=floor(finc/fs*L);  % bin index increment every time LO increases by 1 MHz
spectrum1=zeros(floor((finc*Nfreq+3*fs)/fs*L),1); % extended spectral range
spectrum2=zeros(floor((finc*Nfreq+3*fs)/fs*L),1); % ... resulting from spectra concatenation
w=hanning(L);
for f=0:Nfreq-1
   f
      %spectrum1(f*span+1:f*span+L)=spectrum1(f*span+1:f*span+L)+w.*fftshift(fft(mes1(:,f+1))); % center of FFT in the middle
      %spectrum2(f*span+1:f*span+L)=spectrum2(f*span+1:f*span+L)+w.*fftshift(fft(mes2(:,f+1))); % center of FFT in the middle
      spectrum1(f*span+1:f*span+L)=spectrum1(f*span+1:f*span+L)+fftshift(fft(mes1(:,f+1))); % center of FFT in the middle
      spectrum2(f*span+1:f*span+L)=spectrum2(f*span+1:f*span+L)+fftshift(fft(mes2(:,f+1))); % center of FFT in the middle
%   end
end

badindexsta=1; 
% badindexsta=find(spectrum2(1:floor(length(spectrum2)/2))==0);  badindexsta=badindexsta(end);
badindexsto=find(spectrum2(floor(length(spectrum2)/2):end)==0);badindexsto=badindexsto(1);
spectrum1=spectrum1(badindexsta+1:badindexsto);
spectrum2=spectrum2(badindexsta+1:badindexsto);
x=fftshift(ifft((spectrum1./spectrum2).*hamming(length(spectrum1))));
fs2=finc*Nfreq+3*fs;
N=200;
tplot=[-N:N]/fs2;
res(:,m)=abs(x(floor(length(x)/2)-N:floor(length(x)/2)+N));
plot(tplot,res(:,m)/max(res(:,m)));
axis([-1.1 1.1 0 1])
hold on
end
