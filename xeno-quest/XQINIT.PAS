Unit XQInit;
interface
implementation
uses Overlay;
 const
  OvrMaxSize = 32768;
begin
 OvrInit('Xq.ovr');
 if OvrResult <> ovrOk then
 begin
   case OvrResult of
     ovrError      : Writeln('Program has no overlays.');
     ovrNotFound   : Writeln('Overlay file not found.');
     else Writeln           ('Overlay Manager Error.')
   end;
   Halt(1)
 end
 else
 begin
  OvrInitEms;
  if OvrResult = ovrOK then Writeln('Using EMS Memory for overlay swapping.');
  OvrSetBuf(OvrMaxSize);
 end;
end.
