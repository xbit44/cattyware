program MakeCode;
uses crt;
var
   SYSOPNAME,
   BBSNAME    : String;
   Code       : String;
   CodeIn     : String;
   I,LSN      : integer;
   Sum        : Integer;
   Registered : Boolean;

begin
 textbackground(0);
 clrscr;
 textcolor(14);
 Writeln;
 Write(' Enter Code... ');
 Readln( CodeIn);
 Write(' Enter SysOp Name... ');
 Readln( SYSOPNAME);
 Write(' Enter BBS Name... ');
 Readln( BBSNAME);
 while Length(BBSName)< 25 do BBSName :=BBSName +' ';
 Registered :=false;
 Code:='';
 LSN := Length(SysOpName);
 if LSN >0 then
  begin
   for I:=1 to LSN do
    Begin
     Sum := ord(SysOpName[I]) + ord(BBSName[I]);
     Sum:= Sum Mod 33;
     Sum :=Sum+48;
     Code :=Code+Chr(Sum)
    end
  end;
 Writeln;
 If CodeIn=Code then Write(' Registered ');
 Write(' The Code Is.. ');
 textcolor(15);
 Write(Code);
 textcolor(14);
 Write('');

Readln;

end.