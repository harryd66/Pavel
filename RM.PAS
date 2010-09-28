uses WinDos;

const
 Remove: PChar = 'D:\TEST\TEST';
 CDrive: Byte = 3;

begin
 RemoveDir(Remove);
 Writeln(IOResult);

 Writeln('There is no longer a directory at ', Remove,'.');
end.

