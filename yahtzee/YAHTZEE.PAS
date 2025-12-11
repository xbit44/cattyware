{$M 32767,0,655360}

PROGRAM Yahtzee;

uses Crt,Dos,BBSGam,BBSScrn;

const
 Vrs  =' 1.07';


  Const
     CellName  : Array[1..19] of String[23] =(
		 ' Ones ................',
		 ' Twos ................',
		 ' Threes ..............',
		 ' Fours ...............',
		 ' Fives ...............',
		 ' Sixes ...............',
		 ' SubTotal ............',
		 ' Bonus ...............',
		 ' SubTotal ............',
		 ' Three Of a Kind .....',
		 ' Four Of a Kind ......',
		 ' Full House ..........',
		 ' Small Straight ......',
		 ' Large Straight ......',
		 ' Y A H T Z E E .......',
		 ' Chance ..............',
		 ' Sub Total Bottom ....',
		 ' Sub Total Top .......',
		 ' Total ...............');
     CellColor  : Array[1..19] of byte=(14,14,14,14,14,14,15,10,15,11,11,11,11,11,12,13,15,15,15);




TYPE

  CharSet    = set of Char;
  Cells      = Record
		Value : Integer;
		Used  : Boolean;
	       end;

  Die        = Record
		Roll : Byte;
		Picked : Boolean;
	       end;

  CellData   = Array[1..19] of Cells;
  Dices      = Array[1..5] of Die;


  XXBBS = OBJECT(TBBS)
	   Procedure MainFlow;
	   Procedure Initialize;
	   Procedure CheckRegistered(var BR : BBSData);
           Procedure ClearInsLine;
	   Procedure Instructions;
	   Procedure GetCmd(var Ychar : char; Cset: CharSet);
	   Procedure ShowDice(I: Byte);
	   Procedure ShowRollMenu;
	   Procedure ShowPickMenu;
	   Procedure ShowDArrow;
	   Procedure ShowSArrow;
	   Procedure HideDArrow;
	   Procedure HideSArrow;
	   Procedure ShowScore;
	   Procedure ShowLogo;
	   Procedure SelectDice(I: Byte);
	   Procedure DrawBoard;
	   Procedure mainmenu;
           Procedure UpDateRankings;
           Procedure Rankings;
           Procedure HOF;
	   Procedure RUNX( var Savem : Boolean );
	  end;
var
  XXX           : XXBBS;
  GameCount     : Integer;
  GameOver      : boolean;
  Quit          : Boolean;
  IntChrSet     : CharSet;
  Board		: CellData;
  Dice		: Dices;
  DArrowPos	: Byte;
  SArrowPos	: Byte;
  Turns         : Byte;


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
    Writeln(' Y A H T Z E E');
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
 Procedure XXBBS.Instructions;
 var
  C : Char;
 begin
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    Clrscr;
    emu_color(0,7);
    Comwrite('                    Instructions For Playing YAHTZEE                           ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    if Exist('YAHTZEE.INS') then TypeFileMore('YAHTZEE.INS',C)
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
  HighScore   : Word;
  DateStr     : String[8];
  DumSpace    : Char;

  begin
   GameCount:=GameCount +1;
   Foundem :=False;
   ClearInsLine;
   ComWrite(' Updating Rankings....');
   Assign(RFile,'Yahtzee.RNX');
   Assign(TFile,'Yahtzee.Tmp');
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
      Readln(RFile,InputLine,HighScore,GamesPlayed,DumSpace,DateStr);
      if (pos(BRec.UName,InputLine)>0) or (Board[19].Value> HighScore) then
       begin
        if Not Foundem then
         begin
          FoundEm :=True;
          if (Board[19].Value> HighScore) then
           Writeln(TFile,Brec.Uname,' ',Board[19].Value,' ',GameCount,' ',Date)
          else
          Writeln(TFile,Brec.Uname,' ',HighScore,' ',GameCount,' ',Date);
           if Not (pos(BRec.UName,InputLine)>0) then
          Writeln(TFile,InputLine,' ',HighScore,' ',GamesPlayed,' ',DateStr);
          Board[19].Value:=0;
         end
       end
      else
      Writeln(TFile,InputLine,' ',HighScore,' ',GamesPlayed,' ',DateStr);
     end;
    Close(RFile);
    if Not FoundEm then
      Writeln(TFile,Brec.Uname,' ',Board[19].Value,' ',1,' ',Date);
    Close(TFile);
    Erase(RFile);
    Rename(Tfile,'Yahtzee.RNX');
    if IOResult<>0 then Writeln('I/O error...')
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
  HighScore   : Word;
  InPutLine2  : NameString;
  HighScore2  : Word;
  DateStr     : String[8];
  DumSpace    : Char;
  Sline       : String;

  begin
   Foundem :=False;
   Assign(RFile,'Yahtzee.Rnx');
   Assign(HFile,'Yahtzee.Hof');
   Assign(TFile,'Yahtzee.Tmp');
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
    Readln(RFile,InputLine,HighScore,GamesPlayed,DumSpace,DateStr);
    while not eof(Rfile) do
     begin
      Readln(RFile,SLine);
      Writeln(TFile,Sline);
     end;
    Close(RFile);
    Close(TFile);
    Erase(RFile);
    Rename(Tfile,'Yahtzee.RNX');
    Assign(TFile,'Yahtzee.Tmp');
    ReWrite(TFile);
    while not eof(Hfile) do
     begin
      Readln(HFile,InputLine2,HighScore2,DumSpace,DateStr);
      if (pos(InputLine,InputLine2)>0) or (HighScore > HighScore2) then
       begin
        if Not Foundem then
         begin
          FoundEm :=True;
          if (HighScore > HighScore2) then
           Writeln(TFile,InputLine,' ',HighScore,' ',Date)
          else
          Writeln(TFile,InputLine,' ',HighScore2,' ',Date);
           if Not (pos(InputLine,InputLine2)>0) then
          Writeln(TFile,InputLine2,' ',HighScore2,' ',DateStr);
          HighScore:=0;
         end
       end
      else
      Writeln(TFile,InputLine2,' ',HighScore2,' ',DateStr);
     end;
    Close(HFile);
    if Not FoundEm then
      Writeln(TFile,InputLine,' ',HighScore,' ',DateStr);
    Close(TFile);
    Erase(HFile);
    Rename(TFile,'Yahtzee.Hof');
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
  RFile     : Text;
  GamesPlayed : Word;
  HighScore   : Word;
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
   Comwrite('                    Y A H T Z E E  Player Rankings                             ');
   emu_color(14,0);
   ComWriteln('');
   ComWrite('  Rank  ');
   emu_color(15,0);
   ComWrite('    Name           ');
   emu_color(12,0);
   ComWrite('   High Score   ');
   emu_color(10,0);
   ComWrite('   Games Played ');
   emu_color(13,0);
   ComWriteln('   Last PLayed');
   emu_color(9,0);
   ComWriteln('อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
   if Exist('Yahtzee.RNX') then
   begin
    Assign(RFile,'Yahtzee.RNX');
    Reset(RFile);
    LCount :=0;
    RCount :=0;
    Abort  := False;
    while not eof(Rfile) and Not Abort do
     begin
      Readln(RFile,InputLine,HighScore,GamesPlayed,DumSpace,DateStr);
      LCount:=Lcount +1;
      RCount:=Rcount +1;
      Emu_Color(15,0);
      ComWrite( IToStr(RCount,4)+'.  ');
      Emu_Color(14,0);
      ComWrite(InputLine);
      Emu_Color(12,0);
      ComWrite(IToStr(HighScore,5)+'         ');
      Emu_Color(10,0);
      ComWrite(IToStr(GamesPlayed,6)+'            ');
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
  RFile     : Text;
  GamesPlayed : Word;
  HighScore   : Word;
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
   Comwrite('                    Y A H T Z E E  Hall Of Fame                                ');
   emu_color(14,0);
   ComWriteln('');
   ComWrite('  Rank  ');
   emu_color(15,0);
   ComWrite('    Name           ');
   emu_color(12,0);
   ComWrite('     High Score   ');
   emu_color(13,0);
   ComWriteln('   Date Arrived');
   emu_color(9,0);
   ComWriteln('อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
   if Exist('Yahtzee.HOF') then
   begin
    Assign(RFile,'Yahtzee.HOF');
    Reset(RFile);
    LCount :=0;
    RCount :=0;
    Abort  := False;
    while not eof(Rfile) and Not Abort do
     begin
      Readln(RFile,InputLine,HighScore,DumSpace,DateStr);
      LCount:=Lcount +1;
      RCount:=Rcount +1;
      Emu_Color(15,0);
      ComWrite( IToStr(RCount,4)+'.   ');
      Emu_Color(14,0);
      ComWrite(InputLine);
      Emu_Color(12,0);
      ComWrite(IToStr(HighScore,5)+'            ');
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
       Emu_GotoXY(58,3);
       TimePrompt;
       Emu_GotoXY(XS,YS);
       showmsr;
       Timesav:=time;
       MinCnt:=MinCnt+1;
       if MinCnt >3 then
        begin
          ComWrite(#7);
          Emu_GoToXy(2,24);
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
           delay(2);
           if Local then
           begin
            if KeyPressed then Ychar:=Upcase(readkey);
           end
           else
           begin
            delay(2);
            Ychar:=CREADKEY;
            delay(2);
           end;
           if ChWaiting Or KeyPressed then
            while YChar = #0 do
              if Local then Ychar:=Upcase(readkey)
              else Ychar:=CREADKEY;

           while YChar = '[' do
            if Local then Ychar:=Upcase(readkey)
            else
              begin
               delay(2);
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
{ Procedure XXBBS.GetCmd(var YChar : char; Cset: CharSet);
 var
  Chh : Char;
  begin
   if Online and Not GoOffLine then
   begin
    Ychar:=#0;
    repeat
     if not local and KeyPressed then
      begin
       if ReadKey=#0 then CheckKey
       else ShowFKeys;
      end;
     if ChWaiting or Keypressed  then
      begin
       Ychar:=Upcase(CREADKEY);
       if  Ychar in[#27, #0] then
        begin
          delay(2);
           if Local then
	   begin
	    if KeyPressed then Ychar:=Upcase(readkey);
	   end
           else
	   begin
            delay(2);
            Ychar:=CREADKEY;
            delay(2);
	   end;
	   if ChWaiting Or KeyPressed then
            while YChar = #0 do
	      if Local then Ychar:=Upcase(readkey)
              else Ychar:=CREADKEY;

	   while YChar = '[' do
            if Local then Ychar:=Upcase(readkey)
	    else
              begin
               delay(2);
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

  end;  }
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure RollDie(I: byte);
 begin
  Dice[I].Roll :=1+Random(6);
  if Dice[I].Roll >6 then Dice[I].Roll :=6;
  Dice[I].Picked := False
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.Initialize;
 var I : Integer;
 begin
  SetFlowControl(BRec.UseCTS,BRec.UseRTS);
  SHOWMSR;
  if not LoadEmulation('Yahtzee') then
   begin
     writeln(' Unable to Load Yahtzee.EMU..');
     done;
     halt
   end;
  GoOffLine:=false;
  Randomize;
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
 if Exist('Yahtzee.Scr') then
  begin
   TypeFile('Yahtzee.Scr',Chh);
  end
 else
 begin
  emu_color(14,0);
  Comwriteln('');
  Comwriteln('                               Y A H T Z E E  ');
 end;
 emu_color(7,0);
 Comwriteln('');
 Comwriteln('');
 Comwriteln('                          Version'+Vrs+' (c) 1993 ');
 Comwriteln('                       Neubauer Applications Uncorp ');
 Comwriteln('                     Virtual Reality BBS 512-992-4496');
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
 Comwriteln('               UNREGISTERED COPY  ... ASK SYSOP TO REGISTER');
 Comwriteln('');
 emu_color(10,0);
 Comwriteln(' [B]  Begin Yahtzee');
 emu_color(14,0);
 Comwriteln(' [R]  Rankings');
 emu_color(13,0);
 Comwriteln(' [H]  Hall Of Fame');
 emu_color(11,0);
 Comwriteln(' [I]  Instructions');
 emu_color(12,0);
 Comwriteln(' [Q]  Quit Back to BBS');
 showMsr;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowLogo;
 begin
   Emu_gotoXy(1,1);
   Emu_Color(14,1);
   ComWrite('     Y A H T Z E E   ');
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
 Procedure XXBBS.ShowDice(I :Byte);
 const Xcol = 3;

 begin
    case Dice[I].Roll Of
     1: begin
	 Emu_gotoXy(XCol,4*I);
	 ComWrite('       ');
	 Emu_gotoXy(XCol,1+(4*I));
	 ComWrite('      ');
	 Emu_gotoXy(XCol,2+(4*I));
	 ComWrite('       ');
	end;
     2: begin
	 Emu_gotoXy(XCol,4*I);
	 ComWrite('      ');
	 Emu_gotoXy(XCol,1+(4*I));
	 ComWrite('       ');
	 Emu_gotoXy(XCol,2+(4*I));
	 ComWrite('      ');
	end;
     3: begin
	 Emu_gotoXy(XCol,4*I);
	 ComWrite('      ');
	 Emu_gotoXy(XCol,1+(4*I));
	 ComWrite('      ');
	 Emu_gotoXy(XCol,2+(4*I));
	 ComWrite('      ');
	end;
     4: begin
	 Emu_gotoXy(XCol,4*I);
	 ComWrite('     ');
	 Emu_gotoXy(XCol,1+(4*I));
	 ComWrite('       ');
	 Emu_gotoXy(XCol,2+(4*I));
	 ComWrite('     ');
	end;
     5: begin
	 Emu_gotoXy(XCol,4*I);
	 ComWrite('     ');
	 Emu_gotoXy(XCol,1+(4*I));
	 ComWrite('      ');
	 Emu_gotoXy(XCol,2+(4*I));
	 ComWrite('     ');
	end;
     6: begin
	 Emu_gotoXy(XCol,4*I);
	 ComWrite('     ');
	 Emu_gotoXy(XCol,1+(4*I));
	 ComWrite('     ');
	 Emu_gotoXy(XCol,2+(4*I));
	 ComWrite('     ');
	end;
    end{ case}
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowRollMenu;
 begin
   Emu_GotoXy(1,3);
   Emu_Color(15,8);
   ComWrite(' Select Dice to Roll..                ');
   Emu_GotoXy(1,24);
   Emu_Color(14,0);
   ComWrite(' [,8,2]-Move Selector  ');
   Emu_Color(10,0);
   ComWrite('[SpaceBar]-Select  ');
   Emu_Color(15,0);
   ComWrite('[Enter]-Roll''em  ');
   Emu_Color(13,0);
   ComWrite('[R]edraw  ');
   Emu_Color(12,0);
   ComWrite('[Q]uit');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowPickMenu;
 begin
   Emu_GotoXy(1,3);
   Emu_Color(15,8);
   ComWrite('                    Select Category... ');
   Emu_GotoXy(1,24);
   Emu_Color(14,0);
   ComWrite(' [,8,2]-Move Selector  ');
   Emu_Color(15,0);
   ComWrite('[Enter]-Accept  ');
   Emu_Color(13,0);
   ComWrite('[R]edraw  ');
   Emu_Color(12,0);
   ComWrite('[Q]uit  ');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.DrawBoard;
 Var
   I :Integer;
 begin
  Emu_ClearScreen;
  ShowLogo;
  Emu_Color(10,0);
  Emu_GotoXy(43,3);
  ComWriteln(' Score  ');
  For I := 1 to 19 do
  begin
   Emu_Color(CellColor[I],0);
   ComWriteln('                  '+CellName[I])
  end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowDArrow;
 begin
  Emu_GotoXy(11,1+(DArrowPos*4));
  Emu_Color(14,0);
  ComWrite('<-');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.HideDArrow;
 begin
  Emu_GotoXy(11,1+(DArrowPos*4));
  Emu_Color(14,0);
  ComWrite('  ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowSArrow;
 begin
  Emu_GotoXy(17,3+(SArrowPos));
  Emu_Color(14,0);
  ComWrite('->');
  Emu_Color(15,1);
  ComWrite(CellName[SArrowPos])
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.HideSArrow;
 begin
  Emu_GotoXy(17,3+(SArrowPos));
  Emu_Color(14,0);
  ComWrite('  ');
  Emu_Color(CellColor[SArrowPos],0);
  ComWrite(CellName[SArrowPos])
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.SelectDice(I: Byte);
 begin
  if Dice[I].Picked then
   begin
    Dice[I].Picked :=False;
    Emu_Color(14,1);
   end
    else
     begin
      Dice[I].Picked:= True;
      Emu_Color(15,4);
     end;
   ShowDice(I);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure InitScore;
 var I : Integer;

 begin
  For I := 1 to 19 do
   begin
    Board[I].Used := False;
    Board[I].Value := 0;
   end;
  Board[7].Used := True;
  Board[9].Used := True;
  Board[17].Used:= True;
  Board[18].Used:= True;
  Board[19].Used:= True;

 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowScore;
 Var I : Integer;
 begin
  Emu_Color(15,0);

  Board[7].Value :=Board[1].Value;
  For I:= 2 to 6 do  Board[7].Value :=Board[7].Value+ Board[I].Value;
  if Board[7].Value > 62 then
   begin
     Board[8].Value:=35;
     Board[8].Used:=True;
   end;
  Board[9].Value :=Board[7].Value+Board[8].Value;
  Board[18].Value :=Board[9].Value;
  Board[17].Value :=Board[10].Value;
  For I:= 11 to 16 do  Board[17].Value :=Board[17].Value+ Board[I].Value;
  Board[19].Value :=Board[17].Value+Board[18].Value;

  For I := 1 to 19 do
   if  Board[I].Used then
   begin
    Emu_GotoXy(45, I+3);
    ComWrite(IToStr(Board[I].Value,3));
   end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Hasa( R : Byte) : Boolean;
 Var I : Byte;
 begin
  Hasa :=False;
  For I := 1 to 5 do if Dice[I].Roll = R then Hasa := True;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure AddScore;
 var
   Amnt    : Integer;
   I,J     : byte;
   MatchCount  : Byte;
   MatchNum    : Byte;
   T1,T2,T3,T4 : Byte;
   Smallest    : Byte;
 begin
  Amnt := 0;
  Turns:=Turns+1;
  case SArrowPos of
 1..6: begin
	For I := 1 to 5 do
	if Dice[I].Roll = SArrowPos then Amnt :=Amnt +Dice[I].Roll;
	Board[SArrowPos].Value := Amnt;
	Board[SArrowPos].Used := True
       end;
 10  : begin { 3 of a kind}
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
            if  J=I then J:=J+1;
            if J < 6 then
             begin
               if Dice[I].Roll = Dice[J].Roll then
                   MatchCount := MatchCount +1;
             end
           end
	 end;
	if MatchCount >1 then
           For I := 1 to 5 do Amnt :=Amnt +Dice[I].Roll;
	Board[SArrowPos].Value := Amnt;
	Board[SArrowPos].Used := True
       end;
 11  : begin {4 of a kind}
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
               if Dice[I].Roll = Dice[J].Roll then
                   MatchCount := MatchCount +1;
             end
           end
	 end;
	if MatchCount >2 then
           For I := 1 to 5 do Amnt :=Amnt +Dice[I].Roll;
	Board[SArrowPos].Value := Amnt;
	Board[SArrowPos].Used := True
       end;
 12  : begin {FullHouse}
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
               if Dice[I].Roll = Dice[J].Roll then
                   MatchCount := MatchCount +1;
               MatchNum :=Dice[I].Roll
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
               if Dice[I].Roll <> MatchNum then
                begin
                 J:=0;
                 While (J<5) do
                 begin
                  J:=J+1;
                  if J<>I then
                   begin
                    if Dice[I].Roll =Dice[J].Roll then MatchCount :=1;
                   end
                 end
                end
             end;
             if MatchCount >0 then  Amnt :=25
           end;
          Board[SArrowPos].Value := Amnt;
          Board[SArrowPos].Used := True
       end;
 13  : begin {SmallStraight}
        Smallest := 6;
        For I := 1 to 5 do
         if Dice[I].Roll < Smallest then Smallest := Dice[I].Roll;
         if Smallest <4 then
          begin
           T1 := Smallest + 1;
           T2 := T1 + 1;
           T3 := T2 + 1;
            I:=0;
           if Hasa(T1) and Hasa(T2) and Hasa(T3) then
           begin
            Amnt :=35;
           end
          end;
        Board[SArrowPos].Value := Amnt;
        Board[SArrowPos].Used := True
       end;
 14  : begin {LargeStraight}
        Smallest := 6;
        For I := 1 to 5 do
         if Dice[I].Roll < Smallest then Smallest := Dice[I].Roll;
         if Smallest <4 then
          begin
           T1 := Smallest + 1;
           T2 := T1 + 1;
           T3 := T2 + 1;
           T4 := T3 + 1;
            I:=0;
           if Hasa(T1) and Hasa(T2) and Hasa(T3) and Hasa(T4) then
           begin
            Amnt :=45;
           end
          end;
        Board[SArrowPos].Value := Amnt;
        Board[SArrowPos].Used := True
       end;
 15  : begin {Yahtzee}
        Amnt :=50;
        For I := 2 to 5 do
         if Dice[1].Roll <> Dice[I].Roll then Amnt :=0;
        Board[SArrowPos].Value := Amnt;
        Board[SArrowPos].Used := True
       end;
 16  : begin
	For I := 1 to 5 do Amnt :=Amnt +Dice[I].Roll;
	Board[SArrowPos].Value := Amnt;
	Board[SArrowPos].Used := True
       end;
  end; {Case}
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.MainFlow;
 var
   C     : char;
   I	 : Byte;
   Rolls : Byte;
   NoneFound : Boolean;
   YHit      : Boolean;
 begin
  Repeat
  GameOver := False;
  C:=#0;
  DArrowPos :=1;
  SArrowPos :=1;
  InitScore;
  Turns := 0;
  YHit := False;
  Drawboard;
  Repeat
  CheckTimeLeft;
  ShowMsr;
  For I := 1 to 5 do RollDie(I);
  Emu_Color(14,1);
  For I := 1 to 5 do ShowDice(I);
  Rolls :=0;
  While Online and Not GoOffLine and Not GameOver and (Rolls <2) do
  begin
   Rolls:=Rolls +1;
   ShowRollMenu;
   ShowDArrow;
   C:=#0;
   While  Not (C in['Q', #13]) and Online and Not GoOffLine do
   begin
   GetCmd(C,['Q',#13,'H','P','R',' ']);
   case C of
   'Q' : GameOver :=True;
   ' ': begin
	  SelectDice(DArrowPos);
	end;
   #13: begin
	 HideDArrow;
	 Emu_Color(14,1);
	 NoneFound :=True;
	 For I:=1 to 5 do
	 begin
	  If Dice[I].Picked then
	   begin
	    NoneFound := False;
	    RollDie(I);
	    Dice[I].Picked:=False;
	    ShowDice(I);
	   end;
	  end;
	  if NoneFound then Rolls :=2
	end;
   'R': begin {up}
	 Drawboard;
	 Emu_Color(14,1);
	 For I := 1 to 5 do ShowDice(I);
         ShowScore;
	 ShowRollMenu;
         ShowDArrow;
	end;
   'H': begin {up}
	  HideDArrow;
	  DArrowPos := DArrowPos -1;
	  if DArrowPos < 1 then DArrowPos :=5;
	  ShowDArrow;
	end;
   'P': begin {down}
	  HideDArrow;
	  DArrowPos := DArrowPos +1;
	  if DArrowPos >5 then DArrowPos :=1;
	  ShowDArrow;
	end;
      end { Case};
     end
   end;
  If Online and Not GameOver then
  begin
   While Board[SArrowPos].Used and Online do
    begin
     SArrowPos := SArrowPos +1;
     if SArrowPos  in [7,8,9] then SArrowPos :=10;
     if SArrowPos >16 then SArrowPos :=1;
    end;
   ClearInsLine;
   ShowPickMenu;
   ShowSArrow;
   C:=#0;
   While  Not (C in['Q', #13]) and Online and Not GoOffLine do
   begin
   GetCmd(C,['Q',#13,'H','P','R',' ']);
   case C of
   #13: begin
	  HideSArrow;
	  AddScore;
	  ShowScore
	end;
   'R': begin {up}
	 Drawboard;
	 Emu_Color(14,1);
	 For I := 1 to 5 do ShowDice(I);
         ShowScore;
         ShowSArrow;
	 ShowPickMenu;
	end;
   'H': begin {up}
	  HideSArrow;
          Repeat
           SArrowPos := SArrowPos -1;
           if SArrowPos  in [7,8,9] then SArrowPos :=6;
           if SArrowPos < 1 then SArrowPos :=16;
          Until Not Board[SArrowPos].Used or Not Online;
	  ShowSArrow;
	end;
   'P': begin {down}
	  HideSArrow;
          Repeat
           SArrowPos := SArrowPos +1;
           if SArrowPos  in [7,8,9] then SArrowPos :=10;
           if SArrowPos >16 then SArrowPos :=1;
          Until Not Board[SArrowPos].Used or Not Online;
          ShowSArrow;
	end;
      end { Case};
     end
   end;
{   Turns :=13;
   Board[19].Value:=320;}
   if Turns> 12 then GameOver :=true;
  until (C='Q') or GameOver or Not Online or GoOffLine;
  if Turns >12 then
   begin
    UpdateRankings;
    Delay(1000);
    ClearInsLine;
    ComWrite(' Play Again?? ');
    GetYN(Yhit);
   end;
  Until Not Yhit or Not Online or GoOffline;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function PlayerFound(Uname: String) : Boolean;
 var
  RFile : text;
  InPutLine   : NameString;
  FoundEm     : Boolean;
  GamesPlayed : Integer;
  HighScore   : Integer;
  Ufound    : boolean;
  Code      : Integer;
  begin
   UFound:=false;
   if Exist('Yahtzee.RNX') then
   begin
    Assign(RFile,'Yahtzee.RNX');
    Reset(RFile);
    UFound :=false;
    while not eof(Rfile) do
     begin
      Readln(RFile,InputLine,HighScore,GamesPlayed);
      if pos(Uname,InputLine)>0 then
       begin
        GameCount:=GamesPlayed;
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
  ComWriteln('Yahtzee Version'+ Vrs);
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
    Getchar(C,['B','H','I','Q','R']);
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
                MainFlow;
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
  assign(ConfigFile,'Yahtzee.CFG');
  reset(ConfigFile);
  if IoResult <>0 then
   begin
    Writeln;
    Writeln('Yahtzee.CFG File Not Found ... Execution Halted.');
    if Not Local then
     Writeln('To Run Local type "Yahtzee Your Name"');
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
    Writeln('To Run Local type "Yahtzee Your Name" ');
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
 XXX.Emu_Color(15,0);
 XXX.ComWrite(' ');
 XXX.DONE;
 TextColor(15);
 TextBacKground(0);
END.
