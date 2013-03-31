function options = setOptions()
    options.filter_options.hpf_freq = 1;         % high pass filtering
    options.filter_options.hpf_bandwidth = 0.5; 
    options.filter_options.hpf_ripple = 0.05; 
    options.filter_options.hpf_attenuation = 80; 
    
    options.filter_options.lpf_freq = 70;         % low pass filtering
    options.filter_options.lpf_bandwidth = 2.5; 
    options.filter_options.lpf_ripple = 0.01; 
    options.filter_options.lpf_attenuation = 40; 
    
    options.filter_options.notch_freq = 60;         % notch filtering
    options.filter_options.notch_bandwidth1 = 3; 
    options.filter_options.notch_bandwidth2 = 1; 
    options.filter_options.notch_ripple = 0.05; 
    options.filter_options.notch_attenuation = 80; 
    
    options.channel_options.ref_chan = 44;      % reference channel
    options.channel_options.eeg_chans = 1:64;   % eeg channels
    options.channel_options.ext_chans = [];     % external channels
    options.channel_options.do_reref = 1; 
    options.channel_options.rejection_options.measure = [1 1 1]; 
    options.channel_options.rejection_options.z = [3 3 3]; 
    options.channel_options.bad_channels = []; 
    options.channel_options.exclude_EOG_chans = 1; 
    options.channel_options.interp_after_ica = 1; 
    options.channel_options.op_ref_chan = []; 

    options.ica_options.EOG_channels = [22 24]; 
    options.ica_options.keep_ICA = 0; 
    options.ica_options.run_ica = 1; 
    options.ica_options.k_value = 25; 
    options.ica_options.component_rejection_on = 1; 
    options.ica_options.ica_channels = 1:64; 
    options.ica_options.rejection_options.measure = [1 1 1 1 1]; 
    options.ica_options.rejection_options.z = [3 3 3 3 3]; 

    % no epoching, no epoch interpolation
end
