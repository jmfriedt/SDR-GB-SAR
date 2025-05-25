pkg load signal
ref=rand(1024,1); ref=ref-mean(ref); % reference signal, mean value 0
mes=0.4*ref;                         % surveillance signal with Direct Signal Interference (0 delay)

% time delayed copies of the reference in the surveillance
mes(1:length(ref)-2)=mes(1:length(ref)-2)+0.7*ref(1+2:length(ref)-2+2);  % unwanted
mes(1:length(ref)-5)=mes(1:length(ref)-5)+0.2*ref(1+5:length(ref)-5+5);  % target1
mes(1:length(ref)-9)=mes(1:length(ref)-9)+0.24*ref(1+9:length(ref)-9+9); % target2

Ndsi=3; % range of Direct Signal Interferences (in sample index)
p=1;
for m=-Ndsi:Ndsi
  if m<=0
     mat(:,p)=[ref(-m+1:end) ; zeros(-m,1)]; % time delayed copies of the reference
  else
     mat(:,p)=[zeros(m,1) ; ref(1:end-m)];
  end
  p=p+1;
end
w=pinv(mat)*mes       % least square optimal weights of the reference in the surveillance
mescleaned=mes-mat*w; % remove reference from surveillance in the +/-Ndsi range

Ncor=20;
plot([-Ncor:Ncor],abs(xcorr(ref,mes,Ncor)))
hold on
plot([-Ncor:Ncor],abs(xcorr(ref,mescleaned,Ncor)))
xlabel('delay (samples)')
ylabel('correlation (a.u.)')
text(0,5,'DSI (0 delay)','rotation',90)
text(2,5,'DSI (2 delay, unwanted)','rotation',90)
text(5,25,'target 1 (wanted)','rotation',90)
text(9,25,'target 2 (wanted)','rotation',90)
