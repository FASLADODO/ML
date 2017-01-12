%Qiao Huang 9/11/2016
%   Sources:
%       Detail Formula: 
%           http://practicalcryptography.com/miscellaneous/machine-learning/guide-mel-frequency-cepstral-coefficients-mfccs/
%       Methodology Synopsis: 
%           http://recognize-speech.com/feature-extraction/mfcc
%       Nyquest frequency Problem: 
%           http://dsp.stackexchange.com/questions/6499/help-calculating-understanding-the-mfccs-mel-frequency-cepstrum-coefficients
%       Detailed theories: 
%           http://www2.cmpe.boun.edu.tr/courses/cmpe362/spring2014/files/projects/MFCC%20Feature%20Extraction.pdf
%       Methodology:
%           http://mirlab.org/jang/books/audioSignalProcessing/speechFeatureMfcc.asp?title=12-2%20MFCC
%       Book (Roger Jang):
%           http://mirlab.org/jang/books/audioSignalProcessing/

function Vector = mfcc(filename)
[original_file, fs] = audioread(filename);
[Data_length,Channel_Num] = size(original_file);

% Frame the signal (Cutting into Salami)
N_fft = power(2, ceil(log2(1e-2 * fs))); % 10 ms per frame!!
remainder_when_divided_by_Nfft = rem(Data_length,N_fft);
% zeros compensate
file_with_the_length_of_NFFT_multiples = [original_file; zeros(N_fft-remainder_when_divided_by_Nfft,Channel_Num)]; %make it N's multiple
frame_number = floor(length(file_with_the_length_of_NFFT_multiples)*2/N_fft);
pointer = 1;
Fri = 1;
Framed_file_Matrix = zeros(N_fft,Channel_Num,frame_number-1);

% Dimensions!!!
[length_of_data_points_per_frame, number_of_channels, number_of_frames] = size(Framed_file_Matrix);

for Frj = 1:number_of_channels  %left and right
    for Frk = 1:number_of_frames
        Framed_file_Matrix(:,Frj,Frk) = file_with_the_length_of_NFFT_multiples(pointer:pointer+N_fft-1,Frj);
        pointer = pointer + (N_fft/2);
    end
    pointer = 1;
end

%Hamming Window and FFT
window = hamming(N_fft);
Window = fft(window,N_fft);
FFT_x = 1;
for Fk = 1:number_of_frames
    for Fj = 1:number_of_channels
        FFT_of_the_file_matrix(:,Fj,Fk) = fft(Framed_file_Matrix(:,Fj,Fk),N_fft);
        FFT_of_the_file_matrix_with_window(:,Fj,Fk) = FFT_of_the_file_matrix(:,Fj,Fk) .* Window;
        Halved_FFT_File_Matrix(:,Fj,Fk) = FFT_of_the_file_matrix_with_window(1:N_fft/2,Fj,Fk);
    end
end

%Triangular Bandpass Filter Bank
Melbank_Num = 26;
Hertz_range = [20, fs/2];
Mel_range = [1125*log(1+20/700), 1125*log(1+fs/1400)];
Mel_sequence = linspace(Mel_range(1), Mel_range(2), Melbank_Num);
Hertz_sequence = 700*(exp(Mel_sequence/1125)-1);
Hertz_position = ceil(Hertz_sequence * N_fft / fs);

Tri_Bank = zeros(N_fft/2,Melbank_Num-2);
MFSC_ChannelNum_FrameNum = zeros(Melbank_Num-2,number_of_channels,number_of_frames);
for Ti = 1:Melbank_Num-2
    for Tk = 1:N_fft/2
        if (Tk < Hertz_position(Ti))
            Tri_Bank(Tk,Ti) = 0;
        elseif ((Tk >= Hertz_position(Ti)) && (Tk < Hertz_position(Ti+1)))
            Tri_Bank(Tk,Ti) = (Tk - Hertz_position(Ti)) / (Hertz_position(Ti+1) - Hertz_position(Ti));
        elseif ((Tk >= Hertz_position(Ti+1)) && (Tk < Hertz_position(Ti+2)))
            Tri_Bank(Tk,Ti) = (Hertz_position(Ti+2) - Tk) / (Hertz_position(Ti+2) - Hertz_position(Ti+1));
        elseif (Tk >= Hertz_position(Ti+2))
            Tri_Bank(Tk,Ti) = 0;
        end
    end
    
%   Show the Shape
%     hold on;
%     plot([1:N_fft/2]*fs/N_fft,Tri_Bank(:,Ti));
%     title('Triangular Filter Bank N = 26');
%     xlabel('Frequency (Hz)');
%     ylabel('Amplitude (V/V)');

%   Filter the signal
    for Tk = 1:number_of_frames
        for Tj = 1:number_of_channels
            for Tkk = Hertz_position(Ti):Hertz_position(Ti+2)-1
                MFSC_ChannelNum_FrameNum(Ti,Tj,Tk) = MFSC_ChannelNum_FrameNum(Ti,Tj,Tk)+(abs(Halved_FFT_File_Matrix(Tkk,Tj,Tk)))^2*Tri_Bank(Tkk,Ti);
            end
            Log_MFSC_ChannelNum_FrameNum(Ti,Tj,Tk) = log(MFSC_ChannelNum_FrameNum(Ti,Tj,Tk));
        end
    end
end

%Discrete Cosine Transform (Wiki:DCT-II)
N_mfcc = 13;
MFCC_ChannelNum_FrameNum = zeros(N_mfcc,number_of_channels,number_of_frames)
for Ck = 1:number_of_frames
    for Cj = 1:number_of_channels
        for Ckk = 1:N_mfcc
            for Ci = 1:Melbank_Num-2
                 MFCC_ChannelNum_FrameNum(Ckk,Cj,Ck) = MFCC_ChannelNum_FrameNum(Ckk,Cj,Ck) + Log_MFSC_ChannelNum_FrameNum(Ci,Cj,Ck).*cos(pi*(Ci+1/2)*Ckk/(Melbank_Num-2));
            end
        end
    end
end

% Empty the 1st MFCC
MFCC_ChannelNum_FrameNum(1,:,:) = 0;
% Fill in Energy instead
for Ek = 1:number_of_frames
    for Ej = 1:number_of_channels
        for Ei = 1:N_fft
            MFCC_ChannelNum_FrameNum(1,Ej,Ek) = MFCC_ChannelNum_FrameNum(1,Ej,Ek) + Framed_file_Matrix(Ei,Ej,Ek)^2;
        end
    end
end

%Derivatives
N_D = 2;
Deno_D = 0;
for Dd = 1:N_D
    Deno_D = Deno_D + Dd^2;
end
Deno_D = 2*Deno_D;

DMFCC_ChannelNum_Frame_Num = zeros(N_mfcc,number_of_channels,number_of_frames)
for Dj = 1:number_of_channels
    for Di = 1+N_D:number_of_frames-N_D
        for Dnd = 1:N_D
            DMFCC_ChannelNum_Frame_Num(1:end,Dj,Di) = DMFCC_ChannelNum_Frame_Num(1:end,Dj,Di) + Dnd * (MFCC_ChannelNum_FrameNum(1:end,Dj,Di+Dnd)-MFCC_ChannelNum_FrameNum(1:end,Dj,Di-Dnd));
        end
        DMFCC_ChannelNum_Frame_Num(1:end,Dj,Di) = DMFCC_ChannelNum_Frame_Num(1:end,Dj,Di)/Deno_D;
    end
end

D2MFCC_ChannelNum_FrameNum = zeros(N_mfcc,number_of_channels,number_of_frames)
for D2j = 1:number_of_channels
    for D2i = 1+2*N_D:number_of_frames-2*N_D
        for D2nd = 1:N_D
            % From 2 to the end: We dropped the 1st coefficient.
            D2MFCC_ChannelNum_FrameNum(1:end,D2j,D2i) = D2MFCC_ChannelNum_FrameNum(1:end,D2j,D2i) + D2nd * (DMFCC_ChannelNum_Frame_Num(1:end,D2j,D2i+D2nd)-DMFCC_ChannelNum_Frame_Num(1:end,D2j,D2i-D2nd));
        end
        D2MFCC_ChannelNum_FrameNum(1:end,D2j,D2i) = D2MFCC_ChannelNum_FrameNum(1:end,D2j,D2i)/Deno_D;
    end
end

%Feature Vectors
Vector = zeros(number_of_frames,N_mfcc*3);

    %E-MFCC
    for Vi = 1:N_mfcc
        Vector(:,Vi) = MFCC_ChannelNum_FrameNum(Vi,1,:);
    end
    %E-MFCC-D1
    for Vi = 1+N_mfcc:N_mfcc*2
        Vector(:,Vi) = DMFCC_ChannelNum_Frame_Num(Vi-N_mfcc,1,:);
    end
    %E-MFCC-D2
    for Vi = 1+N_mfcc*2:N_mfcc*3
        Vector(:,Vi) = D2MFCC_ChannelNum_FrameNum(Vi-2*N_mfcc,1,:);
    end
    
    flag = zeros(1,number_of_frames);
    
    %Delete empty frames
    for Vk = 1:number_of_frames
        for Vi = 1:N_mfcc*3
            % Delete the frames with a feature value of 0 (Basically at the boundary.)
            if(0==(Vector(Vk,Vi)))
                flag(Vk) = 1;
            end
            % Delete the frames with a feature value of NaN (Basically at the boundary.)
            if(isnan(Vector(Vk,Vi)))
                flag(Vk) = 1;
            end
        end
        % Delete the frames with low energy (Remove silent frames.)
        threshold = max( Vector(:, 1) )./1e4;
        if(Vector(Vk,1) < threshold)
            flag(Vk) = 1;
        end
    end
    index = find(flag==1)
    Vector(index,:) = [];
     
    %Normalization
    for(Vi = 1:N_mfcc*3)
         Vector(:,Vi) = (Vector(:,Vi)-mean(Vector(:,Vi)))./std(Vector(:,Vi));
    end

end
