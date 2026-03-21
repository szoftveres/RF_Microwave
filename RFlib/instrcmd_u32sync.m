function instrcmd_u32sync (device, cmd, syncword)
    flush(device, "input");
    fprintf(device, cmd);
    flush(device, "output");
    preamble = uint32(0);
    response = [];
    do
        res = read(device, 1);
        preamble = bitshift(preamble, -8);
        preamble = preamble + (uint32(res) * 16777216);
        response = [response res];
    until (preamble == syncword);
end
