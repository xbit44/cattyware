{$M 32768,0,65536}

program SETUP;

uses Mouse,Crt,Dos,VioText;

const
  NumFiles  = 7;
  ProgTitle = '               BBS Door Setup Program  Version 1.0  (c) 1992   ';
  DoorName  = ' Yahtzee';
  LArrow = #75; RArrow = #77; UArrow = #72; DArrow = #80;

  F1 = #59; F2 = #60; F3 = #61; F4 = #62; F5 = #63; F6 = #64; F7 = #65;
  F8 = #66; F9 = #67; F10 = #68; F11 = #133; F12 = #134;

  FileList : array[1..NumFiles] of String =
                ('YAHTZEE.EXE',
                 'YAHTZEE.EMU',
                 'YAHTZEE.SCR',
                 'YAHTZEE.INS',
                 'YAHTZEE.DOC',
                 'YAHTZEE.CFG',
                 'SETUP.EXE');

TYPE
     CMDARRAY  = ARRAY[1..20] OF STRING;
     UFILEType = string[13];
     FirstNameType = string[20];

 CMDBOX = OBJECT
      X,Y,XS,YS  : INTEGER;
      CMDS   : CMDARRAY;
      COL,CMDNUM : BYTE;
     PROCEDURE INIT(XI,YI,XSI,YSI:INTEGER;COMNDS: CMDARRAY;CL:BYTE);
     PROCEDURE SHOW;
     PROCEDURE PROCESS;
   END;

VAR
    SND_ON : BOOLEAN;
    COMNUM     : integer;
    BAUD       : Longint;
    SysOpName  : String[25];
    RN         : String[25];
    BBSNAME    : String[25];
    BBSDIR     : String[25];
    TimeLimit  : Integer;
    TimeUsed   : Integer;
    UseRts     : Boolean;
    UseCts     : Boolean;
    FNLN       : integer;
    LNLN       : integer;
    BRLN       : integer;
    TLLN       : integer;
    TULN       : integer;
    TLLNDef    : integer;
    TULNDef    : integer;
    UFILE      : UfileType;

{--------------------------------------------------------------------}
 procedure INWINDOW(X1,Y1,XSS,YSS,TC,BC:INTEGER);
  var
   K,J : INTEGER;
 begin
  GOTOXY(X1,Y1);
  TEXTCOLOR(TC);
  TEXTBACKGROUND(BC);
  HIDEMOUSECursor;
  WRITE('ฺ');
  FOR K:= 1 TO XSS DO WRITE('ฤ');
  WRITELN('ฟ');
  FOR K := 1 TO YSS DO
   begin
    GOTOXY(X1,WHEREY);
    WRITE('ณ');
    FOR J:= 1 TO XSS DO WRITE(' ');
    WRITELN('ณ')
   end;
  GOTOXY(X1,WHEREY);
  WRITE('ภ');
  FOR K:= 1 TO XSS DO WRITE('ฤ');
  WRITELN('ู');
  SHOWMOUSECursor
 END;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Upper(Strn : String) : String;
 Var
   Index  : Byte;

 Begin
   for Index := 1 to Length(Strn) do
      Strn[Index] := UpCase(Strn[Index]);
   Upper := Strn
 end;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure ErrorMsg(Clr,COL: Integer; msg:String );
 var
  VS        : Vioram;
  Ch        : Char;
 begin
  HideMouseCursor;
  Vs:=Vp^;
  inwindow (25,7,30,3,14,Clr);
  Textcolor(15);
  TextBackGround(Clr);
  GotoXy(25+Col,8);
  Write( Msg);
  GotoXy(33,10);
  Write( ' Press [Enter]..');
  ShowMouseCursor;
  repeat
  until KeyPressed or MousePressed(0) or MousePressed(1);
  while Keypressed do ch:=Readkey;
  HideMouseCursor;
  Vp^:=VS;
  ShowMouseCursor;
 end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function GetConFirm : Boolean;
 var
  VS        : Vioram;
  Ch        : Char;
 begin
  HideMouseCursor;
  Vs:=Vp^;
  inwindow (20,7,30,3,14,2);
  Textcolor(15);
  TextBackGround(2);
  GotoXy(22,8);
  Write('Confirm Game Reset');
  GotoXy(22,10);
  Write('<Enter>=Confirm..or <Esc>');
  ShowMouseCursor;
  repeat
  until KeyPressed or MousePressed(0) or MousePressed(1);
  while Keypressed do ch:=Readkey;
   if ch = #27 then GetConfirm :=False else GetConfirm := True;
  HideMouseCursor;
  Vp^:=VS;
  ShowMouseCursor;
 end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure ErrorMsg1( msg:String );
 begin
  inwindow (25,7,30,3,14,1);
  Textcolor(15);
  TextBackGround(1);
  GotoXy(33,8);
  Write( Msg);
 end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Exist(Filename : String) : Boolean;
 var
   Inf : SearchRec;
 Begin
   FindFirst(Filename, AnyFile, Inf);
   Exist := (DOSError = 0)
 end;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function CopyFile(Source, Dest : String) : Boolean;
 Var
   Src, Dst : File;
   Block    : Array[1..4096] of Char;
   BytesRd  : Word;
   BytesWr  : Word;
   Dir      : DirStr;
   Name     : NameStr;
   Ext      : ExtStr;
   FInfo    : SearchRec;

 Begin
   CopyFile := True;
   if (Dest[Length(Dest)] <> '\') then
    Begin
      FindFirst(Dest, AnyFile, FInfo);
      if (DOSError = 0) then
       Begin
         if (FInfo.Attr AND Directory > 0) then
          Begin
            FSplit(Source, Dir, Name, Ext);
            Dest := Dest + '\' + Name + Ext
          end;
       end
      else
       Begin
         CopyFile := False;
         Exit
       end;
    end
   else
    Begin
      FSplit(Source, Dir, Name, Ext);
      Dest := Dest + Name + Ext
    end;
   if Exist(Source) then
  begin
    Assign(Src, Source);
    Assign(Dst, Dest);
   {$I-}
   Reset(Src, 1);
   Rewrite(Dst, 1);
   Repeat
     BlockRead(Src, Block, 4096, BytesRd);
     BlockWrite(Dst, Block, BytesRd, BytesWr);
   Until (BytesRd = 0) or (BytesWr <> BytesRd);
   Close(Src);
   Close(Dst);
   if (IoResult <> 0) then CopyFile := False
   {$I+}
  end
  else
  begin
   Errormsg(12,4,' File Not Found ');
   CopyFile:=False;
  end
 end;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
PROCEDURE SHOWMAINSCRN;
VAR K: INTEGER;
begin
 HideMouseCursor;
 CLRSCR;
 fillscrn($07,$17);
 GotoXy(1,25);
 Textcolor(15);
 TextBackGround(7);
 Write(ProgTitle);
 GotoXy(1,1);
 Textcolor(15);
 Write('  S');
 Textcolor(15);
 Write('etup');
 Textcolor(0);
 Write('                 Neubauer Applications Uncorp.');

 ShowMouseCursor
END;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

PROCEDURE WAITLETGO;
 begin
  repeat
  until ( MousePressed(0) And Not MousePressed(1));
 end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 procedure CMDBOX.INIT(XI,YI,XSI,YSI:INTEGER;COMNDS: CMDARRAY;CL : BYTE);

 begin
  X      := XI;
  Y      := YI;
  XS     := XSI;
  YS     := YSI;
  CMDS   := COMNDS;
  COL    := CL;
  CMDNUM := 1
 end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

Procedure CMDBOX.SHOW;

 var
  J,K :INTEGER;

 BEGIN
 IF CMDNUM=0 THEN CMDNUM:=1;
 GOTOXY(X,Y);
 TEXTCOLOR(COL);
 TEXTBACKGROUND(0);
 HideMouseCursor;
 WRITE('ฺ');
 FOR J:= 1 TO XS DO WRITE('ฤ');
 WRITELN('ฟ');

FOR K := 1 TO YS DO
BEGIN
TEXTCOLOR(COL);
TEXTBACKGROUND(0);
GOTOXY(X,WHEREY);
WRITE('ณ');
 FOR J:= 1 TO LENGTH(CMDS[K]) DO
 BEGIN
  IF J=2 THEN TEXTCOLOR(15) ELSE TEXTCOLOR(7);
IF K=CMDNUM THEN
 BEGIN
  TEXTBACKGROUND(7);
  IF J<>2 THEN TEXTCOLOR(0);
 END
ELSE TEXTBACKGROUND(0);
   WRITE(COPY (CMDS[K],J,1))
 END;
TEXTCOLOR(COL);
TEXTBACKGROUND(0);
WRITELN('ณ');
END;
GOTOXY(X,WHEREY);
WRITE('ภ');
FOR J:= 1 TO XS DO WRITE('ฤ');
WRITELN('ู');
ShowMouseCursor;
END;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 procedure CMDBOX.PROCESS;
 var
  XC,YC,K        : INTEGER;
  DONE           : BOOLEAN;
  BUTN           : Button;
  Ch             : Char;
  J              : Integer;

BEGIN
 DONE:=FALSE;
 REPEAT
   REPEAT
   UNTIL  MousePressed(0) or KeyPressed;

   IF KEYPRESSED THEN
    BEGIN
      Ch:=Readkey;
      if Ch=#0 then Ch:=readkey;
      CASE Ch OF
         #13:DONE:=TRUE;
         #27:BEGIN
               CMDNUM:=0;
               DONE:=TRUE;
             END;
#88,#69,#101 : DONE:=TRUE;
     DArrow : BEGIN
               IF CMDNUM<YS THEN
                 BEGIN
                  HideMouseCursor;
                  TEXTBACKGROUND(0);
                  TextColor(7);
                  GOTOXY(X+1,CMDNUM+Y);
                  FOR J:= 1 TO LENGTH(CMDS[CMDNUM]) DO
                    BEGIN
                     IF J=2 THEN TEXTCOLOR(15) ELSE TEXTCOLOR(7);
                     WRITE((CMDS[CmdNum][J]))
                   END;
                  CMDNUM:=CMDNUM+1;
                  TEXTBACKGROUND(7);
                  TextColor(0);
                  GOTOXY(X+1,CMDNUM+Y);
                  FOR J:= 1 TO LENGTH(CMDS[CMDNUM]) DO
                    BEGIN
                     IF J=2 THEN TEXTCOLOR(15) ELSE TEXTCOLOR(0);
                     WRITE((CMDS[CmdNum][J]))
                   END;
                  ShowMouseCursor;
                 END
               END;
    UArrow  : IF CMDNUM>1 THEN
                BEGIN
                  HideMouseCursor;
                  TEXTBACKGROUND(0);
                  TextColor(7);
                  GOTOXY(X+1,CMDNUM+Y);
                  FOR J:= 1 TO LENGTH(CMDS[CMDNUM]) DO
                    BEGIN
                     IF J=2 THEN TEXTCOLOR(15) ELSE TEXTCOLOR(7);
                     WRITE((CMDS[CmdNum][J]))
                   END;
                  CMDNUM:=CMDNUM-1;
                  TEXTBACKGROUND(7);
                  TextColor(0);
                  GOTOXY(X+1,CMDNUM+Y);
                  FOR J:= 1 TO LENGTH(CMDS[CMDNUM]) DO
                    BEGIN
                     IF J=2 THEN TEXTCOLOR(15) ELSE TEXTCOLOR(0);
                     WRITE((CMDS[CmdNum][J]))
                    END;
                ShowMouseCursor;
                END
              end; {case}
          FOR K:=1 TO YS DO
           IF (POS(CH,CMDS[K])=2) or (POS(Upcase(CH),CMDS[K])=2)THEN
           BEGIN
            DONE:=TRUE;
            CMDNUM:=K;
           END
       END
  else
  BEGIN
   GetMouseAction(Butn, XC, Yc);
   Xc:=(Xc Shr 3)+1;
   Yc:=(Yc Shr 3)+1;
   IF (XC>X) AND (XC<(X+XS)) AND (YC>Y) AND (YC<=(Y+YS)) THEN
    BEGIN
     IF CMDNUM=YC-Y THEN DONE:=TRUE
     ELSE
     BEGIN
      HideMouseCursor;
      TEXTBACKGROUND(0);
      TextColor(7);
      GOTOXY(X+1,CMDNUM+Y);
      FOR J:= 1 TO LENGTH(CMDS[CMDNUM]) DO
        BEGIN
         IF J=2 THEN TEXTCOLOR(15) ELSE TEXTCOLOR(7);
         WRITE((CMDS[CmdNum][J]))
        END;
      CMDNUM:=(YC-Y);
      TEXTBACKGROUND(7);
      TextColor(0);
      GOTOXY(X+1,CMDNUM+Y);
      FOR J:= 1 TO LENGTH(CMDS[CMDNUM]) DO
        BEGIN
         IF J=2 THEN TEXTCOLOR(15) ELSE TEXTCOLOR(0);
         WRITE((CMDS[CmdNum][J]))
        END;
      ShowMouseCursor;
     END
    end
   end;
 UNTIL DONE;
END;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 procedure PROCESSMAIN(VAR MAINCB: CMDBOX);
 VAR
 XS,YS,XC,YC    : INTEGER;
 DONE           : BOOLEAN;
 Butn           : Button;
 Ch             : char;
BEGIN
 DONE:=FALSE;
 GetMouseAction(Butn, XC, Yc);
 REPEAT
   REPEAT
   UNTIL MousePressed(1) or KEYPRESSED;

 if KeyPressed then
                  BEGIN
                    Ch:=Readkey;
                    CASE Ch OF

             '/',#32,#13,#0 :
                           BEGIN
                            HideMouseCursor;
                            GOTOXY(2,1);
                            TEXTCOLOR(15);
                            TEXTBACKGROUND(0);
                            WRITE(' Setup ');
                            ShowMouseCursor;
                            DONE:=TRUE;
                           END
                     END {CASE EV.KEY}
          END;
IF MousePressed(1) THEN
     BEGIN
       GetMouseAction(Butn, XC, Yc);
       IF (YC=0) AND (XC>1) AND (XC<10) THEN
        BEGIN
          HideMouseCursor;
          GOTOXY(2,1);
          TEXTCOLOR(15);
          TEXTBACKGROUND(0);
          WRITE(' Setup ');
          ShowMouseCursor;
          DONE:=TRUE;
        END
     END;

UNTIL DONE;
END;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetPathName( var SName : String;var Backup : Boolean;
                       InposY1,InposY2 : integer; var select :integer;
                       var Abort : Boolean);
 var
  Done    : Boolean;
  Zeroed  : Boolean;
  CharPos : Byte;
  Xpos    : Integer;
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
   Ypos    := WhereY;
   OrgX    := WhereX;
   OrgY    := WhereY;

   TextColor(14);
   TextBackGround(0);
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
                 if (Xpos < 63) and (CharPos < Length(SName)+1) then
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
                 while (Xpos < 63) and (CharPos < Length(SName)+1) do
                  begin
                   Xpos :=Xpos +1;
                   CharPos :=CharPos +1
                  end;
                   gotoxy(Xpos,Ypos);
                   Zeroed :=true
                end;
        Larrow : begin
                 if (Xpos > 17) and (CharPos >1) then
                  begin
                   Xpos :=Xpos -1;
                   CharPos :=CharPos -1;
                   gotoxy(Xpos,Ypos);
                   Zeroed :=true;
                  end
                end;
        Darrow : begin
                  if InposY1 =Ypos then
                   begin
                    select:=2;
                    Done:=true;
                   end
                  else
                  if InposY2 =Ypos then
                   begin

                    Done:=true;
                   end
                 end;
        Uarrow : begin
                  if InposY2 =Ypos then
                   begin
                    select:=1;
                    BackUp :=true;
                    Done:=true;
                   end
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
                  if (Xpos > 17) and (CharPos >1) then
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
                 if (Xpos > 17) and (CharPos >1) then
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
                  Write('                                               ');
                  ShowMouseCursor;
                  GotoXy(Xpos,Ypos);
                  Zeroed :=true;
                 end;
                 if (Xpos < 63)  then
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
     BEGIN
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
                 while (Xpos < 63) and (CharPos < Length(SName)+1)
                 and (Xpos < XC) do
                  begin
                   Xpos :=Xpos +1;
                   CharPos :=CharPos +1
                  end;
                   gotoxy(Xpos,Ypos);
                   Zeroed :=true
               end
               else
                begin
                 if (Yc =InposY1) or (Yc =InposY2) then
                 begin
                  if (InposY2 =Ypos) and (Yc= InposY1) then
                   begin
                    select:=1;
                    BackUp :=true;
                    Done:=true
                   end
                  else
                   if (InposY1 =Ypos) and (Yc= InposY2) then
                    begin
                     select:=2;
                     Done:=true
                    end
                end
          end
        end
      end
    end
  until done;
 end;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetStringName( var SName : String; MaxLen : integer;
                          var Abort : Boolean);
 var
  Done    : Boolean;
  Zeroed  : Boolean;
  CharPos : Byte;
  Xpos    : Integer;
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
                 if (Xpos < 63) and (CharPos < Length(SName)+1) then
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
                 while (Xpos < 63) and (CharPos < Length(SName)+1) do
                  begin
                   Xpos :=Xpos +1;
                   CharPos :=CharPos +1
                  end;
                   gotoxy(Xpos,Ypos);
                   Zeroed :=true
                end;
        Larrow : begin
                 if (Xpos > 17) and (CharPos >1) then
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
                  if (Xpos > 17) and (CharPos >1) then
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
                 if (Xpos > 17) and (CharPos >1) then
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
                 if (Xpos < 63)  then
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
     BEGIN
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
                 while (Xpos < 63) and (CharPos < Length(SName)+1)
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
 procedure DoInstall( var Doit : Boolean);
 var
  VS        : Vioram;
  DirStr    : String;
  XC,YC     : Integer;
  Done      : boolean;
  DestPath  : String;
  SrcPath   : String;
  BackUp    : Boolean;
  Sel       : Integer;
  Abort     : Boolean;
  AbortCnt  : Integer;

 begin
  HideMouseCursor;
  Vs:=Vp^;
  ShowMouseCursor;
  DoIt :=false;
  BackUp := False;
  inwindow (15,5,50,12,14,4);
  HideMouseCursor;
  gotoxy(24,6);
  TextColor(15);
  Write(DoorName+' Door Installation');
  gotoxy(17,9);
  TextColor(11);
  Write('Installing From (Path).... ');
  gotoxy(17,10);
  TextBackGround(0);
  Write('                                               ');
  GetDir(0,SrcPath);
  gotoxy(17,10);
  TextColor(14);
  Write(SrcPath);

  gotoxy(17,12);
  TextColor(11);
  TextBackGround(4);
  Write('Where To Install (Path)... ');
  gotoxy(17,13);
  TextBackGround(0);
  Write('                                               ');
  gotoxy(17,13);
  TextColor(14);
  DestPath:=SrcPath;
  Write(DestPath);
  gotoxy(33,16);
  TextColor(0);
  TextBackGround(7);
  Write(' <ESC> C');
  Write('ancel ');
  gotoxy(17,10);
  ShowMouseCursor;
  Done :=false;
  Sel:=1;
  repeat
   Backup :=False;
   Abort :=False;
   gotoxy(17,10);
   GetPathName(SrcPath,Backup,10,13,Sel,Abort);
   if Not Abort then
   begin
    if pos('\',Copy(SrcPath,Length(SrcPath),1)) =0 then
     while pos(' ',SrcPath)>0 do
       delete(SrcPath,pos(' ',SrcPath),1);
    srcpath:=SrcPath+'\';
    if Not Exist(SrcPath+'*.*') then
      begin
       Errormsg(5,9,'Path Not Found');
       BackUp :=True
      end
   else
    begin
     gotoxy(17,13);
     if Not Abort then
     GetPathName(DestPath,Backup,10,13,Sel,Abort);
     if pos('\',Copy(DestPath,Length(DestPath),1)) =0 then
     while pos(' ',DestPath)>0 do

       delete(DestPath,pos(' ',DestPath),1);
     DestPath:=DestPath+'\';

     if upper(DestPath)=upper(SRcPath) then
      begin
       Errormsg(3,6,'Directory Error');
       Abort:=true
      end
      else
     if Not Exist(DestPath+'*.*') then
     begin
      Errormsg1('Path Not Found');
      {$I-}
       MkDir(Copy(DestPath,1,length(DestPath)-1));
       gotoXY(30,10);
       if IOResult <> 0 then
       begin
        WriteLn('Cannot create directory');
        Abort :=true
       end
       else
       WriteLn('  Directory Created...');
       DELAY(2000);
      {$I+}
     end
    end
   end
  until Not Backup or Abort;
   HideMouseCursor;
   Vp^:=VS;
   ShowMouseCursor;
   if Not Abort then
    begin
       Errormsg(1,3,'Installation Begins');
       Inwindow(10,3,60,20,14,3);
       Xc:=0;
       TextColor(12);
       GotoXy(12,3);
       Writeln(' Press <ESC> to Abort...');
       AbortCnt :=0;
       While Not abort and (Xc < NumFiles) do
        begin
         Xc:=Xc+1;
         TextColor(15);
         GotoXy(12,4+Xc);
         TextColor(15);
         TextBackGround(3);
         Writeln('Copying ',FileList[Xc],' to ',DestPath+FileList[Xc]);
          Abort := Not CopyFile(SrcPath+FileList[Xc],DestPath);
          if Abort then
            begin
             AbortCnt:= AbortCnt+1;
             if AbortCnt >4 then
                errormsg(4,2,'Too Many Files Missing')
             else
             Abort:=false;
            end;
          if KeyPressed then Abort :=(Readkey=#27);
          Delay(100);
        end;
        if Not Abort then
         begin
          Errormsg(1,5,'Installation Complete');
          Errormsg(2,2,'Select Configuration Next');
          {$I-}
          Chdir(copy(DestPath,1,Length(DestPath)-1));
          if IoResult<>0 then
             errormsg(4,4,' Path Not Found');
          {$I+}
         end
        else
         Errormsg(12,5,'Installation Aborted ');
         HideMouseCursor;
          Vp^:=VS;
         ShowMouseCursor;
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetData;
 var
  FirstName  : FirstNameType;
  ConfigFile : text;
  boovar     : byte;
  I          : integer;
  SecTime    : real;
  TmpSYSOPNM : String;

 begin
  RN:='123456789';
  BBSNAME:='Doors R US BBS';
  SYSOPNAME :='Jack Sysop';
  ComNum    := 1;
  Baud      := 2400;
  BBSDir    :='C:\BBS\YAHTZEE';
  UFile     :='Dorinfo1.DEF';
  FNLN      :=7;
  LNLN      :=8;
  BRLN      :=5;
  TLLN      :=12;
  TLLNDef   :=0;
  TULN      :=0;
  TULNDef   :=3;
  UseRts    :=True;
  UseCts    :=True;

  if exist('Yahtzee.CFG') then
  begin
  {$I-}
  assign(ConfigFile,'Yahtzee.CFG');
  reset(ConfigFile);
  if IoResult <>0 then
   begin
    Writeln;
    Writeln(' Yahtzee.CFG File Not Found ... Execution Halted. ');
   end
  {$I-}
   else
    begin
     readln(Configfile,RN);
     readln(Configfile,COMNUM);
     readln(Configfile,BAUD);
     readln(Configfile,SySopName);
     readln(Configfile,BBSName);
     readln(Configfile,BBSDIR);
     readln(Configfile,UFILE);
     readln(Configfile,FNLN);
     readln(Configfile,LNLN);
     readln(Configfile,BRLN);
     read(Configfile,TLLN);
     if TLLN =0 then
     readln(Configfile,TimeLimit)
     else
      readln(Configfile);
     read(Configfile,TULN);
     if TULN =0 then
     readln(Configfile,TimeUsed)
     else
     readln(Configfile);
     readln(Configfile, Boovar);
     UseRTS := Boovar =1;
     readln(Configfile, Boovar);
     UseCTS := Boovar =1;
     close(Configfile)
    end
   end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure SaveData;
 var
  FirstName  : FirstNameType;
  ConfigFile : text;
  boovar     : byte;
  I          : integer;
  SecTime    : real;
  TmpSYSOPNM : String;

 begin
  Errormsg1(' Saving Data');
  delay(1000);
  {$I-}
  assign(ConfigFile,'Yahtzee.CFG');
  ReWrite(ConfigFile);
  Writeln(Configfile,RN);
  Writeln(Configfile,COMNUM);
  Writeln(Configfile,BAUD);
  Writeln(Configfile,SySopName);
  Writeln(Configfile,BBSName);
  Writeln(Configfile,BBSDIR);
  Writeln(Configfile,UFILE);
  Writeln(Configfile,FNLN);
  Writeln(Configfile,LNLN);
  Writeln(Configfile,BRLN);
  Write(Configfile,TLLN,' ');
    if TLLN =0 then
     Writeln(Configfile,TLLNDef)
    else
     Writeln(Configfile);

  Write(Configfile,TULN,' ');
    if TULN =0 then
     Writeln(Configfile,TULNDef)
    else
     Writeln(Configfile);

     if UseRts then
      Writeln(Configfile,1)
     else
      Writeln(Configfile,0);

     if UseCts then
      Writeln(Configfile,1)
     else
      Writeln(Configfile,0);
      Writeln(Configfile);
     close(Configfile)
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure showdata;
 begin
   HideMouseCursor;
   TextColor(14);
   TextBackGround(1);
   gotoxy(43,5);
   Write('                                  ');
   gotoxy(44,5);
   Write(Rn);
   gotoxy(43,6);
   Write('                                  ');
   gotoxy(44,6);
   Write('COM',ComNum);

   gotoxy(43,7);
   Write('                                  ');
   gotoxy(44,7);
   Write(Baud);

   gotoxy(43,8);
   Write('                                  ');
   gotoxy(44,8);
   Write(SysOpName);

   gotoxy(43,9);
   Write('                                  ');
   gotoxy(44,9);
   Write(BBSNAME);

   gotoxy(43,10);
   Write('                                  ');
   gotoxy(44,10);
   Write(BBSDIR);

   gotoxy(43,11);
   Write('                                  ');
   TextColor(11);
   gotoxy(44,11);
   Write(UFILE);

   gotoxy(43,12);
   Write('                                  ');
   gotoxy(44,12);
   Write(FNLN);

   gotoxy(43,13);
   Write('                                  ');
   gotoxy(44,13);
   Write(LNLN);

   gotoxy(43,14);
   Write('                                  ');
   gotoxy(44,14);
   Write(BRLN);
   gotoxy(43,15);
   Write('                                  ');
   gotoxy(44,15);
   if TLLN =0 then
   Write('Defaulted ',TLLNDEF,' Minutes ')
   else
   Write(TLLN);
   gotoxy(43,16);
   Write('                                  ');
   gotoxy(44,16);
   if TULN =0 then
   Write('Defaulted ',TULNDEF,' Minutes ')
   else
   Write(TULN);
   gotoxy(43,17);
   Write('                                  ');
   gotoxy(44,17);
   TextColor(14);
   if UseRts then
    Write('Yes ')
   else
    Write('No  ');
   gotoxy(43,18);
   Write('                                  ');
   gotoxy(44,18);
   if UseCts then
    Write('Yes ')
   else
    Write('No  ');
    TextBackGround(0);
   gotoxy(43,19);
   Write('                                  ');
   gotoxy(43,20);
   Write('                                  ');
  ShowMouseCursor;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure DoSetup;

 const
  CFGCMDLST: CMDARRAY =('  Registration Code                 ',
                        '  Comm port number                  ',
                        '  Baud rate                         ',
                        '  SysOp''s Name                      ',
                        '  BBS Name                          ',
                        '  Directory of BBS                  ',
                        '  Userfile Name (dorinfo1.def etc.) ',
                        '  Line number of user first name    ',
                        '  Line number of user last name     ',
                        '  Line number of user baud rate     ',
                        '  Line number of user time limit    ',
                        '  Line number of user time used     ',
                        '  Use RTS handshaking               ',
                        '  Use CTS handshaking               ',
                        '  Exit Without Saving Data          ',
                        '  Exit And Save Data                ',
                        '','','','');

   BaudList :Array[1..9] of LongInt = (1200,2400,4800,9600,14400,
                                       19200,38400,57600,115200);

 var
  VS        : Vioram;
  DirStr    : String;
  CFGCB     : CMDBOX;
  Abort     : Boolean;
  StrSave   : String;
  Ch        : Char;
  Done      : Boolean;
  Finish    : Boolean;
  I         : Integer;

 begin
  HideMouseCursor;
  Vs:=Vp^;
  ShowMouseCursor;
  Abort :=False;
  CFGCB.INIT(5,4,70,16,CFGCMDLST,0);
  inwindow (4,3,72,18,14,4);
  gotoxy(7,3);
  TextColor(15);
  HideMouseCursor;
  Writeln(DoorName+' Door Configuration');
  ShowMouseCursor;
  ErrorMsg1('Reading Data');
  delay(100);
  getdata;
  CfgCB.SHOW;
  Finish := False;
  Repeat
  ShowData;
  CfgCB.PROCESS;
  CASE CfgCB.CMDNUM OF
   1: begin
      HideMouseCursor;
      TextColor(15);
      TextBackGround(5);
      gotoxy(43,5);
      Write('                                  ');
      gotoxy(44,5);
      Write(Rn);
      gotoxy(44,5);
      SHowMouseCursor;
      GetStringName( RN,25, Abort);
      end;
   2: begin
      HideMouseCursor;
      TextColor(15);
      TextBackGround(5);
      gotoxy(43,6);
      Write('                                  ');
      Done:=False;
      Repeat
      gotoxy(44,6);
      Write('COM',ComNum);
       Repeat Until KeyPressed;
       Ch:=ReadKey;
       case Ch of
      #27,#13 : Done:=true;
       #8 : Begin
              ComNum:=ComNum-1;
              If ComNum <1 then ComNum :=4;
             End;
       ' ' : Begin
              ComNum:=ComNum+1;
              If ComNum >4 then ComNum :=1;
             End;
        #0 : begin
              Ch:=Readkey;
               if Ch = Uarrow then
               begin
                ComNum:=ComNum+1;
                If ComNum >4 then ComNum :=1;
               end
              else
               Begin
                ComNum:=ComNum-1;
                If ComNum <1 then ComNum :=4;
               End;
             end;
       End;{Case}

      Until Done;
      end;
   3: begin
      I:=0;
      Done :=false;
      While (I<9) and Not done do
       begin
        I:=I+1;
        If BaudList[I]=Baud then Done :=True;
       end;

      HideMouseCursor;
      TextColor(15);
      TextBackGround(5);
      gotoxy(43,7);
      Write('                                  ');
      Done:=False;
      Repeat
      gotoxy(44,7);
      Write(Baudlist[I],'    ');
       Repeat Until KeyPressed;
       Ch:=ReadKey;
       case Ch of
      #27,#13 : Done:=true;
       #8 : Begin
              I:=I-1;
              If I <1 then I :=9;
             End;
       ' ' : Begin
              I:=I+1;
              If I >9 then I :=1;
             End;
        #0 : begin
              Ch:=Readkey;
              if Ch=UArrow then
               begin
                I:=I+1;
                If I >9 then I :=1;
               end
              else
               Begin
                I:=I-1;
                If I <1 then I :=9
                End;
              end;
       End;{Case}

      Until Done;
      Baud :=Baudlist[I];
      end;
   4: begin
      HideMouseCursor;
      TextColor(15);
      TextBackGround(5);
      gotoxy(43,8);
      Write('                                  ');
      gotoxy(44,8);
      Write(SysOpName);
      gotoxy(44,8);
      SHowMouseCursor;
      GetStringName( SysOpName,25, Abort);
      end;
   5: begin
      HideMouseCursor;
      TextColor(15);
      TextBackGround(5);
      gotoxy(43,9);
      Write('                                  ');
      gotoxy(44,9);
      Write(BBSName);
      gotoxy(44,9);
      SHowMouseCursor;
      GetStringName(BBSName,25, Abort);
      end;
   6: begin
      HideMouseCursor;
      TextColor(15);
      TextBackGround(5);
      gotoxy(43,10);
      Write('                                  ');
      gotoxy(44,10);
      Write(BBSDir);
      gotoxy(44,10);
      SHowMouseCursor;
      GetStringName(BBSDir,25, Abort);
      if pos('\',Copy(BBSDir,Length(BBSDir),1)) =0 then
      BBSDir:=BBSDir+'\';
      if Not Exist(BBSDir+'*.*') then
      begin
       Errormsg(4,9,'Path Not Found');
      end;
      BBSDir :=Copy(BBSDir,1,Length(BBSDir)-1);
      end;
   7: begin
      HideMouseCursor;
      TextColor(15);
      TextBackGround(5);
      gotoxy(43,11);
      Write('                                  ');
      gotoxy(44,11);
      Write(UFile);
      gotoxy(44,11);
      SHowMouseCursor;
      GetStringName(Ufile,25, Abort);
      if pos('DORINFO1.DEF',Upper(Ufile))>0 Then
       begin
        FNLN:=7;
        LNLN:=8;
        BRLN:=5;
        TLLN:=12;
        TULN:=0;
        TULNDef:=3;
       end
      else
      if pos('CHAIN.TXT',Upper(Ufile))>0 Then
       begin
        FNLN:=2;
        LNLN:=2;
        BRLN:=20;
        TLLN:=16;
        TULN:=0;
        TULNDef:=3;
       end
      end;
   8: begin
        HideMouseCursor;
        TextColor(15);
        TextBackGround(5);
        gotoxy(43,12);
        Write('                                  ');
        Done:=False;
        Repeat
         gotoxy(44,12);
         Write(FNLN,' ');
         Repeat Until KeyPressed;
        Ch:=ReadKey;
        case Ch of
         #27,#13 : Done:=true;
         #8 : Begin
                if FNLN >1 then
                 begin
                  FNLN:=FNLN-1;
                 end;
               End;
       ' ' : Begin
              FNLN:=FNLN+1;
              If FNLN>99 then FNLN :=1;
             End;
        #0 : begin
              Ch:=Readkey;
              if Ch = Uarrow then
               begin
                FNLN:=FNLN+1;
                If FNLN>99 then FNLN :=1
               end
              else
                if FNLN >1 then
                  FNLN:=FNLN-1;
              end
         End {Case}
        until done;
      end;
   9: begin
        HideMouseCursor;
        TextColor(15);
        TextBackGround(5);
        gotoxy(43,13);
        Write('                                  ');
        Done:=False;
        Repeat
         gotoxy(44,13);
         Write(LNLN,' ');
         Repeat Until KeyPressed;
        Ch:=ReadKey;
        case Ch of
         #27,#13 : Done:=true;
         #8 : Begin
                if LNLN >1 then
                 begin
                  LNLN:=LNLN-1;
                 end;
               End;
       ' ' : Begin
              LNLN:=LNLN+1;
              If LNLN>99 then LNLN :=1;
             End;
        #0 : begin
              Ch:=Readkey;
              if Ch = Uarrow then
               begin
                LNLN:=LNLN+1;
                If LNLN>99 then LNLN :=1
               end
              else
                if LNLN >1 then
                  LNLN:=LNLN-1;
              end
         End {Case}
        until done;
      end;
   10:begin
        HideMouseCursor;
        TextColor(15);
        TextBackGround(5);
        gotoxy(43,14);
        Write('                                  ');
        Done:=False;
        Repeat
         gotoxy(44,14);
         Write(BRLN,' ');
         Repeat Until KeyPressed;
        Ch:=ReadKey;
        case Ch of
         #27,#13 : Done:=true;
         #8 : Begin
                if BRLN >1 then
                 begin
                  BRLN:=BRLN-1;
                 end;
               End;
       ' ' : Begin
              BRLN:=BRLN+1;
              If BRLN>99 then BRLN :=1;
             End;
        #0 : begin
              Ch:=Readkey;
              if Ch = Uarrow then
               begin
                BRLN:=BRLN+1;
                If BRLN>99 then BRLN :=1
               end
              else
                if BRLN >1 then
                  BRLN:=BRLN-1;
              end
         End {Case}
        until done;
      end;
  11: begin
      HideMouseCursor;
      TextColor(15);
      TextBackGround(5);
      gotoxy(43,15);
      Write('                                  ');
      Done:=False;
      Repeat
      gotoxy(44,15);
      if TLLN =0 then
       Write('Defaulted ',TLLNDEF,' Minutes  ')
       else
      Write(TLLN,' ');
      Repeat Until KeyPressed;
       Ch:=ReadKey;
       case Ch of
      #27,#13 : Done:=true;
       #8 : Begin
                if TLLN >0 then
                 begin
                  TLLN:=TLLN-1;
                  If TLLN <1 then
                   begin
                    TLLN :=0;
                    TLLNDef :=4;
                   end
                 end;
              If TLLN =0 then
               begin
                TLLNDef :=TLLNDef -1;
                if TLLNDef<0 then
                 begin
                  TLLN:=1;
                  TLLNDef:=0;
                  gotoxy(43,15);
                  Write('                                  ');
                 end
               end
             End;
       ' ' : Begin
              if TLLN>0 then TLLN:=TLLN+1;
              If TLLN>99 then TLLN :=0;
              If TLLN =0 then
               begin
                TLLNDef :=TLLNDef +1;
                if TLLNDef>90 then
                 begin
                  TLLN:=1;
                  TLLNDef:=0;
                  gotoxy(43,15);
                  Write('                                  ');
                 end
               end
             End;
        #0 : begin
              Ch:=Readkey;
               if Ch = Uarrow then
               begin
                if TLLN>0 then TLLN:=TLLN+1;
                If TLLN>99 then TLLN :=0;
                If TLLN =0 then
                 begin
                  TLLNDef :=TLLNDef +1;
                  if TLLNDef>90 then
                   begin
                    TLLN:=1;
                    TLLNDef:=0;
                    gotoxy(43,15);
                    Write('                                  ');
                   end
                 end
               end
              else
               Begin
                if TLLN >0 then
                 begin
                  TLLN:=TLLN-1;
                  If TLLN <1 then
                   begin
                    TLLN :=0;
                    TLLNDef :=4;
                   end
                 end;
                If TLLN =0 then
                 begin
                  TLLNDef :=TLLNDef -1;
                  if TLLNDef<0 then
                   begin
                    TLLN:=1;
                    TLLNDef:=0;
                    gotoxy(43,15);
                    Write('                                  ');
                   end
                 end
               End;
             end;
       End;{Case}

      Until Done;
      end;
   12: begin
      HideMouseCursor;
      TextColor(15);
      TextBackGround(5);
      gotoxy(43,16);
      Write('                                  ');
      Done:=False;
      Repeat
      gotoxy(44,16);
      if TULN =0 then
       Write('Defaulted ',TULNDEF,' Minutes  ')
       else
      Write(TULN,' ');
      Repeat Until KeyPressed;
       Ch:=ReadKey;


       case Ch of
      #27,#13 : Done:=true;
       #8 : Begin
                if TULN >0 then
                 begin
                  TULN:=TULN-1;
                  If TULN <1 then
                   begin
                    TULN :=0;
                    TULNDef :=4;
                   end
                 end;
              If TULN =0 then
               begin
                TULNDef :=TULNDef -1;
                if TULNDef<0 then
                 begin
                  TULN:=1;
                  TULNDef:=0;
                  gotoxy(43,16);
                  Write('                                  ');
                 end
               end
             End;
       ' ' : Begin
              if TULN>0 then TULN:=TULN+1;
              If TULN>99 then TULN :=0;
              If TULN =0 then
               begin
                TULNDef :=TULNDef +1;
                if TULNDef>90 then
                 begin
                  TULN:=1;
                  TULNDef:=0;
                  gotoxy(43,16);
                  Write('                                  ');
                 end
               end
             End;
        #0 : begin
              Ch:=Readkey;
               if Ch = Uarrow then
               begin
                if TULN>0 then TULN:=TULN+1;
                If TULN>99 then TULN :=0;
                If TULN =0 then
                 begin
                  TULNDef :=TULNDef +1;
                  if TULNDef>90 then
                   begin
                    TULN:=1;
                    TULNDef:=0;
                    gotoxy(43,16);
                    Write('                                  ');
                   end
                 end
               end
              else
               Begin
                if TULN >0 then
                 begin
                  TULN:=TULN-1;
                  If TULN <1 then
                   begin
                    TULN :=0;
                    TULNDef :=4;
                   end
                 end;
              If TULN =0 then
               begin
                TULNDef :=TULNDef -1;
                if TULNDef<0 then
                 begin
                  TULN:=1;
                  TULNDef:=0;
                  gotoxy(43,16);
                  Write('                                  ');
                 end
               end
               End;
             end;
       End;{Case}

      Until Done;
      end;
   13:begin
      HideMouseCursor;
      TextColor(15);
      TextBackGround(5);
      gotoxy(43,17);
      Write('                                  ');
      Done:=False;
      Repeat
      gotoxy(44,17);
      TextColor(14);
      if UseRts then
      Write('Yes ')
      else
      Write('No  ');
      Repeat Until KeyPressed;
       Ch:=ReadKey;
       case Ch of
      #27,#13 : Done:=true;
       #8,' ': UseRts :=Not UseRts;
       #0 : begin
              Ch:=Readkey;
              UseRts :=Not UseRts;
             end;
       End;{Case}
      Until Done;
      end;
   14:begin
      HideMouseCursor;
      TextColor(15);
      TextBackGround(5);
      gotoxy(43,18);
      Write('                                  ');
      Done:=False;
      Repeat
      gotoxy(44,18);
      TextColor(14);
      if UseCts then
      Write('Yes ')
      else
      Write('No  ');
      Repeat Until KeyPressed;
       Ch:=ReadKey;
       case Ch of
      #27,#13 : Done:=true;
       #8,' ': UseCts :=Not UseCts;
       #0 : begin
              Ch:=Readkey;
              UseCts :=Not UseCts;
             end;
       End;{Case}
      Until Done;
      end;
    16   : begin
            Finish:=true;
            SaveData
           end;
    0,15 : Finish:=true;
  end;
  Until Finish;
  HideMouseCursor;
  Vp^:=VS;
  ShowMouseCursor;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure Kill(st : string);
  var
   Kilfile : Text;
 begin
  if Exist(St) then
  begin
   Assign( KilFile,St);
   Erase(KilFile);
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure DoReset;
 begin
  if GetConFirm then
  begin
   Kill('YAHTZEE.hof');
   Kill('YAHTZEE.rnx');
   Errormsg(12,4,'Game Reset Complete ');
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{****************************************************************}
{********************* M A I N   L O O P  ***********************}
{****************************************************************}

CONST
  MAINCMDLST: CMDARRAY =(' Configuration    ',
                         ' Install          ',
                         ' Game Reset       ',
                         ' Run YAHTZEE      ',
                         ' Quit             ',
                         '','','','','','','','','','','','','','','');

var
 MAINCB                         : CMDBOX;
 CH                             : CHAR;
 I,PN,K,XS,YS                   : INTEGER;
 DONE,DOIT                      : BOOLEAN;
 DIRINFO                        : SEARCHREC;
 VS                             : VioRam;

BEGIN

 CLRSCR;
 MoveMouse( 0,0);
 ShowMouseCursor;                                       { show mouse pointer }

 SND_ON := FALSE;

 MAINCB.INIT(2,2,18,5,MAINCMDLST,14);
 DONE:=FALSE;
 SHOWMAINSCRN;
{ ProcessMain(maincb);}
 REPEAT
  MAINCB.SHOW;
  MAINCB.PROCESS;
 CASE MAINCB.CMDNUM OF
   0: DONE:=TRUE;
   1: DoSetup;
   2: DoInStall(Doit);
   3: DoReset;
   4: begin
       VS :=VP^;
       TextBackGround(0);
       TextColor(15);
       clrscr;
       if SysopName='' then Getdata;
       SwapVectors;
       Exec('yahtzee.EXE',SysopName);
       SwapVectors;
        if DosError <>0 then
         begin
          Writeln( 'Execution Error.....');
          Case DosError of
          2: Writeln(' File not found');
          3: Writeln(' Path not found');
          5: Writeln(' Access denied');
          6: Writeln(' Invalid handle');
          8: Writeln(' Not enough memory');
         end;
         delay(2000);
         end;
       VP^:=VS
      end;
   5: DONE:=TRUE;
  END;
UNTIL DONE;
 HideMouseCursor;
 textbackground(0);
 CLRSCR;
 INWINDOW(20,3,33,3,15,0);
 GOTOXY(22,4);
 WRITELN(' Neubauer Applications Uncorp. ');
 GOTOXY(22,5);
 WRITELN(' BBS Door Setup Program. ');
 GOTOXY(22,6);
 WRITELN(' Version 1.00 (c) 1992   ');
 WRITELN;
 WRITELN;
 WRITELN;
 TEXTCOLOR(15);
 WRITELN(' Exit..... ');
 NOSOUND;
 END.
