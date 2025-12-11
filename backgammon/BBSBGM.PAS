{$M 16384,0,653600}

PROGRAM BBSbgm;

uses crt,DOS,BBSGAME;
const
 vrs = ' 2.52';

TYPE
  CharSet    = set of Char;
  Board = array[-10..36] of integer;
  NAMESTRING =string[25];

  Player = record
             Name  : NameString;
             color : byte;
             pntr  : integer;
           end;


  XXBBS = OBJECT(TBBS)
           procedure InitBd;
           procedure Putpip(C,I: integer);
           procedure Pickpip(I: integer);
           procedure showpieces(C1,C2 : integer);
           procedure DrawBoard;
           procedure ShowDice;
           procedure RollDice;
           procedure GetStarter(var NM: boolean);
           procedure MainFlow;
           procedure SelectPlayerColor;
           procedure Instructions;
           procedure UpdateBar;
           procedure UpdateStart;
           procedure UserInit;
           procedure ShowRankings;
           procedure Player1Wins;
           procedure Player2Wins;
           procedure ReadlnX(var ST : string; L : integer; Pas : boolean);
           procedure GetCmd(var Ychar : char; Cset: CharSet);
           procedure Initialize;
           procedure HidePointer;
           procedure HidetoPointer;
           procedure ShowPointer;
           procedure ShowtoPointer;
           procedure GetCMove(var FW,TW : Integer;var NM : boolean);
           procedure GetPMove(var FW,TW : Integer;var NM : boolean);
           procedure CheckRegistered;
           procedure PickDoubles;
           procedure CPickDoubles;
           procedure TakeTurn;
           procedure mainmenu;
           procedure ShowCmds;
           procedure RUNX;
           procedure GetData;
           Function PlayerFound : Boolean;
          end;
var
  FirstRoll  : Boolean;
  Auto       : Boolean;
  GameOver : boolean;
  COMNUM     : integer;
  BAUD       : Longint;
  SysOpName  : String;
  BBSNAME    : String[25];
  BBSDIR     : String[25];
  RN         : String[25];
  Pn         : integer;
  Bd           : Board;
  Gametype     : byte;
  R1, R2, R3   : byte;
  Quit         : boolean;
  BarMove      : boolean;
  DicePick     : byte;
  DoubleFlag   : boolean;
  PLYR1,PLYR2  : Player;
  P2IsComputer : Boolean;
  UseRTS       : Boolean;
  UseCTS       : Boolean;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.CheckRegistered;
 const
   AuthorName ='Chris Neubauer';
 var
   Code       : String;
   I,LSN      : integer;
   Sum        : Integer;

 begin
  Code:='';
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
   for I:=1 to LSN do
    Begin
     Sum := ord(SysOpName[I]) + ord(BBSName[I]);
     Sum:= Sum Mod 21;
     Sum :=Sum+47;
     Code :=Code+Chr(Sum)
    end
  end;

{  Write(RN,'...',Code);}
  Registered :=( RN=Code);
  if Not Registered then
   begin
    textcolor(15);
    Writeln(' BBS BackGammon');
    textcolor(12);
    Writeln(' UNREGISTERED COPY');
    textcolor(14);
    Writeln(' Author:');
    textcolor(11);
    Writeln(' ',AuthorName);
    Writeln(' P.O. Box  1446');
    Write(' Corpus Christi, Tx');
    Writeln('  78403-1446');
    delay(1000)
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.Instructions;
 begin
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    Clrscr;
    emu_color(0,7);
    Comwrite('                     Instructions For Playing BBS BackGammon                   ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    ComWriteln('   This Game of BackGammon is setup so that players are not allowed to make');
    ComWriteln(' Invalid moves.  To Take a turn, simply select [R] for Roll dice, then after ');
    ComWriteln(' The dice have been rolled, simply use the Arrow Keys to select which pip to');
    ComWriteln(' move.  When a MOVE FROM pip has been selected the arrow pointer turns red and');
    ComWriteln(' the player is prompted to select a "MOVE PIP TO" position.  Use the arrow ');
    ComWriteln(' keys to select the desired "TO" position.  Pressing <ENTER> locks in the');
    ComWriteln(' move and Pressing <SPACEBAR> unlocks the Move and allows for another selection');
    ComWriteln(' to be made.');
    emu_color(11,0);
    ComWriteln('');
    ComWriteln('   The Object of the game is to get all of your pips HOME by cleverly selecting');
    ComWriteln(' pips to move and slots to move them to.  Bumping your opponents pips back and');
    ComWriteln(' blocking your opponents pathway are a couple of common strategies used to win.');
    emu_color(15,0);
    ComWriteln('');
    ComWriteln('   The rules of play are straight forward.  If a player has two or more pips');
    ComWriteln(' on any slot then that slot is said to be blocked.  A player will not be ');
    ComWriteln(' allowed to move pips to any location that is blocked by his/her opponent.');
    ComWriteln(' If a player moves a pip to a slot that has just one of his/her opponent''s ');
    ComWriteln(' pips occupying it then the opponents pip will be bumped to the BAR (sent ');
    ComWriteln(' back to the beginning).');
    emu_color(10,0);
    ComWriteln('');
    ComWrite('Press <ENTER>..');
    getenterkey;
    Emu_ClearScreen;
    clrscr;
    showmsr;
    emu_color(0,7);
    Comwrite('                     Instructions For Playing BBS BackGammon                   ');
    ComWriteln('');
    ComWriteln('');
    emu_color(15,0);
    ComWriteln('   Rolling Doubles:  If a player Rolls Doubles then that player will get');
    ComWriteln(' to move 4 times instead of 2.  (Like a Double Turn). ');
    ComWriteln('');
    ComWriteln('   Moving pips to the HOME slot :  Players will not be allowed to move any');
    ComWriteln(' pips to the HOME slot unless all of his/her pips are in the HOME quadrant');
    ComWriteln(' that is in the Last six slots before the HOME slot.');
    ComWriteln('');
    ComWriteln('   Moving pips From the BAR :  Players are required to move all pips off ');
    ComWriteln(' the BAR before any other pip can be moved. ');
    ComWriteln('');
    emu_color(10,0);
    ComWrite('Press <ENTER>..');
    getenterkey;

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
   while pos('  ',Fname)>0 do delete(Fname,pos('  ',Fname),1);
   if length(Fname) >24 then Fname:=Copy(Fname,1,24)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.SelectPlayerColor;
 Var ColrNum : integer;
 CD          : Char;
 begin
  Emu_Color(11,0);
  ColrNum:=10;
  EmU_clearscreen;
  clrscr;
  Comwriteln('');
  Comwriteln('');
  IF GameType =0 then
  begin
   Comwriteln('               าฤฟ  ึฤฤฟ ึฤฤฟ า ฺ  ึฤฤฟ ึฤฤฟ ึฤาฤฟ ึฤาฤฟ ึฤฤฟ ึฤฤฟ');
   Comwriteln('               วฤมฟ วฤฤด บ    วฤมฟ บ ฤฟ วฤฤด บ บ ณ บ บ ณ บ  ณ บ  ณ');
   Comwriteln('               ะฤฤู ะ  ม ำฤฤู ะ  ม ำฤฤู ะ  ม ะ ะ ม ะ ะ ม ำฤฤู ะ  ม');
  end
  else
  begin
   Comwriteln('              ึฤฤฟ ึฤฤฟ าฤฤฟ า  ย     าฤฤฟ าฤฤฟ า  ย ึฤฤฟ าฤฤฟ า  ย ');
   Comwriteln('              วฤฤด บ    วฤ   ำฤฤด ฤฤฤ บ  ณ วฤ   บ  ณ บ    วฤ   ำฤฤด ');
   Comwriteln('              ะ  ม ำฤฤู ะฤฤู ำฤฤู     ะฤฤู ะฤฤู ำฤฤู ำฤฤู ะฤฤู ำฤฤู ');
  end;
  Comwriteln('');
  ComWriteLn('');
  Emu_Color(15,0);
  ComWriteLn(' Use Left/Right Arrow Keys to');
  ComWrite(' Select Your Desired Color....                 ');
  ComWrite('  Opponent''s Color');
  ComWriteLn('');
  Emu_color(Plyr2.Color,0);
  ComWriteLn('');
  ComWriteLn('                                                      ÜÜÜÜÜÜ');
  ComWriteLn('');
  Emu_Color(15,0);
  ComWriteLn(' Press <ENTER> when Done....');
  IF Not Local and P2IsComputer then
  begin
   gotoXy(1,14);
   TextColor(15);
   TextBackground(0);
   Write(' SysOp .. Press [F5] to Join Game..... ');
  end;
  repeat
  EMU_GotoXy(12,11);
  Emu_Color(ColrNum,0);
  ComWrite('ÜÜÜÜÜÜ');
  GetCmd(CD,['M','K',#13]);
  Case Cd of
   'M':begin
        ColrNum:=ColrNum+1;
        if ColrNum >14 then ColrNum :=2;
        if ColrNum =8 then ColrNum :=10
       end;
   'K':Begin
        ColrNum:=ColrNum-1;
        if ColrNum =9 then ColrNum :=7 ;
        if ColrNum <2 then ColrNum :=14
       end
  end;
  Until (Cd=#13) or GoOffLine Or Not Online;
  Plyr1.Color:=ColrNum;
   if JoinIt then
   begin
    Pn:=-1;
    P2IsComputer:=False;
    Emu_gotoXy(1,14);
    Emu_color(15,0);
    Plyr2.Name :=SysopName;
    ComWrite(' '+SysOpName+' ONLINE AND PLAYING LOCAL '+#7+#7);
    JoinIt:=false;
    ColrNum:=Plyr2.color;
   Emu_Color(15,0);
   EMU_GotoXy(45,9);
   ComWrite('                                       ');
   EMU_GotoXy(50,9);
   ComWrite(SysOpName);
   gotoXy(1,8);
   textcolor(15);
   WriteLn('                                   SySop...  Use Left/Right Arrow Keys to');
   WriteLn('                                             Select Your Desired Color....');
   EMU_GotoXy(1,13);
   Emu_Color(15,0);
   ComWriteln(' SysOp Selecting Color Standby....     ');
  repeat
   EMU_GotoXy(55,11);
   Emu_Color(ColrNum,0);
   ComWrite('ÜÜÜÜÜÜ');
   GetCmd(CD,['M','K',#13]);
   Case Cd of
    'M':begin
         ColrNum:=ColrNum+1;
         if ColrNum >14 then ColrNum :=1;
         if ColrNum =8 then ColrNum :=9;
         While ColrNum =Plyr1.Color do
          begin
           ColrNum:=ColrNum +1;
           if ColrNum >14 then ColrNum :=1;
           if ColrNum =8 then ColrNum :=9;
          end;
        end;
    'K':Begin
         ColrNum:=ColrNum-1;
         if ColrNum <1 then ColrNum :=14;
         if ColrNum =8 then ColrNum :=7;
         While ColrNum =Plyr1.Color do
          begin
           ColrNum:=ColrNum -1;
           if ColrNum <1 then ColrNum :=14;
           if ColrNum =8 then ColrNum :=9;
          end
        end
    end;
  Until (Cd=#13) or GoOffLine Or Not Online;
  plyr2.Color:=ColrNum;
  end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetGammonInfo(var G : integer);
  var I : integer;
 begin
  G:=1;
  If Bd[0]>-1 then G:=2;
  I:=26;
  While (Bd[I] > -1) and (I > 0) do I:=I-1;
  if (I >18) and (G=2) then G:=3
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.player1Wins;
 var
  Yhit : boolean;
  RFile : text;
  TFile : text;
  prcent : real;
  prsav  : real;
  gameswon : word;
  gameslost : word;
  gwsave    : word;
  glsave    : word;
  usrname   : string[27];
  Ufound    : boolean;
  DirInfo : searchrec;
  GamCnt       : Integer;

  begin
   Emu_gotoXy(1,23);
   Emu_color(15,0);
   ComWrite('                   ');
   GetGammonInfo(GamCnt);
   emu_Color(15,1);
   Emu_gotoxy(30,9);
   Comwrite('ษออออออออออออออออออออออออออออออออออออออป');
   Emu_gotoxy(30,10);
   Comwrite('บ                                      บ');
   Emu_gotoxy(30,11);
   Comwrite('บ                                      บ');
   Emu_gotoxy(30,12);
   Comwrite('บ                                      บ');
   Emu_gotoxy(30,13);
   Comwrite('ศออออออออออออออออออออออออออออออออออออออผ');
   Emu_gotoxy(31,10);
   if Not P2IsComputer then
   Comwrite(' '+PLyr1.Name+' W I N S  ')
   else
   Comwrite('            Y O U   W I N   ');
   if GamCnt=2 then
    begin
     Emu_gotoxy(31,11);
     Comwrite('             G A M M O N    ');
    end
   else
   if GamCnt=3 then
    begin
     Emu_gotoxy(31,11);
     Comwrite('         B A C K G A M M O N    ');
    end;
   Emu_gotoxy(31,12);
   Comwrite('         Updating Rankings....  ');
   FindFirst('BBSBGM.RNX',Archive,DirInfo);
   if Doserror<> 0 then
   begin
    assign(RFile,'BBSBGM.RNX');
    rewrite(RFile);
    Writeln(RFile,100.00:6:2,gamcnt:15,0:15,' ',Uname:25);
    CLOSE(RFile);
   end
   else
   begin
    gwsave:=Gamcnt;
    glsave:=0;
    prsav:=100.00;
    assign(RFile,'BBSBGM.RNX');
    assign(TFile,'Tmp.Fil');
    rewrite(TFile);
    reset(RFile);
    UFound :=false;
    while not eof(Rfile) do
    begin
     Readln(RFile,prcent,gameswon,gameslost,Usrname);
     if pos(Uname,Usrname)>0 then
      begin
       gwsave:=gameswon+GamCnt;
       glsave:=gameslost;
       if glsave=0 then prsav:=100.00 else
       prsav:=(gwsave/(glsave+gwsave))*100;
       Ufound:= true;
      end
      else
     Writeln(TFile,prcent:6:2,gameswon:15,gameslost:15,Usrname:25);
    end;
    close(TFile);
    rewrite(RFile);
    reset(TFile);
    Ufound:=false;
    while not eof(Tfile) do
    begin
     Readln(TFile,prcent,gameswon,gameslost,Usrname);
     if (gwsave>gameswon) and Not UFound then
      begin
       Ufound:=true;
       Writeln(RFile,prsav:6:2,gwsave:15,glsave:15,Uname:25);
       Writeln(RFile,prcent:6:2,gameswon:15,gameslost:15,Usrname:25);
      end
     else
       Writeln(RFile,prcent:6:2,gameswon:15,gameslost:15,Usrname:25);
    end;
    if not UFound then
       Writeln(RFile,prsav:6:2,gwsave:15,glsave:15,Uname:25);
    CLOSE(RFile);
    rewrite(TFile);
    CLOSE(TFile);
   end;

   Emu_gotoxy(31,12);
   Comwrite('  P l a y   A g a i n ? (Y / n) ');
   ClearReceive;
   GetYn(Yhit,false);
   if Not Yhit then Quit :=true
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function XXBBS.PlayerFound : Boolean;
 var
  RFile : text;
  usrname   : string;
  Ufound    : boolean;

  begin
   UFound:=false;
   if Exist('BBSBGM.RNX') then
   begin
    assign(RFile,'BBSBGM.RNX');
    reset(RFile);
    UFound :=false;
    while not eof(Rfile) do
     begin
      Readln(RFile,Usrname);
      if pos(Uname,Usrname)>0 then Ufound:=True
     end;
    CLOSE(RFile)
   end;
    PlayerFound :=Ufound
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowRankings;
 var
  RFile       : text;
  CNT         : integer;
  prcent      : real;
  gameswon    : word;
  gameslost   : word;
  usrname     : string[27];
  DirInfo     : searchrec;
  ST,STT      : string;
 begin
   if Registered then
   Begin
   FindFirst('BBSBGM.RNX',Archive,DirInfo);
   if Doserror<> 0 then
   begin
    assign(RFile,'BBSBGM.RNX');
    rewrite(RFile);
    CLOSE(RFile);
   end;
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    Clrscr;
    emu_color(0,7);
    Comwrite('                        BBS BackGammon List of Champions                       ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    ComWrite('   Player Name    ');
    emu_color(11,0);
    ComWrite('               % Won   ');
    emu_color(13,0);
    ComWrite('  Games Won ');
    emu_color(12,0);
    ComWriteln('  Games Lost ');
    emu_color(9,0);
    ComWriteln('อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
    emu_color(15,0);
    assign(RFile,'BBSBGM.RNX');
    reset(RFile);
    CNT:=0;
    while not eof(Rfile) and (Cnt<18) do
    begin
     Cnt:=Cnt+1;
     Readln(RFile,prcent,gameswon,gameslost,Usrname);
     str(prcent:12:2,st);
     str(gameswon:12,stt);
     st:=st+stt;
     str(gameslost:12,stt);
     st:=st+stt;
     while pos(' ',UsrName)=1 do delete(UsrName,1,1);
     while length(UsrName)< 25 do Usrname:=UsrName+' ';
     ComWriteln(' '+UsrName+st)
    end;
    close(RFile)
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
    ComWriteln('');
    emu_color(12,0);
    ComWrite(' Press <ENTER>... ');
    getenterkey;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.player2Wins;

 var
  Yhit : boolean;
  RFile : text;
  TFile : text;
  prcent : real;
  prsav  : real;
  gameswon : word;
  gameslost : word;
  gwsave    : word;
  glsave    : word;
  usrname   : string[27];
  Ufound    : boolean;
  DirInfo : searchrec;


  begin
   if Not P2IsComputer then
   begin
    usrname:=Plyr1.Name;
    Plyr1.Name:=Plyr2.Name;
    PLyr2.Name:=UsrName;
    Player1Wins;
    usrname:=Plyr1.Name;
    Plyr1.Name:=Plyr2.Name;
    PLyr2.Name:=UsrName
   end
   else
   begin
   Emu_gotoXy(1,23);
   Emu_color(15,0);
   ComWrite('                   ');
   emu_Color(15,4);
   Emu_gotoxy(30,9);
   Comwrite('ษออออออออออออออออออออออออออออออออออออออป');
   Emu_gotoxy(30,10);
   Comwrite('บ                                      บ');
   Emu_gotoxy(30,11);
   Comwrite('บ                                      บ');
   Emu_gotoxy(30,12);
   Comwrite('บ                                      บ');
   Emu_gotoxy(30,13);
   Comwrite('ศออออออออออออออออออออออออออออออออออออออผ');
   Emu_gotoxy(31,10);
   Comwrite('           Y O U   L O S E   ');
   Emu_gotoxy(31,12);
   Comwrite('         Updating Rankings....  ');
   FindFirst('BBSBGM.RNX',Archive,DirInfo);
   if Doserror<> 0 then
   begin
    assign(RFile,'BBSBGM.RNX');
    rewrite(RFile);
    Writeln(RFile,100.00:6:2,1:15,0:15,' ',Uname:25);
    CLOSE(RFile);
   end
   else
   begin
    gwsave:=0;
    glsave:=1;
    prsav:=0.00;
    assign(RFile,'BBSBGM.RNX');
    assign(TFile,'Tmp.Fil');
    rewrite(TFile);
    reset(RFile);
    UFound :=false;
    while not eof(Rfile) do
    begin
     Readln(RFile,prcent,gameswon,gameslost,Usrname);
     if pos(Uname,Usrname)>0 then
      begin
       gwsave:=gameswon;
       glsave:=gameslost+1;
       if glsave=0 then prsav:=100.00 else
       prsav:=(gwsave/(glsave+gwsave))*100;
       Ufound:= true;
      end
      else
     Writeln(TFile,prcent:6:2,gameswon:15,gameslost:15,Usrname:25);
    end;
    close(TFile);
    rewrite(RFile);
    reset(TFile);
    Ufound:=false;
    while not eof(Tfile) do
    begin
     Readln(TFile,prcent,gameswon,gameslost,Usrname);
     if (gwsave>gameswon) and Not UFound then
      begin
       Ufound:=true;
       Writeln(RFile,prsav:6:2,gwsave:15,glsave:15,Uname:25);
       Writeln(RFile,prcent:6:2,gameswon:15,gameslost:15,Usrname:25);
      end
     else
       Writeln(RFile,prcent:6:2,gameswon:15,gameslost:15,Usrname:25);
    end;
    if not UFound then
       Writeln(RFile,prsav:6:2,gwsave:15,glsave:15,Uname:25);
    CLOSE(RFile);
    rewrite(TFile);
    CLOSE(TFile);
   end;

   Emu_gotoxy(31,12);
   Comwrite('   P l a y   A g a i n ? (Y / n) ');

   GetYn(Yhit,false);
   if Not Yhit then Quit :=true
   end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetCmd(var YChar : char; Cset: CharSet);
 var
  timesav : string[8];
  chh,ct  : char;
  XS,YS : integer;
  MinCNT: integer;
  AcceptLocalKey : Boolean;

  begin
   AcceptLocalKey := Local or ((Not P2IsComputer) and (Pn=-1));
   MinCnt:=0;
   Timesav:=time;
   if Online and Not GoOffLine then
   begin
    if Auto then YCHAR:=#13
    else
    begin
    Ychar:=#0;
    checkTimeLeft;
    repeat
     if not local and KeyPressed then
      begin
       Ct:=ReadKey;
       if (Ct In Cset) and (Ct<>#13) then YChar:=Ct;
       if CT=#0 then CheckKey
       else ShowFKeys;
      end;
     if Timesav<>time then
     begin
       XS:=WHEREX;
       YS:=WHEREY;
       EMU_GOTOXY(2,2);
       TimePrompt;
       showmsr;
       EMU_GOTOXY(XS,YS);
       Timesav:=time;
       MinCnt:=MinCnt+1;
       if MinCnt >3 then
        begin
          ComWriteO(#7);
          Emu_GoToXy(35,24);
          Emu_Color(15,0);
          ComWrite(' Inactivity Warning !!!');
          ComWriteO(#7);
          if MinCnt>4 then GoOffline:=true
        end
     end;
     if ChWaiting or AcceptLocalKey then
      begin
       if Local then Ychar:=Upcase(readkey)
       else
       if Not P2IsComputer and (PN=-1) then Ychar:=Upcase(readkey)
       else
       Ychar:=Upcase(ComREADKEY);

       if  Ychar in[#27, #0] then
        begin
           Delay(10);
           if AcceptLocalKey then Ychar:=Upcase(readkey)
           else
           Ychar:=ComREADKEY;
           Delay(10);

           while (YChar = #0) AND OnLine do
            if AcceptLocalKey then Ychar:=Upcase(readkey)
            else Ychar:=ComREADKEY;

           while (YChar = '[') and Online do
            if AcceptLocalKey then Ychar:=Upcase(readkey)
            else
           Ychar:=ComREADKEY;
           Delay(10);

           if not Local then while ChWaiting do Ychar:=Upcase(ComREADKEY)

           else while keypressed do Ychar:=Upcase(readkey);

           if YChar=#59 then ReqChat:=true;
           if Ychar='A' then Ychar:='M';
           if Ychar='B' then Ychar:='K';
           if Ychar='C' then Ychar:='M';
           if Ychar='D' then Ychar:='K';
           if Ychar='H' then Ychar:='K';
           if Ychar='P' then Ychar:='M';

        end
       end;
        if Ychar='2' then Ychar:='M';
        if Ychar='4' then Ychar:='K';
        if Ychar='6' then Ychar:='M';
        if Ychar='8' then Ychar:='K'
    until (Ychar in Cset) or GoOffLine or Not Online;
    if Not local and Keypressed then
     begin
      while Keypressed do chh:=readkey;
      if chh=#59 then reqchat:=true;
      if chh=#68 then GoOffLine:=true;
     end
    end
   end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.UserInit;
 begin
  UNAME   := '';
  LEVEL   := 0;
  TTYPE   := 1;
  GoOffLine := false;
  TIMELIMIT := 5;
  TimeUsed  := 0;
  LTime    := Time;
  LDate    := Date;
  ReqChat:= false;
  Local  :=false;
  StartTime := TimeNow;
  Hotkeys:=true
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ReadlnX(var ST : string; L : integer; Pas : boolean);
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
               ComWrite(Ch)
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
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.Initialize;
 begin
 if Not Local then
  begin
   SETPORT(COMNUM);
   OPENPORT(COMNUM);
   SETDBPS(BAUD);
   SetFlowControl(UseCTS,UseRTS);
  end;
  SHOWMSR;
  if not LoadEmulation('ansi') then
   begin
     writeln(' Unable to Load "ANSI.EMU"...');
     Done;
     halt
   end;
  GoOffLine:=false;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.InitBd;
  var
   I : integer;
   BDDt : Text;
 begin
  randomize;
  for I:= -10 to 36 do Bd[I] :=0;
  case Gametype of
   0: begin
       if exist('Board.Dat') then
        begin
          Assign(BDDt,'Board.dat');
          reset(BDDt);
          While Not Eof(BDDt) do
           begin
            Read(BDDt,I);
            Readln(BDDt,BD[I])
           end;
          Close(BDDt)
        end
       else
        begin
         BD[24] := -2;
         BD[6]  := -5;
         BD[8]  := -3;
         BD[13] := -5;
         BD[17]  :=3;
         BD[19]  :=5;
         BD[1]  := 2;
         BD[12] := 5
        end
      end;
  1,2: begin
       BD[27] := -15;
       BD[-2] := 15;
      end;
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.UpdateBar;
 var
  J : integer;
  St : String;
 begin
   J:=bd[-1];
   str(J:2,st);
   emu_gotoxy(15,9);
   emu_color(15,0);
   ComWrite(St);
   J:=abs(bd[26]);
   str(J:2,st);
   emu_gotoxy(15,13);
   emu_color(15,0);
   ComWrite(St)
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.UpdateStart;
 var
  J : integer;
  St : String;
 begin
   J:=bd[-2];
   str(J:2,st);
   emu_gotoxy(5,9);
   emu_color(15,0);
   ComWrite(St);
   J:=abs(bd[27]);
   str(J:2,st);
   emu_gotoxy(5,13);
   emu_color(15,0);
   ComWrite(St)
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.Pickpip(I: integer);
 var
  J : Integer;
  begin
  if Barmove then I:=I-PN;
  J:=abs(BD[I]);
  BD[I] :=BD[I] -Pn;
  case I of
  -2,27 : updateStart;
  -1,26 : updateBar;
  13..25: begin
           if J<8 then
            begin
             Emu_Gotoxy(74-((I-13)*4),19-J);
             ComWrite('   ');
            end;
          end;
  0..12 : begin
           if J<8 then
            begin
             Emu_Gotoxy(26+(I*4),3+J);
             ComWrite('   ')
            end
          end
  end {case}

  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.Putpip(C,I: integer);
 var
  J : Integer;
  H : integer;
  begin
  if I<0 then I:=0;
  if I>25 then I:=25;
  if Bd[I] = (PN*-1) then
  begin
   BD[I]:=0;
   if PN = 1 then BD[26]:=BD[26]-1 else BD[-1]:=BD[-1]+1;
   UpDateBar;
  end;
  Bd[I] :=BD[I] +Pn;
  J:= abs(BD[I]);
 case I of

  0..12: begin
           if J<8 then
            begin
             Emu_color(C,0);
             Emu_Gotoxy(26+(I*4),3+J);
             ComWrite('฿฿฿');
            end;
          end;
  13..25 : begin
           if J<8 then
            begin
             Emu_color(C,0);
             Emu_Gotoxy(74-((I-13)*4),19-J);
             ComWrite('ÜÜÜ')
            end
          end
  end {case}

  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.showpieces(C1,C2 : integer);
  var
   I,J,k : integer;
 begin
  emu_gotoxy(13,10);
  emu_color(C1,0);
  ComWrite('ÜÜÜÜÜÜ');
  emu_gotoxy(13,12);
  emu_color(C2,0);
  ComWrite('฿฿฿฿฿฿');
  UpdateBar;
  if GameType =1 then
  begin
   emu_gotoxy(3,10);
   emu_color(C1,0);
   ComWrite('ÜÜÜÜÜÜ');
   emu_gotoxy(3,12);
   emu_color(15,0);
   ComWrite('Start ');
   emu_gotoxy(3,12);
   emu_color(C2,0);
   ComWrite('฿฿฿฿฿฿');
   UpdateStart
  end;
  for I:= 0 to 25 do
   begin
     J:= Bd[I];
     if J < 0 then
      begin
       PN:=-1;
       BD[I]:=0;
       for K:= 1 to abs(j) do Putpip(C2,I)
      end
     else
     begin
      PN:=1;
      BD[I]:=0;
      if J > 0 then for K:= 1 to J do Putpip(C1,I)
     end

   end;
   Emu_color(Plyr2.color,0);
   emu_gotoxy(27,5);
   ComWrite('H');
   emu_gotoxy(27,6);
   ComWrite('O');
   emu_gotoxy(27,7);
   ComWrite('M');
   emu_gotoxy(27,8);
   ComWrite('E');
   Emu_color(Plyr1.color,0);
   emu_gotoxy(27,13);
   ComWrite('H');
   emu_gotoxy(27,14);
   ComWrite('O');
   emu_gotoxy(27,15);
   ComWrite('M');
   emu_gotoxy(27,16);
   ComWrite('E');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.DrawBoard;

  const
   c1 = 5; {7}
   c2 = 3;
  var I :integer;

  begin
   Emu_color(14,0);
   Emu_clearscreen;
   emu_gotoxy(1,1);
   if GameType=0 then
   Comwrite('                             B A C K G A M M O N      Ver.'+vrs+' (c) 1993      ')
   else
   Comwrite('                            A C E Y - D E U C E Y      Ver.'+vrs+' (c) 1993     ');
   Comwriteln('');
   Comwriteln('');
  Emu_color(c1,0);
   Comwriteln('                        ษอออหอออัอออัอออัอออัอออัอออหอออัอออัอออัอออัอออัอออป');
   for I := 1 to 7 do
   begin
    Comwrite('                        บ   บ');
    Emu_color(c2,0);
    Comwrite('   ณ   ณ   ณ   ณ   ณ   ');
    Emu_color(c1,0);
    Comwrite('บ');
    Emu_color(c2,0);
    Comwrite('   ณ   ณ   ณ   ณ   ณ   ');
    Emu_color(c1,0);
    Comwriteln('บ');
   end;
    If GameType>0 then
    begin
     Emu_color(15,0);
     ComWrite('  Start')
    end
    else
     ComWrite('       ');
     Emu_color(c1,0);
    Comwriteln('    <ON BAR>     ฬอออฮอออุอออุอออุอออุอออุอออฮอออุอออุอออุอออุอออุอออน');
   for I := 1 to 7 do
   begin
    Comwrite('                        บ   บ');
    Emu_color(c2,0);
    Comwrite('   ณ   ณ   ณ   ณ   ณ   ');
    Emu_color(c1,0);
    Comwrite('บ');
    Emu_color(c2,0);
    Comwrite('   ณ   ณ   ณ   ณ   ณ   ');
    Emu_color(c1,0);
    Comwriteln('บ');
   end;
   Comwriteln('                        ศอออสอออฯอออฯอออฯอออฯอออฯอออสอออฯอออฯอออฯอออฯอออฯอออผ');
   Emu_color(15,0);
   emu_gotoxy(3,16);
   ComWriteln('Player 1');
   Emu_color(Plyr1.color,0);
   emu_gotoxy(3,17);
   ComWriteln(Plyr1.Name);
   Emu_color(15,0);
   emu_gotoxy(3,5);
   ComWriteln('Player 2');
   Emu_color(Plyr2.color,0);
   emu_gotoxy(3,6);
   ComWriteln(Plyr2.Name);
   Emu_color(15,0);
   Emu_gotoxy(45,21);
   comwriteln('ฺฤฤฤฟ     ฺฤฤฤฟ ');
   Emu_gotoxy(45,22);
   comwriteln('ณ   ณ     ณ   ณ ');
   Emu_gotoxy(45,23);
   comwriteln('ภฤฤฤู     ภฤฤฤู ');
   Emu_color(Plyr2.color,0);
   emu_gotoxy(27,5);
   ComWrite('H');
   emu_gotoxy(27,6);
   ComWrite('O');
   emu_gotoxy(27,7);
   ComWrite('M');
   emu_gotoxy(27,8);
   ComWrite('E');
   Emu_color(Plyr1.color,0);
   emu_gotoxy(27,13);
   ComWrite('H');
   emu_gotoxy(27,14);
   ComWrite('O');
   emu_gotoxy(27,15);
   ComWrite('M');
   emu_gotoxy(27,16);
   ComWrite('E');

  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.RollDice ;
 var
  St : String;
  I  :integer;

 begin
    emu_Color(15,0);
    Emu_gotoxy(47,22);
    comwriteln('/');
    Emu_gotoxy(57,22);
    comwriteln('\');
    Emu_gotoxy(47,22);
    comwriteln('ณ');
    R1 := 1+round(5*random);
    R2 := 1+round(5*random);
    Emu_gotoxy(57,22);
    comwriteln('ณ');
    Emu_gotoxy(47,22);
    comwriteln('\');
    Emu_gotoxy(57,22);
    comwriteln('/');
    R1 := 1+round(5*random);
    R2 := 1+round(5*random);
    Emu_gotoxy(47,22);
    comwriteln('ณ');
    Emu_gotoxy(57,22);
    comwriteln('ณ');
    emu_Color(14,0);
    R1 := 1+round(5*random);
    R2 := 1+round(5*random);
    Str(R1, St);
    Emu_gotoxy(47,22);
    comwriteln(St);
    Str(R2, St);
    Emu_gotoxy(57,22);
    comwriteln(St);
    if R1=R2 then
    begin
     Emu_gotoXy(31,22);
     Emu_color(15,0);
     ComWrite('   DOUBLES    ');
    end;
    if ((R1+R2)=3) and (GameType=1) then
    begin
     Emu_gotoXy(31,22);
     Emu_color(15,0);
     ComWrite(' Acey-Deucey ');
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
procedure XXBBS.ShowDice;
 var
  St : String;
 begin
    Emu_color(14,0);
    Str(R1, St);
    Emu_gotoxy(47,22);
    comwriteln(St);
    Str(R2, St);
    Emu_gotoxy(57,22);
    comwriteln(St);
    if R1=R2 then
    begin
     Emu_gotoXy(31,22);
     Emu_color(15,0);
     ComWrite('   DOUBLES    ');
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.mainmenu;
 var
   I : integer;
   Regstr : String;
 begin
 clearreceive;
 emu_color(15,0);
 textbackground(0);
 emu_ClearScreen;
 clrscr;
 emu_color(10,0);
 Comwriteln('              าฤฟ  ึฤฤฟ ึฤฤฟ า ฺ  ึฤฤฟ ึฤฤฟ ึฤาฤฟ ึฤาฤฟ ึฤฤฟ ึฤฤฟ');
 Comwriteln('              วฤมฟ วฤฤด บ    วฤมฟ บ ฤฟ วฤฤด บ บ ณ บ บ ณ บ  ณ บ  ณ');
 Comwriteln('              ะฤฤู ะ  ม ำฤฤู ะ  ม ำฤฤู ะ  ม ะ ะ ม ะ ะ ม ำฤฤู ะ  ม');
 emu_color(15,0);
 Comwriteln('                                     A N D   ');
 emu_color(11,0);
 Comwriteln('              ึฤฤฟ ึฤฤฟ าฤฤฟ า  ย     าฤฤฟ าฤฤฟ า  ย ึฤฤฟ าฤฤฟ า  ย ');
 Comwriteln('              วฤฤด บ    วฤ   ำฤฤด ฤฤฤ บ  ณ วฤ   บ  ณ บ    วฤ   ำฤฤด ');
 Comwriteln('              ะ  ม ำฤฤู ะฤฤู ำฤฤู     ะฤฤู ะฤฤู ำฤฤู ำฤฤู ะฤฤู ำฤฤู ');
 emu_color(13,0);
 Comwriteln('                            Version'+vrs+' (c) 1993');
 emu_color(11,0);
 Comwriteln('                         Neubauer Applications Uncorp');
 emu_color(14,0);
 Comwriteln('                       Virtual Reality BBS 512-992-4496');
 emu_color(15,0);
  if Registered then
 begin
  I:=Pos('  ',BBSName);
  if I>0 then BBSName[0] := Chr(I-1);
  RegStr:=' Registered to '+BBSName;
  Emu_GotoXy(39-(Length(RegStr) div 2),WhereY);
 ComWriteln(RegStr)
 end
 else
 Comwriteln('                 UNREGISTERED COPY  ... ASK SYSOP TO REGISTER');
{ Comwriteln('                    Original Version for Virtual Reality BBS');}
 Comwriteln('');
 Comwriteln('');
 emu_color(14,0);
 Comwriteln(' [B]  BackGammon ');
 emu_color(11,0);
 Comwriteln(' [A]  Acey-Deucey ');
 emu_color(13,0);
 Comwrite(' [P]  Play Against SysOp..');
 emu_color(15,0);
 if Not Registered then ComWriteln('<-- Only Available If Registered. ')
 Else ComWriteln('');
 emu_color(10,0);
 Comwrite(' [R]  Rankings');
 emu_color(15,0);
 if Not Registered then ComWriteln('            <-- Only Available If Registered. ')
 Else ComWriteln('');
 emu_color(14,0);
 Comwriteln(' [I]  Instructions');
 emu_color(12,0);
 Comwriteln(' [Q]  Quit Back to BBS');
 showMsr;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function HomeFree(W: integer): boolean;
 var
   I : integer;
   HF : boolean;
 begin
  HF:=true;
  case PN of
  -1: begin
       if W>6 then HF:=false;
        I:=7;
        while HF and (I<28) do
         begin
          if BD[I]<0 then HF:=false;
          I:=I+1
         end
      end;
   1: begin
       if W<19 then HF:=false;
       I:=18;
       while HF and (I>-3) do
        begin
         if BD[I]>0 then HF:=false;
         I:=I-1
        end
      end
   end; {case}
  Homefree:=HF;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Trailing(W: integer): boolean;
 var
   I : integer;
   HF : boolean;
 begin
  HF:=false;
  case PN of
  -1: begin
        I:=W+1;
        while not HF and (I<27) do
         begin
          if BD[I]<0 then HF:=true;
          I:=I+1
         end
      end;
   1: begin
       I:=W-1;
       while not HF and (I>-2) do
        begin
         if BD[I]>0 then HF:=true;
         I:=I-1
        end
      end
   end; {case}
  Trailing:=HF;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function RaceIsOn: boolean;
 var
   I            : integer;
   BackPieceLoc : integer;
   HF           : boolean;
 begin
  HF:=false;
  case PN of
  -1: begin
       if (Bd[-1] =0) and (Bd[26]=0) then
        begin
         BackPieceLoc :=0;
         for I:=1 to 24 do if BD[I]<0 then BackPieceLoc :=I;
         if BackPieceLoc > 1 then
         begin
          HF:= true;
          for I:= BackPieceLoc downto 1 do
          if BD[I]>0 then HF:=False;
         end
        end
      end;
   1: begin
       if (Bd[-1] =0) and (Bd[26]=0) then
        begin
         BackPieceLoc :=24;
         for I:=24 downto 1 do if BD[I]>0 then BackPieceLoc :=I;
         if BackPieceLoc < 24 then
         begin
          HF:= true;
          for I:= BackPieceLoc to 24 do
          if BD[I]<0 then HF:=False;
         end
        end
      end
   end; {case}
  RaceIsOn:=HF;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Valid( I : integer) : boolean;
 var
   Tloc : integer;
   limit: integer;
   ValidI : Boolean;

 begin
  ValidI :=false;
  case Pn of
  -1: begin
        If I=27 then I:=25;
        Limit:=0;
        if R1 >0 Then
         begin
          Tloc := I- R1;
          if (Tloc>Limit) and (BD[Tloc]< 2) then ValidI :=true
          else
          if Homefree(I) and (Tloc=Limit) then ValidI :=true
          else
          if Homefree(I) and (Tloc<Limit) and not Trailing(I) then ValidI :=true
         end;
        if R2 >0 Then
         begin
          Tloc := I- R2;
          if (Tloc>Limit) and (BD[Tloc]< 2) then ValidI :=true
          else
          if Homefree(I) and (Tloc=Limit) then ValidI :=true
          else
          if Homefree(I) and (Tloc<Limit) and not Trailing(I) then ValidI :=true
         end
      end;
   1: begin
        If I=-2 then I:=0;
        Limit :=25;
        if R1 >0 Then
         begin
          Tloc := I+ R1;
          if (Tloc<Limit) and ((BD[Tloc]>-2))  then ValidI :=true
          else
          if Homefree(I) and (Tloc=limit) then ValidI :=true
          else
          if Homefree(I) and (Tloc>limit) and not Trailing(I) then ValidI :=true
         end;
        if (R2 >0) Then
         begin
          Tloc := I+ R2;
          if (Tloc<Limit) and (BD[Tloc]>-2) then ValidI :=true
          else
          if Homefree(I) and (Tloc=limit) then ValidI :=true
          else
          if Homefree(I) and (Tloc>limit) and not Trailing(I) then ValidI :=true
         end
      end;
  end; { case }
  Valid :=ValidI
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function MovsAfterMoving(FW,R: Integer) : integer;
 var
   BrdSv   : Board;
   R1S,R2S : Byte;
   Des,FS  : Integer;
   ICnt    : Integer;
   MovCount : Integer;
   Finished : Boolean;

 begin
   MovCount :=-1;
   Finished := False;
   BrdSv := BD;
   R1S   := R1;
   R2S   := R2;

  if R=1 then
   begin
     R2 :=0;
     Finished := Not Valid(FW);
     R2:= R2S
   end
  else
   begin
     R1 :=0;
     Finished := Not Valid(FW);
     R1:= R1S
   end;

  if Not Finished then
   begin
   FS :=FW;
   If FW =-2 then FW:=0;
   If FW = 27 then FW:=25;

   if R=1 then
     begin
      Des := FW + (PN*R1);
      R1 :=0;
     end
   else
     begin
      Des := FW + (PN*R2);
      R2 :=0;
     end;

    FW :=FS;
    If FW =-2 then FW:=-1;
    If FW = 27 then FW:=26;
    Bd[FW]:= BD[FW] -PN;
    if Des>25 then Des:=25;
    if Des<0 then Des:=0;
    Bd[FS]:= BD[FS] -PN;
    Bd[Des]:= BD[Des] +PN;
    MovCount :=0;
    for Icnt := 0 to 27 do
    if (BD[Icnt]*Pn) >0 then
     if Valid(Icnt) then MovCount :=MovCount +1;
   end;

   MovsAfterMoving := MovCount;
   Bd   := BrdSv;
   R1   := R1S;
   R2   := R2S;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function CurrPtr: integer;
 begin
  If PN=1 then CurrPtr:=Plyr1.pntr else CurrPtr:=Plyr2.pntr
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure SetCurrPtr(pp: integer);
 begin
  If PN=1 then Plyr1.pntr:=pp else Plyr2.pntr:=pp
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure getfirstptrloc(var Nm: boolean) ;
 var
   I,pass   : Integer;
   StartPos : Integer;
   MaM1     : Integer;
   MaM2     : Integer;

 begin
  NM:=true;
  case PN of
   -1: begin
        if bd[26] < 0 then
         begin
          plyr2.pntr := 26;
          if valid(25) then NM:=false;
         end
        else
        begin
         pass:=0;
         I:=Plyr2.pntr;
         if not valid(I) then
          begin
           if gametype =0 then I:=25 else I:=27
          end;
         while I>0 do
         begin
          if (Bd[I] < 0) and Valid(I) then
          begin
            NM:=false;
            plyr2.pntr:=I;
            I:=-10
          end;
         I:=I-1;
         if I=26 then I:=25;
         if (I<1) and (pass<1) and NM then
          begin
           if gametype =0 then I:=25 else I:=27;
           pass:= pass +1
          end
         end
        end
       end;
   1: begin
        if bd[-1] > 0 then
         begin
          plyr1.pntr := -1;
          if valid(0) then NM:=false
         end
        else
        begin
         pass:=0;
         I:=Plyr1.pntr;
         if not valid(I) then
          begin
           If GameType =0 then I:=0 else I:=-2;
          end;
         while I<25 do
         begin
         if (Bd[I] > 0) and Valid(I) then
          begin
            NM:=false;
            plyr1.pntr:=I;
            I:=26
          end;
         I:=I+1;
         if I=-1 then I:=0;
         if (I>24) and (pass<1) and NM then
          begin
           If GameType =0 then I:=0 else I:=-2;
           pass:= Pass +1;
          end
         end
        end
       end
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetNextPtrLoc ; var I : integer;
 var
  Nm        : boolean;
  Startpos  : integer;
  MaM1      : Integer;
  MaM2      : Integer;

 begin

  case PN of
   -1: begin
        if bd[26] < 0 then plyr2.pntr := 26
        else
        begin
         I:=plyr2.pntr-1;
         while I>0 do
         begin
          if (Bd[I] < 0) and Valid(I) then
          begin
            plyr2.pntr:=I;
            I:=-10
          end;
         I:=I-1;
         if I=-1 then
         begin
          plyr2.pntr:=27;
          getfirstptrloc(NM);
         end
         end
        end
       end;
   1: begin
        if bd[-1] > 0 then plyr1.pntr := -1
        else
        begin
         I:=plyr1.pntr+1;
         while I<25 do
         begin
         if (Bd[I] > 0) and Valid(I) then
          begin
            plyr1.pntr:=I;
            I:=28
          end;
         I:=I+1;
         if I=26 then
         begin
          plyr1.pntr:=-2;
          getfirstptrloc(NM);
         end
         end
        end
       end
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure getLastptrloc(var Nm: boolean) ;
 var
   I        : integer;
   MaM1     : Integer;
   MaM2     : Integer;
   Pass     : byte;

 begin
  NM:=true;
  case PN of
   -1: begin
        if bd[26] <> 0 then
         begin
          plyr2.pntr := 26;
          if valid(25) then NM:=false;
         end
        else
        begin
         Pass :=0;
         I:=Plyr2.pntr;
         if not valid(I) then I:=0;
         while I<26 do
         begin
          if (Bd[I] < 0) and Valid(I) then
          begin
            NM:=false;
            plyr2.pntr:=I;
            I:=27
          end;
         I:=I+1;
         if I=-1 then I:=0;
         if (I>24) and (pass<1) and NM then
          begin
           If GameType =0 then I:=0 else I:=-2;
           pass:= Pass +1;
          end
         end
        end
       end;
   1: begin
        if bd[-1] <> 0 then
         begin
          plyr1.pntr := -1;
          if valid(0) then NM:=false
         end
        else
        begin
         I:=Plyr1.pntr;
         Pass :=0;
         if not valid(I) then I:=25;
         while I>-1 do
         begin
         if (Bd[I] > 0) and Valid(I) then
          begin
            NM:=false;
            plyr1.pntr:=I;
            I:=-2
          end;
         I:=I-1;
         if I=26 then I:=25;
         if (I<1) and (pass<1) and NM then
          begin
           if gametype =0 then I:=25 else I:=27;
           pass:= pass +1
          end
         end
        end
       end
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetPrevPtrLoc ; var I : integer;
 var
  Nm       : Boolean;
  MaM1     : Integer;
  MaM2     : Integer;

 begin
  case PN of
   -1: begin
        if bd[26] <> 0 then plyr2.pntr := 26
        else
        begin
         I:=plyr2.pntr+1;
         while I<=27 do
         begin
          if (Bd[I] < 0) and Valid(I) then
            begin
             plyr2.pntr:=I;
             I:=30
            end;
         I:=I+1;
         if I=28 then
         begin
          plyr2.pntr:=1;
          getlastptrloc(NM);
         end
         end
        end
       end;
   1: begin
        if bd[-1] <> 0 then plyr1.pntr := -1
        else
        begin
         I:=plyr1.pntr-1;
         while I>-3 do
         begin
         if (Bd[I] > 0) and Valid(I) then
          begin
            plyr1.pntr:=I;
            I:=-10
          end;
         I:=I-1;
         if I=-3 then
         begin
          plyr1.pntr:=24;
          getlastptrloc(NM);
         end
         end
        end
       end
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetNextChoice(FW: integer);
 var
  RSav  : integer;
 begin
  SetCurrPtr(-10);
  case PN of
   1: begin
       If FW=-2 then FW:=0;
       if (R1>0) and (R2>0) then
        begin
         if (MovsAfterMoving(FW,1)=0) and (MovsAfterMoving(FW,2)>0) then
         DicePick :=2
        end;
       if (R1>0) and ((BD[FW+R1]>-2) or ((FW+R1)>24)) and (Dicepick=1) then
         begin
           if ((FW+R1) >24) then
             begin
              if HomeFree(FW) and not ((R1>R2) and Trailing(FW)) then
               begin
                Plyr1.pntr := FW+R1;
               end
              else
                if HomeFree(FW) and ((FW+R1) =25) then
                Plyr1.pntr := FW+R1
             end
           else
            Plyr1.pntr := FW+R1
         end
         else
          if (R2>0) and ((BD[FW+R2]>-2) or ((FW+R2)>24)) then
          if Not ((R1>0) and (MovsAfterMoving(FW,2)=0) and (MovsAfterMoving(FW,1)>0)) then
           begin
            if ((FW+R2) >24) then
             begin
              if HomeFree(FW) and not ((R2>R1) and Trailing(FW)) then
               begin
                Plyr1.pntr := FW+R2;
                DicePick :=2
               end
              else
                if HomeFree(FW) and ((FW+R2) =25) then
                Plyr1.pntr := FW+R2
             end
            else
            begin
             Plyr1.pntr := FW+R2;
             DicePick :=2
            end
          end
      end;

  -1: begin
       if FW=27 then FW:=25;
       if (R1>0) and ((BD[FW-R1]<2) or  ((FW-R1)<1)) and (Dicepick=1) then
           begin
            if ((FW-R1) <1) then
             begin
              if HomeFree(FW) and not ((R1>R2) and Trailing(FW)) then
               begin
                Plyr2.pntr := FW-R1;
               end
              else
                if HomeFree(FW) and ((FW-R1) =0) then
                Plyr2.pntr := FW-R1
             end
            else
           Plyr2.pntr := FW-R1
          end
         else
          if (R2>0) and ((BD[FW-R2] < 2)  or ((FW-R2)<1)) then
           begin
            if ((FW-R2)<1) then
             begin
              if HomeFree(FW) and not ((R2>R1) and Trailing(FW)) then
               begin
                Plyr2.pntr := FW-R2;
                DicePick :=2;
               end
              else
                if HomeFree(FW) and ((FW-R2) =0) then
                Plyr2.pntr := FW-R2
             end
            else
             begin
              Plyr2.pntr := FW-R2;
              DicePick :=2
             end
          end
        end
      end;
   end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowPointer;
 var
  loc : integer;
 begin
  loc :=CurrPtr;
  case loc of
     26,-1: begin
             Emu_gotoXy(1,22);
             Emu_color(15,8);
             ComWrite(' From <BAR>   ' );
            end;
     27,-2: begin
             Emu_gotoXy(1,22);
             Emu_color(15,0);
             ComWrite(' From START ' );
             If Loc =-2 then
              begin
                Emu_gotoXy(6,8);
                Emu_color(12,8);
                Comwrite(#25);
              end
             else
              begin
                Emu_gotoXy(6,14);
                Emu_color(12,8);
                Comwrite(#24);
              end

            end;
   13..25 : begin
             emu_gotoxy(75-((loc-13)*4),20);
             Comwrite(#24);
            end;
   0..12 : begin
             emu_gotoxy(27+(loc*4),2);
             Comwrite(#25);
            end;
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowtoPointer;
 var
  loc : integer;
 begin
  loc :=CurrPtr;
  if loc>25 then loc:=25;
  if loc<0 then loc:=0;
  case loc of
   13..25 : begin
             emu_gotoxy(75-((loc-13)*4),20);
             Comwrite(#24);
{             write(loc)}
            end;
   0..12 : begin
             emu_gotoxy(27+(loc*4),2);
             Comwrite(#25);
{             write(loc);}
            end;
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.HidetoPointer;
 var
  loc : integer;
 begin
  loc :=Currptr;
  if loc>25 then loc:=25;
  if loc<0 then loc:=0;
  case loc of
   13..25 : begin
             emu_gotoxy(75-((loc-13)*4),20);
             Comwrite(' ');
            end;
   0..12 : begin
             emu_gotoxy(27+(loc*4),2);
             Comwrite(' ');
            end;
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.HidePointer;
 var
  loc : integer;
 begin
  loc :=Currptr;
  case loc of
    27,-2 : begin
             Emu_gotoXy(1,22);
             Emu_color(15,0);
             ComWrite('                ');
             If Loc =-2 then
              begin
                Emu_gotoXy(6,8);
                Comwrite(' ');
              end
             else
              begin
                Emu_gotoXy(6,14);
                Comwrite(' ');
              end
            end;
    26,-1 : begin
             Emu_gotoXy(1,22);
             Emu_color(15,0);
             ComWrite('                ');
            end;
   13..25 : begin
             emu_gotoxy(75-((loc-13)*4),20);
             Comwrite(' ');
            end;
   0..12 : begin
             emu_gotoxy(27+(loc*4),2);
             Comwrite(' ');
            end;
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowCmds;
  begin
   Emu_Gotoxy(60,21);
   Emu_Color(14,0);
   ComWrite('  Use Arrow Keys ');
   Emu_Gotoxy(60,22);
   Emu_Color(13,0);
   ComWrite(' <Enter>=Select');
   Emu_Gotoxy(60,23);
   Emu_Color(12,0);
   ComWrite(' <SpaceBar>=Unselect');
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{   Computer decides move here !!!! }
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 procedure XXBBS.GetCMove(var FW,TW : Integer;var NM : boolean);

 type
   PMove = record
            F,T,R,V :integer;    { FROM , TO,  ROLL,  VALUE }
           end;
  var
   I,savptr: integer;
   accept,MoveMade : boolean;
   pipmove : ARRAY [1..50] of Pmove;
   MoveCnt : integer;
   D1,D2   : byte;
   BestMove : integer;
   HighVal  : integer;
   FS       : integer;
   RIO      : Boolean;

 begin
 FS:=0;
 if Online and Not GoOffLine then
 begin
 accept:=false;
 NM :=false;
 RIO :=RaceIsOn;
 DicePick:=1;
 getfirstptrloc(Nm);
 if NM then
  begin
   Emu_Gotoxy(1,22);
   Emu_Color(12,8);
   ComWrite('                            ');
   Emu_Gotoxy(1,23);
   ComWrite(' NO Valid Moves      ');
   ComWriteO(#7);
   delay(3000);
   DoubleFlag:=false;
  end
 else
 begin
 savptr:=CurrPtr;
 repeat
  SetCurrPtr(SavPtr);
  repeat
   Emu_gotoXy(1,22);
   Emu_color(15,0);
   ComWrite('                 ');
   Emu_Gotoxy(1,23);
   Emu_Color(15,0);
   ComWrite(' Move Pip');
   Emu_Color(10,0);
   ComWrite(' FROM...           ');
   ShowPointer;
   delay(35);
   BarMove:=false;
   if (CurrPtr=-1) or (CurrPtr=26) then BarMove :=true;
   if Not BarMove then
   begin
    while (not accept) and not GoOffLine and Online do
      begin
       D1:=R1;
       D2:=R2;
       R2:=0;
       Movecnt:=0;
       for I:= 1 to 27 do
       if VALID(I) and (Bd[I]*PN >0) Then
        begin
         Movecnt:=Movecnt+1;
         with PipMove[MoveCnt] do
          begin
           F:=I;
           R:=1;
           T:=F+(PN*R1);
           if F=27 then T:=T-2;
           V:=0;
          end
        end;
        R2:=D2;
        R1:=0;
       for I:= 1 to 27 do
       if VALID(I) and (Bd[I]*PN >0) Then
        begin
         Movecnt:=Movecnt+1;
         with PipMove[MoveCnt] do
          begin
           F:=I;
           R:=2;
           T:=F+(PN*R2);
           if F=27 then T:=T-2;
           V:=0;
          end
        end;
         { ALL MOVES FOUND AND STORED }
         for I:=1 to Movecnt do
         with PipMove[I] do
          begin
           if (F<7) and (T<>0) then V:=V-4;
           if T<=0 then
            begin
             V:=V+17;
             if T=0 then V:=V+7;
             if RIO then V:=V+20
            end;
           if abs(BD[F])=2 then
            begin
             if Not RIO then V:=V-10;
             if F>18 then V:=V+ 3;
             if (R1>0) and (R2>0) then V:=V+2;
             IF R1=R2 Then V:=V+7;
            end;
           if (abs(BD[T])=0) and (T>0) then
            begin
             if Not RIO then V:=V-6;
             if T<7 then V:=V-3
            end;
           if abs(BD[F])=1 then V:=V+11;
           if abs(BD[T])=1 then V:=V+12;
           if (BD[T])=PN then V:=V+12;
           if abs(BD[T])>2 then V:=V-abs(BD[T]);
           if abs(BD[F])>2 then V:=V+4+abs(BD[F]);
           if F>18 then V:=V+15;
           if F>12 then V:=V+7;
           if (F<7) and (T>0) then
            begin
             V:=V-10;
             if RIO then V:=V-10;
            end;
           if F>6 then
            begin
             V:=V+3;
             if RIO then V:=V+30;
            end
          end;
          HighVal :=PipMove[1].V;
          BestMove:=1;
          for I:=1 to Movecnt do
          with PipMove[I] do
          begin
          if V>Highval then
           begin
             HighVal:=V;
             BestMove:=I;
           end;
          end;
         R1:=D1;
       Hidepointer;
       setCurrPtr(pipmove[BestMove].F);
       accept:=true;
       Emu_Color(12,0);
       ShowPointer;
       if Local or (GetBps > 2400) then delay(550);
       FW :=Pipmove[BestMove].F;
      end
   end
  else accept:=true;
  until accept or GoOffLine Or Not Online;
   if BarMove then
   begin
    FW:= CurrPtr+PN;
    DicePick:=1;
    GetNextChoice(FW);
    if CurrPtr=-10 then
    begin
     DicePick:=2;
     GetNextChoice(FW)
    end
  end;
   Emu_Gotoxy(1,23);
   Emu_Color(15,0);
   ComWrite(' Move Pip ');
   Emu_Color(14,0);
   ComWrite(' TO.....           ');
   if Not BArMove then
    begin
     setCurrPtr(pipmove[BestMove].T);
    end;
   { accept move to position }
   MoveMade:=true;
   Emu_Color(14,0);
   ShowtoPointer;
   delay(150);
   if Local or (GetBps > 2400) then delay(300);
  until (MoveMade and Accept) or GoOffLine Or Not Online;;
  TW:=CurrPtr;
  if TW>25 then Tw:=25;
  if TW<0 then Tw:=0;
  FS:=FW;
  if FW=27 then FW:=25;
 if Not DoubleFlag then
    begin
    if (R1>0) and (R2>0) then
         begin
           if ((FW-R1)<0) AND ((FW-R2)<0) then
           begin
            if (FW-R1)<(FW-R2) then
             begin
              Emu_gotoxy(57,22);
              comwriteln(' ');
              R2:=0
             end
            else
             begin
              Emu_gotoxy(47,22);
              comwriteln(' ');
              R1:=0
             end
           end
          else
           begin
            if (FW-R1=TW) OR (((FW-R1)>TW) and ((FW-R2)<TW)) then
             begin
              Emu_gotoxy(47,22);
              comwriteln(' ');
              R1:=0
             end
            else
             begin
              Emu_gotoxy(57,22);
              comwriteln(' ');
              R2:=0
             end
           end
         end
        else
         if R1>0 then
          begin
           Emu_gotoxy(47,22);
           comwriteln(' ');
           R1:=0
          end
         else
          begin
           Emu_gotoxy(57,22);
           comwriteln(' ');
           R2:=0
          end
    end;
 end
 end;
 FW:=FS
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetPMove(var FW,TW : Integer;var NM : boolean);
  var
   I,Tloc,savptr: integer;
   ch              : char;
   accept,MoveMade : boolean;
   FS              : integer;

 begin
 if Online and Not GoOffLine then
 begin
 accept:=false;
 NM :=false;
 DicePick:=1;
 FS:=0;
 getfirstptrloc(Nm);
 if NM then
  begin
   Emu_Gotoxy(1,22);
   Emu_Color(12,8);
   ComWrite('                            ');
   Emu_Gotoxy(1,23);
   ComWrite(' NO Valid Moves      ');
   ComWriteO(#7);
   Delay(2000);
   DoubleFlag:=false;
  end
 else
 begin
 if (PN=1) or (Not P2IsComputer) then ShowCmds;
 savptr:=CurrPtr;
 repeat
  SetCurrPtr(SavPtr);
  repeat
   Emu_gotoXy(1,22);
   Emu_color(15,0);
   ComWrite('                 ');
   Emu_Gotoxy(1,23);
   Emu_Color(15,0);
   ComWrite(' Move Pip');
   Emu_Color(10,0);
   ComWrite(' FROM...           ');
   ShowPointer;
   BarMove:=false;
   if (CurrPtr=-1) or (CurrPtr=26) then BarMove :=true;

   if Not BarMove then
   begin
   while (not accept) and not GoOffLine and Online do
   begin
   Ch:=' ';
   if (PN=1) or (Not P2IsComputer) then  GetCmd(CH,[#13,'K','M']);
   if ReqChat then
    begin
      Chat;
      drawboard;
      showpieces(plyr1.Color,Plyr2.color);
      Emu_Color(10,0);
      ShowPointer;
      Emu_Gotoxy(1,23);
      Emu_Color(15,0);
      ComWrite(' Move Pip');
      Emu_Color(10,0);
      ComWrite(' FROM...           ');
      ShowDice;
      Emu_Color(10,0);
      ShowPointer;
    end
   else
   begin
   if (PN=-1) and (P2IsComputer) then ch:=#13;
   if PN=-1 then
   begin
    if Ch='M' then Ch:='K' else if Ch='K' then Ch:='M'
   end;
   case ch of
   #13: begin
         accept:=true;
         Emu_Color(12,0);
         ShowPointer;
        end;
   'M': begin
         HidePointer;
         if Currptr<13 then GetNextPtrLoc else GetPrevPtrLoc;
         Emu_Color(10,0);
         ShowPointer;
        end;
   'K': begin
         HidePointer;
         if Currptr>12 then GetNextPtrLoc else GetPrevPtrLoc;
         Emu_Color(10,0);
         ShowPointer
        end;
   end {case}
   end
  end
  end
  else accept:=true;
  until accept or GoOffLine Or Not Online;

   if BarMove then FW:= CurrPtr+PN else FW:=CurrPtr;
   Emu_Gotoxy(1,23);
   Emu_Color(15,0);
   ComWrite(' Move Pip ');
   Emu_Color(14,0);
   ComWrite(' TO.....           ');
   DicePick:=1;
   GetNextChoice(FW);
   if CurrPtr=-10 then
    begin
     DicePick:=2;
     GetNextChoice(FW);
    end;
   ShowtoPointer;
   MoveMade :=false;
   repeat
    ch:=' ';
   if (PN=1) or (Not P2IsComputer) then  GetCmd(CH,[' ','K','M',#13,#27]);
   if (PN=-1) and (P2IsComputer) then ch:=#13;
   case ch of
   #27,' ':begin
        accept:=false;
        MoveMade:=true;
        HidetoPointer;
        SetCurrPtr(FW);
        HidetoPointer
       end;
   #13: begin
         MoveMade:=true;
         Emu_Color(12,0);
         ShowtoPointer;
        end;
 'M','K': begin
         HidetoPointer;
         if DicePick=1 then Dicepick:=2 else DicePick:=1;
         GetNextChoice(FW);
         if CurrPtr=-10 then
          begin
           if DicePick=1 then Dicepick:=2 else DicePick:=1;
           GetNextChoice(FW);
         end;
         ShowtoPointer;
        end;
   end; {case}
  until MoveMade or GoOffLine Or Not Online;;
  until (MoveMade and Accept) or GoOffLine Or Not Online;;
  TW:=CurrPtr;
  if TW>25 then Tw:=25;
  if TW<0 then Tw:=0;
  FS:=FW;
  If FW =-2 then FW:=0;
  If FW = 27 then FW:=25;
   case pn of
 1:if Not DoubleFlag then
    begin
    if (R1>0) and (R2>0) then
         begin
           if ((FW+R1)>25) AND ((FW+R2)>25) then
           begin
            if (FW+R1)>(FW+R2) then
             begin
              Emu_gotoxy(57,22);
              comwriteln(' ');
              R2:=0
             end
            else
             begin
              Emu_gotoxy(47,22);
              comwriteln(' ');
              R1:=0
             end
           end
          else
           begin
            if (R1+FW=TW) OR (((R1+FW)>TW) and ((R2+FW)<TW)) then
             begin
              Emu_gotoxy(47,22);
              comwriteln(' ');
              R1:=0
             end
            else
             begin
              Emu_gotoxy(57,22);
              comwriteln(' ');
              R2:=0
             end
           end
         end
        else
         if R1>0 then
          begin
           Emu_gotoxy(47,22);
           comwriteln(' ');
           R1:=0
          end
         else
          begin
           Emu_gotoxy(57,22);
           comwriteln(' ');
           R2:=0
          end
    end;
-1:if Not DoubleFlag then
    begin
    if (R1>0) and (R2>0) then
         begin
           if ((FW-R1)<0) AND ((FW-R2)<0) then
           begin
            if (FW-R1)<(FW-R2) then
             begin
              Emu_gotoxy(57,22);
              comwriteln(' ');
              R2:=0
             end
            else
             begin
              Emu_gotoxy(47,22);
              comwriteln(' ');
              R1:=0
             end
           end
          else
           begin
            if (FW-R1=TW) OR (((FW-R1)<TW) and ((FW-R2)>TW)) then
             begin
              Emu_gotoxy(47,22);
              comwriteln(' ');
              R1:=0
             end
            else
             begin
              Emu_gotoxy(57,22);
              comwriteln(' ');
              R2:=0
             end
           end
         end
        else
         if R1>0 then
          begin
           Emu_gotoxy(47,22);
           comwriteln(' ');
           R1:=0
          end
         else
          begin
           Emu_gotoxy(57,22);
           comwriteln(' ');
           R2:=0
          end
    end;
  end {case}
 end
 end;
 FW:=FS;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.TakeTurn;
 var
   C        : Char;
   Ready    : boolean;
   TmString : String;
   InCh     : Char;
   pNsAV    : Integer;


 begin
  Ready :=false;
  ClearReceive;
  While KeyPressed Do C:= Readkey;
  if PN= 1 then
  begin
   Emu_color(15,8);
   emu_gotoxy(3,16);
   ComWriteln('Player 1');
   Emu_color(15,0);
   emu_gotoxy(3,5);
   ComWriteln('Player 2')
  end
  else
  begin
   Emu_color(15,0);
   emu_gotoxy(3,16);
   ComWriteln('Player 1');
   Emu_color(15,8);
   emu_gotoxy(3,5);
   ComWriteln('Player 2')
  end;
  if FirstRoll then FirstRoll :=false
  else
  begin
  Ready := false;
  Emu_gotoXy(1,23);
  Emu_color(15,0);
  ComWrite('                  ');
  Emu_Gotoxy(60,21);
  ComWrite('                  ');
  Emu_Gotoxy(60,22);
  ComWrite('                   ');
  Emu_Gotoxy(60,23);
  ComWrite('                    ');

  while Not Ready and Online and Not GoOffLine do
  begin
  ShowMsr;
  CLEARRECEIVE;
  IF not P2IsComputer or (PN=1) then
  begin
   EMU_GOTOXY(2,2);
   TimePrompt;
   if Pn=1 then
   begin
   if Not P2IsComputer then
   begin
    EMU_GOTOXY(1,19);
    Emu_Color(11,0);
    ComWriteln(' [E] Enter Message ');
   end
   else
    EMU_GOTOXY(1,20);
    Emu_Color(15,0);
    ComWriteln(' [R] Roll Dice     ');
    Emu_Color(13,0);
    ComWriteln(' [F] Fresh Screen                         ');
    Emu_Color(12,0);
    ComWriteln(' [Q] Quit (Resign/Forfeit)                ');
    Emu_Color(14,0);
    ComWrite(' Selection? =>');
   end
   else
   begin
    GOTOXY(1,19);
    textColor(11);
    Writeln(' [E] Enter Message ');
    TextColor(15);
    Writeln(' [R] Roll Dice     ');
    TextColor(13);
    Writeln(' [F] Fresh Screen                         ');
    TextColor(12);
    Writeln(' [Q] Quit (Resign/Forfeit)                ');
    TextColor(14);
    Write(' Selection? =>')
   end;
   C:='R';
   if Not P2IsComputer then
   GetCmd(C,['R','Q',' ',#13,'F','E'])
   else
   GetCmd(C,['R','Q',' ',#13,'F']);
   if Chwaiting then if Upcase(ComOnlyKey) ='E' then C:='E';
   Emu_Gotoxy(1,23);
   ComWrite('                  ');
  end
    else
     begin
       C:=' ';
       EMU_GOTOXY(1,22);
       Emu_Color(15,0);
       ComWriteln('                                          ');
     end;
   if ReqChat then
    begin
      Chat;
      drawboard;
      showpieces(plyr1.Color,Plyr2.color);
    end
  else
  begin
   Emu_Color(15,0);
   if Not P2IsComputer then
   begin
    EMU_GOTOXY(1,19);
    ComWriteln('                      ');
   end
   else
   EMU_GOTOXY(1,20);
   ComWriteln('                            ');
   ComWriteln('                            ');
   ComWrite('                                        ');
  case c of
  'E'         : begin
                 Emu_Color(15,0);
                 Emu_GotoXy(1,22);
                 ComWrite(' Enter Your Message.');
                 Emu_GotoXy(1,24);
                 ComWrite('                                                                               ');
                 Emu_GotoXy(2,24);
                 TmString:='';
                 Inch :=#0;
                 while (Length(TmString)<76) and (InCh<>#13) and Online and Not GoOffLine do
                 begin
                  Getchars(InCh);
                  if (InCh=#8) and (Length(TmString)>1) then
                   begin
                    TmString:=Copy(TmString,1,Length(TmString)-1);
                    ComWrite(#8+' '+#8)
                   end
                  else
                  if InCh > #9 then
                  begin
                   ComWrite(Inch);
                   TmString:=TmString+InCh
                  end
                 end
                end;

  'F'         : begin
                 PnSav :=Pn;
                 drawboard;
                 showpieces(plyr1.Color,Plyr2.color);
                  Pn:=PnSav;
                  if PN= 1 then
                   begin
                    Emu_color(15,8);
                    emu_gotoxy(3,16);
                    ComWriteln('Player 1');
                    Emu_color(15,0);
                    emu_gotoxy(3,5);
                    ComWriteln('Player 2')
                   end
                  else
                   begin
                    Emu_color(15,0);
                    emu_gotoxy(3,16);
                    ComWriteln('Player 1');
                    Emu_color(15,8);
                    emu_gotoxy(3,5);
                    ComWriteln('Player 2')
                   end;
                end;
  #13,'R',' ' : begin
                 rolldice;
                 ready:=true;
                end;
  'Q' :  begin
           if ( Pos('Chris Neubauer',PLyr1.Name)=0) and P2IsComputer then Player2Wins
            else Quit :=true;
           Ready:=true;
           Gameover:=true;
           if Not quit then
           begin
            DrawBoard;
            initBd;
            showpieces(plyr1.Color,Plyr2.color)
           end
         end;
     end{case}
    end
   end
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.PickDoubles;
 var
  St : string;
  CD : Char;
 begin
  R1:=6;
  R2:=6;
  Emu_color(15,0);
  Emu_gotoXy(1,23);
  ComWrite('                    ');
  repeat
  Str(R1, St);
  Emu_gotoxy(47,22);
  comwriteln(St);
  Str(R2, St);
  Emu_gotoxy(57,22);
  comwriteln(St);
  Emu_gotoXy(1,22);
  Emu_color(15,0);
  ComWrite('            Use '+#24+#25+' To Pick Your Doubles => ');
  GetCmd(CD,['M','K',#13]);
  Case Cd of
   'K':begin
        R1:=R1+1;
        if R1 >6 then R1 :=1;
        R2:=R1
       end;
   'M':Begin
        R1:=R1-1;
        if R1 <1 then R1 :=6;
        R2:=R1
       end
  end;
  Until (Cd=#13) or GoOffLine Or Not Online;
  Emu_gotoXy(12,22);
  Emu_color(15,0);
  ComWrite('                                 ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.CPickDoubles;
 var
  MoveCnt,I,
   Isav     : integer;
  CntStore  : array [1..6] of integer;
  St        : string;


 begin
   Emu_gotoXy(1,22);
   Emu_color(15,0);
   ComWrite('                  Selecting Doubles....   ');
   Delay(800);
   Emu_gotoXy(1,23);
   ComWrite('                    ');
  for R1:=1 to 6 do
  begin
   R2:=R1;
   Emu_color(15,0);
   Str(R1, St);
   Emu_gotoxy(47,22);
   comwriteln(St);
   Str(R2, St);
   Emu_gotoxy(57,22);
   comwriteln(St);
   R2:=0;
   MoveCnt:=0;
   if BD[26]<>0 then
    begin
     I:=26;
     DicePick:=1;
     GetNextChoice(25);
     if CurrPtr<>-10 then Movecnt:=Movecnt+4;
    end
   else
    for I:= 1 to 24 do
    if VALID(I) and (Bd[I]*PN >0) Then Movecnt:=Movecnt+Bd[I]*PN;
   CntStore[R1]:=MoveCnt;
  end;

  MoveCnt :=0;
  Isav :=0;
  for I:=1 to 6 do if CntStore[I] >= MoveCnt then
   begin
    MoveCnt:=CntStore[I];
    Isav :=I;
   end;
   if Isav =0 then Isav :=6;
   R1:=Isav;
   R2:=R1;
   Emu_color(15,0);
   Str(R1, St);
   Emu_gotoxy(47,22);
   comwriteln(St);
   Str(R2, St);
   Emu_gotoxy(57,22);
   comwriteln(St);
   Emu_gotoXy(12,22);
   Emu_color(15,0);
   ComWrite('                                 ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetStarter(var NM: boolean);
 var
   St :string;

 begin
  Pn:=1;
  FirstRoll :=True;
  emu_Color(14,0);
  Emu_gotoxy(47,22);
  emu_Color(PLyr1.Color,0);
  comwrite('ณ');
  Emu_gotoxy(57,22);
  emu_Color(PLyr2.Color,0);
  comwrite('ณ');
  JoinIt:=false;
  IF Not Local and P2IsComputer then
  begin
   gotoXy(1,24);
   TextColor(15);
   TextBackground(0);
   Write(' SysOp .. Press [F5] to Join Game..... ');
  end;
  Emu_gotoXy(1,23);
  Emu_color(15,0);
  ComWrite(' ROLL For Start <ENTER> ');
  GetEnterKey;
   gotoXy(1,24);
   TextColor(15);
   TextBackground(0);
   Write('                                       ');
   if JoinIt then
   begin
    Emu_gotoXy(1,24);
    Emu_color(15,0);
    Plyr2.Name :=SysopName;
    ComWrite(' '+SysOpName+' ONLINE AND PLAYING LOCAL '+#7+#7);
    Emu_color(Plyr2.color,0);
    emu_gotoxy(3,6);
    ComWriteln(Plyr2.Name);
    JoinIt:=false
   end;
    R1:=3;
    R2:=3;
    while OnLine and Not GoOffLine and (R1=R2) do
    begin
     emu_Color(14,0);
     R1 := 1+round(5*random);
     R2 := 1+round(5*random);

     Emu_gotoxy(47,22);
     comwriteln('ณ');
     Emu_gotoxy(57,22);
     comwriteln('ณ');
     R1 := 1+round(5*random);
     R2 := 1+round(5*random);
     Emu_gotoxy(47,22);
     comwriteln('\');
     Emu_gotoxy(57,22);
     comwriteln('/');
     R1 := 1+round(5*random);
     R2 := 1+round(5*random);
     Emu_gotoxy(47,22);
     comwriteln('ณ');
     Emu_gotoxy(57,22);
     comwriteln('ณ');
     R1 := 1+round(5*random);
     R2 := 1+round(5*random);
     Str(R1, St);
     Emu_gotoxy(47,22);
     emu_Color(PLyr1.Color,0);
     comwriteln(St);
     Str(R2, St);
     Emu_gotoxy(57,22);
     emu_Color(PLyr2.Color,0);
     comwriteln(St);
     delay(100);
    end;


    if R2>R1 then
    begin
     NM:=True;
     Emu_gotoXy(1,23);
     Emu_color(15,0);
     ComWrite(' '+Plyr2.Name+' will Move First');
     PN := -1;
     delay(1500);
     ClearReceive;
    end
    else
    begin
     NM:=false;
     Emu_gotoXy(1,23);
     Emu_color(15,0);
     ComWrite(' '+Plyr1.Name+' will Move First');
     PN := 1;
     delay(1500);
     ClearReceive;
    end;
    if ((R1+R2)=3) and (GameType=1) then
    begin
     Emu_gotoXy(31,22);
     Emu_color(15,0);
     ComWrite(' Acey-Deucey ');
    end;
    Emu_gotoXy(1,23);
    Emu_color(15,0);
    ComWrite('                                        ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function LockedOut : Boolean;
  var
    Locked : boolean;
    I      : Integer;

 begin
  Locked :=False;
  case Pn of
  -1: begin
        if Bd[26] < 0 then
         begin
          Locked :=true;
          for I:= 19 to 24 do
          if Bd[I] < 2 then Locked :=False;
         end
      end;
   1: begin
        if Bd[-1] >0 then
         begin
          Locked :=true;
          for I:= 1 to 6 do
          if Bd[I] >-2 then Locked :=False;
         end
      end;
  end; {case}
  Lockedout :=Locked
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.MainFlow;
 var
  FROMWHERE, TOWHERE,
  Height   : INTEGER;
  NoMove   : boolean;
  C        : Char;
  pass     : byte;
  NumPasses: byte;
  AceyFlag : boolean;
  ConTinue : boolean;
  Abort    : boolean;

 begin
 DrawBoard;
 repeat
 checkTimeLeft;
 showmsr;
 GameOver :=false;
 QUIT     :=false;
 Abort    :=false;
 Initbd;
 showpieces( PLYR1.COLOR, PLYR2.COLOR);
 getstarter(NoMove);
 P2IsComputer:= (pos('COMPUTER',PLYR2.NAME) >0) ;

 repeat
  continue:=true;

  Pn:=1;

  If LockedOut then
    begin
     if not Quit and not GameOver and Online and Not GoOffLine then
      begin
       Emu_Gotoxy(1,22);
       Emu_Color(12,8);
       ComWrite('                            ');
       Emu_Gotoxy(1,23);
       ComWrite(' NO Valid Rolls      ');
       ComWriteO(#7);
       delay(2000)
      end
    end
  else
  while not Quit and Not Gameover and not GoOffLine
          and Continue and Online and Not NoMove do
  begin
  Nomove:=false;
  Continue:=false;
  checkTimeLeft;
  TakeTurn;
  if GameOver then Abort:=true;
  DoubleFlag:=(R1=R2);
  AceyFlag  :=(((R1=1) and (R2=2)) or ((R1=2) and (R2=1))) and (GameType>0);
  if DoubleFlag then
    NumPasses :=4
  else NumPasses :=2;
  pass := 0;
  while not Quit and (pass< NumPasses) and
   Not Gameover  and not GoOffLine and Online and Not NoMove do
   begin
    pass:=pass+1;
    getpmove(Fromwhere,ToWhere,Nomove);
    if Not NoMove then
    begin
     pickpip(FROMWHERE);
     putpip(plyr1.color,ToWhere);
     hidetopointer;
     plyr1.pntr:=FROMWHERE;
     hidepointer;
    end;
    if DoubleFlag and (pass>1) then Doubleflag:=false;
    GameOver := (Bd[0]< -14) or (Bd[25]> 14);
    if NOT NoMove and Not Gameover and AceyFlag and (pass>1) then
     begin
      AceyFlag:=false;
      Continue :=true;
      DoubleFlag:=true;
      pass:=0;
      NumPasses :=4;
      PickDoubles
     end
   end;
   If NoMove then Continue:=false;
   if Continue and Not Gameover and Not Quit and Online and Not GoOffLine then
    begin
     Emu_gotoXy(1,23);
     Emu_color(15,0);
     ComWrite(' ROLL AGAIN <ENTER> ');
     GetEnterKey;
     Emu_gotoXy(1,23);
     ComWrite('                    ')
    end
  end;

   if GameOver and Not abort then
   begin
    player1wins;
    if Not Quit then Drawboard
   end;
   Nomove:=false;
   Continue :=true;
  Pn:=-1;

    If LockedOut then
    begin
     if not Quit and not GameOver and Online and Not GoOffLine then
      begin
       Emu_Gotoxy(1,22);
       Emu_Color(12,8);
       ComWrite('                            ');
       Emu_Gotoxy(1,23);
       ComWrite(' NO Valid Rolls      ');
       ComWriteO(#7);
       delay(2000)
      end
    end
  else
 while not Quit and not GameOver and Online and Not GoOffLine
        and Continue and Not NoMove do
   begin
    TakeTurn;
    if GameOver then Abort:=true;
    Continue :=false;
    AceyFlag  :=(((R1=1) and (R2=2)) or ((R1=2) and (R2=1))) and (GameType>0);
    DoubleFlag:=(R1=R2);
    if DoubleFlag then NumPasses :=4
    else NumPasses :=2;
    pass := 0;
    NoMove:=false;
    while not Quit and not GameOver and Not NoMove
    and (pass< NumPasses) and not GoOffLine and Online do
    begin
     pass:=pass+1;
     if P2IsComputer then getCmove(Fromwhere,ToWhere,Nomove)
      else
      getPmove(Fromwhere,ToWhere,Nomove);
     if Not NoMove then
     begin
      pickpip(FROMWHERE);
      putpip(plyr2.color,ToWhere);
      hidetopointer;
      plyr2.pntr:=FROMWHERE;
      hidepointer;
     end;
    if DoubleFlag and (pass>1) then Doubleflag:=false;
    GameOver := (Bd[0]< -14) or (Bd[25]> 14);

    if NOT NoMove and Not Gameover and AceyFlag and (pass>1) then
     begin
      Continue:=true;
      AceyFlag:=false;
      DoubleFlag:=true;
      pass:=0;
      NumPasses :=4;
      if Not P2IsComputer then PickDoubles
      else
      CPickDoubles
     end
    end;
   If NoMove then Continue:=false;
   if Continue and Not Gameover and Not Quit and Online and Not GoOffLine then
    begin
     Emu_gotoXy(1,23);
     Emu_color(15,0);
     if Not P2IsComputer then
     begin
      ComWrite(' ROLL AGAIN <ENTER> ');
      GetEnterKey;
      Emu_gotoXy(1,23);
      ComWrite('                    ')
     end
     else
     ComWrite(' ROLLING AGAIN ')
    end;
   if GameOver and Not Abort then
   begin
    player2wins;
    if Not Quit then DrawBoard
   end
   end;
  Nomove:=false;
 GameOver := (Bd[0]< -14) or (Bd[25]> 14)
 until GameOver or Quit or GoOffLine Or Not Online;;
 if Not Quit and Online and Not GoOffLine then showpieces(0,0);
 until Quit or GoOffLine Or Not Online
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.RUNX;
 var
  C : Char;
  Yhit : boolean;

 begin
  SHOWMSR;
  C:=#0;
  ComWriteln('');
  Yhit :=False;
  ComWriteln(' BBS BackGammom And Acey-Deucey  Ver.'+Vrs);
  if Not PlayerFound and not Local then
   begin
    ComWrite(' Are You Using ANSI Graphics ?? (Y/n) ');
    getYn(Yhit,false);
    if Not Yhit then
     begin
      ComWriteln('');
      if TimeLeft < 1 then
      ComWriteln(' Out of Time... or Door File Configuration Error..   ')
      else
      ComWriteln(' Sorry. This Door Requires the Use of ANSI Graphics.... ');
      delay(3000);
     end
   end
  else
   begin
    Yhit :=true;
    Delay(1000)
   end;

  if Yhit then
  repeat
  if (Online and Not GoOffLine) then
  MainMenu;
  P2IsComputer:=True;
  PLYR2.NAME :='COMPUTER';
  PN:=1;
  Emu_Color(15,0);
  ComWriteln('');
  ComWrite(' Selection? =>');
  Getchar(C,['A','B','Q','R','I','P']);
  if ReqChat then Chat
  else
  begin
  if (Online and Not GoOffLine) then
    begin
     case C of
     'P': begin
           if Not Registered then
            begin
             Emu_clearscreen;
             ComWriteln('');
             ComWriteln(' Registration Required for Sysop Play ');
             Writeln(' Please Register.. to enable F-Keys. ');
             ShowMsr;
             delay(2000)
           end
           else
           PageSysOp;
          end;
     'B': begin
            Comwriteln('');
            PLYR1.COLOR :=13;
            gameType :=0;
            SelectPlayerColor;
            Initbd;
            if Online and Not GoOffLine then mainflow
           end;
     'A': begin
            Comwriteln('');
            PLYR1.COLOR :=13;
            PLYR2.COLOR :=9;
            GameType :=1;
            SelectPlayerColor;
            Initbd;
            if Online and Not GoOffLine then mainflow
           end;
      'R' : begin
             ShowRankings;
            end;
      'I' : begin
             Instructions;
            end;
      end {case}
    end
   end;
  until (C='Q') or Not Online or GoOffLine;
  if GoOffLine Then
  begin
   Emu_Color(15,0);
   Emu_ClearScreen
  end;
  SHOWMSR;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetData;
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
  I,TmpJ     : integer;
  Code       : integer;
  TmpTime    : integer;
  SecTime    : real;
  TimeStr    : String[5];
  LocChk     : String;

 begin
  {$I-}
  assign(ConfigFile,'BBSBGM.CFG');
  reset(ConfigFile);
  if IoResult <>0 then
   begin
    Writeln;
    Writeln(' No Config file ..."BBSBGM.CFG"... Execution Halted ');
    done;
    halt(1)
   end
  {$I-}
   else
    begin
     readln(Configfile,RN);
     readln(Configfile,COMNUM);
     readln(Configfile,BAUD);
     readln(Configfile,SysOpName);
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
     readln(Configfile, TimeStr);
     TmpJ := pos('M',Upper(TimeStr));
     if TmpJ >2 then
      begin
      Code:=1;
      if pos('AM',Upper(TimeStr))>0 then
        begin
         Val(Copy(TimeStr,1, pos('AM',Upper(TimeStr))-1),TmpTime,code);
         if Code =0 then StartPage :=TmpTime*60;
        end
      else
      if pos('PM',Upper(TimeStr))>0 then
       begin
         Val(Copy(TimeStr,1, pos('PM',Upper(TimeStr))-1),TmpTime,code);
          if TmpTime >0 then
         begin
          if Code =0 then StartPage :=TmpTime*60;
          StartPage :=StartPage +720;
         end
       end;
       if StartPage >1640 then StartPage :=StartPage-1640;
      end;
      readln(Configfile, TimeStr);
      while Pos(' ',TimeStr)>0 do delete(TimeStr,Pos(' ',TimeStr),1);
      Val(TimeStr,TmpTime,code);
      if Code=0 then Duration :=TmpTime;
      readln(Configfile, Boovar);
      UseRTS := Boovar =1;
      readln(Configfile, Boovar);
      UseCTS := Boovar =1;
     close(Configfile);
     CheckRegistered
    end;
  If Not Local then
  begin
  {$I-}
  while BBSDIR[length(BBSDIR)] =' ' do delete( BBSDIR,length(BBSDIR),1);
  assign(ConfigFile,BBSDIR+'\'+UFILE);
  reset(ConfigFile);
  if IoResult <>0 then
   begin
    Writeln;
    Writeln(' No USER file ',BBSDIR+'\'+UFILE,' ... Execution Halted ');
    Writeln(' To Run Local type "BBSBGM Your Name" ');
    Done;
    halt(1)
   end
  {$I-}
   else
    begin
     While Not Eof(ConfigFile) do
      begin
       Readln(ConfigFile,LocChk);
       if Pos('COM0', LocChk) >0 then Local :=true;
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
     readln(Configfile,BAUD);
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
   end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 VAR
   i         : Word;
  XXX        : XXBBS;
  chh        : CHAR;
  abort      : boolean;
  YHIT       : boolean;
  TmpStr     : string;
  code       : integer;

BEGIN
 textBackground(0);
 PLYR2.COLOR :=9;
 CLRSCR;
 UseRTS :=False;
 USeCTS :=False;
 Auto :=FALSE;
 XXX.GoOffLine:=false;
 abort:=false;
 textcolor(14);
 XXX.INIT;
 XXX.UserInit;
 if paramcount > 0 then
  begin
  XXX.LOCAL:=TRUE;
  XXX.UNAME:= paramStr(1)+' '+paramStr(2);
  FORMATNAME(XXX.UNAME);
  SYSOPNAME:='';
  XXX.getdata;
  XXX.TIMELIMIT:=60;
  XXX.TIMEUSED:=0;
  BAUD:=0;
  XXX.SETBPS(0);
  end
  else XXX.getdata;

 XXX.SHOWMSR;
 XXX.RUN;
 XXX.INITIALIZE;
 XXX.SHOWMSR;
 IF Not XXX.Online then
    Writeln(' To Run Local type "BBSBGM Your Name" ');
  Quit :=false;
  PLYR1.NAME :=XXX.UNAME;
  PLYR2.NAME :='COMPUTER';
  PLYR1.PNTR :=0;
  PLYR2.PNTR :=0;
 if (XXX.ONLINE) then
  begin
   XXX.SHOWMSR;
   XXX.Clearreceive;
  if XXX.ONLINE then XXX.StartTime:=XXX.TimeNow;
    XXX.SHOWMSR;
    delay(50);
   IF (XXX.ONLINE and Not XXX.GoOffLine) or (BAUD =0)  THEN XXX.RUNX;
   if XXX.Online and Not XXX.GoOffLine then
   begin
    XXX.emu_gotoxy(1,22);
    XXX.Emu_Color(12,0);
    if XXX.TimeLeft<1 then
    XXX.COMWRITELN(' Time Limit Exceeded....');
    XXX.Emu_Color(15,0);
    if XXX.Local then  BBSNAME:='DOS';
    XXX.COMWRITELN(' Returning to '+BBSNAME);
    delay(2000);
    XXX.SHOWMSR
   end;
 while keypressed do abort :=(readkey=#27)
 end;
 if not XXX.Online then
  begin
   writeln(' No Carrier Detected ');
   delay(500)
  end;
 XXX.Emu_Color(7,0);
 XXX.ComWrite(' ');
 XXX.DONE;
END.
