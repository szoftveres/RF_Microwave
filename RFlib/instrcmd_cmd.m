function instrcmd_cmd (device, cmd)
    fprintf(device, cmd);
    flush(device, "output");
end
