{$M 32767,0,655360}

PROGRAM Poker;

uses Crt,Dos,BBSGam,BBSScrn;

const
 Vrs  =' 1.11';

 CardChar  : Array[1..13] of Char=
       ('A','2','3','4','5','6','7','8','9','1','J','Q','K');

TYPE
  Cards       = Record
                 Value : Byte;
                 Suit  : Byte;
                 Dealt : Boolean;
                end;

  Hand        = Array[1..15] of Byte;
  DeckOCards = Array[1..52] of Cards;
  CharSet    = set of Char;

  XXBBS = OBJECT(TBBS)
           Procedure Decide(PHand, DHand : Byte; Pbust,DBust,PJack,DJack,PFC,DFC: Boolean; Wag : Real);
           Procedure GetBet (var  TWager : Real);
	   Procedure BMainFlow;
	   Procedure FMainFlow;
	   Procedure Initialize;
           Procedure ShowArrow;
           Procedure HideArrow;
	   Procedure CheckRegistered(var BR : BBSData);
           Procedure ClearPanel(Which : Byte);
           Procedure ClearInsLine;
           Procedure ClearInsLine2;
	   Procedure Instructions;
	   Procedure GetCmd(var Ychar : char; Cset: CharSet);
           Procedure ShowFLogo;
	   Procedure ShowLogo;
           Procedure ShowPickMenu(var CHrst: CharSet);
           Procedure ShowOutCome(Clr:Byte; ST: String; Mult : Integer);
           Procedure DecideOutCome;
           Procedure FShowPickMenu;
           Procedure ShowWager(Y : Byte);
           Procedure ShowBucks(Y : Byte);
           Procedure ShuffleCards;
	   Procedure DrawBoard;
	   Procedure FDrawBoard;
           Procedure Redraw;
           Procedure FRedraw;
           Procedure ShowCard(Who ,CardPos : Byte; FaceUp : Boolean);
           Procedure ShowCards;
           Procedure FShowCards;
           Procedure ShowDHandVal;
           Procedure ShowYHandVal;
           Procedure ShowYHandVal2;
	   Procedure mainmenu;
           Procedure UpDateRankings;
           Procedure Rankings;
           Procedure HOF;
	   Procedure RUNX( var Savem : Boolean );
	  end;
var
  XXX            : XXBBS;
  Deck           : DeckOCards;
  GameCount      : Integer;
  Cash           : Real;
  Wager          : Real;
  GameOver       : boolean;
  Quit           : Boolean;
  CheckSet       : CharSet;
  YourHand       : Hand;
  DealHand       : Hand;
  DOrValue       : Byte;
  YOrValue       : Byte;
  YOrValue2      : Byte;
  YCardsShowing  : Byte;
  YCardsShowing2 : Byte;
  DCardsShowing  : Byte;
  YBusted        : Boolean;
  YBusted2       : Boolean;
  DBusted        : Boolean;
  DBlackJack     : Boolean;
  YBlackJack     : Boolean;
  YBlackJack2    : Boolean;
  DFCC           : Boolean;
  YFCC           : Boolean;
  YFCC2          : Boolean;
  Standing       : Boolean;
  TwoHands       : Boolean;
  Playing1stHand : Boolean;
  HasInsurance   : Boolean;
  ArrowPos       : Byte;
  Select         : Array [1..5] of Boolean;


{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function IToStr(I,P : Integer): String;
 var
  TStr : String;
  begin
   Str(I:P,TStr);
   IToStr := TStr
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function LToStr(I: real): String;
 var
  TStr : String;
  begin
   Str(I:0:0,TStr);
   LToStr := TStr
  end;
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
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function RToStr(I: Real; P : Integer): String;
 var
  TStr : String;
  Xp   : Byte;
  begin
   TsTr :='0';
   Str(I:P:0,TStr);
   TStr :=' '+TStr;
   Xp :=0;
   While Xp <=Length(TStr) do
   begin
    Xp:=Xp+1;
    if TStr[Xp]<>' ' then
     begin
      TStr[Xp-1] :='$';
      Xp :=255;
     end;
   end;
   RToStr := TStr
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
 with BR do
  begin
  Code:='';
  I:=Pos('  ',SysOpName);
  if I>0 then SYSopName[0] := Chr(I-1);
  I:=Pos('  ',RN);
  if I>0 then RN[0] := Chr(I-1);
  I:=Pos('  ',BBSName);
  if I>0 then BBSName[0] := Chr(I-1);
  While Length(BBSName)< 25 do BBSName :=BBSName +' ';
  LSN := Length(SysOpName);
  if LSN >0 then
  begin
   for I:=1 to LSN do
    Begin
     Sum := ord(SysOpName[I]) + ord(BBSName[I]);
     Sum:= Sum Mod 71;
     Sum :=Sum+42;
     Code :=Code+Chr(Sum)
    end;
   Registered :=( RN=Code);
  end
  else
   Registered :=False;
  if Not Registered then
   begin
    textcolor(15);
    Clrscr;
    Writeln('B B S   P O K E R');
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
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ClearInsLine;
 begin
   Emu_GotoXy(1,24);
   Emu_Color(15,0);
   ComWrite(' ');
   Emu_ClearToEndOfLine;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ClearInsLine2;
 begin
   Emu_GotoXy(1,23);
   Emu_Color(15,0);
   ComWrite(' ');
   Emu_ClearToEndOfLine;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ClearPanel(Which : Byte);
 var
  I :Integer;
 begin
  Emu_Color(15,0);
  Case Which Of
  1: begin
      For I := 4 to 11 do
      begin
       Emu_GotoXy(1,I);
       ComWrite(' ');
       Emu_ClearToEndOfLine;
      end
     end;
  2: begin
      For I := 14 to 22 do
      begin
       Emu_GotoXy(1,I);
       ComWrite(' ');
       Emu_ClearToEndOfLine
      end
     end
   end {case}
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.Instructions;
 var
  C : Char;
 begin
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    Clrscr;
    emu_color(0,7);
    Comwrite('                    Instructions For Playing BBS POKER                         ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    if Exist('Poker.INS') then TypeFileMore('Poker.INS',C)
    else
    ComWriteln('Instruction File Missing or Corrupted......');
    ComWriteln('');
    GetCr(10)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.UpDateRankings;
 var
  RFile       : Text;
  TFile       : Text;
  InPutLine   : NameString;
  FoundEm     : Boolean;
  GamesPlayed : Word;
  Bucks       : Real;
  DateStr     : String[8];
  DumSpace    : Char;
  CashSave    : Real;

  begin
   CashSave :=Cash;
   If Cash<0 then Cash:=0;
   GameCount:=GameCount +1;
   Foundem :=False;
   ClearInsLine;
   ComWriteln('');
   ComWrite('Updating Rankings....');
   Assign(RFile,'Poker.RNX');
   Assign(TFile,'Poker.Tmp');
   ReWrite(TFile);
    {$I-}
   Reset(RFile);
    {$I+}
    If IoResult<>0 then
     begin
      ReWrite(RFile);
      Reset(RFile);
     end;
    while not eof(Rfile) do
     begin
      Readln(RFile,InputLine,Bucks,GamesPlayed,DumSpace,DateStr);
      if Not FoundEm and ((pos(BRec.UName,InputLine)>0) or (Cash>Bucks)) then
       begin
          if Cash> Bucks then
           begin
            Writeln(TFile,Brec.Uname,' ',Cash,' ',GameCount,' ',Date);
            if (pos(BRec.UName,InputLine)=0) then
            Writeln(TFile,InputLine,' ',Bucks,' ',GamesPlayed,' ',DateStr);
            Cash:=0;
            FoundEm :=True;
           end
       end
      else
      if (pos(BRec.UName,InputLine)=0) then
      Writeln(TFile,InputLine,' ',Bucks,' ',GamesPlayed,' ',DateStr);
     end;
    Close(RFile);
    if Not FoundEm then
      Writeln(TFile,Brec.Uname,' ',Cash,' ',1,' ',Date);
    Close(TFile);
    Erase(RFile);
    Rename(Tfile,'Poker.RNX');
    if IOResult<>0 then Writeln('I/O error...');
    Cash :=CashSave
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure UpDateHOF;
 var
  RFile       : Text;
  TFile       : Text;
  HFile       : Text;
  InPutLine   : NameString;
  FoundEm     : Boolean;
  GamesPlayed : Word;
  Bucks       : Real;
  InPutLine2  : NameString;
  Bucks2      : Real;
  DateStr     : String[8];
  DumSpace    : Char;
  Sline       : String;

  begin
   Foundem :=False;
   Assign(RFile,'Poker.Rnx');
   Assign(HFile,'Poker.Hof');
   Assign(TFile,'Poker.Tmp');
   ReWrite(TFile);
    {$I-}
   Reset(RFile);
    {$I+}
    If IoResult<>0 then
     begin
      ReWrite(RFile);
      Reset(RFile);
     end;
    {$I-}
   Reset(HFile);
    {$I+}
    If IoResult<>0 then
     begin
      ReWrite(HFile);
      Reset(HFile);
     end;
    Readln(RFile,InputLine,Bucks,GamesPlayed,DumSpace,DateStr);
    while not eof(Rfile) do
     begin
      Readln(RFile,SLine);
      Writeln(TFile,Sline);
     end;
    Close(RFile);
    Close(TFile);
    Erase(RFile);
    Rename(Tfile,'Poker.RNX');
    Assign(TFile,'Poker.Tmp');
    ReWrite(TFile);
    while not eof(Hfile) do
     begin
      Readln(HFile,InputLine2,Bucks2,DumSpace,DateStr);
      if Not FoundEm and ((pos(InputLine,InputLine2)>0) or (Bucks > Bucks2)) then
       begin
        if (Bucks > Bucks2) then
           begin
            Writeln(TFile,InputLine,' ',Bucks,' ',Date);
            Writeln(TFile,InputLine2,' ',Bucks2,' ',DateStr);
            FoundEm :=True;
            Bucks:=0;
           end
        end
      else
      Writeln(TFile,InputLine2,' ',Bucks2,' ',DateStr);
     end;
    Close(HFile);
    if Not FoundEm then
      Writeln(TFile,InputLine,' ',Bucks,' ',DateStr);
    Close(TFile);
    Erase(HFile);
    Rename(TFile,'Poker.Hof');
    if IOResult<>0 then Writeln('I/O error...')
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure DateChk;
  var
   Datstr   : String[8];
   DFile    : Text;
 begin
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
    ReWrite(DFile);
    Writeln(Dfile,Date);
    Close(Dfile);
    if Copy(DatStr,1,2)<> Copy(Date,1,2) then
     begin
      UpdateHOF
     end
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.Rankings;
 var
  RFile       : Text;
  GamesPlayed : Word;
  Bucks       : Real;
  InPutLine   : NameString;
  DateStr     : String[8];
  DumSpace    : Char;
  Abort       : Boolean;
  LCount      : Byte;
  RCount      : Integer;
  YHit        : Boolean;
  St          : String;
  begin
   Emu_color(14,0);
   textbackground(0);
   emu_ClearScreen;
   Clrscr;
   emu_color(0,7);
   Comwrite('                      BBS-POKER  Player Rankings                               ');
   emu_color(14,0);
   ComWriteln('');
   ComWrite('  Rank  ');
   emu_color(15,0);
   ComWrite('    Name           ');
   emu_color(10,0);
   ComWrite('     Bucks       ');
   emu_color(12,0);
   ComWrite('   Games Played ');
   emu_color(13,0);
   ComWriteln('   Last PLayed');
   emu_color(9,0);
   ComWriteln('อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
   if Exist('Poker.RNX') then
   begin
    Assign(RFile,'Poker.RNX');
    Reset(RFile);
    LCount :=0;
    RCount :=0;
    Abort  := False;
    while not eof(Rfile) and Not Abort and Online do
     begin
      Readln(RFile,InputLine,Bucks,GamesPlayed,DumSpace,DateStr);
      LCount:=Lcount +1;
      RCount:=Rcount +1;
      Emu_Color(15,0);
      ComWrite( IToStr(RCount,4)+'.  ');
      Emu_Color(14,0);
      ComWrite(InputLine);
      Emu_Color(10,0);
      ComWrite('$'+CommaPut(Bucks)+'   ');
      Emu_GotoXy(48,Wherey);
      Emu_Color(12,0);
      ComWrite(IToStr(GamesPlayed,6)+'           ');
      Emu_Color(7,0);
      ComWriteln(DateStr);

      If Lcount > 19 then
       begin
        LCount :=0;
        Emu_Color(15,0);
        ComWriteln('');
        ComWrite(' More ');
        GetYN(Yhit);
        Abort :=Not YHit
       end
     end;
    Close(RFile)
   end;
    ComWriteln('');
    GetCr(15);
    if IOResult<>0 then Writeln('I/O error...')
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.HOF;
 var
  RFile       : Text;
  GamesPlayed : Word;
  Bucks       : Real;
  InPutLine   : NameString;
  DateStr     : String[8];
  DumSpace    : Char;
  Abort       : Boolean;
  LCount      : Byte;
  RCount      : Integer;
  YHit        : Boolean;
  begin
   Emu_color(14,0);
   textbackground(0);
   emu_ClearScreen;
   Clrscr;
   emu_color(0,7);
   Comwrite('                    BBS-POKER   Hall Of Fame                                   ');
   emu_color(14,0);
   ComWriteln('');
   ComWrite('  Rank  ');
   emu_color(15,0);
   ComWrite('    Name           ');
   emu_color(12,0);
   ComWrite('     High Score  ');
   emu_color(13,0);
   ComWriteln('       Date Arrived');
   emu_color(9,0);
   ComWriteln('อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
   if Exist('Poker.HOF') then
   begin
    Assign(RFile,'Poker.HOF');
    Reset(RFile);
    LCount :=0;
    RCount :=0;
    Abort  := False;
    while not eof(Rfile) and Not Abort do
     begin
      Readln(RFile,InputLine,Bucks,DumSpace,DateStr);
      LCount:=Lcount +1;
      RCount:=Rcount +1;
      Emu_Color(15,0);
      ComWrite( IToStr(RCount,4)+'.   ');
      Emu_Color(14,0);
      ComWrite(InputLine);
      Emu_Color(12,0);
      ComWrite('$'+CommaPut(Bucks)+'   ');
      Emu_GotoXy(54,Wherey);
      Emu_Color(7,0);
      ComWriteln(DateStr);

      If Lcount > 19 then
       begin
        LCount :=0;
        Emu_Color(15,0);
        ComWriteln('');
        ComWrite(' More ');
        GetYN(Yhit);
        Abort :=Not YHit
       end
     end;
    Close(RFile)
   end;
    ComWriteln('');
    GetCr(15);
    if IOResult<>0 then Writeln('I/O error...')
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetCmd(var YChar : char; Cset: CharSet);
 var
  timesav : string[8];
  chh: char;
  XS,YS  : integer;
  MinCnt : integer;
  EO     : Boolean;
  begin
   MinCnt :=0;
   Timesav:=time;
   if Online and Not GoOffLine then
   begin
    Ychar:=#0;
    EO:=True;
    repeat
     checkTimeLeft;
     if not local and KeyPressed then
      begin
       if ReadKey=#0 then CheckKey
       else ShowFKeys;
      end;
     if Timesav<>time then
     begin
       XS:=Wherex;
       YS:=Wherey;
       Emu_GotoXY(58,11);
       TimePrompt;
       Emu_GotoXY(XS,YS);
       showmsr;
       Timesav:=time;
       MinCnt:=MinCnt+1;
       if MinCnt >3 then
        begin
          ComWrite(#7);
          Emu_GoToXy(58,11);
          Emu_Color(15,0);
          ComWrite(' Inactivity Warning !!!'+#7+#7);
          if MinCnt>4 then GoOffline:=true
        end
   end;
     if ChWaiting or Local then
      begin
       if Local then
        begin
         if KeyPressed then Ychar:=Upcase(readkey)
        end
       else Ychar:=Upcase(CREADKEY);
       if  Ychar in[#27, #0] then
        begin
           delay(12);
           if Local then
           begin
            if KeyPressed then Ychar:=Upcase(readkey);
           end
           else
           begin
            delay(12);
            Ychar:=CREADKEY;
            delay(12);
           end;
           if ChWaiting Or KeyPressed then
            while YChar = #0 do
              if Local then Ychar:=Upcase(readkey)
              else Ychar:=CREADKEY;
           while YChar = '[' do
            if Local then Ychar:=Upcase(readkey)
            else
              begin
               delay(12);
               Ychar:=CREADKEY;
              end;
           if not Local then while ChWaiting do Ychar:=Upcase(CREADKEY)
           else while keypressed do Ychar:=Upcase(readkey);
           if YChar=#59 then ReqChat:=true;
           if Ychar='A' then Ychar:='H';
           if Ychar='B' then Ychar:='P';
           if Ychar='C' then Ychar:='M';
           if Ychar='D' then Ychar:='K';
        end
       end;
        if Ychar='2' then Ychar:='P';
        if Ychar='3' then Ychar:='Q';
        if Ychar='9' then Ychar:='I';
        if Ychar='4' then Ychar:='K';
        if Ychar='7' then Ychar:='G';
        if Ychar='1' then Ychar:='O';
        if Ychar='6' then Ychar:='M';
        if Ychar='8' then Ychar:='H'
    until (Ychar in Cset) or GoOffLine or Not Online or Quit ;
    if Not local and Keypressed then
     begin
      while Keypressed do chh:=readkey;
      if chh=#59 then reqchat:=true;
      if chh=#68 then GoOffLine:=true;
     end
    end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.Initialize;
 var I : Integer;
 begin
  SetFlowControl(BRec.UseCTS,BRec.UseRTS);
  SHOWMSR;
  if not LoadEmulation('Poker') then
   begin
     writeln(' Unable to Load Poker.EMU..');
     done;
     halt
   end
  Else TType :=1;

  GoOffLine:=false;
  Randomize;
  For I:= 0 to 51 do
  begin
   Deck[I+1].Value := 1+(I Mod 13);
   Deck[I+1].Suit  := 1+(I Div 13)
  end;
  Wager :=0;
  ArrowPos :=1;
  For I:= 1 to 5 do Select[I] :=False;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.mainmenu;
 var I : integer;
 Regstr : string;
 Chh    : Char;
 begin
 clearreceive;
 emu_color(15,0);
 textbackground(0);
 emu_ClearScreen;
 clrscr;
 if Exist('Poker.Scr') then
  begin
   TypeFile('Poker.Scr',Chh);
  end
 else
 begin
  emu_color(14,0);
  ComWriteln('');
 ComWriteln('                             B B S   P O K E R ');
 end;
 emu_color(7,0);
 ComWriteln('');
 ComWriteln('');
 ComWriteln('                          Version'+Vrs+' (c) 1993 ');
 ComWriteln('                       Neubauer Applications Uncorp ');
 ComWriteln('                     Virtual Reality BBS 512-992-4496');
 emu_color(15,0);
 if BRec.Registered then
 With BRec do
 begin
  I:=Pos('  ',BBSName);
  if I>0 then BBSName[0] := Chr(I-1);
  RegStr:=' Registered to '+BBSName;
  Emu_GotoXy(38-(Length(RegStr) div 2),WhereY);
 ComWriteln(RegStr)
 end
 else
 ComWriteln('               UNREGISTERED COPY  ... ASK SYSOP TO REGISTER');
 ComWriteln('');
 emu_color(10,0);
 ComWriteln(' [B]  Black-Jack');
 emu_color(11,0);
 ComWriteln(' [F]  Five Card Draw');
 emu_color(14,0);
 ComWriteln(' [R]  Rankings');
 emu_color(13,0);
 ComWriteln(' [H]  Hall Of Fame');
 emu_color(10,0);
 ComWriteln(' [I]  Instructions');
 emu_color(12,0);
 ComWriteln(' [Q]  Quit Back to BBS');
 showMsr;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowLogo;
 begin
   Emu_gotoXy(1,1);
   Emu_Color(14,1);
   ComWrite('     BLACK JACK      ');
   Emu_Color(11,1);
   ComWrite('Ver.'+Vrs+'                                                 ');
   Emu_gotoXy(43,1);
   Emu_Color(15,1);
   ComWriteln(BRec.UName);
   Emu_Color(13,0);
   ComWriteln('อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');

 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowFLogo;
 begin
   Emu_gotoXy(1,1);
   Emu_Color(14,1);
   ComWrite('  Five Card Draw     ');
   Emu_Color(11,1);
   ComWrite('Ver.'+Vrs+'                                                 ');
   Emu_gotoXy(43,1);
   Emu_Color(15,1);
   ComWriteln(BRec.UName);
   Emu_Color(13,0);
   ComWriteln('อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');

 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function FaceTo10(Crd : Byte): Byte;
 begin
  if Crd>10 then FaceTo10 :=10 else FaceTo10 :=Crd
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function YHandValue : Byte;
 var
  I     : Integer;
  Total : Integer;
  AceFound : Boolean;
 begin
  Total :=0;
  YOrValue:=0;
  AceFound := False;
  YFCC     :=False;
    For I := 1 to YCardsShowing  do
     begin
      Total := Total + FaceTo10(Deck[YourHand[I]].Value);
      if Deck[YourHand[I]].Value =1 then AceFound := True;
     end;
  YHandValue := Total;
  if (Total < 12) and AceFound then
  begin
   YOrValue := Total;
   YHandValue:= Total +10
  end;
  YBlackJack := (YCardsShowing =2) and ((Total +10)= 21)and AceFound;
  YBusted := Total >21;
  YFCC :=(YCardsShowing >4) and Not YBusted
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function YHandValue2 : Byte;
 var
  I     : Integer;
  Total : Integer;
  AceFound : Boolean;
 begin
  Total    :=0;
  YOrValue2:=0;
  AceFound := False;
  YFCC2     :=False;
    For I := 6 to 5+YCardsShowing2  do
     begin
      Total := Total + FaceTo10(Deck[YourHand[I]].Value);
      if Deck[YourHand[I]].Value =1 then AceFound := True;
     end;
  YHandValue2 := Total;
  if (Total < 12) and AceFound then
  begin
   YOrValue2 := Total;
   YHandValue2:= Total +10
  end;
  YBlackJack2 := (YCardsShowing2 =2) and ((Total +10)= 21)and AceFound;
  YBusted2 := Total >21;
  YFCC2 :=(YCardsShowing2 >4) and Not YBusted2
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function DHandValue : Byte;
 var
  I     : Integer;
  Total : Integer;
  AceFound : Boolean;
 begin
  Total :=0;
  DOrValue:=0;
  DFCC:=False;
  AceFound := False;
   if DCardsShowing =1 then Total := FaceTo10(Deck[DealHand[2]].Value)
   else
   begin
    For I :=1 to DCardsShowing  do
     begin
      Total := Total + FaceTo10(Deck[DealHand[I]].Value);
      if Deck[DealHand[I]].Value =1 then AceFound := True;
     end
   end;
  DHandValue :=Total ;
  if (Total < 12) and AceFound then
   begin
     DOrValue := Total;
     DHandValue := Total +10
   end;
  DBlackJack := (DCardsShowing =2) and ((Total+10)= 21) and AceFound;
  DBusted := Total >21;
  DFCC:=(DCardsShowing >4) and Not DBusted
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function CanDouble : Boolean;
 begin
  CanDouble := (YCardsShowing =2) and (YHandValue in [10..11]);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function CanSplit : Boolean;
 begin
  CanSplit := (YCardsShowing =2) and (Deck[YourHand[1]].Value=Deck[YourHand[2]].Value);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowPickMenu(var CHrst: CharSet);
 begin
   ClearInsLine;
   Emu_Color(14,0);
   ComWrite('[H] Hit  ');
   Emu_Color(15,0);
   ComWrite('[S] Stand   ');
   if CanDouble and Not TwoHands then
    begin
     Emu_Color(13,0);
     ComWrite('[D] Double Down  ');
     CHrst := CHrst+['D','K'];
    end;
   if CanSplit and Not TwoHands then
    begin
     Emu_Color(11,0);
     ComWrite('[X] Split   ');
     CHrst := CHrst+['X'];
    end;
   Emu_Color(10,0);
   ComWrite('[R]edraw   ');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.FShowPickMenu;
 begin
   Emu_GotoXY(1,23);
   Emu_Color(15,0);
   ComWrite('  Select Cards to DisCard.. ');
   ClearInsLine;
   Emu_Color(14,0);
   ComWrite(' [<-,4,6,->]-Move Selector  ');
   Emu_Color(10,0);
   ComWrite('[SpaceBar]-Select  ');
   Emu_Color(15,0);
   ComWrite('[Enter]-Accept  ');
   Emu_Color(13,0);
   ComWrite('[R]edraw   ');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowBucks(Y : Byte);
 begin
  Emu_GotoXy(20,Y);
  Emu_Color(10,0);
  if Cash > 10000000000000.0 then Cash := 1000000000000.0;
  ComWrite(' $'+CommaPut(Cash)+'          ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowWager(Y : Byte);
 begin
  Emu_GotoXy(50,Y);
  Emu_Color(15,0);
  ComWrite( ' Wager >');
  Emu_Color(10,0);
  ComWrite(' $'+CommaPut(Wager)+'         ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowDHandVal;
 begin
  Emu_GotoXy(1,11);
  Emu_Color(14,0);
  ComWrite(' '+IToStr(DHandValue,3));
  if DOrValue >0 then ComWrite(' or '+IToStr(DOrValue,2));
  ComWrite(' Showing       ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowYHandVal;
 begin
  Emu_GotoXy(1,21);
  Emu_Color(14,0);
  ComWrite(' '+IToStr(YHandValue,3));
  if YOrValue >0 then ComWrite(' or '+IToStr(YOrValue,2));
  ComWrite(' Showing       ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowYHandVal2;
 begin
  Emu_GotoXy(41,21);
  Emu_Color(14,0);
  ComWrite(' '+IToStr(YHandValue2,3));
  if YOrValue2 >0 then ComWrite(' or '+IToStr(YOrValue2,2));
  ComWrite(' Showing       ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.DrawBoard;
 Var
   I :Integer;
 begin
  Emu_ClearScreen;
  ShowLogo;
  Emu_Color(10,0);
  Emu_GotoXy(1,3);
  ComWrite(' Dealer''s Hand...');
  Emu_GotoXy(1,12);
  Emu_Color(13,0);
  ComWriteln('อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
  Emu_Color(11,0);
  ComWrite(' Your Hand..');
  Emu_Color(15,0);
  ComWrite('  Bucks ');
  ShowBucks(13);

 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.FDrawBoard;
 Var
   I :Integer;
 begin
  Emu_ClearScreen;
  ShowFLogo;
  Emu_Color(10,0);
  Emu_GotoXy(1,3);
  ComWrite(' Your Hand..');
  Emu_Color(15,0);
  ComWrite(' Bucks ');
  ShowBucks(3);
  Emu_GotoXy(1,12);
  Emu_Color(13,0);
  ComWriteln('อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
  Emu_GotoXy(1,13);
  Emu_Color(7,0);
  ComWriteln('     Hand               Pays');
  Emu_Color(10,0);
  ComWriteln('    One Pair             1=1');
  Emu_Color(11,0);
  ComWriteln('    Two Pairs            2=1');
  Emu_Color(14,0);
  ComWriteln('    Three Of A Kind      5=1');
  Emu_Color(12,0);
  ComWriteln('    Straight            10=1');
  Emu_Color(13,0);
  ComWriteln('    Flush               15=1');
  Emu_Color(10,0);
  ComWriteln('    Full House          20=1');
  Emu_Color(11,0);
  ComWriteln('    Four Of A Kind      25=1');
  Emu_Color(14,0);
  ComWriteln('    Straight Flush      35=1');



 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShuffleCards;
 var
   I       : Integer;
   Cardnum : Byte;

 begin
  ClearInsLine;
  For I := 1 to 52 do Deck[I].Dealt :=False;
  Emu_GotoXy(1,24);
  Emu_Color(15,0);
   ComWrite('  Shuffling Cards...  ');
  For I:=1 to 10 do
   begin
    Emu_Color(I,0);
    ComWrite('\'+#8);
    CardNum := 1+(Random(52));
    While Deck[CardNum].Dealt do
     begin
       CardNum := 1+(Random(52));
      end;
       ComWrite(#8+'\');
       Delay(5);
       Emu_Color(7+I Mod 8,0);
       ComWrite(#8+'/');
       Delay(5);
    YourHand[I]:=CardNum;
    Deck[CardNum].Dealt :=True;
    While Deck[CardNum].Dealt do  CardNum := 1+(Random(52));
    ComWrite(#8+'\');
    Delay(5);
    ComWrite(#8+'/');
    Delay(5);
    DealHand[I]:=CardNum;
    Deck[CardNum].Dealt :=True;
   end;
    Emu_Color(15,0);
    ComWrite('   Done');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowCard(Who ,CardPos : Byte; FaceUp : Boolean);
  var
   SClr : Byte;
   SSut : Char;
   Cardval : Byte;
   SutVAl  : Byte;
   RowOffs : Byte;

 begin
  if Who =1 then
   begin
     SutVal :=Deck[DealHand[CardPos]].Suit;
     Cardval := Deck[DealHand[CardPos]].Value;
     RowOffs :=0;
   end
   else
   begin
    SutVal :=Deck[YourHand[CardPos]].Suit;
    Cardval := Deck[YourHand[CardPos]].Value;
    RowOffs := 10;
   end;
  Case SutVal of
   1: Begin
       SClr := 0;
       SSut :='';
      end;
   2: Begin
       SClr := 12;
       SSut :='';
      end;
   3: Begin
       SClr := 12;
       SSut :='';
      end;
   4: Begin
       SClr := 0;
       SSut :='';
      end;
   end; {case}

  if Not FaceUp then CardVal :=0;
  Emu_GotoXy(1+((CardPos-1)*8),5+RowOffs);
  Emu_Color(0,7);
  ComWrite('ฺฤฤฤฤฤฟ');
  Emu_GotoXy(1+((CardPos-1)*8),6+RowOffs);
  ComWrite('ณ');
  if Cardval >0 then
   begin
    Emu_Color(SClr,7);
    ComWrite(CardChar[CardVal]);
   end;
  case CardVal of
    0      : begin
              Emu_Color(14,4);
              ComWrite('ฐฐฐฐฐ');
             end;
    11..13 : ComWrite(SSut+'ืื');
    10     : ComWrite('0'+SSut+SSut+SSut);
    8..9   : ComWrite(SSut+SSut+SSut+' ');
    4..7   : ComWrite(SSut+' '+SSut+' ');
    2,3    : ComWrite(SSut+'   ');
    1      : ComWrite('    ');
   end;{case}
  Emu_Color(0,7);
  ComWrite('ณ');
  Emu_GotoXy(1+((CardPos-1)*8),7+RowOffs);
  ComWrite('ณ');
  if Cardval >0 then Emu_Color(SClr,7);
  Case CardVal of
    0      : begin
              Emu_Color(14,4);
              ComWrite('ฐฐฐฐฐ');
             end;
    11..13 : ComWrite('ืืืืื');
    10     : ComWrite(SSut+SSut+' '+SSut+SSut);
    9,7    : ComWrite(' '+SSut+SSut+SSut+' ');
    8,6    : ComWrite(' '+SSut+' '+SSut+' ');
    1,3,5  : ComWrite('  '+SSut+'  ');
    4,2    : ComWrite('     ');

   end;{case}
  Emu_Color(0,7);
  ComWrite('ณ');
  Emu_GotoXy(1+((CardPos-1)*8),8+RowOffs);
  ComWrite('ณ');
  if Cardval >0 then Emu_Color(SClr,7);
  case CardVal of
    0      : begin
              Emu_Color(14,4);
              ComWrite('ฐฐฐฐฐ');
             end;
    11..13 : ComWrite('ืื'+SSut);
    10     : ComWrite(SSut+SSut+SSut);
    8..9   : ComWrite(' '+SSut+SSut+SSut);
    4..7   : ComWrite(' '+SSut+' '+SSut);
    2,3    : ComWrite('   '+SSut);
    1      : ComWrite('    ');
   end;{case}
  if Cardval >0 then  ComWrite(CardChar[CardVal]);
  if CardVal =10 then ComWrite('0');
  Emu_Color(0,7);
  ComWrite('ณ');
  Emu_GotoXy(1+((CardPos-1)*8),9+RowOffs);
  ComWrite('ภฤฤฤฤฤู');

 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowCards;
 var
  I : Byte;
 begin
   ShowCard(1,1,False);
   ShowCard(1,2,False);
   ShowCard(2,1,False);
   ShowCard(2,2,False);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.FShowCards;
 var
  I : Byte;
 begin
   ShowCard(1,1,False);
   ShowCard(1,2,False);
   ShowCard(1,3,False);
   ShowCard(1,4,False);
   ShowCard(1,5,False);
{   ShowCard(1,6,True);
   ShowCard(1,7,True);
   ShowCard(1,8,True);
   ShowCard(1,9,True);
   ShowCard(1,10,True);}
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.Redraw;
 var
  I :Integer;
  begin
   Drawboard;
   ShowCard(1,1,False);
   ShowCard(1,2,True);
   For I := 1 to YCardsShowing do
   ShowCard(2,I,True);
   if TwoHands and Not PLaying1stHand then
    begin
     For I := 1 to YCardsShowing2 do ShowCard(2,I+5,True);
     ShowYHandVal2;
     Emu_GotoXY(1,22);
     Emu_Color(15,8);
     ComWrite('                                          Play 2nd Hand');
    end
   else
    if TwoHands then
     begin
      ShowCard(2,6,True);
      ShowCard(2,7,False);
      Emu_GotoXY(3,22);
      Emu_Color(15,8);
      ComWrite('Play 1st Hand');
     end;
   ShowWager(13);
   ShowDHandVal;
   ShowYHandVal;
   ShowpickMenu(CheckSet);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.FRedraw;
 var
  I :Integer;
  begin
   FDrawboard;
   For I := 1 to 5 do
   ShowCard(1,I,Not Select[I]);
   ShowWager(3);
   FShowPickMenu;
   ShowArrow
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.Decide(PHand, DHand : Byte; Pbust,DBust,PJack,DJack,PFC,DFC: Boolean; Wag : Real);
 begin
  if PBust then
   begin
    Cash :=Cash -Wag;
    ShowBucks(13);
    ClearInsLine;
    ComWrite(' You BUSTED ... You Lose ');
    Emu_Color(10,0);
    ComWrite('$'+ LToStr(Wag));
   end
   else
     if (HasInsurance) and DJack then
      begin
       ShowBucks(13);
       ClearInsLine;
       ComWrite(' Fortunately You Had Insurance.... ');
      end
    else
    if DBust or (PHand > DHand) or (PFC and Not DFC) or (PJack and Not DJAck and Not DFC) then
     begin
      If (PJack or PFC) then Wag:=Wag*2;
      Cash :=Cash +Wag;
      ShowBucks(13);
      ClearInsLine;
      ComWrite(' You WON ');
      Emu_Color(10,0);
      ComWrite('$'+ LToStr(Wag));
     end
    else
    if (PHand < DHand) or (DFC and Not PFC) then
     begin
      if DJack then Wag :=Wag *2;
      Cash :=Cash -Wag;
      ShowBucks(13);
      ClearInsLine;
      ComWrite(' The Dealer Wins... You Lose  ');
      Emu_Color(10,0);
      ComWrite('$'+ LToStr(Wag));
     end
    else
    if (PHand = DHand) and (DFC or (DJack and Not PFC)) then
     begin
      Cash :=Cash -Wag;
      ShowBucks(13);
      ClearInsLine;
      ComWrite(' Dealer Wins .. You Lose ');
      Emu_Color(10,0);
      ComWrite('$'+ LToStr(Wag));
     end
    else
    if (PHand = DHand) or (DFC and PFC) or (PJack and DJack) then
     begin
      Cash :=Cash -Wag;
      ShowBucks(13);
      ClearInsLine;
      ComWrite(' Dealer Wins the Tie .. You Lost ');
      Emu_Color(10,0);
      ComWrite('$'+ LToStr(Wag));
     end

 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.GetBet (var  TWager : Real);
 var
   MaxBet    : Real;
  begin
   MaxBet := (Cash);
   If MAxBet>10000 then MaxBet :=10000;
   ComWrite(' Enter Your Wager  [Q]uit  ');
   if Wager =0 then Wager :=10;
   if Wager > 1000000 then Wager :=1000000;
   ComWrite('[Enter]='+LtoStr(Wager)+'  Max='+LtoStr(MaxBet));
   ComWrite(' ??> ');
   GetRNum(TWager,MaxBet);
  end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.BMainFlow;
 var
   C     : char;
   I	 : Byte;
   NoneFound : Boolean;
   YHit      : Boolean;
   Twager    : Real;

 begin
  if Cash <1 then Cash :=50;
  Repeat
  GameOver := False;
  C:=#0;
  YHit := False;
  Drawboard;
  CheckTimeLeft;
  While Online and Not GoOffLine and Not GameOver and (Cash >0) do
  begin
   ShowMsr;
   ShuffleCards;
   ClearPanel(1);
   ClearPanel(2);
   ShowCards;
   ClearInsLine;
   GetBet(TWager);
   if TWager < 0 then GameOver :=True
   else
   begin
    If TWager<> 0 then Wager := Twager;
    If Wager =0 then Wager :=10;
    ShowWager(13);
    ShowCard(1,2,True);
    ShowCard(2,1,True);
    ShowCard(2,2,True);
    YCardsShowing :=2;
    DCardsShowing :=1;
    TwoHands :=False;
    YBusted2 :=True;
    HasInsurance :=False;
    ShowDHandVal;
    ShowYHandVal;
    If YBlackJack then
    begin
     Emu_GotoXy(1,21);
     Emu_Color(12,8);
     ComWrite('      BLACKJACK           ');
    end;
    Standing :=False;
    if Deck[DealHand[2]].Value =1 then
     begin
      Emu_GotoXy(1,21);
      Emu_Color(15,0);
      ComWriteO(#7);
      ComWrite(' Do You Want Insurance ??? ');
      GetYN(Yhit);
      Emu_GotoXy(1,21);
      ComWrite(' ');
      Emu_ClearToEndOfLine;
      if Yhit then
       begin
        HasInsurance := True;
        Cash :=Cash -(Wager / 2);
        ShowBucks(13);
       end
     end;
    CheckSet :=['R','H','S'];
    ShowPickMenu(CheckSet);
    C:=#0;
    While (Not YBusted and Not Standing) and
          Not GameOver and Online And Not GoOffLine do
    begin
    ShowMsr;
    GetCmd(C,CheckSet);
    if ReqChat then
     begin
      Chat;
      Redraw;
      C:=#0
     end
    else
    case C of
    'X': begin
          I:=YourHand[2];
          YourHand[2]:=YourHand[6];
          ShowCard(2,2,True);
          YourHand[6]:=I;
          ShowCard(2,6,True);
          ShowCard(2,7,False);
          TwoHands :=True;
          ShowYHandVal;
          Emu_GotoXY(3,22);
          Emu_Color(15,8);
          ComWrite('Play 1st Hand');
          If YBlackJack then
           begin
            Emu_GotoXy(1,21);
            Emu_Color(12,8);
            ComWrite('      BLACKJACK           ');
           end;
          PLaying1stHand :=True;
          YCardsShowing2 := 1;
          CheckSet :=['R','H','S','Q',#13];
          ShowpickMenu(CheckSet);
         While (Not YBusted and Not Standing) and PLaying1stHand and
            Not GameOver and Online And Not GoOffLine do
          begin
           GetCmd(C,CheckSet);
           if ReqChat then
            begin
              Chat;
              Redraw;
              C:=#0
            end
           else
           case C of
            'R': Redraw;
            'S': begin
                  Standing := True;
                  Playing1stHand :=False
                 end;
            'H': begin
                  if YCardsShowing < 5 then
                   begin
                    YCardsShowing :=YCardsShowing +1;
                    ShowCard(2,YCardsShowing,True);
                    ShowYHandVal;
                    If YFCC then
                     begin
                      Emu_GotoXy(1,21);
                      Emu_Color(12,8);
                      ComWrite('   FIVE CARD CHARLIE    ');
                      Standing :=True
                     end;
                    end
                   end;
           end {Case}
          end;
          Standing :=False;
          Emu_GotoXY(1,22);
          Emu_Color(15,8);
          ComWrite('                                          Play 2nd Hand');
          YCardsShowing2:=2;
          ShowCard(2,7,True);
          ShowYHandVal2;
          If YBlackJack2 then
           begin
             Emu_GotoXy(40,21);
             Emu_Color(12,8);
             ComWrite('   BLACKJACK       ');
           end;
         ShowpickMenu(CheckSet);
         While Not YBusted2 and Not Standing and
            Not GameOver and Online And Not GoOffLine do
          begin
           GetCmd(C,CheckSet);
           if ReqChat then
            begin
              Chat;
              Redraw;
              C:=#0
            end
           else
           case C of
            'R': Redraw;
            'S': begin
                  Standing := True;
                 end;
            'H': begin
                  if YCardsShowing2 < 5 then
                   begin
                    YCardsShowing2 :=YCardsShowing2 +1;
                    ShowCard(2,5+YCardsShowing2,True);
                    ShowYHandVal2;
                    If YFCC2 then
                     begin
                      Emu_GotoXy(40,21);
                      Emu_Color(12,8);
                      ComWrite('  FIVE CARD CHARLIE   ');
                      Standing :=True
                     end;
                    end
                   end;

           end {Case}
          end;
          Standing:=True;
          Emu_GotoXY(1,22);
          Emu_Color(15,0);
          ComWrite(' ');
          Emu_ClearToendOfLine
 	 end;
    'S': begin
          Standing := True;
 	end;
    'R': begin {up}
          Redraw;
 	end;
    'H': begin
          if YCardsShowing < 5 then
          begin
           YCardsShowing :=YCardsShowing +1;
           ShowCard(2,YCardsShowing,True);
           ShowYHandVal;
           If YFCC then
            begin
             Emu_GotoXy(30,21);
             Emu_Color(12,8);
             ComWrite('FIVE CARD CHARLIE');
             Standing :=True
            end;
          end
         end;
  'D','K': begin
          if YCardsShowing < 5 then
          begin
           YCardsShowing :=YCardsShowing +1;
           ShowCard(2,YCardsShowing,True);
           ShowYHandVal;
           Wager :=Wager*2;
           Standing :=True
          end
         end
       end; { Case};
      end;
   if Not GameOver then
   begin

    ShowCard(1,1,True);
    DCardsShowing :=2;
    ShowDHandVal;
    if DBlackJack then
     begin
      Emu_GotoXy(30,11);
      Emu_Color(12,8);
      ComWrite('Dealer Has BLACKJACK...');
     end;
    If Not YBusted or (Not YBusted2) then
     begin
      While (DHandValue < 17) and Not DBusted and (DCardsShowing <5) and
             Not DBlackJack and Not DFCC and Not GameOver and Online and
             Not GoOffLine do
       begin
        DCardsShowing := DCardsShowing +1;
        ShowCard(1,DCardsShowing,True);
        ShowDHandVal;
        if DFCC then
         begin
          Emu_GotoXy(30,11);
          Emu_Color(12,8);
          ComWrite('Dealer Has FIVE CARD CHARLIE...');
         end;
        if DBusted then
         begin
          Emu_GotoXy(30,11);
          Emu_Color(12,8);
          ComWrite('Dealer Has BUSTED...')
         end
       end
      end;
 if Not GameOver then
        begin
         if TwoHands then
          begin
           Emu_GotoXy(1,23);
           Emu_Color(15,0);
           ComWrite('  1st Hand....');
           Decide(YHandValue,DHandValue,YBusted,DBusted,
                  YBlackJack,DBlackJack,YFCC,DFCC,Wager);
           GetCr(14);
           Emu_GotoXy(1,23);
           Emu_Color(15,0);
           ComWrite('  2nd Hand....');
           Decide(YHandValue2,DHandValue,YBusted2,DBusted,
                  YBlackJack2,DBlackJack,YFCC2,DFCC,Wager);

          end
          else
          Decide(YHandValue,DHandValue,YBusted,DBusted,
                  YBlackJack,DBlackJack,YFCC,DFCC,Wager);
        end;
    end;
   end;
  if Not GameOver then GetCr(11);
  if TwoHands then
   begin
     Emu_GotoXy(1,23);
     Emu_Color(15,0);
     ComWrite('              ')
   end
 end;
  ClearInsLine;
  if Cash <1 then
  begin
    ComWrite(' You Are Out of Cash ... Come Back Tomorrow... ');
    GoOffLine := True;
    Delay(4000);
    Yhit :=False
  end;
  Until Not Yhit or Not Online or GoOffline;
  ClearInsLine;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowArrow;
 begin
  Emu_GotoXy(4+((ArrowPos-1)*8),11);
  Emu_Color(14,0);
  ComWrite('');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.HideArrow;
 begin
  Emu_GotoXy(4+((ArrowPos-1)*8),11);
  Emu_Color(14,0);
  ComWrite(' ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Hasa(B : Byte) : Boolean;
  Var
   I : Integer;
   F : Boolean;
  begin
   F:=False;
   For I :=1 to 5 do
    if Deck[DealHand[I]].Value = B then F := True;
   Hasa :=F
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Flush : Boolean;
  Var
   I : Integer;
   F : Boolean;
  begin
   F:=True;
   For I :=1 to 4 do
    if Deck[DealHand[I]].Suit <> Deck[DealHand[I+1]].Suit then F := False;
   Flush :=F
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Straight : Boolean;
 Var
   I           : Integer;
   T1,T2,T3,T4 : Byte;
   S           : Boolean;
   Smallest    : Byte;
 begin
   S :=False;
   Smallest := 13;
   For I := 1 to 5 do
     if Deck[DealHand[I]].Value < Smallest then
         Smallest :=Deck[DealHand[I]].Value;
     if (Smallest =1) then
       begin
        if Not Hasa(2) then
        Smallest :=9
       end;
     if Smallest <10 then
      begin
       T1 := Smallest + 1;
       T2 := T1 + 1;
       T3 := T2 + 1;
       T4 := T3 + 1;
       I:=0;
       if Hasa(T1) and Hasa(T2) and Hasa(T3) and Hasa(T4) then
        begin
         S:=True;
        end
      end;
  Straight :=S
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function FourOKind : Boolean;
 Var
  MatchCount :Byte;
  I,J        :Byte;
    begin {4 of a kind}
        FourOKind := False;
        MatchCount :=0;
        I :=0;
        While (MatchCount < 3) and (I<2) do
	 begin
          I := I + 1;
          MatchCount :=0;
          J:=0;
          While (MatchCount < 3) and (J<5) do
           begin
            J:= J+1;
            if  J=I then J:=J+1;
            if J < 6 then
             begin
               if Deck[DealHand[I]].Value = Deck[DealHand[J]].Value then
                   MatchCount := MatchCount +1;
             end
           end
	 end;
	if MatchCount >2 then FourOKind := True
       end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function ThreeOKind : Boolean;
 Var
  MatchCount :Byte;
  I,J        :Byte;
    begin {4 of a kind}
        ThreeOKind := False;
        MatchCount :=0;
        I :=0;
        While (MatchCount <2) and (I<3) do
	 begin
          I := I + 1;
          MatchCount :=0;
          J:=0;
          While (MatchCount < 2) and (J<5) do
           begin
            J:= J+1;
            if  J=I then J:=J+1;
            if J < 6 then
             begin
               if Deck[DealHand[I]].Value = Deck[DealHand[J]].Value then
                   MatchCount := MatchCount +1;
             end
           end
	 end;
	if MatchCount >1 then  ThreeOKind := True
       end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function FullHouse : Boolean;
 Var
  MatchCount :Byte;
  MatchNum   :Byte;
  I,J        :Byte;
   begin {FullHouse}
        FullHouse :=False;
        MatchCount :=0;
        I :=0;
        While (MatchCount < 2) and (I<3) do
	 begin
          I := I + 1;
          MatchCount :=0;
          J:=0;
          While (MatchCount < 2) and (J<5) do
           begin
            J:= J+1;
            if J=I then J:=J+1;
            if J < 6 then
             begin
               if Deck[DealHand[I]].Value = Deck[DealHand[J]].Value then
                   MatchCount := MatchCount +1;
                  MatchNum := Deck[DealHand[I]].Value
             end
           end
	 end;
	if MatchCount >1 then
           begin
            MatchCount :=0;
            I :=0;
            While (I<5) and  (MatchCount =0) do
             begin
              I := I+1;
               if Deck[DealHand[I]].Value  <> MatchNum then
                begin
                 J:=0;
                 While (J<5) do
                 begin
                  J:=J+1;
                  if J<>I then
                   begin
                    if Deck[DealHand[I]].Value = Deck[DealHand[J]].Value then
                      MatchCount :=1;
                   end
                 end
                end
             end;
             if MatchCount >0 then  FullHouse :=True
          end;
       end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function TwoPair : Boolean;
 Var
  MatchCount :Byte;
  MatchNum   :Byte;
  I,J        :Byte;
   begin {TwoPair}
        TwoPair :=False;
        MatchCount :=0;
        I :=0;
        While (MatchCount < 1) and (I<4) do
	 begin
          I := I + 1;
          MatchCount :=0;
          J:=0;
          While (MatchCount < 1) and (J<5) do
           begin
            J:= J+1;
            if J=I then J:=J+1;
            if J < 6 then
             begin
               if Deck[DealHand[I]].Value = Deck[DealHand[J]].Value then
                   MatchCount := MatchCount +1;
                  MatchNum := Deck[DealHand[I]].Value
             end
           end
	 end;
	if MatchCount >0 then
           begin
            MatchCount :=0;
            I :=0;
            While (I<5) and  (MatchCount =0) do
             begin
              I := I+1;
               if Deck[DealHand[I]].Value  <> MatchNum then
                begin
                 J:=0;
                 While (J<5) do
                 begin
                  J:=J+1;
                  if J<>I then
                   begin
                    if Deck[DealHand[I]].Value = Deck[DealHand[J]].Value then
                      MatchCount :=1;
                   end
                 end
                end
             end;
             if MatchCount >0 then  TwoPair :=True
          end;
       end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Pair : Boolean;
 Var
  MatchCount :Byte;
  MatchNum   :Byte;
  I,J        :Byte;
   begin {Pair}
        Pair :=False;
        MatchCount :=0;
        I :=0;
        While (MatchCount < 1) and (I<4) do
	 begin
          I := I + 1;
          MatchCount :=0;
          J:=0;
          While (MatchCount < 1) and (J<5) do
           begin
            J:= J+1;
            if J=I then J:=J+1;
            if J < 6 then
             begin
               if Deck[DealHand[I]].Value = Deck[DealHand[J]].Value then
                   MatchCount := MatchCount +1;
                  MatchNum := Deck[DealHand[I]].Value
             end
           end
	 end;
         if MatchCount >0 then  Pair :=True
       end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowOutCome(Clr:Byte; ST: String; Mult : Integer);
 begin
  Emu_GotoXy(1,11);
  Emu_Color(Clr,0);
  ComWrite(St);
  If Mult =0 then
   begin
    Cash :=Cash - Wager;
    Emu_Color(12,0);
    ComWrite('            You Lost');
    Emu_Color(10,0);
    ComWrite('  $'+Commaput(Wager));
   end
  else
   begin
    Cash :=Cash +(Mult * Wager);
    Emu_Color(10,0);
    ComWrite('            You Collect  $'+Commaput(Mult*Wager));
   end;
  ShowBucks(3);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.DecideOutCome;
  begin
    if Straight then
     begin
      If Flush then
      ShowOutCome(12,'A Straight Flush', 35)
      else
      ShowOutCome(14,'A Straight ', 10);
     end
    else
     If FourOKind then
      begin
       ShowOutCome(15,'Four Of A Kind ', 25);
      end
    else
     If FullHouse then
      begin
       ShowOutCome(11,'Full House ', 20);
      end
    else
     If Flush then
      begin
       ShowOutCome(10,'A Flush ', 15);
      end
    else
     If ThreeOKind then
      begin
       ShowOutCome(13,'Three Of A Kind ', 5);
      end
    else
     If TwoPair then
      begin
       ShowOutCome(14,'Two Pair ', 2);
      end
    else
     If Pair then
      begin
       ShowOutCome(13,' A Pair ', 1);
      end
    else
      begin
       ShowOutCome(7,' Empty Hand ', 0);
      end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.FMainFlow;
 var
   C     : char;
   I	 : Byte;
   NoneFound : Boolean;
   YHit      : Boolean;
   TWager    : Real;
   Code      : Integer;
   MAxBet    : Real;
 begin
  if Cash <=0 then Cash :=50;
  Repeat
  GameOver := False;
  C:=#0;
  YHit := False;
  FDrawboard;
  CheckTimeLeft;
  ShowMsr;
  While Online and Not GoOffLine and Not GameOver and (Cash >0) do
  begin
   ShowMsr;
   ShuffleCards;
   ClearPanel(1);
   FShowCards;
   ClearInsLine;
   GetBet(TWager);
   if TWager =-1 then GameOver :=True
   else
   begin
    If TWager<> 0 then Wager := Twager;
    If Wager =0 then Wager :=10;
    ShowWager(3);
    For I :=1 to 5 do ShowCard(1,I,True);
    Standing :=False;
    CheckSet :=['M','K',#13,' ','R','P'];
    FShowPickMenu;
    ShowArrow;
    C:=#0;
    While Not Standing and Not GameOver and Online And Not GoOffLine do
    begin
     ShowMsr;
     GetCmd(C,CheckSet);
     ClearInsLine2;
     if ReqChat then
       begin
         Chat;
         FRedraw;
         C:=#0
       end
    else
    case C of
    #13: begin
          Standing := True;
 	end;
    'R': begin {up}
          FRedraw;
 	end;
    'M': begin {Right}
           HideArrow;
           ArrowPos :=ArrowPos +1;
           if ArrowPos >5 then ArrowPos :=1;
           ShowArrow;
         end;
    'K': begin {Left}
           HideArrow;
           ArrowPos :=ArrowPos -1;
           if ArrowPos <1 then ArrowPos :=5;
           ShowArrow;
 	end;
  '1'..'9': begin
             Val(C,Deck[DealHand[ArrowPos]].Value,Code);
             ShowCard(1,ArrowPos,True);
             Select[ArrowPos] :=False
            end;
'P',' ': begin {Select}
           if Select[ArrowPos] then
            begin
             ShowCard(1,ArrowPos,True);
             Select[ArrowPos] :=False
            end
           else
            begin
             Select[ArrowPos] :=True;
             ShowCard(1,ArrowPos,False)
            end
         end;
       end; { Case};
      end;
      HideArrow;
      For I := 1 to 5 do
       begin
        if Select[I] then
         begin
          Select[I] := False;
          DealHand[I]:= DealHand[I+5];
          ShowCard(1,I,True)
         end
       end;
      if Not GameOver then
       begin
        DecideOutCome;
        ClearInsLine;
        GetCr(11);
       end
    end
 end;
  ClearInsLine;
  if Cash <1 then
  begin
    ComWrite(' You Are Out of Cash ... Come Back Tomorrow... ');
    GoOffLine := True;
    Delay(4000);
    Yhit :=False
  end;
  Until GameOver or Not Online or GoOffline;
  ClearInsLine;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function PlayerFound(Uname: String) : Boolean;
 var
  RFile : text;
  InPutLine   : NameString;
  FoundEm     : Boolean;
  GamesPlayed : Integer;
  Bucks       : Real;
  Ufound    : boolean;
  Code      : Integer;
  begin
   UFound:=false;
   if Exist('Poker.RNX') then
   begin
    Assign(RFile,'Poker.RNX');
    Reset(RFile);
    UFound :=false;
    while not eof(Rfile) do
     begin
      Readln(RFile,InputLine,Bucks,GamesPlayed);
      if pos(Uname,InputLine)>0 then
       begin
        GameCount:=GamesPlayed;
        Cash :=Bucks;
        if Cash <0 then Cash :=50;
        Ufound:=True
       end
     end;
    CLOSE(RFile)
   end;
    PlayerFound :=Ufound;
    if IOResult<>0 then Writeln('I/O error...')
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.RUNX( var Savem : Boolean );
 var
  C : Char;
  Yhit : boolean;
  I    : Integer;
 begin
  Showmsr;
  Savem := True;
  C:=#0;
  ComWriteln('BBS POKER Version'+ Vrs);
  if Local then
   begin
    Emu_Color(14,0);
    ComWriteln('Local Mode Enabled... ');
    Yhit :=true
   end;
  DateChk;
  if Not PlayerFound(BRec.UName) then
   begin
    if Not Local then
     begin
      ComWriteln('');
      ComWriteln('Detecting Ansi...');
      Yhit :=DetectAnsi;
      delay(500);
      ClearRX;
      if Not Yhit then
       begin
        ComWrite('Are You Using ANSI Graphics ?? [Y/n] ');
        getYn(Yhit)
       end;
      if Not Yhit then
       begin
        ComWriteln('');
        ComWriteln('Sorry. This Door Requires the Use of ANSI Graphics.... ');
        delay(2000);
        Savem :=false
       end
     end
    else
     begin
      Yhit :=true;
      Delay(1000)
     end
   end;
  if Yhit and OnLine And not GoOfflIne then
   Repeat
    if (Online and Not GoOffLine) then
    MainMenu;
    Emu_Color(15,0);
    ComWriteln('');
    ComWrite(' Selection? =>');
    GetChar(C,['B','H','I','Q','R','F']);
    if ReqChat then Chat
    else
     begin
      if (Online and Not GoOffLine) then
       begin
        case C of
        'R' : begin
               if Not Brec.Registered then
                begin
                 ClearInsLine;
                 ComWrite(' Rankings is Only Available in Registered Versions...');
                end
               else Rankings
              end;
        'H' : begin
               if Not Brec.Registered then
                begin
                 ClearInsLine;
                 ComWrite(' Hall Of Fame is Only Available in Registered Versions...');
                end
               else HOF
              end;
        'B' : begin
                if Cash <0 then Cash :=50;
                BMainFlow;
              end;
        'F' : begin
                if Cash <0 then Cash :=50;
                FMainFlow;
              end;
        'I' : begin
               Instructions;
              end;
        end {case}
      end
   end;
  if GoOffLine Then
    begin
     Emu_Color(15,0);
     Emu_ClearScreen;
    end;
  until (C='Q') or Not Online or GoOffLine;
  Showmsr;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure GetData(var BR : BBSData; var ComNum : Byte; Var BD : LongInt;
                   var Local : Boolean);
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
  {$I-}
 if paramcount > 0 then
  begin
   LOCAL:=TRUE;
   UNAME:= paramStr(1)+' '+paramStr(2);
   FORMATNAME(UNAME);
   BBSNAME:='DOS';
   SYSOPNAME:='';
   TIMELIMIT:=60;
   TIMEUSED:=0;
   ComNum  :=0;
   BD:=0;
  end;
  assign(ConfigFile,'Poker.CFG');
  reset(ConfigFile);
  if IoResult <>0 then
   begin
    Writeln;
    Writeln('Poker.CFG File Not Found ... Execution Halted.');
    if Not Local then
     Writeln('To Run Local type "Poker Your Name"');
    halt(1)
   end
  {$I-}
   else
    begin
     readln(Configfile,RN);
     readln(Configfile,COMNUM);
     if Not Local then
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
  if Not Local then
  begin
  {$I-}
  while BBSDIR[length(BBSDIR)] =' ' do delete( BBSDIR,length(BBSDIR),1);
  assign(ConfigFile,BBSDIR+'\'+UFILE);
  reset(ConfigFile);
  if IoResult <>0 then
   begin
    Writeln;
    Writeln('No USER file ',BBSDIR+'\'+UFILE,' ... Execution Halted ');
    Writeln('To Run Local type "Poker Your Name" ');
    halt(1)
   end
  {$I-}
   else
    if Not Local then
    begin
     While Not Eof(ConfigFile) do
      begin
       Readln(ConfigFile,LocChk);
     if Pos('COM0', upper(LocChk)) >0 then Local :=true;
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
  end;
  if IORESULT <>0 then Writeln('I/O ERROR..');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
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
 Cash:=50;
 GetData(BBRec,Cport,BDRate,Lcl);
 XXX.INIT(Cport,BDRate,BBRec,Lcl);
 XXX.RUN;
 XXX.INITIALIZE;
 XXX.CheckRegistered(XXX.BRec);
 XXX.Emu_ClearScreen;
 XXX.SHOWMSR;
 if (XXX.ONLINE) then
  begin
   XXX.Clearreceive;
   XXX.BRec.StartTime:=XXX.TimeNow;
   XXX.SHOWMSR;
   IF (XXX.ONLINE and Not XXX.GoOffLine) or (BDRate =0) Then XXX.RUNX(Savem);
   if XXX.Online then
   begin
    XXX.emu_gotoxy(1,22);
    XXX.Emu_Color(12,0);
    xxx.UpdateRankings;
    XXX.ComWriteln('');
    if XXX.TimeLeft<2 then
    XXX.ComWriteln('Time Limit Exceeded....');
    XXX.Emu_Color(15,0);
    XXX.ComWriteln('Returning to '+XXX.Brec.BBSNAME);
    XXX.SHOWMSR
   end;
 end;
 if not XXX.Online then
  begin
   writeln('No Carrier Detected');
   delay(500)
  end;
 XXX.Emu_Color(15,0);
 XXX.ComWrite(' ');
 XXX.DONE;
 TextColor(15);
 TextBacKground(0);
END.
