{$M,32768,0,55768}
 Program XQTerm;
 Uses Crt,Dos,BBSUnit,Ansi_X,Mouse,BBSScrn,Utility,Game,XQChChg;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Const
  Baudrates : Array[1..7] of longint = (1200,2400,4800,9600,14400,19200,38400);
  LArrow = #75; RArrow = #77; UArrow = #72; DArrow = #80;

 Type JSPOS = record { Describes joystick position }
		x,
		y : integer;
	       end;
  XBBS = Object(TBBS)
         end;
 DialRec = Record
             Name    : NameString;
             Number  : NameString;
             Baud    : LongInt;
            end;
 FonList   = Array[1..100] of DialRec;
 CMDARRAY  = Array[1..20] OF String;

 CMDBOX = OBJECT
            X,Y,XS,YS  : Byte;
            CMDS       : CMDARRAY;
            COL,TCol,
            CMDNUM     : BYTE;
            Procedure INIT(XI,YI,XSI,YSI:Byte;COMNDS: CMDARRAY;CL,TL:BYTE);
            Procedure Update(COMNDS: CMDARRAY);
            Procedure SHOW;
            Procedure PROCESS(var Cmd : Char);
          end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 var
  OnlineTime    : Word;
  StatusChanged : Boolean;
  BPPtr	        : Byte;
  DD            : CmdBox;
  FL            : FonList;
  SC            : CmdArray;
  PgOff         : Integer;
  JoyCenter     : JSPos;
  JoyStickActive : Boolean;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure CMDBOX.INIT(XI,YI,XSI,YSI:Byte;COMNDS: CMDARRAY;CL,TL:BYTE);
 begin
  X      := XI;
  Y      := YI;
  XS     := XSI;
  YS     := YSI;
  CMDS   := COMNDS;
  COL    := CL;
  Tcol   := TL;
  CMDNUM := 1
 end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
procedure GetJoyButton( var j1b1, j1b2 : Boolean );

var Regs : Registers;        { Processor registers for interrupt call }

begin
  Regs.ah := $84;                                      { Function 84H }
  Regs.dx := 0;                                    { Sub-function 00H }
  intr( $15, Regs );                             { Call interrupt 15H }
  j1b1 := ((( Regs.al and  16 ) shr 4) xor 1)=1;     { Bit 4 of AL = J1B1 }
  j1b2 := ((( Regs.al and  32 ) shr 5) xor 1)=1;     { Bit 5 of AL = J1B2 }
end;

{**********************************************************************
*  GetJoyPos : Gets positions of both joysticks.                      *
**-------------------------------------------------------------------**
*  Input     : JS1 = Joystick structure for joystick 1                *
*              JS2 = Joystick structure for joystick 2                *
**********************************************************************}

procedure GetJoyPos( var Js1, Js2 : JSPOS );

var Regs : Registers;        { Processor registers for interrupt call }

begin
  Regs.ah := $84;                                      { Function 84H }
  Regs.dx := 1;                                    { Sub-function 01h }
  intr( $15, Regs );                             { Call interrupt 15H }
  Js1.x := Regs.ax;                          { X-position: Joystick 1 }
  Js1.y := Regs.bx;                          { Y-position: Joystick 1 }
  Js2.x := Regs.cx;                          { X-position: Joystick 2 }
  Js2.y := Regs.dx;                          { Y-position: Joystick 2 }
end;

{*********************************************************************}
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function GetStickChar : Char;
 var
  Dum : JSPos;
  Dum2: JSPos;
  JBut1, JBut2 : Boolean;
  TC     : Char;
 begin
  TC :=#0;
  GetJoyButton(JBut1,JBut2);
  if JBut1 then TC :='F'
  else
  if JBut2 then TC :='U'
  else
  begin
   GetJoyPos( Dum,Dum2 );
   if (Dum.X-JoyCenter.X)< -20 then TC :='4'
   else
   if (Dum.X-JoyCenter.X)> 20 then TC :='6';
   if (Dum.Y-JoyCenter.Y)< -20 then
    begin
     if TC=#0 then TC :='8'
     else
      if TC='4' then TC :='7'
     else
      if TC='6' then TC :='9'
    end
   else
    if (Dum.Y-JoyCenter.Y)> 20 then
     begin
       if TC=#0 then TC :='2'
     else
      if TC='4' then TC :='1'
     else
      if TC='6' then TC :='3'
     end
  end;
  GetStickChar :=TC;
 end;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure CalStick;
 var
  Dum : JSPos;
 begin
  GetJoyPos( JoyCenter,Dum );
  JoyStickActive :=True;
 end;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure CMDBOX.Update(COMNDS: CMDARRAY);
 begin
  CMDS   := COMNDS;
 end;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure CMDBOX.SHOW;
var
 J,K :Integer;
 begin
 IF CMDNUM=0 THEN CMDNUM:=1;
 GOTOXY(X,Y);
 TEXTCOLOR(COL);
 TEXTBACKGROUND(0);
 HideMouseCursor;
 WRITE('ฺ');
 FOR J:= 1 TO XS DO WRITE('ฤ');
 WRITELN('ฟ');
FOR K := 1 TO YS DO
begin
 TEXTCOLOR(COL);
 TEXTBACKGROUND(0);
 GOTOXY(X,WHEREY);
 WRITE('ณ');
 TextColor(15);
 If K=CMDNUM then TEXTBACKGROUND(7);
 Write(Copy(CMDS[K],1,4));
 If K=CMDNUM then TextColor(0)
 else TextColor(TCol);
 Write(Copy(CMDS[K],5,LENGTH(CMDS[K])-4));
 TEXTCOLOR(COL);
 TEXTBACKGROUND(0);
 WRITELN('ณ');
end;
GOTOXY(X,WHEREY);
WRITE('ภ');
FOR J:= 1 TO XS DO WRITE('ฤ');
WRITELN('ู');
ShowMouseCursor;
end;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure CMDBOX.PROCESS(var Cmd : Char);
 var
  XC,YC,K        : Integer;
  DONE           : BOOLEAN;
  BUTN           : Button;
  Ch             : Char;
  J              : Integer;

begin
 DONE:=FALSE;
 Cmd := 'D';
 REPEAT
   REPEAT
   UNTIL  MousePressed(0) or KeyPressed;
   IF KEYPRESSED THEN
    begin
      Ch:=Readkey;
      if Ch=#0 then Ch:=readkey;
      CASE Ch OF
         #13:DONE:=TRUE;
         #27:begin
               DONE:=TRUE;
               Cmd :='A';
             end;
      'e','E': begin
                Done:=True;
                Cmd :='E';
               end;
      'd','D': begin
                Done:=True;
                Cmd :='D';
               end;
      'G'    : begin
                Done:=True;
                CmdNum :=51;
               end;
      'O'    : begin
                Done:=True;
                CmdNum :=52;
               end;
      'I'    : begin
                Done:=True;
                CmdNum :=53;
               end;
      'Q'    : begin
                Done:=True;
                CmdNum :=54;
               end;
#88,#69,#101 : DONE:=TRUE;
     DArrow : begin
               IF CMDNUM<YS THEN
                 begin
                  HideMouseCursor;
                  TEXTBACKGROUND(0);
                  GOTOXY(X+1,CMDNUM+Y);
                  TextColor(15);
                  Write(Copy(CMDS[CmdNum],1,4));
                  TextColor(Tcol);
                  Write(Copy(CMDS[CmdNum],5,LENGTH(CMDS[CmdNum])-4));
                  CMDNUM:=CMDNUM+1;
                  GOTOXY(X+1,CMDNUM+Y);
                  TEXTBACKGROUND(7);
                  TextColor(15);
                  Write(Copy(CMDS[CmdNum],1,4));
                  TextColor(0);
                  Write(Copy(CMDS[CmdNum],5,LENGTH(CMDS[CmdNum])-4));
                  ShowMouseCursor;
                 end
                else
                 begin
                  CmdNum :=YS+1;
                  Done :=true
                 end
               end;
    UArrow  : IF CMDNUM>1 THEN
                begin
                  HideMouseCursor;
                  TEXTBACKGROUND(0);
                  GOTOXY(X+1,CMDNUM+Y);
                  TextColor(15);
                  Write(Copy(CMDS[CmdNum],1,4));
                  TextColor(Tcol);
                  Write(Copy(CMDS[CmdNum],5,LENGTH(CMDS[CmdNum])-4));
                  CMDNUM:=CMDNUM-1;
                  GOTOXY(X+1,CMDNUM+Y);
                  TEXTBACKGROUND(7);
                  TextColor(15);
                  Write(Copy(CMDS[CmdNum],1,4));
                  TextColor(0);
                  Write(Copy(CMDS[CmdNum],5,LENGTH(CMDS[CmdNum])-4));
                  ShowMouseCursor;
                end
                else
                 begin
                  CmdNum :=50;
                  Done :=true;
                 end
              end; {case}
          FOR K:=1 TO YS DO
           IF (POS(CH,CMDS[K])=2) or (POS(Upcase(CH),CMDS[K])=2)THEN
           begin
            DONE:=TRUE;
            CMDNUM:=K;
           end
       end
  else
  begin
   GetMouseAction(Butn, XC, Yc);
   Xc:=(Xc Shr 3)+1;
   Yc:=(Yc Shr 3)+1;
   if YC>(Y+YS+2) then
    begin

     Done :=true;
     if Xc in[23..29] then
      begin
       HideMouseCursor;
       Cmd :='D';
       TextBackGround(0);
       TextColor(12);
       GotoXy(25,24);
       Write(' Dial ');
       ShowMouseCursor;
      end
      else
     if Xc in[33..39] then
      begin
       HideMouseCursor;
       Cmd :='E';
       TextBackGround(0);
       TextColor(12);
       GotoXy(34,24);
       Write(' Edit ');
       ShowMouseCursor;
      end
      else
     if Xc in[41..47] then
      begin
       CmdNum :=0;
       Done :=true
      end
    end
   else
   if YC>(Y+YS+1) then
    begin
     Done :=true;
     CmdNum :=YS+2;
    end
   else
   if YC>(Y+YS) then
    begin
     Done :=true;
     CmdNum :=YS+1;
    end
   else
   if YC=Y then
    begin
     Done :=true;
     CmdNum :=50
    end
   else
   if YC=Y-1 then
    begin
     Done :=true;
     CmdNum :=55
    end
   else
   IF (XC>X) AND (XC<(X+XS)) AND (YC>Y) AND (YC<=(Y+YS)) THEN
    begin
     IF CMDNUM=YC-Y THEN DONE:=TRUE
     ELSE
     begin
      HideMouseCursor;
      TEXTBACKGROUND(0);
      TextColor(Tcol);
      GOTOXY(X+1,CMDNUM+Y);
      TextColor(15);
      Write(Copy(CMDS[CmdNum],1,4));
      TextColor(Tcol);
      Write(Copy(CMDS[CmdNum],5,LENGTH(CMDS[CmdNum])-4));
      CMDNUM:=(YC-Y);
      TEXTBACKGROUND(7);
      TextColor(0);
      GOTOXY(X+1,CMDNUM+Y);
      TEXTBACKGROUND(7);
      TextColor(15);
      Write(Copy(CMDS[CmdNum],1,4));
      TextColor(0);
      Write(Copy(CMDS[CmdNum],5,LENGTH(CMDS[CmdNum])-4));
      ShowMouseCursor;
     end
    end
   end;
 UNTIL DONE;
end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure GetConnectStr(var XXX: TBBS);
 var
  Result     : String[40];
  Code       : Integer;
  Ch         : Char;
  TmpBPS     : LongInt;
  I,J        : Integer;
 begin
   TextColor(12);
   TextBackGround(0);
   GotoXY(2,2);
   Write(' CONNECT ');
  With XXX do
  With BBSRec Do
  begin
   Result :='';
   Ch:=#0;
   TmpBPS :=0;
   Repeat
    IF ChWaiting then
       begin
         Ch := UpCase(COnlyKey);
         if Ch > #32 then
          begin
           Result := Result + Ch;
           Write(Ch)
          end
        end;
   until (Ch=#13);
   ConnectString:=ReSult;
   Code := pos('/',Result);
   if Code =0 then val(copy(result,1,Length(Result)),TmpBPS,Code)
   else val(copy(result,1,code-1),TmpBPS,Code);
   if (TmpBPS <1200) or (Code<>0) then TmpBPS:=1200;
   SetDBps(TmpBPS);
   SetBps(GetBps);
   For I:= 9 to 12 do
   For J:= 120 to 150 do
   begin
    Sound(I*(J*3));
    Delay((J-100) mod 6)
   end;
   Nosound
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure GetMouseCHAR(var INCHAR: char);
 var
  XC    : Integer;
  YC    : Integer;
  Butn  : Button;
 begin
   Inchar:=#0;
   if Moused then
   begin
   GetMouseAction(Butn, XC, YC);
   if Butn = RightB then
    begin
     InChar :=#13;
     Butn :=NoB
    end
   else
   if Butn = LeftB then
    begin
     Xc:=(Xc Shr 3)+1;
     Yc:=(Yc Shr 3)+1;
     Inchar := Chr(VP^[Yc,Xc].Character);
     Butn :=NoB
    end
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Read_key (VAR ch1, ch2: Char);
 begin
  ch1 := ReadKey;
  IF ch1 = #0 THEN
    ch2 := ReadKey
  ELSE
    ch2 := #0;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function TickS  : Word;
 var
   H, M, S, HS : Word;
 begin
   GetTime(H, M, S, HS);
   TickS := S;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function TickM  : Word;
 var
   H, M, S, HS : Word;
 begin
   GetTime(H, M, S, HS);
   TickM := M;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure GetInput(Prmt : String ; Var St: String);
 var
   Xp,Yp : Byte;
   Txa   : Word;
 begin
   Xp:=WhereX;
   Yp:=WhereY;
   TxA :=TextAttr;
   HideMouseCursor;
    Window(1,25,80,25);
    TextColor(14);
    Textbackground(1);
    GotoXy(1,25);
    Clrscr;
    St :='';
    Write(' ',Prmt,' =>  ');
    Readln(St);
    Window(1,1,80,24);
   gotoXy(Xp,Yp);
   TextAttr:=TxA;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure GetFonList(Var FL : FonList);
 var
  Fonfile : File of FonList;
  I       : Integer;
  begin
   if Exist('XQDialDr.dat') then
    begin
     Assign(FonFile,'XQDialDr.dat');
     Reset(FonFile);
     Read(FonFile,Fl);
     Close(FonFile);
    end
    else
     for I:= 1 to 100 do
      With FL[I] do
      begin
       Name   :='                         ';
       Number :='                         ';
       Baud :=2400;
      end
  end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure SaveFonList(FL : FonList);
 var
  Fonfile : File of FonList;
  I       : Integer;
  begin
     Assign(FonFile,'XQDialDr.dat');
     ReWrite(FonFile);
     Write(FonFile,FL);
     Close(FonFile);
  end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Showcmds;
 begin
   TextBackGround(1);
   TextColor(15);
   GotoXy(25,24);
   Write(' D');
   TextColor(14);
   Write('ial     ');
   TextColor(15);
   Write('E');
   TextColor(14);
   Write('dit    ');
   TextColor(15);
   Write('ESC ');
   TextColor(14);
   Write('Exit');
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure SHowDialList(FL : FonList);
 var
  I       : Integer;
  begin
   TextColor(15);
   GotoXy(10,1);
   Writeln( 'Xeno Quest Ansi Terminal.   Version '+Vrs+'         '+ Time+'m');
   ShowCmds;
   Window(3,2,78,21);
   TextBackGround(0);
   Clrscr;
   TextColor(0);
   TextBackGround(7);
   Writeln(' Entry       Name / Description             Number              Baud Rate   ');
   Window(1,1,80,24);
  end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure SetScreen(FL : FonList; OffS : Integer;var SC : CmdArray);
 var
  I       : Integer;
  SNum    : String;
  BNum    : String;
 begin
   For I := 1 to 18 do
    begin
     Str(I+Offs:3,SNum);
     Str(FL[I+Offs].Baud: 8,BNum);
     Sc[I] := SNum+'.  '+FL[I+Offs].Name +'   '+FL[I+Offs].Number+'   '+BNum+'    ';
    end
 end;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure GetStringName( var SName : String; MaxLen : Integer;
                          var Abort : Boolean);
 var
  Done    : Boolean;
  Zeroed  : Boolean;
  CharPos : Byte;
  Xpos    : Integer;
  SXpos   : Integer;
  Ypos    : Integer;
  Xc,Yc   : Integer;
  OrgX,OrgY : Byte;
  Ch        : Char;
  Butn      : Button;

 begin
   Done    :=False;
   Zeroed  :=false;
   CharPos :=1;
   Xpos    := WhereX;
   SXpos   := WhereX;
   Ypos    := WhereY;
   OrgX    := WhereX;
   OrgY    := WhereY;

  Repeat
   Repeat
   until MousePressed(0)  or KeyPressed ;

   if KeyPressed then
     begin
       Ch:=Readkey;
       If Ch=#0 then
       begin
        Ch:=Readkey;
{        Write(ord(Ch));}
        case Ch of
       RArrow : begin
                 if (Xpos < (SXPos+MaxLen)) and (CharPos < Length(SName)+1) then
                  begin
                   Xpos :=Xpos +1;
                   CharPos :=CharPos +1;
                   gotoxy(Xpos,Ypos);
                   Zeroed :=true;
                  end
                end;
       #71 :  begin
                 CharPos :=1;
                 Xpos:=OrgX;
                 GotoXy(Xpos,OrgY)
                end;

       #79  : begin
                 while (Xpos < (SXPos+MaxLen)) and (CharPos < Length(SName)+1) do
                  begin
                   Xpos :=Xpos +1;
                   CharPos :=CharPos +1
                  end;
                   gotoxy(Xpos,Ypos);
                   Zeroed :=true
                end;
        Larrow : begin
                 if (Xpos > SXPos) and (CharPos >1) then
                  begin
                   Xpos :=Xpos -1;
                   CharPos :=CharPos -1;
                   gotoxy(Xpos,Ypos);
                   Zeroed :=true;
                  end
                end;
        Darrow : begin
                    Done:=true;
                 end;
         #83:  begin
                if CharPos >0 then
                 begin
                  delete(Sname,CharPos,1);
                  GotoXy(OrgX,OrgY);
                  HideMouseCursor;
                  Write(Sname+' ');
                  gotoxy(Xpos,Ypos);
                  ShowMouseCursor;
                 end
               end;
       end;{case}
      end
      else
       case Ch of
       #13   : Done :=True;
       #27   : begin
                Done := True;
                Abort := True;
               end;
        #8    : begin
                 if CharPos<Length(Sname) then
                  begin
                  if (Xpos > SXPos) and (CharPos >1) then
                   begin
                    Xpos :=Xpos -1;
                    CharPos :=CharPos -1;
                    delete(Sname,CharPos,1);
                    GotoXy(OrgX,OrgY);
                    HideMouseCursor;
                    Write(Sname,' ');
                    gotoxy(Xpos,Ypos);
                    ShowMouseCursor;
                   end
                  end
                  else
                 if (Xpos > SXPos) and (CharPos >1) then
                  begin
                   Xpos :=Xpos -1;
                   CharPos :=CharPos -1;
                   gotoxy(Xpos,Ypos);
                   HideMouseCursor;
                   Write(' ');
                   gotoxy(Xpos,Ypos);
                   Sname[0] := chr(CharPos);
                   ShowMouseCursor;
                   Zeroed :=true;
                  end
                end;
    #32..#126: begin
                if not Zeroed then
                 begin
                  Sname:='';
                  HideMouseCursor;
                  Write('                          ');
                  ShowMouseCursor;
                  GotoXy(Xpos,Ypos);
                  Zeroed :=true;
                 end;
                 if (Xpos < (SXPos+MaxLen))  then
                  begin
                   Sname[CharPos] := Ch;
                   HideMouseCursor;
                   Write(ch);
                   ShowMouseCursor;
                   if CharPos > Length(SName) then
                   Sname[0] := chr(CharPos);
                   Xpos :=Xpos +1;
                   CharPos :=CharPos +1;
                   gotoxy(Xpos,Ypos)
                  end
                end;
       end
     end
    ELSE
     begin
      GetMouseAction(Butn, XC, Yc);
      Xc:=(Xc Shr 3)+1;
      Yc:=(Yc Shr 3)+1;
      case YC of
        16:begin
             case Xc of
               33..47 : begin
                         Done :=True;
                         Abort := True
                        end
             end  {case Xc}
           end
        else
          begin
              if Yc= OrgY then
               begin
                 Xpos:=OrgX;
                 CharPos :=1;
                 while (Xpos < (SXPos+MaxLen)) and (CharPos < Length(SName)+1)
                 and (Xpos < XC) do
                  begin
                   Xpos :=Xpos +1;
                   CharPos :=CharPos +1
                  end;
                   gotoxy(Xpos,Ypos);
                   Zeroed :=true
               end
          end
        end
      end
  until done;
 end;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure ProcessDialList(var FL : FonList;var Num: Integer);
 var
  I       : Integer;
  Ch      : Char;
  Sc      : CmDarray;
  Finished : Boolean;
  Abort    : Boolean;
  Index    : Integer;
  Done     : Boolean;
  begin
   I :=1;
   Num :=0;
   SetScreen(FL,PgOff,SC);
   DD.Update(SC);
   Finished :=False;
   DD.Show;
   While Not Finished do
   begin
   DD.Process(Ch);
   Case DD.CmdNum of
   50   : if PgOff >0 then
           begin
            PgOff := PgOff -1;
            SetScreen(FL,PgOff,SC);
            DD.UpDate(SC);
            DD.CmdNum :=1;
            DD.Show;
           end
          else
          DD.CmdNum :=1;
   51   : if PgOff >0 then
           begin
            PgOff := 0;
            SetScreen(FL,PgOff,SC);
            DD.UpDate(SC);
            DD.CmdNum :=1;
            DD.Show;
           end
          else
          DD.CmdNum :=1;
   52   : if PgOff < 82 then
           begin
            PgOff := 82;
            SetScreen(FL,PgOff,SC);
            DD.UpDate(SC);
            DD.CmdNum :=18;
            DD.Show;
           end
           else DD.CmdNum :=18;
   53,55 : if PgOff >0 then
           begin
            PgOff := PgOff-10;
            if PgOff <0 then PgOff :=0;
            SetScreen(FL,PgOff,SC);
            DD.UpDate(SC);
            DD.CmdNum :=1;
            DD.Show;
           end
          else
          DD.CmdNum :=1;
   54,20 : if PgOff <82 then
           begin
            PgOff := PgOff+10;
            if PgOff >82 then PgOff :=82;
            SetScreen(FL,PgOff,SC);
            DD.UpDate(SC);
            DD.CmdNum :=18;
            DD.Show;
           end
          else
          DD.CmdNum :=1;
   0     : Finished :=true;
   1..18: begin
           if Ch ='A' then Finished :=true
           else
           begin
           Index :=DD.CmdNum+PgOff;
           if Ch ='D' then
           begin
            Num := Index;
            Finished := True;
           end
           else
           begin
           HideMouseCursor;
           TextColor(15);
           TextBackGround(5);
           gotoxy(9,DD.Y+DD.CmdNum);
           Write('                         ');
           gotoxy(10,DD.Y+DD.CmdNum);
           Write(FL[Index].Name);
           SHowMouseCursor;
           gotoxy(10,DD.Y+DD.CmdNum);
           GetStringName(Fl[Index].Name,25, Abort);
           FormatName(Fl[Index].Name);
           While Length(Fl[Index].Name) <25 do FL[Index].Name :=FL[Index].Name+' ';
           TextColor(0);
           TextBackGround(7);
           gotoxy(9,DD.Y+DD.CmdNum);
           Write(' ',FL[Index].Name,' ');
           TextColor(15);
           TextBackGround(2);
           gotoxy(37,DD.Y+DD.CmdNum);
           Write('                         ');
           gotoxy(38,DD.Y+DD.CmdNum);
           Write(FL[Index].Number);
           SHowMouseCursor;
           gotoxy(38,DD.Y+DD.CmdNum);
           GetStringName(Fl[Index].Number,25, Abort);
           FormatName(Fl[Index].Number);
           While Length(Fl[Index].Number) <25 do FL[Index].Number :=FL[Index].Number+' ';
           TextColor(0);
           TextBackGround(7);
           gotoxy(37,DD.Y+DD.CmdNum);
           Write(' ',FL[Index].Number,' ');
           I:=0;
           Done :=False;
           While (I<7) and Not done do
           begin
            I:=I+1;
            If BaudRates[I]=FL[Index].Baud then Done :=True;
           end;
           HideMouseCursor;
           TextColor(15);
           TextBackGround(5);
           gotoxy(69,DD.Y+DD.CmdNum);
           Write('         ');
           Done:=False;
           Repeat
            gotoxy(70,DD.Y+DD.CmdNum);
            Write(BaudRates[I],'  ');
            Repeat Until KeyPressed;
            Ch:=ReadKey;
       case Ch of
      #27,#13 : Done:=true;
       #8 : begin
              I:=I-1;
              If I <1 then I :=7;
             end;
       ' ' : begin
              I:=I+1;
              If I >7 then I :=1;
             end;
        #0 : begin
              Ch:=Readkey;
              if Ch=UArrow then
               begin
                I:=I+1;
                If I >7 then I :=1;
               end
              else
               begin
                I:=I-1;
                If I <1 then I :=7
                end;
              end;
       end;{Case}
       Until Done;
           FL[Index].Baud :=BaudRates[I];
           Index := DD.CmdNum;
           SetScreen(FL,PgOff,SC);
           SaveFonList(FL);
           DD.UpDate(SC);
           DD.CmdNum:=Index;
           DD.Show;
           ShowCmds
          end
          end
          end;
  19   : if PgOff < 82 then
           begin
            PgOff := PgOff +1;
            SetScreen(FL,PgOff,SC);
            DD.UpDate(SC);
            DD.CmdNum :=18;
            DD.Show;
           end
           else DD.CmdNum :=18;
         end
     end;
  end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure DoDialDir(var XXX: XBBS);
 var
  FL     : FonList;
  Ch     : Char;
  DString : String;
  CString : String;
  QuitNow : Boolean;
  Indx    : Integer;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function WaitFr(var Strn : String; Timeout : Word; Xl,Yl :byte) : Boolean;
 Var
   Rcv             : String;
   Ch              : Char;
   SS, ES, X, Y, Z : Word;
   Ticker          : Integer;
   Found           : Boolean;

 begin
 With XXX do
  begin
   WaitFr := False;
   Rcv := '';
   Found := False;
   Ticker := 0;
   GotoXy(Xl,Yl);
   for X := 1 to Length(Strn) do
    begin
      Strn[X] := UpCase(Strn[X]);
    end;
   GetTime(X, Y, SS, Z);
   while ((Ticker <> Timeout) and (Timeout > 0)) and (not Found) do
    begin
       if KeyPressed then
        begin
         if Readkey =#27 then
          begin
           Ticker :=TimeOut;
           Found:=False
          end
     end;
      IF ChWaiting then
        begin
         Ch := UpCase(CReadkey);
         if Not (Ch in [#13,#10]) then
           begin
            Write(Ch);
            Rcv := Rcv + Ch;
           end;
         if (Pos('CONNECT',Rcv) > 0) then
          begin
            Strn:=Rcv;
            Found := True
          end;
         if (Pos('BUSY',RCV) > 0) then
          begin
            Strn:=Rcv;
            Found := True
          end ;
         if (Pos('NO ANSWER',RCV) > 0) then
          begin
            Strn:=Rcv;
            Found := True
          end ;
         if (Pos('NO DIALTONE',RCV) > 0) then
          begin
            Strn:=Rcv;
            Found := True
          end
        end;
       ES := SS;
      GetTime(X, Y, SS, Z);
      if (ES <> SS) then Ticker:=ticker+1
    end;
   WaitFr := Found
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure ShowStLine;
  var
   X,Y    : Integer;
   Tstr   : String;
   SLine  : String;
   TCSav  : Byte;
  begin
  With XXX do
   begin
   X:=WHEREX;
   Y:=WHEREY;
   TCSav :=TextAttr;
   Sline :=' ณ ';
   Str(OnlineTime, Tstr);
   Sline:=Sline +'Time:'+Tstr+'ณ';
   Str( GetBps, Tstr);
   Sline:=Sline +'Baud '+Tstr+'ณ'+ Time+'ณ'+Date+'ณ';
   if Local then Sline:=Sline+ ' Local ณ'
   else if Not Online then Sline:=Sline+ ' OffLine ณ'
   else Sline:=Sline+ '  Online  ณ';
   Sline:=Sline+ '  Alt-X EXIT  ณ';
   if Length(Sline) > 79 then Sline :=Copy(Sline,1,79);
   HideMouseCursor;
   Window(1,25,80,25);
   TextColor(0);
   Textbackground(7);
   Clrscr;
   Write(Sline);
   Window(1,1,80,24);
   ShowMouseCursor;
   TextAttr :=TCSav;
   GotoXY(X,Y)
  end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure DialNum(St: String);
 var
   Pup : PopUp;
 begin
  With XXX Do
   begin
    ShowStLine;
    HideMouseCursor;
    Pup.Init(22,14,57,20,13,1,11,'');
    GotoXy(26,15);
    TextColor(15);
    TextBackGround(1);
    Write(St);
    GotoXy(26,19);
    TextColor(11);
    Write('Last Status ');
    TextColor(13);
    Write(CString);
    GotoXy(26,16);
    TextColor(14);
    Write( 'Dialing '+Dstring);
    Dial(BBSRec.PulseOrTone+DSTRING);
    GotoXy(26,17);
    TextColor(28);
    Write('Waiting for Connection');
    IF Waitfr(CString,50,26,18) Then
     begin
      delay(100);
      if POS('CONNECT',CString) > 0 then  GetConnectStr(XXX);
     end
     else QuitNow :=True;
    Pup.Done
   end;
   ShowMouseCursor
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 begin
  GetFonList(FL);
  HideMouseCursor;
  TextColor(14);
  TextBackGround(1);
  ClrScr;
  ShowDialList(FL);
  ProcessDialList(FL,Indx);
  Window(1,1,80,24);
 With XXX do
  if Indx <>0 then
  begin
   {if Indx :=0 then GetInput('Number to Dial ',Dstring);}
   DString :=FL[Indx].Number;
   While Pos(' ',Dstring) > 0 do Delete(DString,Pos(' ',Dstring),1);
   CString :='';
   if Length(Dstring) > 6  then QuitNow :=False;
   HideMouseCursor;
   if Dstring <>'' then
    Repeat
     DialNum(FL[Indx].Name);
    Until (Pos('CONNECT',CString) >0) OR QuitNow;
   ShowMouseCursor;
  end;
  HideMouseCursor;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure DoTcTerm(var XXX: XBBS);
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure ShowStLine;
  var
   X,Y    : Integer;
   Tstr   : String;
   SLine  : String;
   TCSav  : Byte;
  begin
  With XXX do
   begin
   X:=WHEREX;
   Y:=WHEREY;
   TCSav :=TextAttr;
   Sline :=' ณ ';
   Str(OnlineTime, Tstr);
   Sline:=Sline +'Time:'+Tstr+'ณ';
   Str( GetBps, Tstr);
   Sline:=Sline +'Baud '+Tstr+'ณ'+ Time+'ณ'+Date+'ณ';
   if Local then Sline:=Sline+ ' Local ณ'
   else if Not Online then Sline:=Sline+ ' OffLine ณ'
   else Sline:=Sline+ '  Online  ณ';
   Sline:=Sline+ '  Alt-X EXIT  ณ';
   if Length(Sline) > 79 then Sline :=Copy(Sline,1,79);
   HideMouseCursor;
   Window(1,25,80,25);
   TextColor(0);
   Textbackground(7);
   Clrscr;
   Write(Sline);
   Window(1,1,80,24);
   ShowMouseCursor;
   TextAttr :=TCSav;
   GotoXY(X,Y)
  end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 var
  Exit_prog	: Boolean;
  ch1, ch2 	: Char;
  ch3      	: Char;
  TkS      	: Word;
  TkM      	: Word;
  Pup      	: PopUp;
  LastChars	: String[8];
  St       	: String;
  RMouse   	: Boolean;
  DSZCmd        : String;

begin
 With XXX do
 begin
  {$I-}
  OnlineTime := 0;
  Local :=False;
  SetDBps(Baud);
  SetBps(Baud);
  Exit_prog := False;
  ClearRX;
  CLearTX;
  HideMouseCursor;
  Window(1,25,80,25);
  TextColor(0);
  TextBackGround(7);
  Clrscr;
  Window(1,1,80,24);
  TextColor(14);
  TextBackGround(0);
  ClrScr;
  ShowStLine;
  Writeln( 'Xeno Quest Ansi Terminal.   Alt-X Exit     Alt-D Dial   Alt-J JoyStick');
  ShowMouseCursor;
  TextColor(11);
  with BBSRec do
  ComWriteO(ModemInitString+#13);
  TkS :=TickS;
  TkM :=TickM;
  StatusChanged := Online;
  St :='';
  RMouse :=False;
  if Moused then ShowMouseCursor;
  Repeat
    Ch3 :=COnlyKey;
    if Ch3 > #0 then
    begin
     if Length(lastchars) > 6 then delete(lastchars,1,1);
     Lastchars := lastchars + Ch3;
     Display_Ansi(Ch3);
     if Pos('[6n',LastChars) >0 then
       ComWriteO('['+IntToStr(WhereX)+';'+IntToStr(WhereY)+'F');
    end
    else
    if TkS<>TickS then
      begin
       TkS:=TickS;
       if StatusChanged <> Online then
        begin
          StatusChanged :=Online;
          ShowStLine;
          OnLineTime :=0
        end
       else
       if TkM<>TickM then
       begin
        TkM :=TickM;
        if Online then OnLineTime :=OnLineTime +1;
        ShowStLine;
       end;
      end
    else
    begin
    if JoyStickActive then
    begin
     Ch1:=GetStickChar;
     IF ch1 <> #0 THEN
      begin
       ClearTX;
       ComWriteO(ch1)
      end
      else
       ClearTX
    end;
    IF KeyPressed THEN
      begin
       read_key (ch1, ch2);
       IF ch1 <> #0 THEN ComWriteO(ch1)
       else
        CASE ch2 OF
           'P': ComWriteO('[B');
           'K': ComWriteO('[D');
           'H': ComWriteO('[A');
           'M': ComWriteO('[C');
          #59 : begin
                  GetInput('Enter DOS Command',St);
                  Pup.ScrSave;
                  Shell(GetEnv('COMSPEC'), '/C'+St);
                  Pup.Done;
                  ShowStLine;
                  ShowMouseCursor;
                end;
          #60 : begin
                  ComWriteO(BBSRec.SysOpName+#13);
                end;
          '$' : begin
                  CalStick;
                end;
           ' ': begin {Alt-D}
                 HideMouseCursor;
                 Pup.ScrSave;
	         DoDialDir(XXX);
                 Pup.Done;
                 TextBackGround(0);
                 ShowMouseCursor;
                end;
          #45 : {Alt-X} Exit_prog := True;
           '.': begin
                 HideMouseCursor;
	         Display_Ansi('');
                 if MouseInstalled then ShowMouseCursor
                end;
           '0': begin
                 BPPtr :=BPPtr +1;
                 if BPPtr >7 then BPPtr :=1;
                 SetDBps(Baudrates[BPPtr]);
                 SetBps(GetBps);
                 ShowStLine
                end;
           '#': begin {alt-h}
                 Pup.Init(25,18,52,22,15,1,14,' Hanging Up ');
                 If Not Hangup then Pup.Init(25,18,52,22,31,4,11,'Unable to Hangup');
                 Delay(500);
                 Pup.Done;
                end;
          else Write(Ch2);
        end; {Case}
      end
     else
      if Moused then
      begin
       GetMouseChar(Ch1);
       IF ch1 <> #0 Then
        begin
         ComWriteO(ch1);
         if (Ch1 =#13) and Not Online then
            begin {Alt-D}
              HideMouseCursor;
              Pup.ScrSave;
	      DoDialDir(XXX);
              Pup.Done;
              TextBackGround(0);
              ShowMouseCursor;
             end;
         Repeat
          GetMouseChar(Ch1);
         Until Ch1 = #0
        end
       end
      end;
   UNTIL exit_prog;
   SetDBps(0);
  end
  {$I+}
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
procedure restore;
begin
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 VAR
  Savdir     : String;
  BBSRecord  : BBSData;
  ComNum     : Byte;
  X	     : Byte;
  BaudIn     : LongInt;
  XXX        : XBBS;
  Code       : Integer;



begin
 ClrScr;
 JoyStickActive :=False;
 GetDir(0,Savdir);
 BBSRecord.ModemInitString :='AT&C1&D2M0';
 BBSRecord.DialInitString :='ATZ';
 BBSRecord.PulseOrTone :='T';
 BBSRecord.LockedBaud := False;
 if ParamCount >0 then
  begin
   VAL(ParamStr(1),ComNum,Code);
   if (Code<> 0) or (Not (ComNum in [1..4])) then
    begin
     Writeln(' Invalid Comport Number..');
     ResetChars;
     halt;
    end;
   VAL(ParamStr(2),BaudIn,Code);
   if (Code<> 0) or (Not (ComNum in [1..4])) then
    begin
     Writeln(' Invalid Baud Rate..');
     ResetChars;
     Halt
    end
  end
  else
  begin
   writeln;
   Writeln(' Usage : ex.  XQTERM 1 14400');
   Writeln(' Usage : XQTERM [Comport] [Baudrate]');
   ResetChars;
   Halt;
  end;


 XXX.SetDBps(0);
 XXX.INIT(ComNum,BBSRecord,BaudIn,1,1);
 GetFonList(FL);
 SetScreen(FL,0,SC);
 PgOff :=0;
 DD.Init(3,3,74,18,SC,13,14);
 DoTCTerm(XXX);
 XXX.Done;
 ResetChars;
 Chdir(Savdir)
end.