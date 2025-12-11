{$V-}
{$X+}

UNIT BBSGAM;
{********************************************************************}
INTERFACE

Uses Crt,Dos,Emulate,BBSScrn;

Type
 NameString = string[25];
 BBSData = Record
            SysOpName    : NameString;
            UNAME        : NameString;
            BBSNAme      : String;
            BBSDir       : String;
            RN           : String;
            TimeUsed     : integer;
            STARTTIME    : integer;
            TIMELIMIT    : integer;
            Registered   : Boolean;
            UseCTS       : Boolean;
            USeRTS       : Boolean
           end;

  CharSet = set of Char;
  TBBS = Object(Emul)
    BRec         : BBSData;
    StartPage    : Integer;
    Duration     : Integer;
    JoinIt       : boolean;
    TIMESON      : WORD;
    HOTKEYS      : boolean;
    ReqChat      : boolean;
    GoOffLine    : boolean;
    Procedure Init (ComNum : Byte; BD :LongInt;BBRec : BBSData; Lcl: Boolean);
    Procedure Run;
    Procedure Done;
    Procedure CHAT;
    Procedure PageSysOp;
    function  TimeNow: integer;
    Procedure CheckKey;
    Procedure SHOWFKeys;
    Procedure SHOWMSR;
    Procedure ShowTimeLeft;
    Function  TimeLeft: integer;
    Procedure CheckTimeLeft;
    Procedure GiveWarning;
    Procedure GetCHARS(var INCHAR: char);
    Procedure GetCHAR(var INCHAR:Char; CSet: CharSet);
    Procedure GetYN(var YHIT: boolean) ;
    Procedure GetNY(var YHIT: boolean) ;
    Procedure GetYNQ(var YHIT,Aborted: boolean; Prompton : boolean);
    Procedure GetCR( C : Byte);
    Procedure GetEnterKey;
    Procedure GetEnterKeyNC;
    Procedure Getstring(var FSTRING:STRING; Pstring:string;Confirm:boolean);
    Procedure GetNum(var Num: Integer; MaxVal: integer);
    Procedure GetLNum(var Num: LongInt; MaxVal: LongInt);
    Procedure GetRNum(var Num: Real; MaxVal:Real);
    Procedure ReadlnX(var ST : string; L : integer);
    Procedure TimePrompt;
    Procedure ChangeColor(Attr : Byte);
    Function  Incoming : Boolean;
    Procedure ClearReceive;
    Procedure ClearTransmit;
    Function  GetBps : Longint;
    Procedure SetDBps(BpsIN : Word);
    Function  WaitFor(Strn : String; Timeout : Word) : Boolean;
    Function  DetectAnsi : Boolean;
    Procedure SetIntChar(Ch : CharSet);
    Procedure MenuWrite(bb,cb,cf: byte; CDSTR : String; var ChSt : Char);
    Procedure TMenuWrite(bb,cb,cf: byte; CDSTR : String);
    Procedure TypeFileMore(Fname : String;var ChRet : Char);
    Procedure TypeFile(Fname : String;var  ChRet : Char);
    Procedure TypeHOLE(Fname : String; HoleNm : Byte);

    private
    Com        : Byte;
    IntCharset : CharSet;
    Bps        : word;
  end;

 Type
  VEL   = RECORD
               CASE BOOLEAN OF
                TRUE  : (Character, ATTRIBUTE :BYTE);
                FALSE : (CONTENTS             :WORD);
           end;


Procedure FormatName(var FNAME :NameSTRING);
Function Backspace(Num : Byte) : String;
Function Center(Strn : String) : String;
Function CopyFile(Source, Dest : String) : Boolean;
Function Date : String;
Function Exist(Filename : String) : Boolean;
Function IntToStr(Num : LongInt) : String;
Function Left(Strn : String; Places : Byte) : String;
Function Lower(Strn : String) : String;
Function Replicate(Ch : String; Num : Byte) : String;
Function Right(Strn : String; Places : Byte) : String;
Function Space(Num : Byte) : String;
Function StrToInt(Strn : String) : LongInt;
Function Time : String;
Function Upper(Strn : String) : String;
Function XPos(Strn, SubStrn : String; Offset : Byte) : Byte;

{********************************************************************}

IMPLEMENTATION


Const
  LArrow = #75; RArrow = #77; UArrow = #72; DArrow = #80;
  F1 = #59; F2 = #60; F3 = #61; F4 = #62; F5 = #63; F6 = #64; F7 = #65;
  F8 = #66; F9 = #67; F10 = #68; F11 = #133; F12 = #134;


Var
  Count          : Integer;
  FileName       : String;
  Comport        : Byte;
  Place          : Word;
  Hold           : Byte;
  Code, Status   : Word;


{--- Miscellaneous routines -----------------------------------------}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure FormatName(var FNAME :NameSTRING);
var
 I        : integer;
 SPCTAG   : boolean;
 TMPCHAR  : char;
 begin
  if length(FNAME) >0 then
   begin
     for I:=1 to length(FNAME) do
      If (FNAME[I] in ['A'..'Z']) then
       FNAME[I]:=CHR(ord(FNAME[I])+32);
     SPCTAG:=true;
     for I:=1 to length(FNAME) do
      begin
       if SPCTAG then
        begin
         FNAME[I]:=UPCASE(FNAME[I]);
        end;
       spctag:= (copy(FNAME,I,1)=' ');
      end
   end;
   if pos('  ',Fname)>0 then delete(Fname,pos('  ',Fname),1);
   while Length(FName)< 25 do Fname:=Fname+' ';
   Fname:=Copy(Fname,1,21)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Tick  : Word;
 var
   H, M, S, HS : Word;
 begin
   GetTime(H, M, S, HS);
   Tick := M
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.GiveWarning;
  var
   XSV,YSV : Integer;
 begin
  XSV:=WhereX;
  YSV:=WhereY;
  Emu_GoToXy(1,24);
  ComWriteO(#7);
  ComWrite('Inactivity Warning !!!');
  ComWriteO(#7);
  ComWriteO(#7);
  Emu_GotoXY(XSV,YSV);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 { GETS A SINGLE CHAR AND MONITORS CARRIER }
 Procedure TBBS.GetCHARS(var INCHAR: char);
 var
  DumInput  : Char;
  Ch        : Byte;
  SavTime   : Byte;
  MinCount  : Integer;
 begin
  SavTime:=Tick;
  MinCount:=0;
  DumInput :=#0;
 While (DumInput =#0) and OnLine and not GoOffLine and Not ReqChat do
  begin
   if SavTime<>Tick then
    begin
     MinCount:=MinCount+1;
     SavTime:=Tick;
     if MinCount>2 then
      begin
       GiveWarning;
       if MinCount>3 then GoOffline:=true
      end
    end;
   DumInput:=#0;
   IF KEYPRESSED and not ReqChat and not GoOffLine And Online Then
     begin
       DumInput:=(ReadKey);
       if DumInput=#0 then
         begin
          CheckKey;
          ShowMsr
         end
       else
         ShowFKeys
     end
   else
   if Chwaiting then DumInput :=CReadKey;
   CheckTimeLeft;
  end;
  if NOT Online then GoOffline :=true;
  ShowMsr;
  INCHAR:=DumInput;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 Procedure TBBS.GetCHAR(var INCHAR:Char; CSet: CharSet);
 var
   DumInput    : Char;
   DumCRInput  : Char;
   CR          : Char;
   Ch          : Byte;

 begin
  DumInput:=#0;
  While not(DumInput in CSET) and Not GoOffLine and Not ReqChat do
  begin
   if HotKeys then
    begin
     repeat
      GetCharS(DumInput);
      DumInput :=UpCase(DumInput);
     Until (DumInput In CSet) or GoOffline or ReqChat;
     if DumInput <>#13 then ComWrite(DumInput)
    end
   else
   begin
    CR:=#8;
    While (CR =#8) and Not GoOffLine  and Not ReqChat do
    begin
     Repeat
      GetCharS(DumInput);
      DumInput :=UpCase(DumInput);
     Until (DumInput In CSet) or GoOffline or ReqChat;
     CR:=#0;
     if Not (DumInput=#13) then
     begin
      ComWrite(DumInput);
      Repeat
       CR :=#0;
       GetCharS(CR);
      Until (CR In [#8,#13]) or GoOffline or ReqChat;
     end;
     if CR=#8 then
      begin
       DumInput :=#0;
       ComWrite(#8+' '+#8)
      end
    end
   end;
  end;
  INCHAR:=DumInput;
  ClearRX
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.GetCR( C : Byte);
 begin
   Emu_Color(C,0);
   ComWrite(' Press [ENTER].. ');
   GetEnterKey
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.GetEnterKey;
 var
   CHRS     : CHAR;
 begin
  ClearRX;
  ShowMsr;
  Repeat
   GetCharS(CHRS);
  Until (CHRS=#13) or GoOffLine  or ReqChat ;
  if ReqChat then Chat;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.GetEnterKeyNC;
 var
   CHRS     : CHAR;
 begin
  ClearRX;
  ShowMsr;
  Repeat
   GetCharS(CHRS);
  Until (CHRS=#13) or GoOffLine  or ReqChat ;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.GetYN(var YHIT: boolean) ;
 var
   DumInput    : Char;
   CR          : Char;

 begin
  Emu_Color(15,0);
  ComWrite(' [');
  Emu_Color(12,0);
  ComWrite('Y');
  Emu_Color(15,0);
  ComWrite(',');
  Emu_Color(14,0);
  ComWrite('n');
  Emu_Color(15,0);
  ComWrite('] ');
  YHIT :=false;
  DumInput:=#0;
  While not(DumInput  in ['Y','N']) and not GoOffline and Not ReqChat do
  begin
    GetChar(DumInput,['Y','N',#13]);
    if DumInput in['Y',#13] then
     begin
      if DumInput = #13 then ComWriteln('Yes')
      else
       ComWriteln('es');
      DumInput:='Y'
     end
    else if DumInput='N' then ComWriteln('o');
  end;
  YHIT:=(DumInput in['Y',#13]);
  if ReqChat then Chat;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.GetYNQ(var YHIT,Aborted: boolean; Prompton : boolean);
 var
   DumInput    : Char;
   CR          : Char;
   Ch          : byte;
   SavTime     : String;
   XSV,YSV,
   MinCount    : integer;

 begin
  Aborted :=false;
  SavTime :=Time;
  MinCount :=0;
  if Prompton then
  begin
   emu_Color(15,0);
   Comwrite(' [');
   emu_Color(12,0);
   Comwrite('Y');
   emu_Color(15,0);
   Comwrite(',');
   emu_Color(14,0);
   Comwrite('n');
   emu_Color(15,0);
   Comwrite(',');
   emu_Color(11,0);
   Comwrite('q');
   emu_Color(15,0);
   Comwrite('] ')
 end;
  ShowMsr;
  YHIT :=false;
  DumInput:=#0;
  showmsr;
  ClearReceive;
  While not(DumInput  in ['Y','N','Q']) and not GoOffline
        and Online do
  begin
    GetChar(DumInput,['Y','N',#13,'Q']);
    if DumInput in['Y',#13] then
     begin
      if DumInput = #13 then ComWriteln('Yes')
      else
       ComWriteln('es');
      DumInput:='Y'
     end
    else
     if DumInput='N' then ComWriteln('o')
    else
      if DumInput='Q' then
        begin
         Comwriteln('uit');
         Aborted :=true;
        end;
  end;
  YHIT:=(DumInput in['Y',#13]);
  if ReqChat then Chat;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.GetNY(var YHIT: boolean) ;
 var
   DumInput    : Char;
   CR          : Char;
 begin
  Emu_Color(15,0);
  ComWrite(' [');
  Emu_Color(14,0);
  ComWrite('y');
  Emu_Color(15,0);
  ComWrite(',');
  Emu_Color(12,0);
  ComWrite('N');
  Emu_Color(15,0);
  ComWrite('] ');
  YHIT :=false;
  DumInput:=#0;
  While not(DumInput  in ['Y','N']) and not GoOffline and Not ReqChat do
  begin
    GetChar(DumInput,['Y','N',#13]);
    if DumInput in['N',#13] then
     begin
      if DumInput = #13 then ComWriteln('No')
      else
      ComWriteln('o');
      DumInput:='N'
     end
    else if DumInput='Y' then ComWriteln('es');
  end;
  YHIT:=(DumInput in['Y',#13]);
  if ReqChat then Chat;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.Getstring(var FSTRING : STRING; Pstring : string;
                           Confirm : boolean );
 var
  ENTEREDWRONG    : boolean;
  ATTEMPTS        : integer;
  YHIT            : boolean;
  DumInput        : Char;
  Ch              : byte;
 begin
  SHOWMSR;
  ATTEMPTS:=0;
  ENTEREDWRONG:=true;
  SHOWMSR;
  while ENTEREDWRONG and (ATTEMPTS <=5) and not GoOffline and Online do
  begin
   ATTEMPTS:=ATTEMPTS+1;
   ComWrite(PSTRING);
   FSTRING:='';
   ReadLnX(FSTRING,20);
     IF KEYPRESSED Then
       begin
        DumInput:=readkey;
        if DumInput=#0 then
            begin
             CheckKey;
             ShowMsr
            end
        end;
    if Not Confirm then EnteredWrong :=false;
    IF confirm and (FSTRING='') THEN ENTEREDWRONG :=true
    else
     if Online and not GoOffLine and confirm then
     begin
      ENTEREDWRONG :=false;
      ComWriteln('');
      ComWrite(' You Entered.. [');
      ComWrite(FSTRING);
      ComWrite(']     Is This Correct ? ');
      GetYN(YHIT);
      ENTEREDWRONG:=NOT YHIT;
     end
   end;
   if ATTEMPTS>5 then
    begin
     ComWriteln(' Too Many Attempts...  ');
     GoOffLine := true;
    end;
  SHOWMSR;
  CheckTimeLeft;
  if ReqChat then Chat;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.ReadlnX(var ST : string; L : integer);
  var
   TStr   : string;
   DoneR  : boolean;
   Ch     : Char;
   Lt     : integer;
  begin
   ShowMsr;
   Doner :=false;
   Tstr:='';
   St:='';
   while not DoneR and Online and Not GoOffLine do
    begin
    GetcharS(Ch);
     if Not GoOffLine  and Online and (Ch<>#0) then
      begin
       Lt := Length(TStr);
       Case Ch of
       #13: begin
             DoneR :=true;
             ComWriteln('');
            end;
        #8: begin
             if Lt>0 then
              begin
               TStr:=Copy(TStr,1,Lt-1);
               ComWrite(#8+' '+#8)
              end
           end;
 #32..#122: begin
             if Lt<L then
              begin
               TStr:=TStr+Ch;
               ComWrite(Ch)
              end
            end
       end {case}
      end
    end;
   St:=TStr;
  if ReqChat then Chat
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.GetNum(var Num: Integer; MaxVal: integer);
 var
   C: Char;
   St:String;
   Xp,Yp : integer;
   Code  : integer;
 begin
  Xp:=WhereX;
  Yp:=WhereY;
  Num:=0;
  St:='';
  C:=#0;
  While (C<>#13) and online and not GoOffLine And Not ReqChat  do
  begin
   GetChar(C,['0'..'9',#13,#8,#127]);
   case C of
   '0'..'9' : begin
               if ((Num*10)<=(Maxval+11)) and (length(St)< 10) then St:=St+C;
               Emu_GotoXy(Xp,Yp);
               ComWrite(St+' '+#8)
              end;
   #8,#127  : begin
               if Length(St)>0 then St:=Copy(St,1,Length(St)-1);
               Emu_GotoXy(Xp,Yp);
               ComWrite(St+' '+#8)
              end
    end; {case}
  val(St,Num,Code);
  end;
  if Num>MaxVal then Num:=MaxVal
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.GetLNum(var Num: LongInt; MaxVal: LongInt);
 var
   C: Char;
   St:String;
   Xp,Yp : integer;
   Code  : integer;
 begin
  Xp:=WhereX;
  Yp:=WhereY;
  Num:=0;
  St:='';
  C:=#0;
  While (C<>#13) and online and not GoOffLine And Not ReqChat  do
  begin
   GetChar(C,['Q','0'..'9',#13,#8,#127]);
   case C of
   'Q'      : begin
               C:=#13;
               ST:='-1';
              end;
   '0'..'9' : begin
               if ((Num*10)<=(Maxval+11)) and (length(St)< 10) then St:=St+C;
               Emu_GotoXy(Xp,Yp);
               ComWrite(St+' '+#8)
              end;
   #8,#127  : begin
               if Length(St)>0 then St:=Copy(St,1,Length(St)-1);
               Emu_GotoXy(Xp,Yp);
               ComWrite(St+' '+#8)
              end
    end; {case}
  val(St,Num,Code);
  end;
  if Num>MaxVal then Num:=MaxVal
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.GetRNum(var Num: Real; MaxVal:Real);
 var
   C: Char;
   St:String;
   Xp,Yp : integer;
   Code  : integer;
 begin
  Xp:=WhereX;
  Yp:=WhereY;
  Num:=0;
  St:='';
  C:=#0;
  While (C<>#13) and online and not GoOffLine And Not ReqChat  do
  begin
   Repeat
   GetCharS(C);
   Until (C in ['q','Q','0'..'9',#13,#8,#127]) or Not Online Or GoOFfLine;
   case C of
   'Q','q'  : begin
               C:=#13;
               ST:='-1';
              end;
   '0'..'9' : begin
               if ((Num*10)<=(Maxval+11)) and (length(St)< 10) then St:=St+C;
               Emu_GotoXy(Xp,Yp);
               ComWrite(St+' '+#8)
              end;
   #8,#127  : begin
               if Length(St)>0 then St:=Copy(St,1,Length(St)-1);
               Emu_GotoXy(Xp,Yp);
               ComWrite(St+' '+#8)
              end
    end; {case}
  val(St,Num,Code);
  end;
  if Num>MaxVal then Num:=MaxVal
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.CheckTimeLeft;
 begin
 If Timeleft<1 then
   begin
     GoOffLine :=true;
     ComWriteln(#7#7);
     delay(2000)
   end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function TBBS.TimeLeft: integer;
 var TimeTmp : integer;
 begin
 with BRec do
 begin
  TimeTmp :=(Timelimit-TimeUsed)-(TimeNow- StartTime);
  If TimeTmp > TimeLimit then
   begin
    TimeTmp :=TimeLimit;
    StartTime :=TimeNow
   end;
 If TimeTmp <0 then TimeTmp :=0;
 TimeLeft:=TimeTmp
 end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.TimePrompt;
  var TmpStr : String;
      XX     : Integer;
 begin
  XX:= TimeLeft;
  if XX< 6 then EMU_COLOR(12,8) else EMU_COLOR(15,0);
  Str(XX,TmpStr);
  if XX=1 then
  COMWRITE(' '+TmpStr+ ' Minute Left..')
  else
  COMWRITE(' '+TmpStr+ ' Minutes Left..');
  EMU_COLOR(15,0)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.ShowTimeLeft;
 begin
  write(' Time: ',(TimeLeft):3,' ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.SHOWFKeys;
  VAR
   X,Y,I : INTEGER;
  BEGIN
   if Not Local then
   begin
     X:=WHEREX;
     Y:=WHEREY;
     Window(1,1,80,25);
     GOTOXY(1,25);
     textcolor(14);
     textbackground(7);
     if BREC.Registered then
     Write('  F1 Chat     F2 Boost Time     F3 Beep User     F9 Lower Time     F10 Zap    ')
     else
     Write('  F- Keys Disabled In UNREGISTERED VERSION       Please Register...           ');
     Window(1,1,80,24);
     textbackground(0);
     GOTOXY(X,Y)
   end
  END;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.SHOWMSR;
  VAR
   X,Y    : Integer;
   Tstr   : String;
   SLine  : String;
   TS     : Word;
  Begin
   With BRec do
   begin
   X:=WHEREX;
   Y:=WHEREY;
   TS :=TextAttr;
   Sline :=' '+UNAME+' ณ';
   Str( TimeLeft, Tstr);
   Sline:=Sline +'Time:'+Tstr+'ณ';
   Str( GetBps, Tstr);
   Sline:=Sline +'Baud '+Tstr+'ณ'+ Time+'ณ'+Date+'ณ';
   Str( MemAvail div 1024, Tstr);
   Sline:=Sline +Tstr+'kณ';
   if ReqChat then Sline:=Sline+'Chat Requestณ'
   else if Local then Sline:=Sline+ 'Localณ'
   else if Not Online then Sline:=Sline+ ' Carrier Lostณ'
   else Sline:=Sline+ 'Normalณ';
   if Not Local then Sline:=Sline+ '[H]elpณ';
   if Length(Sline) > 79 then Sline :=Copy(Sline,1,79);
   while Length(Sline)<79 do sline :=Sline+' ';
   Window(1,1,80,25);
   GOTOXY(1,25);
   textcolor(0);
   textbackground(7);
   Write(Sline);
   Window(1,1,80,24);
   TextAttr:=TS;
   GOTOXY(X,Y)
   end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.CheckKey;
 var Ch : integer;
     XS,YS : integer;
 begin
   CH:= ord(Readkey);
   With BRec do
    if Registered then
    begin
    case ch of
    68 :GoOffLine:=true;
    59 : ReqCHAT:=true;{F1}
    61 : ComWrite(#7);{F3}
    62 : begin
          ComWrite(#7);{F4}
          SwapVectors;
          Exec(GetEnv('ComSpec'),'');
          SwapVectors
         end;
    63 : begin
          JoinIt :=True;
          ComWrite(#7);
          Xs:=WhereX;
          Ys:=WhereY;
          gotoXy(1,24);
          Write(' Beep....                                                                      ');
          gotoXy(Xs,YS)
         end;
    67 : begin{F9}
          TimeLimit:=(TimeLimit-(TimeLimit div 5));
          write(#7);
          ShowMsr
         end;
    60 : begin{F2}
          TimeLimit:=TimeLimit+10;
          write(#7);
          ShowMsr
         end
     else ShowFKeys;
    end; {case}
   ShowMsr;
   end
   else ShowFKeys;
   while keypressed do ch:=ord(readkey)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function TBBS.TimeNow: integer;
  var
    I,code      : integer;
    MinNow      : integer;
    Start       : string[6];

begin
   With BRec do
   begin
    Start:= time;
    val(copy(Start,1,2),I, Code);
    If (I=12) and (Start[6]='a') then I:=0;
    I:=I*60;
    if (Start[6]='p') and (copy(Start,1,2)<>'12') then I:=I+ 720;
    MinNow:=I;
    val(copy(Start,4,2),I, Code);
    MinNow:=MinNow+I;
    If MinNow <0 then MinNow :=0;
    IF MinNow=0 then StartTime:=MinNow;
    TimeNow := MinNow
   end
  end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 Procedure TBBS.PageSySop;
 var
  I,J, Attempts        : integer;
  TmpStr,TStr,TTStr    : string;
  Ch                   : byte;
  Chh                  : char;
  XSS,YSS              : integer;
  TTime                : Integer;

 begin
    Emu_Color(15,0);
    emu_clearscreen;
    ComWriteln('');

    TTime:=StartPage div 60;
    if TTime > 12 then
    begin
     TmpStr:='pm';
     TTime:=TTime-12;
    end
    else Tmpstr:='am';

    Str(TTime,TStr);
    TStr:=TStr+':00'+TmpStr;
    TTime:=(StartPage div 60) + Duration;

    if TTime > 12 then
    begin
     TmpStr:='pm';
     TTime:=TTime-12;
     if TTime > 12 then
      begin
       TmpStr:='am';
       TTime:=TTime-12;
      end
    end
    else Tmpstr:='am';
    Str(TTime,TTStr);
    TTStr:=TTStr+':00'+TmpStr;

    ComWriteln(' You May Page the SysOp between the Hours of '+TStr+' and '+TTStr+'.' );
    If (TimeNow<StartPage) OR (TimeNow>(StartPage+(Duration*60))) then
    begin
      Emu_Color(15,0);
      ComWriteln('');
      ComWriteln(' The Time Now is '+Time+'m .');
      if TimeNow<StartPage then Writeln(' Too Early',Timenow,StartPage);
      ComWriteln(' And the Chances that you will get an answer are Not Good.');
      ComWriteln(' Try again Later....');
      ComWrite(' Press <ENTER>.. ');
      GetEnterKey;
    end
    else
    begin
    ComWriteln('');
    ComWriteln(' The Time Now is '+Time+'m .');
    ComWriteln('');
    Attempts :=1;
    ComWrite(' Press <ENTER>.. to Start Paging... or <ESC> to Abort ');
    GetChar(Chh,[#27,#13]);
    ComWriteln('');
    ComWriteln('');
    if Chh<> #27 then
    begin
    ComWrite(' Press <ESC> To Stop Paging... ');
     XSS:=wherex;
     YSS:=Wherey;
    repeat
     GotoXy(Xss,YSS);
     ComWriteln('');
     ComWrite(' Paging The SysOp Now !   ');
     if Brec.Registered then
     begin
      Writeln;
      Writeln(' User Requesting a Challenge!! ');
      Write  (' SysOp ... press F1 to Chat! ');
      ShowMsr;
     end;
     str(Attempts,TmpStr);
     ComWrite('Attempt #'+ TmpStr);
      Attempts := Attempts +1;
      I:=9;
      while (I<20) and (Not keypressed) and (not Chwaiting ) do
      begin
      I:=I+1;
      For J:= 100 to 200 do
      begin
       sound(I*J);
       delay((J-100) mod 10)
      end
      end;
      nosound;
      if chwaiting then
       begin
         chh:=CReadkey;
         IF CHH=#0 THEN CHH:=CReadkey;
         attempts:=11;
       end;
    if not keypressed and (attempts<10) then delay(2000);
    until keypressed or Not Online or GoOffLine or (Attempts > 10) ;
     IF KEYPRESSED and (Ord(READKEY) = 0) Then
            begin
             CheckKey;
             ShowMsr
            end;
     if ReqChat then Chat
     else
     if Not ReqChat then
      begin
       ComWriteln('');
       ComWriteln(' No Response .....');
       ComWriteln('');
       ComWriteln(' Try again Later....');
       ComWriteln('');
       ComWrite(' Press <ENTER>.. ');
       GetEnterKey;
      end
     end
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TBBS.CHAT;
  var
  InChar, Ychar : Char;
  XS,YS,XU,YU   : integer;
  I             : integer;
  Lstr          : String;
  WW,WW2        : String;
  Tlsav         : word;
 begin
 if Not Local then
  begin
  TTYpe := 1;
  tlsav :=TimeLeft;
  textbackground(0);
  emu_clearscreen;
  ComWriteln('');
  emu_color(14,3);
  ComWriteln(' The SySop Wants To Chat  !!!! ');
  emu_color(11,0);
  ComWriteln(' Hang on a second..');
  emu_color(15,7);
  emu_gotoxy(1,13);
  ComWriteln('      '+chr(25)+chr(25)+'  Your Input  '+chr(25)+chr(25)+'                   '+
             chr(24)+chr(24)+'    SySop    '+chr(24)+chr(24)+'                  ');
  XS:=1;
  YS:=4;
  XU:=1;
  YU:=14;
  emu_color(14,0);
  WW  :='';
  WW2 :='';
   repeat
    while keypressed do
     begin
      emu_color(14,0);
      EMU_GOTOXY(XS,YS);
      Inchar :=READKEY;
      case Inchar of
      #13:begin
           ComWriteln('');
           WW:=''
          end;
      ' ': begin
            WW:='';
            ComWrite(' ')
           end;
#33..#127: begin
            if (length(WW) > 0 ) and (Xs>=78) then
             begin
              for I:= 1 to length(WW) do
               ComWrite(#8+' '+#8);
               ComWriteln('');
               Xs :=wherex;
               Ys :=whereY;
               if TType in[1,3] then
                begin
                 if Ys>11 then
                  begin
                   getScreenStr(1,79,(YS-1),Lstr);
                   if TTYpe =1 then Emu_ClearToTop
                    else
                      begin
                        for I:=2 to 11 do
                         begin
                          Emu_Gotoxy(0,I);
                          Emu_ClearToEndOfLine
                         end;
                       Gotoxy(1,2);
     for I:=2 to 11 do Write('                                                                                ');
                      end;
                   XS:=1;
                   YS:=1;
                   Emu_gotoXY(XS,YS);
                   Comwriteln(Lstr);
                   YS:=2;
                  end
                end
               else
                if Ys>22 then ComWriteln('');
               EMU_GOTOXY(XS,YS);
               ComWrite(WW);
               WW:=''
             end;
            ComWrite(Inchar);
            WW:=WW+InChar;
            if length(WW)> 15 then WW:='';
           end;
      #8: begin
            ComWrite(#8+' '+#8);
           if length(WW) >0 then delete(WW,Length(WW),1)
          end
     end;

      XS:=WhereX;
      Ys:=whereY;
      if TType in [1,3] then
      begin
      if Ys>11 then
       begin
        getScreenStr(1,79,(YS-1),Lstr);
        Emu_ClearToTop;
        if TType = 3 then
         begin
          for I:=2 to 11 do
          begin
           Emu_Gotoxy(1,I);
           Emu_ClearToEndOfLine
          end;
         Gotoxy(1,2);
         for I:=2 to 11 do Write('                                                                                ');
         end;
        XS:=1;
        YS:=1;
        Emu_gotoXY(XS,YS);
        Comwriteln(Lstr);
        YS:=2;
       end
      end
     end;

    While ChWaiting and Online do
     begin
      emu_color(11,0);
      EMU_GOTOXY(XU,YU);
      Ychar:=CReadkey;
      case YChar of
      #13:begin
           ComWriteln('');
           WW2:=''
          end;
      ' ': begin
            WW2:='';
            ComWrite(' ')
           end;
#33..#127: begin
            if (length(WW2) > 0 ) and (XU >=77) then
             begin
              for I:= 1 to length(WW2) do
               ComWrite(#8+' '+#8);
               ComWriteln('');
               XU:=1;
               YU:=whereY;
               if Yu>22 then
                begin
                  if TType in[1,3] then
                    begin
                      getScreenStr(1,79,(YU-1),Lstr);
                      Gotoxy(1,14);
                      for I:=1 to 10 do
                      begin
                       Write('                                        ');
                       write('                                        ');
                      end;
                      Emu_Gotoxy(1,14);
                      Emu_ClearToEndOfScreen;
                      Emu_Deleteline;
                      Emu_Gotoxy(1,14);
                      ComWriteln(Lstr);
                      XU:=1;
                      Yu:=15
                    end
                end;
               Emu_Gotoxy(1,YU);
               ComWrite(WW2);
               XU:=WhereX;
               YU:=whereY;
               WW2:=''
             end;
            Emu_Gotoxy(XU,YU);
            COMWRITE(YChar);
            WW2:=WW2+YChar;
            if length(WW2)> 15 then WW2:='';
           end;
      #8: begin
           Comwrite(#8+' '+#8);
           if length(WW2) >0 then delete(WW2,Length(WW2),1);
          end
     end;
      XU:=WhereX;
      YU:=whereY;
      if Yu>22 then
       begin
        if TType in[1,3] then
        begin
        getScreenStr(1,79,(Yu-1),Lstr);
         Gotoxy(1,14);
         for I:=1 to 10 do Write('                                                                                ');
         Emu_Gotoxy(1,14);
         Emu_ClearToEndOfScreen;
         Emu_Deleteline;
         Emu_Gotoxy(1,14);
         Comwriteln(Lstr);
         XU:=1;
         Yu:=15;
        end
       end
     end;
   until (Inchar=#27) or Not Online;
  ReqChat:=false;
  XU:=0;
  while (XU<60) and (TimeLeft<Tlsav) do
  With BRec do
   begin
    StartTime:=StartTime+1;
    XU:=Xu+1;
   end;
  emu_clearscreen;
 end
  else
   begin
    ClrScr;
    Write(' Want to Chat with yourself aye??? ');
    delay(2000);
    ReqChat:=false
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

Function Backspace(Num : Byte) : String;
 Var
   X : Byte;
   S : String;

 begin
   S := '';
   for X := 1 to Num do
      S := S + #8#32#8;
   Backspace := S
 end;

{--------------------------------------------------------------------}

Function Center(Strn : String) : String;
 Var
   C, X : Byte;

 begin
   C := (((Lo(WindMax) - Lo(WindMin)) + 1) - Length(Strn)) Div 2;
   for X := 1 to C do
    begin
      Strn := ' ' + Strn
    end;
   Center := Strn
 end;

{--------------------------------------------------------------------}

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

 begin
   CopyFile := True;
   if (Dest[Length(Dest)] <> '\') then
    begin
      FindFirst(Dest, AnyFile, FInfo);
      if (DOSError = 0) then
       begin
         if (FInfo.Attr AND Directory > 0) then
          begin
            FSplit(Source, Dir, Name, Ext);
            Dest := Dest + '\' + Name + Ext
          end;
       end
      else
       begin
         CopyFile := False;
         Exit
       end;
    end
   else
    begin
      FSplit(Source, Dir, Name, Ext);
      Dest := Dest + Name + Ext
    end;
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
   {$I+}
   if (IOResult <> 0) then CopyFile := False
 end;

{--------------------------------------------------------------------}

Function Date : String;
 Var
   Dt         : String;
   Y, M, D, W : Word;

 begin
   GetDate(Y, M, D, W);
   Dt := IntToStr(M);
   if (M < 10) then Dt := '0' + Dt;
   Dt := Dt + '/';
   if (D < 10) then Dt := Dt + '0';
   Dt := Dt + IntToStr(D);
   Dt := Dt + '/';
   if (Y < 10) then Dt := Dt + '0';
   Dt := Dt + Copy(IntToStr(Y), 3, 2);
   Date := Dt
 end;

{--------------------------------------------------------------------}

Function Exist(Filename : String) : Boolean;
 var
   Inf : SearchRec;

 begin
   FindFirst(Filename, AnyFile, Inf);
   Exist := (DOSError = 0)
 end;

{--------------------------------------------------------------------}

Procedure GetScreenStr(X1, X2, Y : Byte; var St : String);
 Var
   I : Integer;
   A : Byte;
   C : Char;

 begin
   St := '';
   for I := X1 to X2 do
    begin
      GetScreenWord(I, Y, A, C);
      St := St + C
    end
 end;

{--------------------------------------------------------------------}
{--------------------------------------------------------------------}

Function IntToStr(Num : LongInt) : String;
 Var
   S : String;

 begin
   Str(Num, S);
   IntToStr := S
 end;

{--------------------------------------------------------------------}

Function Left(Strn : String; Places : Byte) : String;
 Var
   X : Byte;

 begin
   for X := Length(Strn) + 1 to Places do
      Strn := Strn + ' ';
   Left := Copy(Strn, 1, Places)
 end;

{--------------------------------------------------------------------}

Function Lower(Strn : String) : String;
 Var
   Index : Byte;

 begin
   for Index := 1 to Length(Strn) do
      case Strn[Index] of
         'A'..'Z' : Inc(Strn[Index], 32)
      end;
   Lower := Strn
 end;

{--------------------------------------------------------------------}
{--------------------------------------------------------------------}

Function Replicate(Ch : String; Num : Byte) : String;
 Var
   Strn : String;
   X    : Byte;

 begin
   Strn := '';
   for X := 1 to Num do
    begin
      Strn := Strn + Ch
    end;
   Replicate := Strn
 end;

{--------------------------------------------------------------------}

Function Right(Strn : String; Places : Byte) : String;
 Var
   X : Byte;

 begin
   for X := Length(Strn) + 1 to Places do
      Strn := ' ' + Strn;
   Right := Copy(Strn, 1, Places)
 end;

{--------------------------------------------------------------------}

Function Space(Num : Byte) : String;
 Var
   Strn : String;
   X    : Byte;

 begin
   Strn := '';
   for X := 1 to Num do
    begin
      Strn := Strn + ' '
    end;
   Space := Strn
 end;

{--------------------------------------------------------------------}

Function StrToInt(Strn : String) : LongInt;
 Var
   R : LongInt;
   E : Integer;

 begin
   Val(Strn, R, E);
   StrToInt := R
 end;

{--------------------------------------------------------------------}
{--------------------------------------------------------------------}

Function Time : String;
 Var
   T           : String;
   AP          : Char;
   H, M, S, HS : Word;

 begin
   GetTime(H, M, S, HS);
   AP := 'a';
   if (H >= 12) then
    begin
      H := H - 12;
      AP := 'p'
    end;
   if (H = 0) then H := 12;
   T := IntToStr(H);
   if (H < 10) then T := ' ' + T;
   T := T + ':';
   if (M < 10) then T := T + '0';
   T := T + IntToStr(M);
   Time := T + AP
 end;

{--------------------------------------------------------------------}

Function Upper(Strn : String) : String;
 Var
   Index  : Byte;

 begin
   for Index := 1 to Length(Strn) do
      Strn[Index] := UpCase(Strn[Index]);
   Upper := Strn
 end;

{--------------------------------------------------------------------}

Function XPos(Strn, SubStrn : String; Offset : Byte) : Byte;
 begin
   Strn := Copy(Strn, Offset, 255);
   XPos := Pos(SubStrn, Strn) + Offset - 1;
   if (Pos(SubStrn, Strn) = 0) then XPos := 0
 end;

{--- TBBS methods ---------------------------------------------------}

Procedure TBBS.Init (ComNum : Byte; BD :LongInt;BBRec : BBSData; Lcl: Boolean);
 begin
  Local     := Lcl;
  if Local then ComNum :=0;
  Inherited Init(ComNum);
  BRec      := BBREC;
  Color     := True;
  GoOffLine := false;
  HotKeys   := True;
  ReqChat   := false;
  SetDBps(BD);
  Baud  :=BD;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{--------------------------------------------------------------------}

Procedure TBBS.Run;
 begin
 end;

{--------------------------------------------------------------------}

Procedure TBBS.Done;
 begin
   ClosePort;
 end;

{--------------------------------------------------------------------}

Procedure TBBS.ChangeColor(Attr : Byte);
 Begin
   Emu_Color((Attr SHL 4) SHR 4, Attr SHR 4);
   TextAttr := Attr
 end;

{--------------------------------------------------------------------}
Function TBBS.Incoming : Boolean;
begin
 Incoming := Keypressed or Chwaiting
end;
{--------------------------------------------------------------------}
Procedure TBBS.ClearReceive;
 Begin
  if Not Local then ClearRx;
 end;

{--------------------------------------------------------------------}

Procedure TBBS.ClearTransmit;
 Begin
   if Not Local then ClearTX;
 end;

{--------------------------------------------------------------------}
{--------------------------------------------------------------------}
Function TBBS.GetBps : Longint;
 Begin
   GetBps := Bps
 end;
{--------------------------------------------------------------------}
{--------------------------------------------------------------------}
Procedure TBBS.SetDBps(BpsIN : Word);
 Begin
   Bps := BpsIN;
 end;

{--------------------------------------------------------------------}
{--------------------------------------------------------------------}
{--------------------------------------------------------------------}
{--------------------------------------------------------------------}
Function TBBS.WaitFor(Strn : String; Timeout : Word) : Boolean;
 Var
   Rcv             : String;
   Ch              : Char;
   SS, ES, X, Y, Z : Word;
   Ticker          : Integer;
   Found           : Boolean;

 begin
   WaitFor := False;
   Rcv := '';
   Found := False;
   Ticker := 0;
   for X := 1 to Length(Strn) do
    begin
      Strn[X] := UpCase(Strn[X]);
    end;
   GetTime(X, Y, SS, Z);
   while ((Ticker <> Timeout) and (Timeout > 0)) and (not Found) do
    begin
      if (ChWaiting) then
       begin
         Ch := UpCase(CReadkey);
         if (Length(Rcv) = Length(Strn)) then
          begin
            Rcv := Copy(Rcv, 2, Length(Rcv) - 1);
          end;
         Rcv := Rcv + Ch;
         if (Pos(Strn, Rcv) > 0) then
          begin
            Found := True;
          end;
       end;
      ES := SS;
      GetTime(X, Y, SS, Z);
      if (ES <> SS) then Ticker:=ticker+1
    end;
   WaitFor := Found
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function TBBS.DetectAnsi : Boolean;
 begin
  ComWriteO('[6n');
  DetectAnsi:=Waitfor('[',5);
  ClearReceive;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure TBBS.MenuWrite(bb,cb,cf: byte; CDSTR : String; var ChSt : Char);
 begin
   if Online And Not GoOffLine and (ChSt=#0) then
   begin
    Emu_color(15,bb);
    ComWrite('    ');
    Emu_color(15,cb);
    ComWrite('   '+CDSTR[1]);
    Emu_color(cf,cb);
    ComWrite(Copy(CDSTR,2,length(CDSTR)-1));
    Emu_color(0,bb);
    ComWriteln('Ü    ');
    ComWriteln('     ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿    ');
    if KeyPressed then
     begin
      if KeyPressed then ChSt := UpCase(Readkey);
      if Keypressed then CheckKey;
     end;
      if ChWaiting and Not Local then
      begin
       ChSt :=UpCase(CReadkey);
      end;
     if Not (ChSt in IntCharSet) then Chst :=#0;
   end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure TBBS.TMenuWrite(bb,cb,cf: byte; CDSTR : String);
 begin
    Emu_color(15,bb);
    ComWriteln('                               ');
    ComWrite('  ');
    Emu_color(cf,cb);
    ComWrite(CDSTR);
    Emu_color(0,bb);
    ComWriteln('Ü  ');
    ComWriteln('   ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿  ');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

Procedure TBBS.SetIntChar(Ch : CharSet);
 begin
   IntCharSet := Ch;
 end;

{--------------------------------------------------------------------}

Procedure TBBS.TypeFile(Fname : String;var ChRet : Char);
 Var
   F     : Text;
   Abort : Boolean;
   Line  : String;
   X     : Byte;
   Ch    : Char;

 begin
   ChRet:=#0;
   if (Exist(Fname)) then
    begin
      Abort := False;
      Assign(F, Fname);
      Reset(F);
      while (not EOF(F)) and (not Abort) do
       begin
         ReadLn(F, Line);
         X := 1;
         while (X <= Length(Line)) and not (Abort) do
          begin
            ComWrite(Line[X]);
            X:=X+1
          end;
         if (not EOF(F)) then ComWriteLn('')
       end;
      Close(F)
    end
 end;

{********************************************************************}
{--------------------------------------------------------------------}

Procedure TBBS.TypeFileMore(Fname : String;var ChRet : Char);
 Var
   F     : Text;
   Abort : Boolean;
   YHit  : Boolean;
   Line  : String;
   X     : Byte;
   Ch    : Char;
   LCount : INteger;

 begin
   ChRet:=#0;
   if (Exist(Fname)) then
    begin
      LCount :=0;
      Abort := False;
      Assign(F, Fname);
      Reset(F);
      while (not EOF(F)) and (not Abort) do
       begin
         ReadLn(F, Line);
         X := 1;
         while (X <= Length(Line)) and not (Abort) do
          begin
            ComWrite(Line[X]);
            X:=X+1
          end;
         if (not EOF(F)) then
          begin
           ComWriteLn('');
           LCount:=Lcount +1;
           If Lcount > 19 then
             begin
              LCount :=0;
              Emu_Color(15,0);
              ComWriteln('');
              ComWrite(' More ');
              GetYN(Yhit);
              Abort :=Not YHit
             end
          end
       end;
      Close(F)
    end
 end;

{********************************************************************}

Procedure TBBS.TypeHOLE(Fname : String; HoleNm : byte);
 Var
   F     : Text;
   Abort : Boolean;
   Line  : String;
   X     : Byte;
   CHeckNum : Byte;
   Next     : boolean;

 begin
   if (Exist(Fname)) then
    begin
      Abort := False;
      Assign(F, Fname);
      Reset(F);
      while (not EOF(F)) and (not Abort) do
       begin
        ReadLn(F, CheckNum);
        if CheckNum = HoleNm then
         begin
          while (not EOF(F)) and (not Abort) do
          begin
           ReadLn(F, Line);
           X := 1;
           abort := (pos('ซฌ',Line) > 0);
           while (X <= Length(Line)) and Not Abort do
              begin
                ComWrite(Line[X]);
                X:=X+1
              end;
           if (not EOF(F)) and Not Abort then ComWriteLn('')
          end
         end
        else
        begin  { look for next Hole }
         Next := False;
         while (not EOF(F)) and (not Next) do
          begin
           ReadLn(F, Line);
           Next:= (pos('ซฌ',Line) > 0)
          end
        end
       end;
     Close(F)
    end
 end;

{********************************************************************}

Begin
end.

