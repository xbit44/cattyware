{$M 32767,0,655360}

 PROGRAM BBSrace;
 Uses crt,DOS,BBSGAM;
 Type
   CMDARRAY  = ARRAY[1..8] OF STRING[20];
   ENGCOST   = ARRAY[1..8] OF LONGINT;
   CARCOST   = ARRAY[1..8] OF LONGINT;
 Const
  Vrs  =' 1.55';
  RacePerday =10;
  CARTYPE: CMDARRAY= ('Camaro         ',
                      'Firebird       ',
                      'Mustang        ',
                      'Monte Carlo    ',
                      'Thunderbird    ',
                      'Grand National ',
                      'Cougar         ',
                      'Corvette       ');
  CARPRICE: CARCOST= ( 18000,18500,22500,25000,38000,53000,85000,149000);
  ENGPRICE: ENGCOST= ( 4000,15500,22500,55000,118000,223000,325000,447000);
  ENGINTYPE: CMDARRAY= ('V8 287 TURBO ',
                        'V8 305       ',
                        'V8 305 TURBO ',
                        'V8 350 TURBO ',
                        'V8 400       ',
                        'V8 400 TURBO ',
                        'V8 454       ',
                        'V8 454 TURBO ');
 Type
  CharSet    = set of Char;
  NAmeStr    = string[20];
  PointType  = record
                 X,Y: integer
               end;

  Players = record
             Name       : NameStr;
             Money      : Real;
             Car        : Byte;
             Engine     : Byte;
             Fuel       : integer;
             Tires      : integer;
             EngineWear : integer;
             Wager      : real;
             Won        : Word;
             Lost       : Word;
             RaceCnt    : integer;
             PlyrDate   : String[8];
           end;

 Playerstat = array[1..300] of Players;

  XXBBS = OBJECT(TBBS)
           Procedure MakeWager;
           Procedure CheckRegistered(var BR : BBSData);
           Procedure DoRace;
           Procedure BuyCar;
           Procedure BuyFuel;
           Procedure BuyTires;
           Procedure BuyEngine(var Aborted : boolean);
           Procedure ShowCarInfo;
           Procedure ShowContender1;
           Procedure ShowContender2;
           Procedure ShowPitMenu;
           Procedure ShowRaceMenu;
           Procedure SelectOpp;
           Procedure ClearMenu;
           Procedure HideCar( Lane,Loc : integer);
           Procedure ShowCar( Lane,Loc,CColor : integer);
           Procedure ShowLogo;
           Procedure DrawTrack;
           Procedure MainFlow;
           Procedure Redraw;
           Procedure Instructions;
           Procedure UserInit;
           Procedure ShowStatus;
           Procedure GetNum(var Num: real; MaxVal: real);
           Procedure Initialize;
           Procedure ShowHallFame;
           Procedure ShowRankings;
           Procedure mainmenu;
           Procedure RUNX;
           Procedure ShowNews;
           Function PlayerFound : Boolean;
           Procedure DateChk;
          end;
var
  XXX        : XXBBS;
  QuitNow    : boolean;
  Pn         : integer;
  Pn2        : integer;
  Quit       : boolean;
  LTIME      : STRING;
  Ldate      : String[9];
  Player     : Playerstat;
  PlayerCnt  : integer;
  TypWager   : Byte;
  PName      : NameStr;
  NewGAme    : Boolean;
  Car1C,Car2C : byte;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 function CommaPut( Num : real ): string;
 var
  st : string;
  L  : Integer;

 begin
  Str(Num:0:0, St);
  L:= Length(St);
  case L of
  4..6:   insert(',',St,L-2);
  7..9 : begin
          insert(',',St,L-2);
          insert(',',St,L-5);
         end;
  10..12 : begin
            insert(',',St,L-2);
            insert(',',St,L-5);
            insert(',',St,L-8);
           end;
  13..15 : begin
            insert(',',St,L-2);
            insert(',',St,L-5);
            insert(',',St,L-8);
            insert(',',St,L-11);
           end;

  end;
  CommaPut :=St
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 Procedure XXBBS.CheckRegistered(var BR : BBSData);

 const
   AuthorName ='Chris Neubauer';
 var
   Code       : String;
   I,LSN      : integer;
   Sum        : Integer;

 begin
  With BR do
  begin
  Code:='#$@%$#&^%*&^';
  I:=Pos('  ',SysOpName);
  if I>0 then SYSopName[0] := Chr(I-1);
  I:=Pos('  ',RN);
  if I>0 then RN[0] := Chr(I-1);
  I:=Pos('  ',BBSName);
  if I>0 then BBSName[0] := Chr(I-1);
  while Length(BBSName)< 25 do BBSName :=BBSName +' ';
  LSN := Length(SysOpName);
  if LSN >0 then
  begin
   Code :='';
   for I:=1 to LSN do
    Begin
     Sum := ord(SysOpName[I]) + ord(BBSName[I]);
     Sum:= Sum Mod 33;
     Sum :=Sum+48;
     Code :=Code+Chr(Sum)
    end
  end;
  BR.Registered :=(RN=Code);
  if Not BR.Registered then
   begin
    textcolor(15);
    Clrscr;
    Writeln('BBS Drag Racing '+ Vrs);
    textcolor(12);
    Writeln('UNREGISTERED COPY');
    textcolor(14);
    Writeln('Author:');
    textcolor(11);
    Writeln(AuthorName);
    Writeln('P.O. Box  1446');
    Write('Corpus Christi, Tx');
    Writeln(' 78403-1446');
    delay(2000);
   end
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function StTrunc(St : String) : String;
 begin
  While Pos('  ',St) > 0 do St:= Copy(St,1,Length(St)-1);
  StTrunc:=St
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function XXBBS.PlayerFound : Boolean;
 var
  I      : Integer;
  UFound : Boolean;
  begin
   UFound:=false;
   For I :=1 to PlayerCnt do
   begin
    if Pos(PName,Player[I].Name) >0 then
     begin
      PN :=I;
      Ufound :=True
     end;
   if Pos('Computer',Player[I].Name) >0 then PN2 :=I;
   end;
   PlayerFound :=Ufound
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowStatus;
 var
   I  : integer;
   St : String;

 begin
  Emu_Color(15,0);
  emu_ClearScreen;
  ComWriteln('');
  ComWriteln('        BBS Drag Racing Version'+Vrs);
  Emu_Color(14,0);
  ComWriteln('                Your Status');
  ComWriteln('');
  Emu_Color(12,0);
  ComWriteln('ออออออออออออออออออออออออออออออออออออออออออออออ');
  ComWriteln('');
  Emu_Color(15,0);
  ComWrite(' Player Name...... ');
  Emu_Color(14,0);
  ComWriteln(Player[PN].Name);
  Emu_Color(15,0);
  ComWrite(' Cash............. ');
  Emu_Color(10,0);
  ComWriteln('$'+CommaPut(Player[PN].Money));
  Emu_Color(15,0);
  ComWrite(' Rating........... ');
  Emu_Color(13,0);
  if Player[PN].Money< 100000 then
   ComWriteln('Beginner')
   else
  if Player[PN].Money< 1000000 then
   ComWriteln('Amateur')
   else
  if Player[PN].Money< 10000000 then
   ComWriteln('Sub-Professional')
   else
  if Player[PN].Money< 100000000 then
   ComWriteln('Profesional')
   else
  if Player[PN].Money>=100000000 then
   ComWriteln('Legend');

  Emu_Color(15,0);
  ComWrite(' Car.............. ');
  Emu_Color(11,0);
  ComWriteln(CarType[Player[PN].Car]);
  Emu_Color(15,0);
  ComWrite(' Engine........... ');
  Emu_Color(14,0);
  ComWriteln(EnginType[Player[PN].Engine]);
  Emu_Color(15,0);
  ComWrite(' Races Won........ ');
  Emu_Color(10,0);
  Str(Player[PN].Won:5,st);
  ComWriteln(st);
  Emu_Color(15,0);
  ComWrite(' Races Lost....... ');
  Emu_Color(12,0);
  Str(Player[PN].Lost:5,st);
  ComWriteln(st);
  Emu_Color(15,0);
  ComWrite(' Races Left Today. ');
  Emu_Color(15,0);
  Str(10-Player[PN].RaceCnt:5,st);
  ComWriteln(st);
  Emu_Color(15,0);
  ComWriteln('');
  GetCR(15);
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.Instructions;
 begin
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    Clrscr;
    emu_color(0,7);
    Comwrite('                 Instructions For Playing BBS Drag Racing                       ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    ComWriteln('   Object : The object of BBS Drag Racing is to rule the Drag Racing Circuit');
    ComWriteln(' by having the best Car and Engine and of Course, the most Money.  You will be');
    ComWriteln(' required to keep your Dragster in good shape.  Remember to Check your FUEL, ');
    ComWriteln(' TIRES, and ENGINE regularly.  At the end of Each Month the Player list will ');
    ComWriteln(' be reset and the Top Player will get added to the all time Hall of Fame List.');
    emu_color(11,0);
    ComWriteln('');
    ComWriteln('   Selecting Opponents :  You May select your opponent from the currently ');
    ComWriteln(' Available players, Wager Money against them and Stomp them into the pavement');
    ComWriteln(' by beating them in a Race.');
    ComWriteln('');
    ComWriteln('  Wagering Money:   Wagering and winning is one of the sure fire ways to get');
    ComWriteln(' on top fast, but be careful, if you lose all your money you will have to wait');
    ComWriteln(' until the next day when you will be given some more money for expenses.');
    ComWriteln('');
    ComWriteln('  All Players are allowed 10 races per day.  You may wager on any or all of ');
    ComWriteln(' the races that you participate in. ');
    ComWriteln('');
    GetCr(10);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure ShellSort(var SortList :PlayerStat; Count: integer);
  var
    D , Limit   : integer;
    Next, Exndx : integer;
    ExFlag      : boolean;
    TmpRec      : Players;

 begin
  D:=1;
  If Count >=4 then
   begin
    while D <= Count do D:=D*2;
    D:= (D div 2) -1;
   end;
   while D > 0 do
    begin
     Limit := Count-D;
     Next  := 1;
     while Next <= Limit do
      begin
       if SortList[Next].Money < SortList[Next+D].Money then
        begin
         Exndx := Next;
         ExFlag := False;
         while Not Exflag do
          begin
           TmpRec:=SortList[Exndx];
           SortList[Exndx]:=SortList[Exndx+D];
           SortList[Exndx+D]:= TmpRec;
           Exndx:=Exndx-D;
           if Exndx>= 1 then
            ExFlag := (SortList[Exndx].Money >= SortList[Exndx+D].Money)
           else ExFlag := True;
          end
        end;
       Next := Next + 1
      end;
     D := D Div 2
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure ResetPuter(PN2:Integer);
 begin
   with Player[PN2] do
    begin
     Name       :='Computer                ';
     Money      :=10000;
     Car        :=1+ round(Random*7);
     Engine     :=1+ round(Random*7);
     EngineWear :=60+ round(Random*37);
     Fuel       :=60+ round(Random*37);
     Tires      :=60+ round(Random*37);;
     Wager      :=0;
     Won        :=0;
     Lost       :=0;
     PlyrDate   :=Date
    end;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure SavePlayers;
  var
   I     : integer;
   Rfile : text;

 begin
   Assign(RFile,'Plyrfile.dta');
   ReWrite(RFile);
   I :=0;
   while I<PlayerCnt do
   begin
    I:=I+1;
    with Player[I] do
    writeln(RFile,Name,' ',round(Money),' ',Car,' ',Engine,' ',EngineWear,
            ' ',Fuel,' ',Tires,' ',Won,' ',Lost,' ',RaceCnt,' ',PlyrDate,' ');
   end;
  CLOSE(RFile);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure GetPlayers;
  var
   Dummy : integer;
   Rfile : text;
   found : boolean;
   DumChar : Char;

 begin
   if Not Exist('Plyrfile.dta') then
   begin
    PlayerCnt :=1;
    ResetPuter(1);
    SavePlayers;
    NewGame :=True
   end
   else
   begin
   PlayerCnt:=0;
   Assign(RFile,'Plyrfile.dta');
   Reset(RFile);
   while not eof(Rfile) and (PlayerCnt<301) do
   begin
    PlayerCnt:=PlayerCnt+1;
    with Player[PlayerCnt] do
     begin
      readln(RFile,Name,Money,Car,Engine,EngineWear,Fuel,Tires,Won,lost,RaceCnt,
             DumChar,PlyrDate);
       if Engine =0 then Engine:=1
     end
  end;
   CLOSE(RFile);
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowHallFame;
 var
  Rfile       : text;
  Pname       : NameStr;
  CNT,I       : integer;
  Money1      : Real;
  ST,STT      : string;
  LineCount   : integer;
  Continue    : Boolean;
  DtStr       : String[8];
  DumChar     : char;

 begin
   if BRec.Registered then
   Begin
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    emu_color(0,7);
    Comwrite('                       BBS Drag Racing HALL of FAME                             ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    ComWrite('   Player Name    ');
    emu_color(11,0);
    ComWrite('          Bucks    ');
    emu_color(10,0);
    ComWrite('         Level    ');
    emu_color(15,0);
    ComWriteln('           Date    ');
    emu_color(9,0);
    ComWrite('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
    emu_color(15,0);
    ComWriteln('');
    CNT :=1;
    LineCount:=0;
    Continue:=true;
    If Exist('Race.Hof') then
   begin
    Assign(Rfile,'Race.Hof');
    Reset(Rfile);
    while Not Eof(Rfile) and Online and Not GoOffLine and Continue do
     begin
      Readln(Rfile,Pname, Money1,DumChar,DtStr);
      Emu_Color(14,0);
      ComWrite('  '+PName+' ');
      Emu_Color(10,0);
      ComWrite('  $'+CommaPut(Money1));
      Emu_GotoXy(45,wherey);
      Emu_Color(13,0);
      if Money1< 100000 then
      ComWrite('Beginner        ')
      else
      if Money1< 1000000 then
      ComWrite('Amateur         ')
      else
      if Money1< 10000000 then
      ComWrite('Sub-Professional')
      else
      if Money1< 100000000 then
      ComWrite('Profesional     ')
      else
      ComWrite('Legend          ');
      Emu_Color(15,0);
      ComWriteln('    '+DtStr);
      LineCount:= LineCount+1;
      If LineCount >16 then
       begin
        LineCount:=0;
        ComWriteln('');
        Emu_Color(15,0);
        ComWrite('  More ');
        GetYn(ConTinue);
        if Continue then
         begin
           textbackground(0);
           emu_ClearScreen;
           emu_color(0,7);
           Comwrite('                     BBS Drag Racing List of Champions                          ');
           emu_color(14,0);
           ComWriteln('');
           ComWriteln('');
           ComWrite('   Player Name    ');
           emu_color(11,0);
           ComWrite('          Bucks    ');
           emu_color(10,0);
           ComWrite('         Level    ');
           emu_color(15,0);
           ComWriteln('           Date    ');
           emu_color(9,0);
           ComWrite('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
           emu_color(15,0);
           ComWriteln('');
         end
       end
     end;
    Close(Rfile);
    end
    else
    begin
     emu_color(14,0);
     textbackground(0);
     emu_color(0,7);
     ComWriteln('');
     ComWriteln(' Hall of Fame Is Empty....... ');
     ComWriteln('')
    end
    end
    else
    begin
     emu_color(14,0);
     textbackground(0);
     emu_ClearScreen;
     emu_color(0,7);
     ComWriteln('');
     ComWriteln(' Rankings Option is Only Available With Registered Version..');
     ComWriteln('');
    end;
    GetCR(10);
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowRankings;
 var
  CNT,I       : integer;
  Money1      : real;
  ST,STT      : string;
  LineCount   : integer;
  Continue    : Boolean;

 begin
   if Brec.Registered then
   Begin
    ShellSort(Player,PlayerCnt);
    if Not Playerfound then writeln(' Data File Error...');
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    emu_color(0,7);
    Comwrite('                      BBS Drag Racing List of Champions                         ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    ComWrite('   Player Name    ');
    emu_color(11,0);
    ComWrite('        Bucks    ');
    emu_color(13,0);
    ComWrite('     Status  ');
    emu_color(12,0);
    ComWrite('         Won   Lost  ');
    emu_color(15,0);
    ComWriteln(' Ratio');
    emu_color(9,0);
    ComWrite('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
    emu_color(15,0);
    ComWriteln('');
    CNT :=1;
    LineCount:=0;
    Continue:=true;
    while (CNT <= PlayerCnt) and Online and Not GoOffLine and Continue do
     begin
      Emu_Color(14,0);
      ComWrite('  '+Player[Cnt].Name);
      Emu_Color(10,0);
      Money1 := Player[CNT].Money;
      ComWrite('  $'+Commaput(Money1));
      for I := 1 to 14-Length(Commaput(Money1)) do ComWrite(' ');
      Emu_Color(13,0);
      if Money1< 100000 then
       ComWrite('Beginner        ')
      else
      if Money1< 1000000 then
       ComWrite('Amateur         ')
      else
      if Money1< 10000000 then
       ComWrite('Sub-Professional')
      else
      if Money1< 100000000 then
       ComWrite('Profesional     ')
      else
      if Money1>=100000000 then
       ComWrite('Legend          ');
      Emu_Color(15,0);
      Str(Player[Cnt].Won:5 ,St);
      ComWrite(St+' ');
      Emu_Color(15,0);
      Str(Player[Cnt].Lost:5,St);
      ComWrite(St+'   ');
      Emu_Color(14,0);
      if (Player[Cnt].Won+ Player[Cnt].Lost) >0 then
      begin
       Str(round((Player[Cnt].Won/(Player[Cnt].Lost+Player[Cnt].Won))*100) :4,St);
       ComWriteln(St+'%')
      end
      else
       ComWriteln('   0%');
      Cnt:=Cnt+1;
      LineCount:= LineCount+1;
      If LineCount >16 then
       begin
        LineCount:=0;
        ComWriteln('');
        ComWrite('  More ');
        GetYn(ConTinue);
        if Continue then
         begin
           textbackground(0);
           emu_ClearScreen;
           emu_color(0,7);
           Comwrite('                     BBS Drag Racing List of Champions                         ');
           emu_color(14,0);
           ComWriteln('');
           ComWriteln('');
           ComWrite('   Player Name    ');
           emu_color(11,0);
           ComWrite('        Bucks    ');
           emu_color(13,0);
           ComWrite('     Status  ');
           emu_color(12,0);
           ComWrite('         Won   Lost  ');
           emu_color(15,0);
           ComWriteln(' Ratio');
           emu_color(9,0);
           ComWrite('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
           emu_color(15,0);
           ComWriteln('');
         end
       end
     end
    end
    else
    begin
     emu_color(14,0);
     textbackground(0);
     emu_ClearScreen;
     emu_color(0,7);
     ComWriteln('');
     ComWriteln(' Rankings Option is Only Available With Registered Version..');
     ComWriteln('');
    end;
    GetCR(15);
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.UserInit;
 begin
  with BRec do
  begin
  UNAME   := '';
  TTYPE   := 1;
  GoOffLine := false;
  TIMELIMIT := 5;
  TimeUsed  := 0;
  LTime    := Time;
  LDate    := Date;
  ReqChat:= false;
  Registered :=False;
  StartTime := TimeNow;
  Hotkeys:=true;
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.Initialize;
 begin
  SHOWMSR;
  if not LoadEmulation('RACE') then
   begin
     writeln(' Unable to Load Race.emu..');
     Done;
     halt
   end;
  GoOffLine:=false;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowCar( Lane,Loc,CColor : integer);
 begin
  If Lane = 1 then Lane :=5 else Lane :=11;
  Emu_gotoxy(Lane,21-Loc);
  Emu_Color(7,0);
  ComWrite('฿');
  Emu_Color(CColor,0);
  ComWrite('ฑ');
  Emu_Color(7,0);
  ComWrite('฿');
  Emu_gotoxy(Lane,22-Loc);
  ComWrite('Ü');
  Emu_Color(CColor,0);
  ComWrite('ฑ');
  Emu_Color(7,0);
  ComWrite('Ü');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.HideCar( Lane,Loc : integer);
 begin
  If Lane = 1 then Lane :=5 else Lane :=11;
  Emu_gotoxy(Lane,22-Loc);
  ComWrite('   ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowContender1;
 var
     I : integer;
     St : string;
 begin
  Emu_Gotoxy(20,7);
  Emu_Color(11,0);
  ComWrite(Player[PN].Name);
  Emu_Gotoxy(20,8);
  Emu_Color(10,0);
  ComWrite('$'+Commaput(Player[PN].Money)+'           ');
  Emu_Gotoxy(20,9);
  Emu_Color(13,0);
  if Player[PN].Money< 100000 then
   ComWrite('Beginner        ')
   else
  if Player[PN].Money< 1000000 then
   ComWrite('Amateur         ')
   else
  if Player[PN].Money< 10000000 then
   ComWrite('Sub-Professional')
   else
  if Player[PN].Money< 100000000 then
   ComWrite('Profesional     ')
   else
   if Player[PN].Money>=100000000 then
   ComWrite('Legend          ');
  Emu_Gotoxy(20,10);
  Emu_Color(15,0);
  ComWrite(CarType[Player[PN].Car]);
  Emu_Gotoxy(20,11);
  Emu_Color(14,0);
  if Not (Player[PN].Engine in [1..8]) then
   begin
    Emu_Color(12,0);
    ComWrite(' B L O W N !! ');
   end
  else
  ComWrite(EnginType[Player[PN].Engine]);
  Emu_Gotoxy(20,12);
  Emu_Color(15,0);
  ComWrite('Races Left.. ');
  Str(RacePerDay-Player[PN].RaceCnt:3,St);
  Emu_Color(10,0);
  ComWrite(St)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowContender2;
 var
     I : integer;
     St : string;
 begin
  Emu_Color(11,0);
  Emu_Gotoxy(50,7);
  ComWrite(Player[PN2].Name);
  Emu_Gotoxy(50,8);
  Emu_Color(10,0);
  ComWrite('$'+CommaPut(Player[PN2].Money)+'           ');
  Emu_Gotoxy(50,9);
  Emu_Color(13,0);
  if Player[PN2].Money< 100000 then
   ComWrite('Beginner        ')
   else
  if Player[PN2].Money< 1000000 then
   ComWrite('Amateur         ')
   else
  if Player[PN2].Money< 10000000 then
   ComWrite('Sub-Professional')
   else
  if Player[PN2].Money< 100000000 then
   ComWrite('Profesional     ')
  else
   if Player[PN2].Money>=100000000 then
   ComWrite('Legend          ');

  Emu_Gotoxy(50,10);
  Emu_Color(15,0);
  ComWrite(CarType[Player[PN2].Car]);
  Emu_Gotoxy(50,11);
  Emu_Color(14,0);
  ComWrite(EnginType[Player[PN2].Engine]);
  Emu_Gotoxy(50,12);
  Emu_Color(11,0);
  Str(Player[PN2].EngineWear:3,St);
  St:=St+'% New';
  ComWrite('Engine '+St)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowRaceMenu;
 begin
  Emu_Gotoxy(30,14);
  Emu_color(15,0);
  ComWrite(' Race Track Options' );
  Emu_Gotoxy(29,15);
  Emu_color(15,0);
  ComWrite('ออออออออออออออออออออออออ' );
  Emu_Gotoxy(30,16);
  if  Player[PN].RaceCnt<RacePerDay then
  begin
   Emu_color(10,0);
   ComWrite('[S]  Select Opponent ' );
   if Player[PN].Wager =0 then
   begin
    Emu_Gotoxy(30,17);
    Emu_color(11,0);
    ComWrite('[W]  Wager ' )
   end;
   Emu_Gotoxy(30,WhereY+1);
   Emu_color(14,0);
   ComWrite('[B]  Begin Race ' );
   Emu_Gotoxy(30,WhereY+1);
  end;
  Emu_color(13,0);
  ComWrite('[G]  Go to Pit ' );
  Emu_Gotoxy(30,WhereY+1);
  Emu_color(12,0);
  ComWrite('[Q]  Quit To Main Menu ' );
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowCarInfo;
  var
   St : String;
 begin
  Emu_Gotoxy(30,14);
  Emu_color(15,0);
  ComWrite('  Your Car Status' );
  Emu_Gotoxy(29,15);
  Emu_color(15,0);
  ComWrite('ออออออออออออออออออออออออ' );
  Emu_Gotoxy(30,16);
  Emu_color(10,0);
  ComWrite('Fuel...... ');
  Str(Player[PN].Fuel:3,St);
  St:=St+'% Full';
  Emu_color(15,0);
  ComWrite(St);
  Emu_Gotoxy(30,17);
  Emu_color(13,0);
  ComWrite('Tires..... ');
  Str(Player[PN].Tires:3,St);
  St:=St+'% New';
  Emu_color(15,0);
  ComWrite(St);
  Emu_Gotoxy(30,18);
  Emu_color(11,0);
  ComWrite('Engine.... ');
  Str(Player[PN].EngineWear:3,St);
  St:=St+'% New';
  Emu_color(15,0);
  ComWrite(St);
  Emu_Gotoxy(30,20);
  Emu_Color(15,0);
  ComWrite(' Press [Enter]');
  GetEnterKeyNC;
  If ReqChat then
    begin
     Chat;
     Redraw
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowPitMenu;
 begin
  Emu_Gotoxy(30,14);
  Emu_color(15,0);
  ComWrite('    Pit Options' );
  Emu_Gotoxy(29,15);
  Emu_color(13,0);
  ComWrite('ออออออออออออออออออออออออ' );
  Emu_Gotoxy(30,16);
  Emu_color(15,0);
  ComWrite('[L]  Look At Car');
  Emu_Gotoxy(30,17);
  Emu_color(10,0);
  ComWrite('[F]  Buy Fuel');
  Emu_Gotoxy(30,18);
  Emu_color(13,0);
  ComWrite('[T]  Buy New Tires');
  Emu_Gotoxy(30,19);
  Emu_color(11,0);
  ComWrite('[E]  Buy New Engine');
  Emu_Gotoxy(30,20);
  Emu_color(14,0);
  ComWrite('[C]  Buy New Car');
  Emu_Gotoxy(30,21);
  Emu_color(12,0);
  ComWrite('[Q]  Quit To Race Menu ' );
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowLogo;
 begin
  Emu_Gotoxy(30,1);
  Emu_color(14,0);
  ComWrite(' BBS Drag Racing Ver.'+Vrs);
  Emu_Gotoxy(30,2);
  Emu_color(11,0);
  ComWrite('   Virtual Reality BBS');
  Emu_Gotoxy(30,3);
  Emu_color(15,0);
  ComWrite('     (512)-992-4496 ' );
  Emu_Gotoxy(17,5);
  Emu_Color(15,0);
  ComWrite('       Left Lane                     Right Lane ');
  Emu_Gotoxy(17,6);
  Emu_Color(9,0);
  ComWrite('ออออออออออออออออออออออออออ    ออออออออออออออออออออออออออ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 Procedure XXBBS.DrawTrack;
 var I : integer;
     St : string;
 begin
  Emu_Gotoxy(1,1);
  ComWriteln('     Finish ');
  ComWriteln('  ณ฿Ü฿Ü฿Ü฿Ü฿Ü฿ณ');
  ComWriteln('  ณ฿Ü฿Ü฿Ü฿Ü฿Ü฿ณ');
  For I:= 1 to 18 do
  ComWriteln('  ณ     .     ณ');
  ComWriteln('  ณ฿฿฿฿฿฿฿฿฿฿฿ณ');
  ComWrite  ('     Start');
  ShowCar(1,1,Car1C);
  Car2C:=Round(1+(Random*5));
  ShowCar(2,1,Car2C);

 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.mainmenu;
 var
   C : Char;
   I : Integer;
   RegStr : String;
 begin
 clearreceive;
 emu_color(15,0);
 textbackground(0);
 emu_ClearScreen;
 clrscr;
 TypeFile('DragRac.Ans',C);
 Comwriteln('');
 emu_color(11,0);
 Comwriteln('');
 Comwriteln('                           Version'+Vrs+' (c) 1993 ');
 emu_color(15,0);
 Comwriteln('                        Neubauer Applications Uncorp ');
 emu_color(14,0);
 Comwriteln('                      Virtual Reality BBS 512-992-4496');
 emu_color(15,0);
 if BRec.Registered then
 with Brec do
 begin
  I:=Pos('  ',BBSName);
  if I>0 then BBSName[0] := Chr(I-1);
  RegStr:=' Registered to '+BBSName;
  Emu_GotoXy(38-(Length(RegStr) div 2),WhereY);
 ComWriteln(RegStr)
 end
 else
 Comwriteln('               UNREGISTERED COPY  ... ASK SYSOP TO REGISTER');
 Comwriteln('');
 Comwriteln('');
 emu_color(15,0);
 Comwriteln(' [G]  Go to Race Track');
 emu_color(10,0);
 Comwriteln(' [Y]  Your Status');
 emu_color(14,0);
 Comwriteln(' [R]  Rankings');
 emu_color(11,0);
 Comwriteln(' [H]  Hall of Fame');
 emu_color(7,0);
 Comwriteln(' [I]  Instructions');
 emu_color(12,0);
 Comwriteln(' [Q]  Quit Back to BBS');
 showMsr;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ClearMenu;
 var
  I : integer;
 begin
  Emu_color(15,0);
  for I := 1 to 10 do
  begin
   Emu_Gotoxy(20,13+I);
   Emu_ClearToEndOfLine
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.SelectOpp;
 var
  Continue    : Boolean;
  I           : integer;
  Yhit        : Boolean;

 begin
  ShellSort(Player,PlayerCnt);
  if Not Playerfound then writeln(' Data File Error...');
  Continue:=true;
  Emu_Color(15,0);
  if PlayerCnt >0 then
  begin
   Emu_GoToXy(20,14);
   ComWrite(' Selecting Opponent...');
   I:=1;
   Player[PN].Wager:=0;
   while (I<=PlayerCnt) and  Online and Not GoOffLine And Continue Do
    begin
     if Player[I].Name <> Player[PN].Name then
     begin
      Emu_GoToXy(20,16);
      ComWrite(' Race Against '+Player[I].Name);
      Emu_GoToxy(30,17);
      GetYn(Yhit);
      if Yhit then
       begin
        PN2:=I;
        ShowContender2;
        ClearMenu;
        Continue :=false
       end;
      Emu_GoToxy(30,17);
      ComWrite('              ')
     end;
     I :=I+1;

    end;
    If Continue then
     begin
      ClearMenu;
      Emu_GoToxy(20,15);
      ComWrite(' No More Available Players.....');
      Emu_GoToxy(20,17);
      ComWrite(' Press [Enter]');
      GetEnterKeyNC;
      If ReqChat then
      begin
       Chat;
       Redraw
      end;
      ClearMenu
     end
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.BuyFuel;
  var
   St : string;
   Doit : Boolean;
   Cost : integer;
  begin
    Emu_Color(15,0);
    Emu_gotoxy(20,16);
    Str(Player[PN].Fuel,St);
    St:=St+'% Full';
    ComWrite('Your Tank is '+St);
    Emu_gotoxy(20,17);
    ComWrite('Want to Fill''er Up ??');
    GetYN(Doit);
    if Doit then
     begin
      Emu_gotoxy(20,18);
      Cost :=100 + (5*(100-Player[PN].Fuel));
      IF Player[PN].Money > Cost then
      begin
       Player[PN].Money:=Player[PN].Money-Cost;
       Player[PN].Fuel:=100;
       ComWrite('The Fill Up Cost You  $'+CommaPut(Cost));
       ShowContender1
      end
      else
       begin
        ComWrite('You Don''t Have Enough Money!!!' )
       end;
       Emu_Gotoxy(20,20);
       Emu_Color(15,0);
       ComWrite('Press [Enter]');
       GetEnterKeyNC;
       If ReqChat then
        begin
         Chat;
         Redraw
        end
     end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.BuyTires;
  var
   St : string;
   Doit : Boolean;
   Cost : integer;
  begin
    Emu_Color(15,0);
    Emu_gotoxy(20,16);
    Str(Player[PN].Tires,St);
    St:=St+'% New';
    ComWrite('Your Tires are '+St);
    Emu_gotoxy(20,17);
    ComWrite('Want to Buy New Tires ??');
    GetYN(Doit);
    if Doit then
     begin
      Emu_gotoxy(20,18);
      Cost :=1000 + (10*(100-Player[PN].Tires));
      IF Player[PN].Money > Cost then
      begin
       Player[PN].Money:=Player[PN].Money-Cost;
       Player[PN].Tires:=100;
       ComWrite('The New Tires Cost You  $'+ CommaPut(Cost));
       ShowContender1
      end
      else
       begin
        ComWrite('You Don''t Have Enough Money!!!' )
       end;
       Emu_Gotoxy(20,20);
       Emu_Color(15,0);
       ComWrite('Press [Enter]');
       GetEnterKeyNC;
       If ReqChat then
        begin
         Chat;
         Redraw
        end
     end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.BuyEngine(var Aborted : boolean);
  var
   St : string;
   Doit      : Boolean;
   Cost      : Longint;
   NewEngNum : byte;
   ExtraCost : Real;
  begin
    ExtraCost := Random * (Player[PN].Money/10);

    NewEngNum:=Player[PN].Engine+1;
    If NewEngNum >8 then NewEngNum :=8;
    If NewEngNum <2 then NewEngNum :=1;
    Emu_Color(15,0);
    Emu_gotoxy(20,16);
    Str(Player[PN].EngineWear,St);
    St:=St+'% New';
    ComWrite('Your Current Engine is '+St);
    Doit:=false;
    Aborted :=false;
   while ONline And Not GoOffLine and Not Doit And (NewEngNum>0)
         and Not Aborted do
   begin
    Emu_gotoxy(20,17);
    ComWrite('Buy a New ');
    Emu_Color(14,0);
    ComWrite(EnginType[NewEngNum]);
    if Player[PN].Money > 100000000 then
     Cost :=EngPrice[NewEngNum]+round(ExtraCost)
    else
    if Player[PN].Money > 50000000 then
     Cost :=EngPrice[NewEngNum]+round(ExtraCost/5)
    else
    if Player[PN].Money > 10000000 then
     Cost :=EngPrice[NewEngNum]+round(ExtraCost/10)
    else
     Cost :=EngPrice[NewEngNum];
    Emu_gotoxy(20,18);
    Emu_ClearToEndOfLine;
    Emu_gotoxy(20,18);
    Emu_Color(15,0);
    ComWrite('For  $'+CommaPut(Cost));
    GetYNQ(Doit,Aborted,True);
    if Not Aborted then
    begin
    if Doit then
     begin
      Emu_gotoxy(20,19);
      IF Player[PN].Money > Cost then
      begin
       Player[PN].Money:=Player[PN].Money-Cost;
       Player[PN].Engine:=NewEngNum;
       Player[PN].EngineWear:=100;
       ComWrite('You Got it!!' );
       ShowContender1
      end
      else
       begin
        ComWrite('You Don''t Have Enough Money!!!' )
       end;
       Emu_Gotoxy(20,20);
       Emu_Color(15,0);
       ComWrite('Press [Enter]');
       GetEnterKeyNC;
       If ReqChat then
        begin
         Chat;
         Redraw
        end
     end;
     NewEngNum:=NewEngNum-1;
    end
   end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure AddNews(Racey,Racer :NameStr; RaceyMoney : real);
 Var
   NewsFile : text;
  begin
   if pos('Computer',Racey) =0 then
    begin
     if Not Exist('RaceNews.Dta') then
      begin
       Assign(NewsFile,'RaceNews.Dta');
       Rewrite(NewsFile)
      end
     else
      begin
       Assign(NewsFile,'RaceNews.Dta');
       Append(NewsFile)
      end;
     Writeln(NewsFile, Racey,Racer,RaceyMoney);
     Close(NewsFile)
    end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXbbs.ShowNews;
 Var
   NewsFile : text;
   NewFile  : text;
   Racer    : NameStr;
   Racey    : NameStr;
   Amount   : Real;
   FrstFound: Boolean;
   AmtStr   : String;

  begin
   Emu_Color(14,0);
   Emu_ClearScreen;
   FrstFound := true;
   if Exist('RaceNews.Dta') then
    begin
     Assign(NewsFile,'RaceNews.Dta');
     Reset(NewsFile);
     Assign(NewFile,'RaceNews.Tmp');
     ReWrite(NewFile);
     while (Not Eof(NewsFile)) and Online and Not GoOffLine and (DosError=0) do
     begin
      Readln(NewsFile,Racey,Racer,Amount);
      if Racey = Player[PN].Name then
       begin
        if FrstFound then
         begin
          FrstFound:=false;
          ComWriteln('');
          ComWriteln('                          BBS Drag Racing Version'+Vrs);
          Emu_Color(12,0);
          ComWriteln('');
          ComWriteln('                          W H A T    H A P P E N E D ???');
          Emu_Color(11,0);
          ComWriteln(' ____________________________________________________________________________');
          ComWriteln('');
          Emu_Color(15,0)
         end;
         if Amount >0 then
          begin
           Emu_Color(14,0);
           ComWrite(' You got Raced by ');
           Emu_Color(11,0);
           ComWrite(Racer);
           Emu_Color(15,0);
           ComWrite(' You Won  ');
           Emu_Color(10,0);
           ComWriteln('$'+CommaPut(Amount)+'.')
          end
         else
          begin
           Emu_Color(14,0);
           ComWrite(' You got Raced by ');
           Emu_Color(11,0);
           ComWrite(Racer);
           Emu_Color(13,0);
           ComWrite(' You Lost ');
           Emu_Color(12,0);
           ComWriteln('$'+CommaPut(-1*Amount)+'.')
          end
       end
      else
       Writeln(NewFile,Racey,Racer,Amount)
     end;
     Close(NewFile);
     Close(NewsFile);
     Erase(NewsFile);
     Rename(NewFile,'RaceNews.Dta')
    end;
   if Not FrstFound then
   begin
     ComWriteln('');
     GetCr(15);
   end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.BuyCar;
  var
   St : string;
   Doit : Boolean;
   Cost : Longint;
   NewCarNum : byte;
  begin
    NewCarNum:=Player[PN].Car+1;
    If NewCarNum >8 then NewCarNum :=8;
    Doit:=false;
    while ONline And Not GoOffLine and Not Doit And (NewCarNum>0) do
   begin
    Emu_Color(15,0);
    Emu_gotoxy(20,17);
    ComWrite('Buy a New ');
    Emu_Color(14,0);
    ComWrite(CarType[NewCarNum]);
    Str(CarPrice[NewCarNum],St);
    St:='$'+St;
    Emu_gotoxy(20,18);
    Emu_ClearToEndOfLine;
    Emu_gotoxy(20,18);
    Emu_Color(15,0);
    ComWrite('For  $'+CommaPut(CarPrice[NewCarNum]));
    GetYN(Doit);
    if Doit then
     begin
      Emu_gotoxy(20,19);
      Cost :=CarPrice[NewCarNum];
      IF Player[PN].Money > Cost then
      begin
       Player[PN].Money:=Player[PN].Money-Cost;
       Player[PN].Car:=NewCarNum;
       ComWrite('You Got it!!' );
       ShowContender1
      end
      else
       begin
        ComWrite('You Don''t Have Enough Money!!!' )
       end;
       Emu_Gotoxy(20,20);
       Emu_Color(15,0);
       ComWrite('Press [Enter]');
       GetEnterKeyNC;
       If ReqChat then
        begin
         Chat;
         Redraw
        end
     end;
     NewCarNum:=NewCarNum-1;
    end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure MoveCars(Var Loc1,Loc2,Erc1,Erc2:integer);
 var
  Adv1, Adv2 : integer;
 begin

 if (Loc1<18) and (Loc2<18) and (Erc1=0) then
  begin
     with Player[PN] do
     begin
      Adv1 := 1000+((car*15)+(Engine*30)+(EngineWear*2)+(Tires*10))-Fuel;
      if (Random*Adv1>450) or (Erc2>0) then
       begin
        IF (Random*100)>8 then Fuel:=Fuel-(1+((Car+Engine) div 8));
        if Fuel <0 then
         begin
          Erc1:=2;
          Fuel:=0
         end
         else
         Loc1:=Loc1+1
       end
     end
  end;
 if (Loc2<18) and (Loc1<18) and (Erc2=0) then
  begin
     with Player[PN2] do
     begin

      Adv2 := 1000+((car*14)+(Engine*28)+(EngineWear*2)+Tires)-Fuel;
      if (Random*Adv2>470) or (Erc1>0) then
       begin
        IF (Random*100)>8 then Fuel:=Fuel-(1+((Car+Engine) div 9));
        if Fuel <0 then
         begin
          Erc2:=2;
          Fuel:=0
         end
         else
         Loc2:=Loc2+1
        end
     end
  end;
 delay(20)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 Procedure XXBBS.DoRace;
 var
  St          : String;
  Ready       : Boolean;
  RedLight    : Boolean;
  ERC1,ERC2   : integer;
  Loc1,Loc2   : integer;
  Loc1s,Loc2s : integer;
  WaitCnt     : integer;

 begin
  Loc1:=1;
  Loc2:=1;
  RedLight:=false;
  Emu_Gotoxy(20,20);
  Emu_Color(11,0);
  if Player[PN].Wager>Player[PN].Money then Player[PN].Wager:=Player[PN].Money;
  ComWrite('Your Wager $'+CommaPut(Player[PN].wager));
  Emu_Gotoxy(20,18);
  Emu_Color(15,0);
  ComWrite('Ready to RACE ??? ');
  GetYN(Ready);
  Emu_Gotoxy(20,18);
  Emu_Color(15,0);
  ComWrite(' ');
  Emu_ClearToEndOfLine;
  Emu_Gotoxy(20,20);
  Emu_Color(15,0);
  Emu_ClearToEndOfLine;
  if Ready then
  begin
  if Player[PN].Money >100000000 then
  begin
   if (Random*30) > 27 then Player[PN].Tires:=Player[PN].Tires-45
   else
     if (Random*30) >=28 then Player[PN].EngineWEAR:=Player[PN].EngineWEAR-45;
  end
  else
  if Player[PN].Money >10000000 then
  begin
   if (Random*40) > 37 then Player[PN].Tires:=Player[PN].Tires-45
   else
     if (Random*40) >=38 then Player[PN].EngineWEAR:=Player[PN].EngineWEAR-45;
  end;
 if Player[PN].wager >0 then
  begin
   Emu_Gotoxy(20,20);
   Emu_Color(11,0);
   ComWrite('Your Wager $'+CommaPut(Player[PN].wager))
  end;
  Emu_Gotoxy(20,22);
  Emu_Color(10,0);
  ComWrite('Press <Enter> on Green Light');
  ClearReceive;
  Emu_Gotoxy(9,18);
  Emu_Color(14,7);
  ComWrite('฿');
  Emu_Gotoxy(9,19);
  Emu_Color(7,7);
  ComWrite(' ');
  delay(800);
  RedLight := ChWaiting or KeyPressed;
  Emu_Gotoxy(9,18);
  Emu_Color(14,7);
  ComWrite('Ü');
  delay(800);
  RedLight := ChWaiting or KeyPressed;
  Emu_Gotoxy(9,18);
  Emu_Color(14,7);
  ComWrite(' ');
  Emu_Gotoxy(9,19);
  Emu_Color(14,7);
  ComWrite('฿');
  delay(800);
  RedLight := ChWaiting or KeyPressed;
  Emu_Gotoxy(9,19);
  Emu_Color(10,7);
  ComWrite('Ü');
  RedLight := ChWaiting or KeyPressed;
  Emu_Gotoxy(20,22);
  Emu_Color(15,0);
  ComWrite(' ');
  Emu_ClearToEndOfLine;
  if Not Keypressed or ChWaiting then ERC1:=5 else Erc1:=0;
  Erc2:=0;
  if RedLight then
   begin
    Erc1:=1;
    Emu_Gotoxy(9,19);
    Emu_Color(10,4);
    ComWrite('Ü');
    Emu_Color(15,0);
   end;

  with Player[PN] do
   begin
    if Tires<50 then Erc1 :=3;
    if EngineWear<50 then Erc1 :=4;
   end;

  with Player[PN2] do
   begin
    if Tires<15 then Erc2 :=3;
    if EngineWear<19 then Erc2 :=4;
   end;
   WaitCnt :=0;
  while (Loc1<18) and (Loc2<18) and ((Erc1=0) or (Erc1=5) or (Erc2=0))
  and Online and not GoOffLine  and (waitcnt <5000) do
    begin
     WaitCnt:=WaitCnt+1;
     if Erc1=5 then
      begin
       delay(250);
       if GetBps =1200 then Delay(500);
       if Chwaiting or Keypressed then
        begin
         ClearReceive;
         While Keypressed do if readkey =#13 then delay(10);
         Erc1:=0;
        end
      end;
     if (GetBps >2400) or Local then Delay(50);
     Loc1s:=Loc1;
     Loc2s:=Loc2;
     MoveCars(Loc1,Loc2,Erc1,Erc2);
     if Loc1s <>Loc1 then
      begin
       HideCar(1,Loc1s);
       ShowCar(1,Loc1,Car1C);
      end;
     if Loc2s <>Loc2 then
      begin
       HideCar(2,Loc2s);
       ShowCar(2,Loc2,Car2C);
      end;
    end;
   if Erc1 >0 then
    begin
     Emu_Gotoxy(20,17);
     Case Erc1 of
      1: begin
          Emu_Color(12,0);
          ComWrite('You REDLIGHTED !!!!');
         end;
      2: begin
          Emu_Color(14,0);
          ComWrite('You RAN OUT OF GAS !!!!');
         end;
      3: begin
          Emu_Color(13,0);
          ComWrite('You had a TIRE BLOW OUT !!!!');
         end;
      4: begin
          Emu_Color(11,0);
          ComWrite('You BLEW Your ENGINE !!!! ');
         end;
      end
    end;

  with Player[PN] do
   begin
    Tires:=Tires- ((Car+Engine) div 2);
    EngineWear:=EngineWear-(1+((Car+Engine) div 3));
    if Tires<0 then Tires:=0;

    if Erc1=4 then
     begin
      EngineWear:=0;
      Engine:=Engine-2;
      if Engine<1 then Engine:=1
     end
   end;

   if Erc2 >0 then
    begin
     Emu_Gotoxy(20,18);
     Case Erc2 of
      1: begin
          Emu_Color(12,0);
          ComWrite(Copy(Player[PN2].Name,1,pos('  ',Player[PN2].Name))+' REDLIGHTED !!!!');
         end;
      2: begin
          Emu_Color(14,0);
          ComWrite(Copy(Player[PN2].Name,1,pos('  ',Player[PN2].Name))+' RAN OUT OF GAS.');
         end;
      3: begin
          Emu_Color(13,0);
          ComWrite(Copy(Player[PN2].Name,1,pos('  ',Player[PN2].Name))+'''s TIRE BLEW.');
         end;
      4: begin
          Emu_Color(11,0);
          ComWrite(Copy(Player[PN2].Name,1,pos('  ',Player[PN2].Name))+'''s ENGINE BLEW.');
         end;
      end{case}
    end;

  with Player[PN2] do
   begin
    if Fuel<(15+Car+Engine) then Fuel :=Engine+Car+70+(round(Random*15));
    Tires:=Tires- ((Car+Engine)div 4);
    EngineWear:=EngineWear-(1+(Car div 3));
    if Tires<0 then Tires:=60+round(random*30);
    if EngineWear<8 then EngineWear:=60+round(random*30)
   end;

  if (Erc1=0) and (Loc1=18) then
   begin
    Emu_Gotoxy(20,16);
    Emu_Color(15,0);
    ComWrite('You WIN !!!!');
    Emu_Gotoxy(20,19);
    Emu_Color(10,0);
    ComWrite('You Collect $10,000');
    Player[PN].Money:=Player[PN].Money+10000;
    Player[PN].WON:=Player[PN].WON+1;
    Player[PN2].LOST:=Player[PN2].LOST+1;
    if Player[PN].Wager >0 then
    begin
     Emu_Gotoxy(20,20);
     Emu_Color(10,0);
     if TypWager=1 then
     ComWrite('The Track Paid You $'+CommaPut(Player[PN].wager)+'   ')
     else
     begin
      ComWrite('Your Opponent Paid You $'+CommaPut(Player[PN].wager)+'      ');
      AddNews(Player[PN2].Name,Player[PN].Name,(-1 * Player[PN].Wager))
     end;
     Player[PN].Money :=Player[PN].Money+Player[PN].Wager;
     If Typwager =2 then Player[PN2].Money :=Player[PN2].Money-Player[PN].Wager;
     Player[PN].Wager:=0
    end;
    if Typwager=2 then ShowContender2
   end;

  if (Erc2=0) and (Loc2=18) then
   begin
    Emu_Gotoxy(20,16);
    Emu_Color(15,0);
    ComWrite(Copy(Player[PN2].Name,1,pos('  ',Player[PN2].Name))+' WINS !!!!');
    Player[PN2].Money:=Player[PN2].Money+10000;
    AddNews(Player[PN2].Name,Player[PN].Name,10000);
    Player[PN2].WON:=Player[PN2].WON+1;
    Player[PN].LOST:=Player[PN].LOST+1;

    if Player[PN].Wager >0 then
    begin
     Emu_Gotoxy(20,20);
     Emu_Color(10,0);
     ComWrite('You Paid $'+CommaPut(Player[PN].wager)+'          ');
     Player[PN].Money :=Player[PN].Money-Player[PN].Wager;
     If Typwager =2 then
      begin
       Player[PN2].Money :=Player[PN2].Money+Player[PN].Wager;
       AddNews(Player[PN2].Name,Player[PN].Name,Player[PN].Wager)
      end
     else
     begin
      if (Random*5.1) > 3 then
       begin
        Player[PN2].Money :=Player[PN2].Money+Player[PN].Wager;
        Emu_Gotoxy(20,21);
        Emu_Color(11,0);
        ComWriteln('The Track Gave The Money To '+Player[PN2].name);
        AddNews(Player[PN2].Name,Player[PN].Name,Player[PN].Wager);
       end
     end;
     Player[PN].Wager:=0
    end;
    ShowContender2
   end;
   ClearReceive;
   While KeyPressed do if Readkey=#13 then Delay(10);
   Player[PN].RaceCnt:= Player[PN].RaceCnt+1;
   ShowContender1;
   Emu_Color(15,0);
   Emu_Gotoxy(20,22);
   ComWrite('Press [Enter]');
   GetEnterKeyNC;
   If ReqChat then
    begin
     Chat;
     Redraw
    end;
   ClearMenu;
   drawtrack;
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.GetNum(var Num: real; MaxVal: real);
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
  While (C<>#13) and online and not GoOffLine And Not ReqChat do
  begin
   GetChar(C,['0'..'9',#13,#8,#127]);
   case C of
   '0'..'9' : begin
               if (Num*10)<=(Maxval+11) then St:=St+C;
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
 Procedure XXBBS.MakeWager;
  var
    MaxWager  : real;
    C         : Char;
    St        : String;
 begin
  Emu_Gotoxy(20,16);
  Emu_color(15,0);
  ComWrite(' Placing a Wager....');
  Emu_Gotoxy(20,18);
  Emu_color(15,0);
  ComWrite(' 1. Place Wager With Track');
  Emu_Gotoxy(20,19);
  Emu_color(15,0);
  ComWrite(' 2. Place Wager With Opponent');
  Emu_Gotoxy(20,21);
  Emu_color(14,0);
  ComWrite(' Selection? ');
  GetChar(C,['1','2']);

  ClearMenu;
   case C of
   '1': begin
         Emu_Gotoxy(20,16);
         Emu_color(15,0);
         ComWrite(' Placing a Wager with the Track.');
         MaxWager :=Player[PN].Money;
         if Maxwager > 500000 then MaxWager:=500000;
         if Player[PN].Money > 1000000 then MaxWager:= Player[PN].money / 2;
         if MaxWager>8500000 then
          begin
           if (random * 10 ) > 5 then
            MaxWager :=8500000
           else
            MaxWager :=15000000
          end;
         Emu_Gotoxy(20,18);
         ComWrite(' Max Bet = $'+CommaPut(MaxWager));
         Emu_Gotoxy(20,19);
         ComWrite(' Enter Wager Amount..$ ');
         GetNum(Player[PN].Wager,MaxWager);
         ClearMenu;
         TypWager:=1
        end;
   '2': begin
         Emu_Gotoxy(20,16);
         Emu_color(15,0);
         ComWrite('A Wager with '+Copy(Player[PN2].Name,1,pos('  ',Player[PN2].Name)));
         MaxWager :=Player[PN2].Money / 10;
         if Maxwager > Player[PN].Money then MaxWager:=Player[PN].Money;
         if MaxWager>20000000 then MaxWager :=20000000;
         Str(round(MaxWager),St);
         Emu_Gotoxy(20,18);
         ComWrite(' Max Bet = $'+CommaPut(MaxWager));
         Emu_Gotoxy(20,19);
         ComWrite(' Enter Wager Amount..$ ');
         GetNum(Player[PN].Wager,MaxWager);
         ClearMenu;
         TypWager:=2
        end;
   end{case}
  
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.Redraw;
 begin
   Emu_color(15,0);
   Emu_clearScreen;
   DrawTrack;
   ShowLogo;
   Showmsr;
   ShowContender1;
   ShowContender2;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.MainFlow;
  var
    C       : char;
    AN      : integer;
    Aborted : Boolean;
    ABCount : Integer;

 begin
  checkTimeLeft;
  AbCount :=0;
  if Online and Not GoOffLine then
  begin
   Redraw;
   C:=#0;
   AN:=0;
   while Online and Not GoOffLine and (C<>'Q') do
   begin
   If ReqChat then
    begin
     Chat;
     Redraw;
    end;
    ShowRaceMenu;
    QUIT     :=false;
    Emu_Color(15,0);
    Emu_gotoxy(26,22);
    ComWrite('Selection?  ');
    if Player[PN].RaceCnt<RacePerDay then
     begin
      if Player[PN].Wager =0 then
       GetChar(C,['Q','B','W','S','G'])
      else
       GetChar(C,['Q','B','S','G'])
     end
    else GetChar(C,['Q','G']);
    if C<>'Q' then ClearMenu;
    case C of
      'W' : MakeWager;
      'B' : begin
             DoRace;
             AbCount :=0;
            end;
      'S' : begin
             SelectOpp;
            end;
      'G' : begin
             C:=#0;
             while Online and Not GoOffLine and (C<>'Q') do
             begin
              ShowPitMenu;
              Emu_Color(15,0);
              Emu_gotoxy(26,23);
              ComWrite('Selection?  ');
              GetChar(C,['Q','L','T','F','C','E']);
              If ReqChat then
               begin
                Chat;
                Redraw;
                ShowPitMenu;
               end;
              ClearMenu;
              case C of
               'L' : begin
                      ShowCarInfo;
                      ClearMenu;
                    end;
               'F' : begin
                      BuyFuel;
                      ClearMenu;
                    end;
               'T' : begin
                      BuyTires;
                      ClearMenu;
                    end;
               'E' : begin
                      if AbCount > 5 then
                       begin
                        ClearMenu;
                        Emu_color(12,0);
                        Emu_GotoXy(26,17);
                        ComWrite(' The Engine Dealer Gets Tired of You Bugging');
                        Emu_GotoXy(26,18);
                        ComWrite(' him and Locks the door.  ');
                        Emu_GotoXy(26,21);
                        Emu_Color(15,0);
                        ComWrite(' Press [Enter]');
                        GetEnterKeyNC;
                        ClearMenu;
                        If ReqChat then
                          begin
                            Chat;
                            Redraw;
                            ShowPitMenu;
                          end;
                       end
                       else
                      begin
                       BuyEngine(Aborted);
                       ClearMenu;
                       If Aborted then AbCount :=AbCount +1
                      end
                    end;
               'C' : begin
                      BuyCar;
                      ClearMenu;
                      AbCount :=0;
                    end;
              end {case}
             end;
             C:=#0
            end
    end {case}
   end;
   If AN<>0 then
    begin
     Player[AN] := Player[PN2];
     AN:=0
    end
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure InitPlayer;
 begin
   Randomize;
   TypWager :=1;
   Car1C:=Round(1+(Random*5));
   Car2C:=Round(1+(Random*5));
   with Player[PN] do
    begin
     Name       :=PName;
     Money      :=10000;
     Car        :=1;
     Engine     :=1;
     EngineWear :=100;
     Fuel       :=100;
     Tires      :=100;
     Wager      :=0;
     Won        :=0;
     Lost       :=0;
     RaceCnt    :=0;
     PlyrDate :=Date
    end;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.RUNX;
 var
  C : Char;
  Yhit : boolean;
  NewPlayer : boolean;

 begin
  SHOWMSR;
  C:=#0;
  TextColor(7);
  ComWriteln('');
  ComWrite('BBS Drag Racing  Ver.');
  ComWriteln(Vrs);
  if Local then
   begin
    Emu_Color(14,0);
    ComWriteln('Local Mode Enabled... ');
    Delay(1000);
    Yhit :=true
   end;

  NewGame :=False;
  DateChk;
  GetPlayers;
 if NewGame then
  begin
   Emu_Color(15,0);
   ComWriteln(' ');
   ComWriteln('Welcome to BBS Drag Racing ..');
   ComWriteln('Player File Initialized.. ');
   PlayerCnt :=1;
   ResetPuter(1);
   SavePlayers;
   GetCr(14);
  end;
  if Not PlayerFound then
   begin
    PLayerCnt :=PLayerCnt +1;
    If PLayerCnt>300 then  PLayerCnt :=300;
     PN :=PLayerCnt;
     InitPlayer;

   if Not Local then
    begin
     TTYPE :=2;
     ComWriteln('');
     ComWriteln('Detecting Ansi...');
     Yhit :=DetectAnsi;
     delay(500);
     if Not Yhit then
      begin
       ComWrite('Are You Using ANSI Graphics ?? ');
       getYn(Yhit);
       TTYPE :=1
      end
    end
   else Yhit :=true;

  if Not Yhit then
   begin
    ComWriteln('');
    ComWriteln(' Sorry. This Door Requires the Use of ANSI Graphics.... ');
    delay(2000);
    ComWriteln('');
    ComWriteln(' Returning to '+Brec.BBSName);
    delay(1000);
   end
  end
  else
   begin
    Yhit :=true;
    Delay(1000)
   end;
 if  Yhit and OnLine And not GoOfflIne then
 begin
  repeat
  if (Online and Not GoOffLine) then
  MainMenu;
  Emu_Color(15,0);
  ComWriteln('');
  ComWrite(' Selection? =>');
  Getchar(C,['G','H','Y','R','I','Q']);
  if ReqChat then Chat
  else
  begin
  if (Online and Not GoOffLine) then
    begin
     case C of
      'G' : begin
             ShowNews;
             QuitNow:=false;
             MainFlow;
            end;
      'R' : begin
             ShowRankings;
            end;
      'H' : begin
             ShowHallFame;
            end;
      'I' : begin
             Instructions;
            end;
      'Y' : begin
             ShowStatus;
            end;
      end {case}
    end
   end;
  until (C='Q') or Not Online or GoOffLine;
  end;
  SHOWMSR;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.DateChk;
  var
   DFile    : text;
   HOFFILE  : text;
   TMPFile  : Text;
   Datstr   : String[8];
   HofPyrName : NameStr;
   Bucks      : Real;
   DumChar    : Char;
   Count      : Integer;
   Added      : Boolean;
   I          : Integer;
 begin
  Added :=False;
  {$I-}
   if Not Exist('Datefil.Dat') then
   begin
    assign(Dfile,'Datefil.Dat');
    ReWrite(DFile);
    Writeln(Dfile,Date);
    Close(Dfile)
   end
   else
   begin
    assign(Dfile,'Datefil.Dat');
    Reset(DFile);
    Readln(Dfile,DatStr);
    Close(Dfile);
    if DatStr <> Date then
     begin
      GetPlayers;
      for I := 1 to PlayerCnt do
       with Player[I] do
       begin
        if Money <5000 then Money :=5000;
        RaceCnt :=0;
        if Engine =0 then Engine:=1
       end;
       SavePlayers
     end;
    ReWrite(DFile);
    Writeln(Dfile,Date);
    Close(Dfile);
    if Copy(DatStr,1,2)<> Copy(Date,1,2) then
     begin
      NewGame :=True;
      getplayers;
      if playerCnt>1 then
      begin
       ShellSort(Player,PlayerCnt);
       if Exist('Plyrfile.Dta') then
        begin
         Assign(Dfile,'Plyrfile.Dta');
         Erase(Dfile);
         if Exist('RaceNews.Dta') then
          begin
           Assign(Dfile,'RaceNews.Dta');
           Erase(Dfile)
          end
        end
      end;
      if not exist('Race.Hof') then
       begin
        Assign(HOFFile,'Race.Hof');
        Rewrite(HOFFile);
        Writeln(HoFFile, Player[1].Name,' ', ROUND(Player[1].Money),' ',Date);
        close(HOFFile);
        ComWriteln('');
        ComWriteln(' Last Month''s Hall of Famer.... '+Player[1].Name)
       end
       else
       begin
        Assign(HOFFile,'Race.Hof');
        Assign(TMPFile,'Race.Tmp');
        Reset(HOFFile);
        ReWrite(TMPFile);
        Count :=0;
      while (Not Eof(HofFile)) and (Count <15) do
       begin
        Count :=Count +1;
        Readln(HoFFile, HofpyrName,DumChar, Bucks,DumChar,Datstr);
        if (Player[1].Money >Bucks) and Not Added then
         begin
          Writeln(TmpFile, Player[1].Name,' ', (Player[1].Money),' ',Date);
          Writeln(TmpFile, HofpyrName,' ', Bucks,' ',Datstr);
          ComWriteln('');
          ComWriteln(' Last Month''s Hall of Famer.... '+Player[1].Name);
          Added:=true
         end
        else
         Writeln(TmpFile, HofpyrName,' ', Bucks,' ',Datstr)
       end;
        if (Not Added) and (Count <15) then
         begin
          Writeln(TmpFile, Player[1].Name,' ', (Player[1].Money),' ',Date);
          ComWriteln('');
          ComWriteln(' Last Month''s Hall of Famer.... '+Player[1].Name);
         end;
        close(HOFFile);
        close(TmpFile);
        Erase(HOFFile);
        Rename(TmpFile,'Race.Hof')
       end
     end
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure GetData(var BR : BBSData; var ComNum : Byte; Var BD : LongInt;
                   var Lcl : Boolean);
 var
  ConfigFile : text;
  boovar     : byte;
  UFILE      : string[13];
  FirstName  : string[20];
  FNLN       : integer;
  LNLN       : integer;
  BRLN       : integer;
  TLLN       : integer;
  TULN       : integer;
  I          : integer;
  SecTime    : real;
  LocChk     : String;

 begin
 With BR do
 begin
  RN:='';
  BBSNAME:='';
  SYSOPNAME :='';
  UName     :='';
  GetDir(0,BBSDir);
  UseRTS :=true;
  USeCTS :=true;
 if paramcount > 0 then
  begin
   LCL:=TRUE;
   UNAME:= paramStr(1)+' '+paramStr(2);
   FORMATNAME(UNAME);
   BBSNAME:='DOS';
   SYSOPNAME:='';
   TIMELIMIT:=60;
   TIMEUSED:=0;
   ComNum  :=0;
   BD:=0;
  end;
  assign(ConfigFile,'BBSRace.CFG');
  reset(ConfigFile);
  if IoResult <>0 then
   begin
    Writeln;
    Writeln('BBSRace.CFG File Not Found ... Execution Halted.');
    if Not Lcl then
     Writeln('To Run Local type "BBSRace Your Name"');
    halt(1)
   end
   else
    begin
     readln(Configfile,RN);
     readln(Configfile,COMNUM);
     if Not Lcl then
      readln(Configfile,BD)
     else
      readln(Configfile);
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
     close(Configfile);
    end;
  if Not Lcl then
  begin
  {$I-}
  if Exist(BBSDir+'\*.*') then
  begin
   while BBSDIR[length(BBSDIR)] =' ' do delete( BBSDIR,length(BBSDIR),1);
   assign(ConfigFile,BBSDIR+'\'+UFILE);
   reset(ConfigFile);
  {$I+}
  if IoResult <>0 then
   begin
    Writeln;
    Writeln('No USER file ',BBSDIR+'\'+UFILE,' ... Execution Halted ');
    Writeln('To Run Local type "BBSRace Your Name" ');
    halt(1)
   end
   else
    if Not Lcl then
    begin
     While Not Eof(ConfigFile) do
      begin
       Readln(ConfigFile,LocChk);
     if Pos('COM0', upper(LocChk)) >0 then Lcl :=true;
    end;
    reset(ConfigFile);
    if FNLN>1 then for I:=1 to FNLN-1 do  readln(Configfile);
     readln(Configfile,FirstNAME);
     I:=1;
     while FirstName[I]<>' ' do I:=I+1;
     firstname:= copy(FirstName,1,I);
     reset(ConfigFile);
     if LNLN>1 then for I:=1 to LNLN-1 do  readln(Configfile);
     readln(Configfile,Uname);
     I:= pos(FirstName,Uname);
     if I>0 then delete(Uname,I,length(FirstName));
     Uname:=FirstName+' '+Uname;
     FormatName(UNAME);
     reset(ConfigFile);
     if BRLN>1 then for I:=1 to BRLN-1 do  readln(Configfile);
     readln(Configfile,BD);
     reset(ConfigFile);
    if TLLN>1 then
      begin
       for I:=1 to TLLN-1 do  readln(Configfile);
       if pos('CHAIN.TXT',Upper(Ufile))> 0
        then
         begin
          readln(Configfile,SecTime);
          TIMELIMIT := round(SecTime/60)
         end
         else readln(Configfile,TIMELIMIT)
      end;
     reset(ConfigFile);
     if TULN>1 then
      begin
       for I:=1 to TULN-1 do  readln(Configfile);
       readln(Configfile,TIMEused)
      end;
     close(Configfile)
    end
   end
   end
  end;
  if IORESULT <>0 then
   begin
    Writeln('I/O ERROR..');
    Delay(1000)
   end

 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 VAR
  code       : integer;
  Savem      : boolean;
  BBRec      : BBSData;
  CPort      : Byte;
  BDRate     : LongInt;
  Lcl        : Boolean;

BEGIN
 Savem :=false;
 XXX.UserInit;
 GetData(BBRec,Cport,BDRate,Lcl);
 XXX.Local :=true;
 XXX.INIT(Cport,BDRate,BBRec,Lcl);
 XXX.RUN;
 XXX.INITIALIZE;
 PName :=XXX.Brec.Uname;
 XXX.CheckRegistered(XXX.BRec);
 XXX.Emu_ClearScreen;
 XXX.SHOWMSR;
 if (XXX.ONLINE) then
  begin
   XXX.Clearreceive;
   XXX.BRec.StartTime:=XXX.TimeNow;
   XXX.SHOWMSR;
   IF (XXX.ONLINE and Not XXX.GoOffLine) or (XXX.Local) Then XXX.RUNX;
   if XXX.Online then
   begin
    XXX.emu_gotoxy(1,23);
    XXX.Emu_Color(12,0);
    if XXX.TimeLeft<2 then
    XXX.COMWRITELN('Time Limit Exceeded....');
    XXX.Emu_Color(15,0);
    XXX.COMWRITELN('Returning to '+XXX.Brec.BBSNAME);
    XXX.SHOWMSR
   end;
 end;
 if not XXX.Online then
  begin
   writeln('No Carrier Detected');
   delay(500)
  end;
 SavePlayers;
 XXX.Emu_Color(15,0);
 XXX.ComWrite(' ');
 XXX.DONE;
 TextColor(15);
 TextBacKground(0);
END.
