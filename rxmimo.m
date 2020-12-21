
rxRadios = comm.SDRuReceiver('Platform','N200/N210/USRP2','IPAddress','192.168.10.1');

rxRadios.ChannelMapping = 1;
rxRadios.CenterFrequency= 1.1*1e9;
rxRadios.Gain = 3;

frmLen = 354;           % frame length
maxNumErrs = 300;       % maximum number of errors
maxNumPackets = 3000;   % maximum number of packets
EbNo = 0:2:12;          % Eb/No varying to 12 dB
N = 2;                  % number of Tx antennas
M = 1;                  % number of Rx antennas
pLen = 8;               % number of pilot symbols per frame
W = hadamard(pLen);
pilots = W(:, 1:N);     % orthogonal set per transmit antenna
H = zeros(frmLen, N, M);

% Pre-allocate variables for speed
HEst = zeros(frmLen, N, M);
ber_Estimate = zeros(3,length(EbNo));
ber_Known    = zeros(3,length(EbNo));

errorCalc1 = comm.ErrorRate;

bpskDemod = comm.BPSKDemodulator('OutputDataType','double');
ostbcComb = comm.OSTBCCombiner;

for i = 1:inf
    [rxSig, datalen] = rxRadios();
    %disp(datalen);
     % Channel Estimation
        %   For each link => N*M estimates
                HEst(1,:,:) = (pilots(:,:).' * double(rxSig(1:pLen, :))) / pLen;
         %HEst(1,:,:) = (double(rxSig(1:pLen, :))) / pLen;
        %   assume held constant for the whole frame
        HEst = HEst(ones(frmLen, 1), :, :);
        
     % Combiner using estimated channel
        decDataEst = ostbcComb(double(rxSig(pLen+1:end,:)), double(HEst));

        % Combiner using known channel
        decDataKnown = ostbcComb(double(rxSig(pLen+1:end,:)), ...
                           squeeze(H(pLen-7:end,:,:,:)));
    
                         % ML Detector (minimum Euclidean distance)
        demodEst   = bpskDemod(decDataEst);      % estimated
        demodKnown = bpskDemod(decDataKnown);    % known
        
  
        % Calculate and update BER for current EbNo value
        %   for estimated channel
      %  ber_Estimate(:,idx) = errorCalc1(int16(rxSig), int16(demodEst));
        %   for known channel
       % ber_Known(:,idx)    = errorCalc2(rxSig, demodKnown);

   % disp(demodEst);
  %  disp(demodKnown);
    disp(rxSig);
end
release(rxRadios);



