 Unit Utility;
 InterFace
 Uses Dos,Crt,BBSUnit,BBSScrn;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 Procedure Checkdate;
 Procedure Inc_Call_Count( var CallCount : LongInt);
 Procedure FormatName(var FNAME :STRING);
 Function  CopyFile(Source, Dest : String) : Boolean;
 Procedure UpDateToday(var XXX: TBBS);
 Procedure AddUser(var XXX: TBBS);
 Procedure UpgradeUser( XXX : TBBS);
 Procedure WriteUsrfil(XXX : TBBS);
 Procedure GetData(var BRec : BBSData; var ComNum : Byte;
                   var Baud1 :LongInt; var MXC,MYC : Byte);
 Procedure TMenuWrite(XXX : TBBS; bb,cb,cf: byte; CDSTR : String);
 Procedure MenuWrite(XXX :TBBS; bb,cb,cf: byte; CDSTR : String; var ChSt : Char);
 Procedure Getstring(var XXX:TBBS; var FString:String; Pstring:String; Confirm:Boolean );
 procedure ReadlnX(var XXX:TBBS;var ST:String; L:Integer; Pas:Boolean);
 Procedure ExecDSZ(var XXX: TBBS; ExecStr : String);

Implementation
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 {$I-}
 procedure UpDateToday(var XXX: TBBS);

 var
  ConfigFile   : Text;
  RenFile      : Text;
  DATESTR      : string[8];
  TNAME        : String[25];

 begin
 With XXX do
 With BBSRec do
 if UName <>'' then
 begin
  Tname :=UNAME;
  if pos(SySopName,Tname) =0 then
 begin
  WHILE length(Tname) < 25 do Tname:=Tname+' ';
  WHILE length(City) < 25 do City:=City+' ';
  ChDir(BBSDir);
  if not Exist('Todays.usr') then
   begin
    Assign(ConfigFile,'Todays.usr');
    Rewrite(Configfile);
    writeln(Configfile,DATE);
    Writeln(Configfile,TNAME, '  ',CITY,'  ', TIME,'     ',GetBps);
    close(Configfile)
   end
   else
    begin
     Assign(ConfigFile,'Todays.usr');
     Reset(ConfigFile);
     if IoResult = 0 then
     begin
     Readln(Configfile,DATESTR);
     if DATESTR<> DATE then
      begin
       if Exist('Todays.bak') then
        begin
         Assign(RenFile,'Todays.bak');
         Erase(RenFile);
        end;
       Rename(Configfile,'Todays.bak');
       Close(Configfile);
       Assign(ConfigFile,'Todays.usr');
       Rewrite(Configfile);
       writeln(Configfile,DATE);
       Writeln(Configfile,TNAME, '  ',CITY,'  ', TIME,'     ',GetBps);
       close(Configfile);
      end
     else
     begin
      Append(Configfile);
      Writeln(Configfile,TNAME, '  ',CITY,'  ', TIME,'     ',GetBps);
      close(Configfile)
     end
    end
    end
   end
  end;
  If IOResult<>0 then Writeln('I/O Error...');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure AddUser(var XXX: TBBS);
 var
  InpFile : text;
  UserName,UserCity : NameSTRING;
  UserPass          : PassSTRING;
  UserPHONE         : PHSTRING;
  C,H               : BYTE;

 begin
  With XXX do
  With BBSRec do
   begin
    UserName:= UName;
    UserCity:= City;
    UserPass:= PassWord;
    UserPHONE:= PHNO;
    If COLOR then C:=1 else C:=0;
    If HOTKEYS then H:=1 else H:=0;
    While (length(UserName)<25) DO UserName:=UserName+' ';
    While length(UserPass) <8 DO UserPass:=UserPass+' ';
    While length(UserCity) <25 DO UserCity:=UserCity+' ';
    While length(UserPHONE) <14 DO UserPHONE:=UserPHONE+' ';
    if Exist(BBSDir+'\User.lst') then
     begin
      ChDir(BBSDir);
      Assign(Inpfile,'User.lst');
      Append(Inpfile);
      Writeln(Inpfile,UserName,UserPass,UserCity,UserPHONE,' ',LEVEL,' ',
          TTYPE,' ',C,' ',H,' ',TimeSON,' ',TimeUsed,' ',Time,DATE,'   ');
      close(Inpfile);
     end
   end;
   If IOResult <>0 then Writeln('I/O Error..');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure UpgradeUser( XXX : TBBS);
 var
  InpFile, outFile  : text;
  UserName,UserNam,
  UserCity,
  UserCit           : NameString;
  UserPass,UserPas  : PassString;
  UserPhone,UserPhon: PHString;
  C,H               : Byte;
  T,U,V,W           : Byte;
  X                 : Word;
  TLEFT             : Byte;
  DUMCHAR           : CHAR;
  Y                 : String[6];
  Z                 : String[8];
  Found             : boolean;

 begin
 With XXX do
 With BBSRec do
 if (Level > 0) and (UName<>'') then
 begin
  UserName:=UName;
  UserCITY:= CITY;
  UserPass:=PassWord;
  UserPHONE := PHNO;
  IF Color then C:=1 else C:=0;
  if HOTKEYS then H:=1 else H:=0;
  TimeUsed :=TimeUsed+(TimeNow- StartTime);
  if TimeUsed>= (TimeLimit-3) then TimeUsed:=TimeLimit-3;
  if TimeUsed<0 then TimeUsed:=0;
  StartTime:= TimeNow;
  While (length(UserName)<25) DO UserName:=UserName+' ';
  While length(UserPass) <8 DO UserPass:=UserPass+' ';
  While length(UserCITY) <25 DO UserCITY:=UserCITY+' ';
  While length(UserPHONE) <14 DO UserPHONE:=UserPHONE+' ';
  If Not Exist(BBSDir+'\User.lst') then
   begin
    ComWriteln('');
    ComWriteln(' User File not found. or corrupted..');
   end
  else
  begin
   ChDir(BBSDir);
   Assign(Inpfile,'User.lst');
   Reset(Inpfile);
   Assign(outfile,'User.tmp');
   Rewrite(Outfile);
   Found := False;
   If IORESULT =0 then
   begin
   while Not Eof(InpFile) do
    begin
     Readln(Inpfile,UserNAM,UserPAS,UserCIT,UserPHON,T,U,V,W,X,TLEFT,DUMCHAR,Y,Z);
     If (UserNAM=UserName) and (UserName<>'') THEN
       begin
        Writeln(OUTfile,UserName,UserPass,UserCITY,UserPHONE,' ',LEVEL,' ',
              TTYPE,' ',C,' ',H,' ',TimeSON,' ',TimeUsed,' ',Time,DATE,'   ');
       end
     else
     Writeln(OutFile,UserNam,UserPAS,UserCIT,UserPHON,' ',T,' ',U,' ',
               V,' ',W,' ',X,' ',TLEFT,' ',Y,Z,'   ')
     end;
   Close(Outfile);
   Close(Inpfile);
   Erase(InpFile);
   ReName(OutFile,'User.lst');
  end
  end
  end;
  If IOResult <>0 then Writeln('I/O Error..');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetData(var BRec : BBSData; var ComNum : Byte;
                   var Baud1 :LongInt; var MXC,MYC : Byte);

 var
  BooVar          : Integer;
  ConfigFile      : Text;
  Pup             : PopUp;
 begin
 with BRec do
 Begin
  TextBackGround(0);
  ClrScr;
  Pup.Init(15,5,60,9,15,4,15,'Total Control BBS... Version '+VRS);
  Delay(500);
  ConnectString:='Local';
  ModemInitString :='AT&C1&D2M0';
  DialInitString :='ATZ';
  PulseOrTone :='T';
  LockedBaud := False;
  If Exist('TCBBS.CFG')
  then
  begin
   Assign(ConfigFile,'TCBBS.CFG');
   reset(ConfigFile);
   readln(Configfile,COMNUM);
   readln(Configfile,Baud1);
   readln(Configfile,SysOpName);
   readln(Configfile,BBSName);
   readln(Configfile,BBSDIR);
   readln(Configfile,ModemInitString);
   readln(Configfile,PulseOrTone);
   readln(Configfile,Editor);
   readln(Configfile,IdleScreen);
   readln(Configfile,ScrnBlnker);
   readln(Configfile,MXC);
   readln(Configfile,MYC);
   readln(Configfile, BooVar);
   DoorsYes:=(BooVar=1);
   readln(Configfile, BooVar);
   ReqSerYes:=(BooVar=1);
   readln(Configfile, BooVar);
   XonXoff:=(BooVar=1);
   readln(Configfile, BooVar);
   RTSCTS:=(BooVar=1);
   readln(Configfile, BooVar);
   LockedBaud:=(BooVar=1);
   readln(Configfile, DialInitString);
   close(Configfile);
   Pup.Done;
   BBSDir :=Upper(BBSDir)
  end
  else
   begin
    Pup.Done;
    Pup.Init(9,5,68,9,12,4,15,' No Config file "TCBBS.CFG" ... Execution Halted ');
    GotoXY(1,18);
    TextColor(7);
    TextbackGround(0);
    Writeln('...');
    halt(1)
   end
  end;
  If IOResult <>0 then Writeln('I/O Error..');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure ExecDSZ(var XXX: TBBS; ExecStr : String);
 var
  SpdPos : Byte;

 begin
  With XXX do
  begin
  ComWriteO(#7);
  ComWriteln('Press <ESC> or <Cntrl-X> Several Times to ABORT !');
  Delay(1000);
  ClearRX;
  ClearTX;
  GotoXY(1,5);
  If OnLine then
    Shell(BBSRec.BBSDIR+'\DSZ.EXE',ExecStr)
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure ReadlnX(var XXX:TBBS;var ST:String; L:Integer; Pas:Boolean);
  var
   TStr   : string;
   DoneR  : boolean;
   Ch     : Char;
   Lt     : integer;
  begin
  With XXX do
  begin
   ShowMsr;
   Doner :=False;
   Tstr:='';
   St:='';
   while not doneR and Online and Not GoOffLine do
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
               if Pas then ComWrite('*') else ComWrite(Ch)
              end
            end
       end {case}
      end
    end;
   St:=TStr;
  if ReqChat then Chat
  end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Getstring(var XXX:TBBS; var FString:String; Pstring:String; Confirm:Boolean );

 var
  ENTEREDWRONG    : boolean;
  Attempts        : integer;
  YHIT            : boolean;
  DumInput        : Char;
  Ch              : byte;
 begin
  With XXX do
  begin
  ShowMsr;
  Attempts:=0;
  ENTEREDWRONG:=true;
  ShowMsr;
  while ENTEREDWRONG and (Attempts <=5) and not GoOffline and Online do
  begin
   Attempts:=Attempts+1;
   ComWrite(PSTRING);
   FSTRING:='';
   ReadLnX(XXX,FSTRING,25,False);
   if NOT Online then GoOffline :=true;
     IF KEYPRESSED Then
       begin
        DumInput:=readkey;
        if DumInput=#0 then
            begin
             CheckKey;
             ShowMsr
            end
        end;
    if Not Confirm then EnteredWrong :=False;
    IF confirm and (FSTRING='') THEN ENTEREDWRONG :=true
    else
     if Online and not GoOffLine and confirm then
     begin
      ENTEREDWRONG :=False;
      ComWriteln('');
      ComWrite(' You Entered.. [');
      ComWrite(FSTRING);
      ComWrite(']     Is This Correct ?  ');
      GetYN(YHIT);
      ENTEREDWRONG:=NOT YHIT;
     end
   end;
   if Attempts>5 then
    begin
     Emu_Color(12,0);
     ComWriteln(' Too Many Attempts...  ');
     Delay(3000);
     GoOffLine := true;
    end;
  ShowMsr;
  CheckTimeLeft;
 end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure TMenuWrite(XXX : TBBS; bb,cb,cf: byte; CDSTR : String);
 begin
   With XXX do
   begin
    Emu_color(15,bb);
    ComWriteln('                               ');
    ComWrite('  ');
    Emu_color(cf,cb);
    ComWrite(CDSTR);
    Emu_color(0,bb);
    ComWriteln('Ü  ');
    ComWriteln('   ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿  ');
   end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure MenuWrite(XXX :TBBS; bb,cb,cf: byte; CDSTR : String; var ChSt : Char);
 begin
  With XXX do
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
       ChSt :=UpCase(CReadKey);
      end;
     if Not (ChSt in IntCharSet) then Chst :=#0;
   end
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure WriteUsrfil(XXX : TBBS);
  var
   Ufile : text;
 begin
 With XXX Do
  With BBSRec do
   begin
   TimeUsed :=TimeUsed+(TimeNow- StartTime);
   StartTime:=TimeNow;
   if TimeUsed> TimeLimit then TimeUsed:=TimeLimit-1;
   if TimeUsed<0 then TimeUsed:=0;
   assign(Ufile,'UserFile');
   rewrite(Ufile);
   writeln(Ufile, Uname);
   writeln(Ufile, Getbps);
   writeln(Ufile, ComPort);
   writeln(Ufile, TType);
   writeln(Ufile, Timelimit);
   writeln(Ufile, TimeUsed);
   IF HotKeys then writeln(Ufile, 1) else writeln(Ufile, 0);
   IF GoOffLine then writeln(Ufile, 1) else writeln(Ufile, 0);
   writeln(Ufile, Level);
   IF Color      then writeln(Ufile, 1) else writeln(Ufile, 0);
   IF SpkOn      then writeln(Ufile, 1) else writeln(Ufile, 0);
   IF LOCAL      then writeln(Ufile, 1) else writeln(Ufile, 0);
   If XonXoff    then writeln(Ufile, 1) else writeln(Ufile, 0);
   If RTSCTS     then writeln(Ufile, 1) else writeln(Ufile, 0);
   IF LockedBaud then writeln(Ufile, 1) else writeln(Ufile, 0);
   IF LockedBaud then writeln(Ufile, 1) else writeln(Ufile, 0);
   close(Ufile);
  end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
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
   if (Dest[Length(Dest)] = ':') then
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
   if (Dest[Length(Dest)] = '\') then
    Begin
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

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure FormatName(var FNAME :STRING);
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
   if pos('  ',Fname)>0 then delete(Fname,pos('  ',Fname),1)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure Inc_Call_Count( var CallCount : LongInt);
 var
  ConfigFile : text;
  NumCalls   : Longint;
 begin
  if Not Exist('TCBBS.NUM') then
   begin
    assign(ConfigFile,'TCBBS.NUM');
    Rewrite(Configfile);
    writeln(Configfile,1);
    Numcalls:=1;
    close(Configfile)
   end
   else
    begin
     Assign(ConfigFile,'TCBBS.NUM');
     Reset(ConfigFile);
     readln(Configfile,NumCalls);
     NumCalls:=Numcalls+1;
     Rewrite(Configfile);
     writeln(Configfile,NumCalls);
     close(Configfile)
    end;
  CallCount:=NumCalls
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
procedure Checkdate;
var
  y, m, d, dow : Word;
  timfil       : text;
begin
 GETDate(y,m,d,dow);
  IF  Y=1980 then
   begin
    if Not Exist('date.fil') then
    begin
     assign(timfil,'date.fil');
     rewrite(timfil);
     writeln(timfil,y);
     writeln(timfil,m);
     writeln(timfil,d);
     close(timfil);
    end
    else
     begin
      assign(timfil,'date.fil');
      reset(timfil);
      readln(timfil,y);
      readln(timfil,m);
      readln(timfil,d);
      setDate(y,m,d);
      close(timfil)
     end
   end;
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
end.