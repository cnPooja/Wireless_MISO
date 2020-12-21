txradio = comm.SDRuTransmitter('Platform','N200/N210/USRP2','IPAddress','192.168.10.1,192.168.10.3');

frmLen = 354;       % frame length
numPackets = 1000;
N = 2;              % maximum number of Tx antennas
M = 1;              % maximum number of Rx antennas
pLen = 8;

W= hadamard(pLen);
pilots = W(:, 1:N);

txradio.ChannelMapping = [1 2];
txradios.CenterFrequency= [1.1 1.2] *1e9;
txradios.Gain = [1 1];

% Create comm.BPSKModulator and comm.BPSKDemodulator System objects(TM)
P = 4;				% modulation order
bpskMod = comm.BPSKModulator;
qpskMod = comm.QPSKModulator;

% Create comm.OSTBCEncoder and comm.OSTBCCombiner System objects
ostbcEnc = comm.OSTBCEncoder;

% Pre-allocate variables for speed
H = zeros(frmLen, N, M);

% Loop over several EbNo points
for idx = 1:inf
  
    
    % Loop over the number of packets
    for packetIdx = 1:numPackets
        % Generate data vector per frame
        data = randi([0 P-1], frmLen, 1);
        
        % Modulate data
        modData = qpskMod(data);

        %disp(modData);
        % Alamouti Space-Time Block Encoder
        encData = ostbcEnc(modData);
        
        %disp(encData);
        % Prepend pilot symbols for each frame
        txSig = [pilots; encData];
        
        txradio(txSig);
        
        disp(data);
    end
    
end
                
release(txradio);
