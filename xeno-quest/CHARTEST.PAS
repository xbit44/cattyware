uses charchng;
const
  C : CharDefs =(24,60,90,60,24,255,189,60,60,60,54,54,66,66,195,195);
var
  I : Integer;

begin
 ChangeChar(C ,Chr(128));
 write(Chr(128));
 readln;
 ResetChars
end.