{$M 32768,0,655360}

PROGRAM BBSgolf;

uses crt,DOS,BBSGAME;
TYPE
  PointType = record
                X,Y: integer
              end;

 Clubarray   = array[1..16] of string[8];
 ClubColor   = array[1..16] of Byte;
 ClubMaxLim  = array[1..16] of Integer;
 ClubMinLim  = array[1..16] of Integer;

const
 Bkcolor  = 1;
 Vrs      =' 2.45';
 XNamePos = 4;
 YNamePos = 19;
 ScorePosX= 72;
 ScorePosY= 16;
 StrokePosX= 73;
 StrokePosY= 15;
 XPenal   = 2;
 YPenal   = 22;
 CmntLocX = 1;
 CmntLocY = 22;
 MAXX     = 60;
 MINX     = 1;
 MAXY     = 16;
 MINY     = 1;

 InCup    = 1;
 OnTee    = 2;
 Green    = 3;
 InFairWay= 4;
 Ruff     = 5;
 DeepRuff = 6;
 Sand     = 7;
 trees    = 8;
 water    = 9;
 OB       = 10;

 Club : clubarray = (' 1 Wood ',' 2 Wood ',' 3 Wood ',' 5 Wood ',' 1 Iron ',
                     ' 2 Iron ',' 3 Iron ',' 4 Iron ',' 5 Iron ',' 6 Iron ',
                     ' 7 Iron ',' 8 Iron ',' 9 Iron ',' PWedge ',' SWedge ',
                     ' Putter ');
 ClubClrF : ClubColor = (15,15,14,10,15,15,14,11,10,14,15,15,14,12,14,15);
 ClubClrB : ClubColor = (6 ,6 ,6 ,6 ,3 ,2 ,2 ,1 ,1 ,1 ,1 ,5 ,5 ,1 ,4, 2);
 ClubMax : ClubMaxLim = (255,239,215,195,182,175,160,155,140,130,120,
                        110,105,95,75,20);

 ClubMin : ClubMinLim = (25,20,20,18,16,15,15,15,15,15,14,
                         13,12,10,5,0);

TYPE
 PlayerInfo   =  record
                   Name : string[20];
                   Cash : longInt;
                   RdPld: Integer;
                   HI1s : Integer;
                 end;

 Playerstat = array[1..300] of PlayerInfo;

 CharSet    = set of Char;


  Clubs       = byte;

  Players = record
             Name  : string[20];
             BAG   : array[1..13] of Clubs;
             ClubNum   : byte;
             Angle     : integer;
             Power     : integer;
             Score     : integer;
             Stroke    : Integer;
             HoleNum   : integer;
             RealDist  : Real;
             RealDistX : Real;
             RealDistY : Real;
             LieNum    : integer;
             Money     : LongInt;
             Holein1s  : Integer;
             CourseNum : Integer;
             RoundsPlyd: Integer;
             Wager     : integer;
             BallLoc   : PointType;
           end;

 Contents  = Record
              Attr : Byte;
              Ch   : Char;
             end;

 GolfHole  =  RECORD
                 PinLoc  : PointType;
                 GROUND  : array [MINX..MAXX,MINY..MAXY] of Contents;
              end;

 HoleRec      = Record
                 par   : Byte;
                 Yards : integer;
                 HdCp  : Byte;
                 Score : Integer;
                End;

 CourseRec    = Record
                 CourseName : string[25];
                 FilePrefix : String[2];
                 CourseNum  : integer;
                 HoleData   : array [1..18] of HoleRec;
                end;

  NAMESTRING =string[25];

  XXBBS = OBJECT(TBBS)
           procedure ShowT10;
           procedure CheckRegistered;
           function  GetRealDist : real;
           procedure MainFlow;
           procedure Instructions;
           procedure UserInit;
           procedure ShowStatus;
           procedure SelectCourse;
           procedure ShowPrices;
           procedure ShowClubDist;
           procedure ShowRankings;
           procedure GetCmd(var Ychar : char; Cset: CharSet);
           procedure ViewGreen(Holnum: byte);
           procedure ViewIt(Holnum: byte);
           procedure ShowClub;
           procedure ShowDPwrBar;
           procedure ShowHoleData;
           procedure GetHoleData;
           procedure GetGreenData;
           procedure GetGreenlie;
           procedure Lie;
           procedure HideBall(Flash : Boolean);
           procedure ShowBall;
           function  GetGreenDist : real;
           procedure EraseTeeLoc;
           procedure GetTeeLoc(var TeeLoc : PointType);
           procedure GetGreenPinLoc(var PinLoc : PointType);
           procedure GetPinLoc(var PinLoc : PointType);
           procedure Get1stDist(X1,Y1,X2,Y2: integer; var D : Real);
           procedure GetSnap(var XS: Byte);
           procedure SelectPower(var AB : boolean);
           procedure SelectAngle(var backup : boolean);
           procedure ShowMarker;
           procedure PutSavChar(MF,MB: Byte; MC :Char);
           procedure PuttBall;
           procedure HitBall;
           procedure Initialize;
           procedure ShowReadyLine;
           Procedure ShowExitLine;
           Procedure ClearExitLine;
           procedure Score( X,Y :integer; ShowStroke : boolean);
           procedure ScoreCard;
           procedure PayDay;
           procedure mainmenu;
           procedure RUNX( var Savem : Boolean );
           procedure GetData;
           Function PlayerFound : Boolean;
          end;
var
  CURRHole   : GolfHole;
  QuitNow    : boolean;
  Auto       : Boolean;
  GameOver   : boolean;
  UsingSavedData : boolean;
  ShowTheCard    : boolean;
  COMNUM     : integer;
  BAUD       : Longint;
  SysOpName  : String[25];
  RN         : String[25];
  BBSNAME    : String[25];
  BBSDIR     : String[25];
  Pn         : integer;
  Quit       : boolean;
  PLYR1      : Players;
  CourseRecord : CourseRec;
  NSWind     : integer;
  EWWind     : integer;
  WindStr    : String;
  Ldate      : String[9];
  Bxs,Bys    : integer;
  Brx,Bry    : real;
  Marker     : PointType;
  UseRTS     : Boolean;
  UseCTS     : Boolean;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure UpDatePlayer;
 var
  PlyrFile     : text;
  TmpPlyrFile  : text;
  found        : boolean;
  TmpName      : String[20];
  DateStr      : String[9];
  I            : integer;
  TmpArry      : array [1..18] of integer;
  TmpRec       : Players;
  TBxs,TBys    : integer;
  TBrx,TBry    : real;


 begin
   Assign(TmpPlyrFile,'PlyrFile.Tmp');
   ReWrite(TmpPlyrFile);
   Assign(PlyrFile,'PlyrFile.Dta');
   Reset(PlyrFile);
   Found:=false;
   while not eof(PlyrFile) do
    begin
     with TmpRec do
     begin
       read(PlyrFile,Name,Money,CourseNum,HoleNum,Stroke,
              Score,LieNum,HoleIn1s,Wager,RoundsPlyd,BallLoc.X,BallLoc.Y,
              RealDistX,RealDistY,TBrx,TBrY,TBXs,TBYs);
       for I := 1 to 18 do Read(PlyrFile,TmpArry[I]);
       Readln(PlyrFile,Datestr);
     end;
     if Plyr1.Name=TmpRec.Name then
     begin
      Found:=True;
      with Plyr1 do
      write(TmpPlyrFile,Name,' ',Money,' ',CourseNum,' ',HoleNum,' ',Stroke,
      ' ',Score,' ',LieNum,' ',HoleIn1s,' ',Wager,' ',RoundsPlyd,
      ' ',BallLoc.X,' ',BallLoc.Y,' ',RealDistX:0:4,' ',RealDistY:0:4,
      ' ',Brx:0:4,' ',BrY:0:4,' ',BXs,' ',BYs,' ');
      with CourseRecord do
        for I := 1 to 18 do Write(TmpPlyrFile,HoleData[I].Score,' ');
      Writeln(TmpPlyrFile,Date);
     end
     else
      begin
       with TmpRec do
       begin
         if pos(date,datestr)=0 then Money :=Money -100;
         if Money >0 then
         begin
         write(TmpPlyrFile,Name,' ',Money,' ',CourseNum,' ',HoleNum,' ',Stroke,
         ' ',Score,' ',LieNum,' ',HoleIn1s,' ',Wager,' ',RoundsPlyd,
         ' ',BallLoc.X,' ',BallLoc.Y,' ',RealDistX:0:4,' ',RealDistY:0:4,
         ' ',TBrx:0:4,' ',TBrY:0:4,' ',TBXs,' ',TBYs,' ');
         for I := 1 to 18 do Write(TmpPlyrFile,TmpArry[I],' ');
         Writeln(TmpPlyrFile,Date);
        end
       end
      end;
    end;
    if Not Found then
     begin
      with Plyr1 do
      write(TmpPlyrFile,Plyr1.Name,' ',Money,' ',CourseNum,' ',HoleNum,' ',Stroke,
      ' ',Score,' ',LieNum,' ',HoleIn1s,' ',Wager,' ',RoundsPlyd,
      ' ',BallLoc.X,' ',BallLoc.Y,' ',RealDistX:0:4,' ',RealDistY:0:4,
      ' ',Brx:0:4,' ',BrY:0:4,' ',BXs,' ',BYs,' ');
      with CourseRecord do
        for I := 1 to 18 do Write(TmpPlyrFile,HoleData[I].Score,' ');
      Writeln(TmpPlyrFile,Date)
     end;
   Close(PlyrFile);
   Close(TmpPlyrFile);
   Erase(PlyrFile);
   rename(TmpPlyrFile,'PlyrFile.DTA');
 end;
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
     Sum:= Sum Mod 42;
     Sum :=Sum+47;
     Code :=Code+Chr(Sum)
    end
  end;
  Registered :=( RN=Code);
  if Not Registered then
   begin
    TextBackGround(0);
    Clrscr;
    textcolor(15);
    Writeln(' BBS GOLF');
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

 procedure XXBBS.PayDay;
 var
  PayCheck : LongInt;
  PayAmt   : LongInt;
  St       : string;
  I        : integer;
 begin
  PayCheck:=0;
  Emu_ClearScreen;
  ComWriteln('');
  ComWriteln('       BBS Golf Version'+Vrs);
  Emu_Color(14,8);
  ComWriteln('           It''s PAY DAY ');
  ComWriteln('');
  Emu_Color(12,0);
  ComWriteln('ออออออออออออออออออออออออออออออออออออ');
  ComWriteln('');
  Emu_Color(11,0);
  ComWrite('  Finishing Round ......');
  Emu_Color(15,0);
  ComWriteln('   $2,000 ');
  PayCheck:=PayCheck+2000;
  Emu_Color(11,0);
  if Plyr1.Score<0 then
  begin
   ComWrite('  Sub-Par Bonus  ...... ');

   Emu_Color(15,0);
   PayAmt:=40000;
   For I:= -1 downto PLyr1.Score do PayAmt :=PayAmt+10000;
   ComWriteln('   $'+Commaput(PayAmt));
   PayCheck:=PayCheck+PayAmt
  end
  else
  if Plyr1.Score=0 then
  begin
   ComWrite('  Even-Par Bonus ...... ');
   Emu_Color(15,0);
   ComWriteln('   $10,000 ');
   PayCheck:=PayCheck+10000
  end
  else
  if Plyr1.Score<4 then
  begin
   ComWrite('  Less Than 4 Over Par..');
   Emu_Color(15,0);
   ComWriteln('   $5,000 ');
   PayCheck:=PayCheck+5000
  end;
  plyr1.Money:=Plyr1.Money+PayCheck;
  ComWriteln('');
  Emu_Color(15,0);
  ComWrite(' Press [Enter]');
  GetEnterKey;
  Plyr1.Score:=0
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetCourseRec(CNUM : integer);
 var
  CrsFile : text;
  I,k     : integer;
  Dirinfo : SearchRec;
  CourseDataFile: array[1..25] of String[12];

 begin
 with CourseRecord do
 begin
  FindFirst('*Crs.dat',Archive,Dirinfo);
  while doserror=0 do
   begin
    assign(CrsFile,DirInfo.Name);
    reset(CrsFile);
    Readln(CrsFile,CourseName);
    Readln(CrsFile,FilePrefix);
    Readln(CrsFile,K);
    Close(CrsFile);
    CourseDataFile[K]:=DirInfo.Name;
    FindNext(DirInfo)
  end;
  if Exist( CourseDataFile[CNUM]) then
   begin
    assign(CrsFile, CourseDataFile[CNUM]);
    reset(CrsFile);
    Readln(CrsFile,CourseName);
    Readln(CrsFile,FilePrefix);
    Readln(CrsFile,CourseNum);
    For I:=1 to 18 do
     Readln(CrsFile,K,HoleData[K].Par,HoleData[K].Yards,HoleData[K].HdCp);
    Close(CrsFile);
   end
   else
    begin
     Writeln(' Course Corrupted or Not Found.... Returning to System.');
     delay(2000);
     Halt(1)
    end;
  end
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
   if Exist('PlyrFile.Dta') then
   begin
    assign(RFile,'PlyrFile.Dta');
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
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetPlayerStatus( var NP : boolean);
 var
  PlyrFile     : text;
  found        : boolean;
  TmpName      : String[20];
  I            : integer;
 begin
  Np:=False;
  If Not Exist('PlyrFile.Dta') then
  begin
   Assign(PlyrFile,'PlyrFile.Dta');
   Rewrite(PlyrFile);
   Close(PlyrFile);
   UpDatePlayer;
   Np:=True
  end
  else
  begin
   Assign(PlyrFile,'PlyrFile.Dta');
   Reset(PlyrFile);
   Found:=False;
   while not eof(PlyrFile) and Not Found do
    begin
     read(PlyrFile,TmpName);
     if Plyr1.Name= TmpName then
     begin
      found:=true;
      with Plyr1 do
      read(PlyrFile,Money,CourseNum,HoleNum,Stroke,Score,LieNum,
      HoleIn1s,Wager,RoundsPlyd,BallLoc.X,BallLoc.Y,RealDistX,RealDistY,
      Brx,BrY,BXs,BYs);
      with CourseRecord do
        for I := 1 to 18 do Read(PlyrFile,HoleData[I].Score);
      Readln(PlyrFile,LDate)
     end
     else
     readln(PlyrFile);
    end;
  close(PlyrFile)
  end;
  if Plyr1.CourseNum>0 then GetCourseRec(Plyr1.CourseNum);
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure UpdateTop10;
  var
   OutFile, Infile : text;
   FileRec  : Playerstat;
   TmpScore : integer;
   TmpName  : String[20];
   RecCount : Integer;
   Added    : boolean;


  begin
   if Not Exist(CourseRecord.FilePrefix+'.T10') then
   begin
     assign(OutFile,CourseRecord.FilePrefix+'.T10');
     Rewrite(Outfile);
     Writeln(Outfile, CourseRecord.CourseName);
     Writeln(Outfile, CourseRecord.FilePrefix);
     Writeln(Outfile, Plyr1.CourseNum);
     Writeln(Outfile, Plyr1.Name,' ',Plyr1.Score*-1);
     Close(Outfile);
    end
    else
     begin
      assign(Infile,CourseRecord.FilePrefix+'.T10');
      assign(Outfile,CourseRecord.FilePrefix+'.Tmp');
      Rewrite(Outfile);
      Reset(Infile);
      RecCount :=0;
      While Not Eof(Infile) and (RecCount <10 ) do
       begin
        Readln(Infile);
        Readln(Infile);
        Readln(Infile);
        Writeln(Outfile, CourseRecord.CourseName);
        Writeln(Outfile, CourseRecord.FilePrefix);
        Writeln(Outfile, Plyr1.CourseNum);
        Added :=False;
         While Not Eof(Infile) and (RecCount <10 ) do
          begin
           Readln(Infile,TmpName,TmpScore);
           If ((Plyr1.Score*-1)>TmpScore) and Not Added then
            begin
             Writeln(Outfile, Plyr1.Name,' ',Plyr1.Score*-1);
             Writeln(Outfile, TmpName,' ',TmpScore);
             Added:=true;
             RecCount :=RecCount+2;
            end
            Else
             begin
               Writeln(Outfile, TmpName,' ',TmpScore);
               RecCount :=RecCount+1;
             end
          end;
          IF Not Added And (RecCount<10) then
            Writeln(Outfile, Plyr1.Name,' ',Plyr1.Score*-1);
       end;
      Close(Infile);
      Close(Outfile);
      Erase(Infile);
      Rename(OutFile,CourseRecord.FilePrefix+'.T10');
     end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowT10;
 var
   I,K,CourseCnt  : integer;
   St             : String;
   CourseName1    : String[25];
   CrsFile        : text;
   Dirinfo        : SearchRec;
   FP             : Array[1..25] of String[2];
   CourseNames    : array[1..25] of String[25];
   Cfound         : Array[1..25] of Boolean;
   FPT            : string[2];
   PrtName        : String[20];
   C              : Char;
   Code           : integer;
   DoneLooking    : Boolean;

 begin
  CourseCnt :=0;
  K :=0;
  for I:=1 to 25 do Cfound[I] :=false;
  FindFirst('*.T10',Archive,Dirinfo);
  while doserror=0 do
   begin
    assign(CrsFile,DirInfo.Name);
    reset(CrsFile);
    Readln(CrsFile,CourseName1);
    Readln(CrsFile,FPT);
    Readln(CrsFile,K);
    Close(CrsFile);
    CourseCnt:=CourseCnt+1;
    K:=CourseCnt;
    FP[K]:=FPT;
    CourseNames[K]:=CourseName1;
    Cfound[K] :=true;
    FindNext(DirInfo)
  end;
  DoneLooking :=False;
  While Not DoneLooking and Online and Not GoOffLine do
  begin
  Emu_Color(15,0);
  emu_ClearScreen;
  ComWriteln('');
  ComWriteln('       BBS Golf Version'+Vrs);
  Emu_Color(14,0);
  ComWriteln('          Top Ten Scores');
  ComWriteln('         Available Courses');
  ComWriteln('');
  Emu_Color(11,0);
  ComWriteln('ออออออออออออออออออออออออออออออออออออ');
  ComWriteln('');
  if Not Registered and (CourseCnt>1) then CourseCnt:=1;
  If CourseCnt<1 then
  begin
   Emu_Color(15,0);
   ComWriteln(' No Top Scores Recorded Yet...');
   ComWriteln('');
   Emu_Color(15,0);
   ComWrite(' Press [Enter]');
   GetEnterKey;
   DoneLooking :=true
  end
  else
  begin
   for I:= 1 to CourseCnt do
    begin
    Emu_Color(15,0);
    Str(I,St);
    ComWrite(St+'.      ');
    Emu_Color(14,0);
    ComWriteln(CourseNames[I]);
   end;
   Emu_Color(12,0);
   ComWriteln('Q.      Quit  ');
   ComWriteln('');
   Emu_Color(15,0);
   ComWrite(' Select Course to View Top 10 Scores of # ');
   str(CourseCnt:2,ST);
   GetChar(C,['1'..ST[2],'Q']);
   if ReQChat then
     begin
      C:='0';
      Chat
     end;
   if C='Q' then DoneLooking :=true;
  if Online and Not GoOffLine and Not DoneLooking then
  begin
   Val(C,I,Code);
  if Code<> 0 then
    begin
     ComWriteln(' Top 10 File Corrupted... Returning to System..');
     delay(3000);
     GoOffLine :=true;
   end
   else
    begin
    assign(CrsFile,FP[I]+'.T10');
    reset(CrsFile);
    while Not Eof(CrsFile) and online and not GoOffLine do
     begin
       Readln(CrsFile,St);
       Readln(CrsFile,St);
       Readln(CrsFile,St);
       Emu_ClearScreen;
       emu_color(0,7);
       while length(CourseNames[I])<25 Do CourseNames[I]:=CourseNames[I]+' ';
       Comwrite('     '+CourseNames[I]+' Top 10 Best Scores           ');
       emu_color(14,0);
       ComWriteln('');
       ComWriteln('');
       ComWrite('      Player Name    ');
       emu_color(10,0);
       ComWriteln('             Score    ');
       emu_color(9,0);
       ComWriteln('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
       emu_color(15,0);
       while Not Eof(CrsFile) and online and not GoOffLine do
       begin
        Readln(CrsFile,PrtName,I);;
        Emu_color(11,0);
        ComWrite('     '+PrtName+'         ');
        If I=0 then St:=' Even'  else   Str(I*-1,St);
        if I<0 then St:='+'+St;
        Emu_color(15,0);
        Comwriteln(St)
       end
     end;
    Close(CrsFile);
    end
   end
  end;
  if Not DoneLooking then
   begin
    ComWriteln('');
    Emu_Color(15,0);
    ComWrite(' Press [Enter]');
    GetEnterKey;
   end
  end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.SelectCourse;
 var
   I,K,CourseCnt  : integer;
   St             : String;
   Fp             : String[2];
   CourseName     : String[25];
   CrsFile        : text;
   Dirinfo        : SearchRec;
   CourseNames    : array[1..25] of String[25];
   C              : Char;
   Code           : integer;

 begin
  Plyr1.CourseNum:=1;
  CourseCnt :=0;
  FindFirst('*Crs.dat',Archive,Dirinfo);
  while doserror=0 do
   begin
    assign(CrsFile,DirInfo.Name);
    reset(CrsFile);
    Readln(CrsFile,CourseName);
    Readln(CrsFile,FP);
    Readln(CrsFile,K);
    Close(CrsFile);
    CourseNames[K]:=CourseName;
    CourseCnt:=CourseCnt+1;
    FindNext(DirInfo)
  end;
  If CourseCnt<1 then
  begin
   ComWriteln(' No Course Files Found... Returning to System..');
   delay(3000);
   done;
   halt(1);
  end;
  Emu_Color(15,0);
  emu_ClearScreen;
  ComWriteln('');
  ComWriteln('       BBS Golf Version'+Vrs);
  Emu_Color(14,0);
  ComWriteln('         Available Courses');
  ComWriteln('');
  Emu_Color(12,0);
  ComWriteln('ออออออออออออออออออออออออออออออออออออ');
  ComWriteln('');
  if Not Registered then CourseCnt:=1;
  for I:= 1 to CourseCnt do
  begin
   Emu_Color(15,0);
   Str(I,St);
   ComWrite(St+'.      ');
   Emu_Color(14,0);
   ComWriteln(CourseNames[I]);
  end;
  ComWriteln('');
  Emu_Color(15,0);
  if Not registered then
  begin
    ComWriteln(' There are Many other Courses Available With Registration. ');
    ComWriteln(' Ask SysOp to Register!!!');
    ComWriteln(' In the Mean Time Have Fun at '+CourseNames[1]+'.');
    C:='1';
    ComWriteln('');
    ComWrite('Press [Enter]...');
    GetEnterKey
  end
  else
  begin
   ComWrite(' Select Course # ');
   str(CourseCnt:2,ST);
   GetChar(C,['1'..ST[2]])
  end;
  if ReQChat then
   begin
     C:='0';
     Chat;
   end;
  if Not QuitNow and Online and Not GoOffLine then
  begin
   Val(C,Plyr1.CourseNum,Code);
  if Code<> 0 then
    begin
     ComWriteln(' Course File Corrupted... Returning to System..');
     delay(3000);
     done;
     halt(1)
   end
  end;
  if Plyr1.Money> 1000 then Plyr1.Money:=Plyr1.Money-1000;
  If PLyr1.Money<0 then Plyr1.Money:=5000;
  Plyr1.HoleNum:=1;
  Plyr1.LieNum:=OnTee;
  Plyr1.Score:=0;
  Plyr1.Stroke:=0;
  for I:=1 to 18 do CourseRecord.Holedata[I].Score:=0
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowStatus;
 var
   I  : integer;
   St : String;

 begin
  Emu_Color(15,0);
  emu_ClearScreen;
  ComWriteln('');
  ComWriteln('         BBS Golf Version'+Vrs);
  Emu_Color(14,0);
  ComWriteln('             Your Status');
  ComWriteln('');
  Emu_Color(12,0);
  ComWriteln('อออออออออออออออออออออออออออออออออออออออ');
  ComWriteln('');
  Emu_Color(15,0);
  ComWrite(' Player Name...... ');
  Emu_Color(14,0);
  ComWriteln(Plyr1.Name);
  Emu_Color(15,0);
  ComWrite(' Cash............. ');
  Emu_Color(10,0);
  ComWriteln('$'+ CommaPut(Plyr1.Money));
  Emu_Color(15,0);
  ComWrite(' Rating........... ');
  Emu_Color(13,0);
  if Plyr1.Money< 10000 then
   ComWriteln('Beginner')
   else
  if Plyr1.Money< 100000 then
   ComWriteln('Amateur')
   else
  if Plyr1.Money< 1000000 then
   ComWriteln('Sub-Professional')
   else
  if Plyr1.Money< 10000000 then
   ComWriteln('Profesional')
   else
  if Plyr1.Money>=100000000 then
   ComWriteln('Legend');
  Emu_Color(15,0);
  ComWrite(' Hole In Ones.....  ');
  Emu_Color(14,0);
  Str(Plyr1.HoleIn1s:3,St);
  ComWriteln(St);
  Emu_Color(15,0);
  ComWrite(' Rounds Played....  ');
  Emu_Color(14,0);
  Str(Plyr1.RoundsPlyd:3,St);
  ComWriteln(St);
  Emu_Color(15,0);
  ComWrite(' Current Course... ');
  Emu_Color(11,0);
  if CourseRecord.CourseName <>'' then
  begin
   ComWriteln(CourseRecord.CourseName);
   Emu_Color(15,0);
   ComWrite(' Current Hole.....   ');
   Emu_Color(14,0);
   Str(Plyr1.HoleNum:2,St);
   ComWriteln(St);
   Emu_Color(15,0);
   ComWrite(' Current Score.... ');
   Emu_Color(14,0);
   Score(21,14,false);
   ComWriteln('');
   ComWriteln('');
  end
  else
  ComWriteln(' None ');

  ComWriteln('');
  Emu_Color(15,0);
  ComWrite(' Press [Enter]');
  GetEnterKey;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowPrices;
 var
   I  : integer;
   St : String;

 begin
  Emu_Color(15,0);
  emu_ClearScreen;
  ComWriteln('');
  ComWriteln('                             BBS Golf Version'+Vrs);
  Emu_Color(14,0);
  ComWriteln('                              How Money Is Awarded');
  Emu_Color(12,0);
  ComWriteln('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
  ComWriteln('');
  Emu_Color(15,0);
  ComWrite(' Finishing a Round  ......... ');
  Emu_Color(14,0);
  ComWriteln(' $2,000');
  Emu_Color(15,0);
  ComWrite(' Score of +1 to +3  ......... ');
  Emu_Color(14,0);
  ComWriteln(' $5,000');
  Emu_Color(15,0);
  ComWrite(' Score of EVEN      ......... ');
  Emu_Color(14,0);
  ComWriteln(' $10,000');
  Emu_Color(15,0);
  ComWrite(' Sub-Par Score      ......... ');
  Emu_Color(14,0);
  ComWriteln(' $40,000 + 10,000 for each Stroke Under Par');
  Emu_Color(15,0);
  ComWrite(' Hole In One        ......... ');
  Emu_Color(14,0);
  ComWriteln(' $50,000');
  Emu_Color(15,0);
  ComWrite(' Albatros           ......... ');
  Emu_Color(14,0);
  ComWriteln(' $5,000');
  Emu_Color(15,0);
  ComWrite(' Eagle              ......... ');
  Emu_Color(14,0);
  ComWriteln(' $1,000');
  Emu_Color(15,0);
  ComWrite(' Bird               ......... ');
  Emu_Color(14,0);
  ComWriteln(' $50');
  Emu_Color(11,0);
  ComWriteln('');
  ComWriteln('');
  ComWriteln('                                Expenses');
  Emu_Color(13,0);
  ComWriteln('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
  ComWriteln('');
  Emu_Color(15,0);
  ComWrite(' Playing a Round       ......... ');
  Emu_Color(14,0);
  ComWriteln(' $1,000');
  ComWriteln('');
  Emu_Color(15,0);
  ComWrite(' Daily Green Fee       ......... ');
  Emu_Color(14,0);
  ComWriteln(' $100');
  ComWriteln('');
  Emu_Color(15,0);
  ComWrite(' Press [Enter]');
  GetEnterKey;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowClubDist;
 var
   I  : integer;
   St : String;

 begin
  Emu_Color(15,0);
  emu_ClearScreen;
  ComWriteln('');
  ComWriteln('   BBS Golf Version'+Vrs);
  Emu_Color(14,0);
  ComWriteln('      Club Distances');
  ComWriteln('');
  Emu_Color(11,0);
  ComWriteln('   Club          Distance');
  Emu_Color(12,0);
  ComWriteln('อออออออออออออออออออออออออออออ');
  for I := 1 to 13 do
  begin
   Emu_Color(ClubClrF[Plyr1.Bag[I]],ClubClrB[Plyr1.Bag[I]]);
   ComWrite( ' '+Club[plyr1.Bag[I]]+' ');
   Emu_Color(15,0);
   str(ClubMax[plyr1.Bag[I]]+ClubMin[plyr1.Bag[I]]:3,ST);
   ComWrite( '      '+St);
   Emu_Color(10,0);
   ComWrite('  yards');
   ComWriteln('');
  end;
  ComWriteln('');
  Emu_Color(15,0);
  ComWrite(' Press [Enter]');
  GetEnterKey;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ScoreCard;
  var
   I,J,Youts,
   Outs,Souts : integer;
   St: String;
 begin
  if OnLine And Not GoOffLine then
  begin
  Emu_Color(9,0);
  Emu_clearscreen;
  ComWriteln('ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ');
  ComWriteln('ณ                                                                        ณ');
  ComWriteln('รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤยฤฤฤฤยฤฤฤฤยฤฤฤฤยฤฤฤฤยฤฤฤฤยฤฤฤฤยฤฤฤฤยฤฤฤฤฤด');
  ComWriteln('ณ                     ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ     ณ');
  ComWriteln('รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤฤด');
  ComWriteln('ณ                     ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ     ณ');
  ComWriteln('รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤฤด');
  ComWriteln('ณ                     ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ     ณ');
  ComWriteln('รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤฤด');
  ComWriteln('ณ                     ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ     ณ');
  ComWriteln('รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤฤด');
  ComWriteln('ณ                     ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ     ณ');
  ComWriteln('ฦอออออออออออออออออออออุออออุออออุออออุออออุออออุออออุออออุออออุออออุอออออต');
  ComWriteln('ณ                     ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ     ณ');
  ComWriteln('รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤฤด');
  ComWriteln('ณ                     ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ     ณ');
  ComWriteln('รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤฤด');
  ComWriteln('ณ                     ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ     ณ');
  ComWriteln('รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤฤด');
  ComWriteln('ณ                     ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ     ณ');
  ComWriteln('รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤลฤฤฤฤฤด');
  ComWriteln('ณ                     ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ    ณ     ณ');
  ComWriteln('ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤมฤฤฤฤมฤฤฤฤมฤฤฤฤมฤฤฤฤมฤฤฤฤมฤฤฤฤมฤฤฤฤมฤฤฤฤฤู');
  with CourseRecord do
  begin
   Emu_gotoXy(3,2);
   Emu_Color(15,0);
   ComWrite(CourseName);
   Emu_gotoXy(35,2);
   ComWrite(Plyr1.Name);
   Score(whereX+3,2,false);
   ComWriteln(' ');
   ComWriteln('');
   Emu_Color(10,0);
   Emu_CursorRight;
   Emu_CursorRight;
   ComWrite('Hole #             ');
   Emu_CursorRight;
   For I:=1 to 9 do
   begin
   Str(I:3,St);
   Emu_CursorRight;
   ComWrite(St+' ');
   end;
   Emu_CursorRight;
   ComWriteln(' In  ');
   ComWriteln('');
   Emu_Color(14,0);
   Emu_CursorRight;
   Emu_CursorRight;
   ComWrite('Yards              ');
   Emu_CursorRight;
   J:=0;
   For I:=1 to 9 do
   begin
   J:=J+CourseRecord.Holedata[I].Yards;
   Str(CourseRecord.Holedata[I].Yards:4,St);
   Emu_CursorRight;
   ComWrite(St);
   end;
   Str(J:5,St);
   Youts:=J;
   Emu_CursorRight;
   ComWriteln(St);
   ComWriteln('');
   Emu_Color(11,0);
   Emu_CursorRight;
   Emu_CursorRight;
   ComWrite('Par                ');
   Emu_CursorRight;
   J:=0;
   For I:=1 to 9 do
   begin
   J:=J+CourseRecord.Holedata[I].Par;
   Str(CourseRecord.Holedata[I].Par:3,St);
   Emu_CursorRight;
   ComWrite(St+' ');
   end;
   Str(J:4,St);
   Outs:=J;
   Emu_CursorRight;
   ComWriteln(St+' ');
   ComWriteln('');
   Emu_Color(15,0);
   Emu_CursorRight;
   Emu_CursorRight;
   ComWrite(Plyr1.Name);
   for I:=1 to 20-Length(Plyr1.Name) do ComWrite(' ');
   {tag}
   J:=0;
   For I:=1 to 9 do
   begin
    J:=J+CourseRecord.Holedata[I].Score;
    Str(CourseRecord.Holedata[I].Score:3,St);
    Emu_CursorRight;
    if ST='  0' then ComWrite('    ')
    else
     begin
      if CourseRecord.Holedata[I].Score < CourseRecord.Holedata[I].Par then
      Emu_color(12,0)
      else if CourseRecord.Holedata[I].Score > CourseRecord.Holedata[I].Par then
      Emu_color(10,0)
      else Emu_color(15,0);
      ComWrite(St+' ')
     end
   end;
   Str(J:4,St);
   Souts:=J;
   Emu_CursorRight;
   ComWriteln(St+' ');
   ComWriteln('');
   Emu_Color(13,0);
   Emu_CursorRight;
   Emu_CursorRight;
   ComWrite('HandiCap           ');
   Emu_CursorRight;
   For I:=1 to 9 do
   begin
   Str(CourseRecord.Holedata[I].HDCP:3,St);
   Emu_CursorRight;
   ComWrite(St+' ');
   end;
   ComWriteln('');
   ComWriteln('');
   Emu_Color(10,0);
   Emu_CursorRight;
   Emu_CursorRight;
   ComWrite('Hole #             ');
   Emu_CursorRight;
   For I:=10 to 18 do
   begin
   Str(I:3,St);
   Emu_CursorRight;
   ComWrite(St+' ');
   end;
   Emu_CursorRight;
   ComWriteln(' Out ');
   ComWriteln('');
   Emu_Color(14,0);
   Emu_CursorRight;
   Emu_CursorRight;
   ComWrite('Yards              ');
   Emu_CursorRight;
   J:=YOuts;
   For I:=10 to 18 do
   begin
   J:=J+CourseRecord.Holedata[I].Yards;
   Str(CourseRecord.Holedata[I].Yards:4,St);
   Emu_CursorRight;
   ComWrite(St);
   end;
   Str(J:5,St);
   Emu_CursorRight;
   ComWriteln(St);
   ComWriteln('');
   Emu_Color(11,0);
   Emu_CursorRight;
   Emu_CursorRight;
   ComWrite('Par                ');
   Emu_CursorRight;
   J:=Outs;
   For I:=10 to 18 do
   begin
   J:=J+CourseRecord.Holedata[I].Par;
   Str(CourseRecord.Holedata[I].Par:3,St);
   Emu_CursorRight;
   ComWrite(St+' ');
   end;
   Str(J:4,St);
   Emu_CursorRight;
   ComWriteln(St+' ');
   ComWriteln('');
   Emu_Color(15,0);
   Emu_CursorRight;
   Emu_CursorRight;
   ComWrite(Plyr1.Name);
   for I:=1 to 20-Length(Plyr1.Name) do ComWrite(' ');
   J:=Souts;
   For I:=10 to 18 do
   begin
    J:=J+CourseRecord.Holedata[I].Score;
    Str(CourseRecord.Holedata[I].Score:3,St);
    Emu_CursorRight;
    if ST='  0' then ComWrite('    ')
    else
     begin
      if CourseRecord.Holedata[I].Score < CourseRecord.Holedata[I].Par then
      Emu_color(12,0)
      else if CourseRecord.Holedata[I].Score > CourseRecord.Holedata[I].Par then
      Emu_color(10,0)
      else Emu_color(15,0);
      ComWrite(St+' ')
     end
   end;
   Str(J:4,St);
   Emu_CursorRight;
   ComWriteln(St+' ');
   ComWriteln('');
   Emu_Color(13,0);
   Emu_CursorRight;
   Emu_CursorRight;
   ComWrite('HandiCap           ');
   Emu_CursorRight;
   For I:=10 to 18 do
   begin
   Str(CourseRecord.Holedata[I].HDCP:3,St);
   Emu_CursorRight;
   ComWrite(St+' ');
   end;
   ComWriteln('');
  end;
  emu_Color(15,0);
  ComWriteln('');
  ShowTheCard:=false;
  ComWrite('Press [ENTER]');
  GetenterKey

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
    Comwrite('                     Instructions For Playing BBS Golf                          ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    ComWriteln('   Object : The object of BBS Golf is to become a Legendary Golfer.');
    ComWriteln(' Upon Reaching $5,000,000 you become a Legend.  You earn Bucks by playing  ');
    ComWriteln(' Good Golf Games.  Bonuses are received for Hole In Ones and for Sub-PAR ');
    ComWriteln(' Games.  Once you Start a round of golf, you will be required to finish that ');
    ComWriteln(' round before starting any others. You may quit at any time. Your Game will be ');
    ComWriteln(' Saved and resumed automatically when you return..');
    emu_color(11,0);
    ComWriteln('');
    ComWriteln('   Selecting Club :   Club Distances can be viewed from the main menu.  Use');
    ComWriteln(' The PgUp/PgDn Keys or 9 for up, 3 for down to change the club selection');
    ComWriteln(' while you are on the course..');
    ComWriteln('');
    ComWriteln('  Selecting Direction :   Simply Move the Flashing White Pole Marker to the ');
    ComWriteln(' spot that you want the ball to go.   Use the Up/Down/Left/Right Arrow keys');
    ComWriteln(' or 8 for Up, 2 for Down, 4 for Left, and 6 for Right.');
    ComWriteln('');
    ComWriteln('  Selecting Power :   After your Club And Direction are Set up, Press [Enter]' );
    ComWriteln(' to begin swinging Your Club.  This is where Timing Skills will be required.');
    ComWriteln(' After Pressing "[SpaceBar] to HIT THE BALL", The Power Bar will Start to Grow.');
    ComWriteln(' Press [SpaceBar] When the Power Bar reaches the desired power.');
    ComWriteln(' A selection of power greater than 100% will cause Overswing variations.');
    emu_color(10,0);
    ComWriteln('');
    ComWrite('Press [ENTER]..');
    getenterkey;
    Emu_ClearScreen;
    clrscr;
    showmsr;
    emu_color(0,7);
    Comwrite('                     Instructions For Playing BBS Golf                          ');
    ComWriteln('');
    ComWriteln('');
    emu_color(14,0);
    ComWriteln('  Snap : BBS Golf now has a SNAP feature. After the power Bar has Reached' );
    ComWriteln(' the desired power, It will Move the opposite direction toward the SNAP Line.');
    ComWriteln(' Hit the [Spacebar] When the Power Bar reaches the Snap Line. An Early snap ');
    ComWriteln(' will cause a Draw and a Late snap will cause a Fade.');
    ComWriteln('');
    ComWriteln('');
    emu_color(15,0);
    ComWriteln('   Special Notes :  Your ball will be visible if you land in the fairway or ');
    ComWriteln(' on the green, However, if you land in the rough or any where else, your ball');
    ComWriteln(' will be harder to see and will be marked by a black cursor.  Also Be careful');
    ComWriteln(' when driving through trees. They can be a major Obstacle.');
    ComWriteln('');
    ComWriteln('   If during any Hole your stroke count reaches 10, the computer will ');
    ComWriteln(' automatically place your ball in the cup.');
    ComWriteln('');
    ComWriteln('');
    emu_color(10,0);
    ComWrite('Press [ENTER]..');
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
   if pos('  ',Fname)>0 then delete(Fname,pos('  ',Fname),1);
   while Length(FName)< 20 do Fname:=Fname+' ';
   Fname:=Copy(Fname,1,20)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure ShellSort(var SortList :PlayerStat; Count: integer);
  var
    D , Limit   : integer;
    Next, Exndx : integer;
    ExFlag      : boolean;
    TmpRec      : PlayerInfo;

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
       if SortList[Next].Cash < SortList[Next+D].Cash then
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
            ExFlag := (SortList[Exndx].Cash >= SortList[Exndx+D].Cash)
           else ExFlag := True;
          end
        end;
       Next := Next + 1
      end;
     D := D Div 2
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetPlayers(var Players: PlayerStat; var PlayerCnt : integer);
  var
   Dummy : integer;
   Rfile : text;

 begin
   if Not Exist('Plyrfile.dta') then
   begin
    assign(RFile,'Plyrfile.dta');
    rewrite(RFile);
    CLOSE(RFile)
   end;
   PlayerCnt:=0;
   assign(RFile,'Plyrfile.dta');
   reset(RFile);
   while not eof(Rfile) and (PlayerCnt<300) do
   begin
    PlayerCnt:=PlayerCnt+1;
    readln(Rfile,Players[PlayerCnt].Name,Players[PlayerCnt].Cash,
           Dummy,Dummy,Dummy,Dummy,Dummy,Players[PlayerCnt].HI1s,Dummy,
           Players[PlayerCnt].RdPld);
     IF Players[PlayerCnt].Name =Plyr1.Name then
      begin
       Players[PlayerCnt].Cash  :=Plyr1.Money;
       Players[PlayerCnt].HI1s  :=Plyr1.HoleIn1s;
       Players[PlayerCnt].Rdpld :=Plyr1.Roundsplyd
      end
   end;
  CLOSE(RFile)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowRankings;
 var
  RFile       : text;
  CNT,I       : integer;
  Money1      : LongInt;
  ST,STT      : string;
  Players     : Playerstat;
  PlayerCnt   : integer;
  LineCount   : integer;
  Continue    : Boolean;

 begin
   if Registered or (pos('Chris Neubauer',Plyr1.Name) >0) then
   Begin
   GetPlayers(Players,PlayerCnt);
   ShellSort(Players,PlayerCnt);
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    emu_color(0,7);
    Comwrite('                       BBS Golf List of Champions                               ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    ComWrite('   Player Name    ');
    emu_color(11,0);
    ComWrite('       Bucks    ');
    emu_color(13,0);
    ComWrite('      Status  ');
    emu_color(12,0);
    ComWrite('       Rounds Played');
    emu_color(14,0);
    ComWriteln('    Aces');
    emu_color(9,0);
    ComWriteln('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
    emu_color(15,0);
    CNT :=1;
    LineCount:=0;
    Continue:=true;
    while Not (CNT > PlayerCnt) and Online and Not GoOffLine and Continue do
     begin
      Emu_Color(14,0);
      ComWrite('  '+Players[Cnt].Name);
      Emu_Color(10,0);
      Money1 := Players[CNT].Cash;
      ComWrite('   $'+ CommaPut(Money1));
      Emu_GotoXy(40,WhereY);
      Emu_Color(13,0);
      if Money1< 10000 then
       ComWrite('Beginner        ')
      else
      if Money1< 100000 then
       ComWrite('Amateur         ')
      else
      if Money1< 1000000 then
       ComWrite('Sub-Professional')
      else
      if Money1< 5000000 then
       ComWrite('Profesional     ')
      else
      if Money1> 4999999 then
       ComWrite('Legend          ');
       Str(Players[CNT].RdPld:5,St);
       emu_color(15,0);
       ComWrite('     '+St);
       Str(Players[CNT].HI1S:4,St);
       emu_color(15,0);
       ComWriteln('      '+St);
      Cnt:=Cnt+1;
      LineCount:= LineCount+1;
      If LineCount >16 then
       begin
        LineCount:=0;
        ComWriteln('');
        ComWrite('  More ');
        GetYn(ConTinue,true);
        if Continue then
         begin
           textbackground(0);
           emu_ClearScreen;
           emu_color(0,7);
           Comwrite('                       BBS Golf List of Champions                               ');
           emu_color(14,0);
           ComWriteln('');
           ComWriteln('');
           ComWrite('   Player Name    ');
           emu_color(11,0);
           ComWrite('       Bucks    ');
           emu_color(13,0);
           ComWrite('      Status  ');
           emu_color(12,0);
           ComWrite('       Rounds Played');
           emu_color(14,0);
           ComWriteln('    Aces');
           emu_color(9,0);
           ComWriteln('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
           emu_color(15,0);
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
    emu_color(12,0);
    ComWrite(' Press [ENTER]... ');
    getenterkey;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetCmd(var YChar : char; Cset: CharSet);
 var
  timesav : string[8];
  chh: char;
  XS,YS : integer;
  MinCnt : integer;

  begin
   MinCnt :=0;
   ClearReceive;
   Timesav:=time;
   if Online and Not GoOffLine then
   begin
    Ychar:=#0;
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
       EMU_GOTOXY(60,24);
       TimePrompt;
       EMU_GOTOXY(XS,YS);
       showmsr;
       Timesav:=time;
       MinCnt:=MinCnt+1;
       if MinCnt >3 then
        begin
          ComWriteO(#7+#7+#7);
          Emu_GoToXy(35,24);
          Emu_Color(15,0);
          ComWrite(' Inactivity Warning !!!');
          if MinCnt>4 then GoOffline:=true
        end
   end;
     if ChWaiting or Local then
      begin
       if Local then Ychar:=Upcase(readkey)
        else Ychar:=Upcase(ComREADKEY);
       If YChar='X' then QuitNow :=true;
       IF YChar in ['S','R'] then ShowTheCard :=true;

       if  Ychar in[#27, #0] then
        begin
           delay(10);
           if Local then
           begin
           Ychar:=Upcase(readkey);
           end
           else
           begin
            delay(10);
            Ychar:=ComREADKEY;
            delay(10);
           end;
           while YChar = #0 do
            if Local then Ychar:=Upcase(readkey)
            else Ychar:=ComREADKEY;
           while YChar = '[' do
            if Local then Ychar:=Upcase(readkey)
            else
              begin
               delay(10);
               Ychar:=ComREADKEY;
              end;
           if not Local then while ChWaiting do Ychar:=Upcase(ComREADKEY)
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
        if Ychar='6' then Ychar:='M';
        if Ychar='8' then Ychar:='H'
    until (Ychar in Cset) or GoOffLine or Not Online or QuitNow;
    if Not local and Keypressed then
     begin
      while Keypressed do chh:=readkey;
      if chh=#59 then reqchat:=true;
      if chh=#68 then GoOffLine:=true;
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
  TIMELIMIT := 60;
  TimeUsed  := 0;
  LTime    := Time;
  LDate    := Date;
  ReqChat:= false;
  Local  :=false;
  StartTime := TimeNow;
  Hotkeys:=true;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.Initialize;
 begin
  SETPORT(COMNUM);
  IF not Local then
  begin
   OPENPORT(COMNUM);
   SETDBPS(BAUD);
   SetFlowControl(UseCTS,UseRTS)
  end;
  SHOWMSR;
  if not LoadEmulation('GOLF') then
   begin
     writeln(' Unable to Load GOLF.emu..');
     done;
     halt
   end;
  GoOffLine:=false;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.mainmenu;
 var I : integer;
 Regstr : string;
 Chh    : Char;
 begin
 clearreceive;
 emu_color(15,0);
 textbackground(0);
 emu_ClearScreen;
 clrscr;
 if Exist('GlfScr.Scr') then
  begin
   TypeFile('GlfScr.Scr',Chh);
  end
 else
 begin
  Comwriteln('');
  Comwriteln('                    าฤฟ  าฤฟ  ึฤฤฟ     ึฤฤฟ ึฤฤฟ า    าฤฤฟ');
  Comwriteln('                    วฤมฟ วฤมฟ ำฤฤฟ     บ ฤฟ บ  ณ บ    วฤ  ');
  Comwriteln('                    ะฤฤู ะฤฤู ำฤฤู     ำฤฤู ำฤฤู ะฤฤู ะ   ');
 end;
 Comwriteln('');
 Comwriteln('');
 emu_color(11,0);
 Comwrite('                           Version');
 emu_color(12,0);
 Comwrite(Vrs);
 emu_color(14,0);
 Comwriteln(' (c) 1993 ');
 emu_color(15,0);
 Comwriteln('                        Neubauer Applications Uncorp ');
 emu_color(7,0);
 Comwriteln('                      Virtual Reality BBS 512-992-4496');
 emu_color(11,8);
 if Registered then
 begin
  I:=Pos('  ',BBSName);
  if I>0 then BBSName[0] := Chr(I-1);
  RegStr:=' Registered to '+BBSName;
  Emu_GotoXy(38-(Length(RegStr) div 2),WhereY);
 ComWriteln(RegStr)
 end
 else
 Comwriteln('               UNREGISTERED COPY  ... ASK SYSOP TO REGISTER');
{ Comwriteln('                  Original Version for Virtual Reality BBS');}
 Comwriteln('');
 Comwriteln('');
 emu_color(10,0);
 Comwriteln(' [G]  Go to Golf Course');
 emu_color(13,0);
 Comwriteln(' [Y]  Your Status');
 emu_color(11,0);
 Comwriteln(' [R]  Rankings');
 emu_color(15,0);
 Comwriteln(' [C]  Course Top Ten Scores');
 emu_color(14,0);
 Comwriteln(' [D]  Club Distances');
 emu_color(10,0);
 Comwriteln(' [P]  Prizes and Prices');
 emu_color(7,0);
 Comwriteln(' [I]  Instructions');
 emu_color(12,0);
 Comwriteln(' [Q]  Quit Back to BBS');
 showMsr;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ViewIt(Holnum: byte);
 var
  st          : string;
  I,J         : integer;
  begin
  If Online And Not GoOffLine then
  begin
   emu_color(15,0);
   emu_clearscreen;
   emu_gotoxy(1,1);
   TYPEHole(CourseRecord.FilePrefix+'.glf',HolNum);
   for I:=1 to 16 do
    begin
     for j:=1 to 60 do
     begin
      GetScreenWord(J, I, CurrHole.Ground[J,I].Attr,CurrHole.Ground[J,I].Ch)
     end
    end
   end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ViewGreen(Holnum: byte);
 var
  st          : string;
  I,J         : integer;

  begin
   If Online And Not GoOffLine then
   begin
   emu_color(15,0);
   emu_clearscreen;
   emu_gotoxy(1,1);
   TYPEHole(CourseRecord.FilePrefix+'g.glf',HolNum);
   for I:=1 to 16 do
    begin
     for j:=1 to 60 do
     begin
      GetScreenWord(J, I, CurrHole.Ground[J,I].Attr,CurrHole.Ground[J,I].Ch)
     end
    end
   end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBs.HideBall(Flash : Boolean);
  Var
   X,Y : integer;
   Offs  : Byte;

  begin
   if Flash then Offs :=8 else Offs :=0;
   X:=Plyr1.Ballloc.X;
   Y:=Plyr1.Ballloc.Y;
   if X>Maxx then X:=Maxx;
   if X<MinX then X:=Minx;
   if Y>MaxY then X:=MaxY;
   if Y<MinY then X:=MinY;
   Emu_gotoxy(X,Y);
   Emu_color(CurrHole.Ground[X,Y].Attr Mod 16,(CurrHole.Ground[X,Y].Attr Div 16)+Offs);
   if CurrHole.Ground[X,Y].Ch = '.' then ComWrite(' ')
   else ComWrite(CurrHole.Ground[X,Y].Ch)
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBs.ShowBall;
  Var
   X,Y  : integer;
  begin
   X:=Plyr1.Ballloc.X;
   Y:=Plyr1.Ballloc.Y;
   if X>Maxx then X:=Maxx;
   if X<MinX then X:=Minx;
   if Y>MaxY then X:=MaxY;
   if Y<MinY then X:=MinY;
   Emu_Color(15,CurrHole.Ground[X,Y].Attr Div 16);
    Emu_gotoxy(X,Y);
   if (Plyr1.LieNum= InFairWay) or
      (Plyr1.LieNum= OnTee) or
      (Plyr1.LieNum= Green) then
       begin
        CoMwrite('.');
        Emu_gotoxy(X,Y);
      end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowMarker;
 begin
  Emu_gotoxy(Marker.X,Marker.Y);
  Emu_Color(15, 10);
  ComWrite('');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetSavChar(var MF,MB: Byte; var MC :Char);
 begin
  MF :=CurrHole.Ground[Marker.X,Marker.Y].Attr Mod 16;
  MB :=CurrHole.Ground[Marker.X,Marker.Y].Attr Div 16;
  MC :=CurrHole.Ground[Marker.X,Marker.Y].Ch
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.PutSavChar(MF,MB: Byte; MC :Char);
 begin
   Emu_gotoxy(Marker.X,Marker.Y);
   Emu_Color( MF, MB);
   ComWrite(MC);
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.SelectAngle(var backup : boolean);
 var CD : Char;
     ST : string;
 Dummy  : real;
 TmpLie : integer;
 I,J    : integer;
 MarkSpotFColor : byte;
 MarkSpotBColor : byte;
 MarkChar       : Char;
 TmpReal        : Real;
 Dx             : integer;
 Dy             : Integer;

 begin
  SHowMsr;
  ShowClub;
  GetSavChar( MarkSpotFColor, MarkSpotBColor,MarkChar);
  ShowMarker;
  Dx := Marker.X-Plyr1.Ballloc.X ;
  DY := Marker.Y-Plyr1.Ballloc.Y ;
  if DX <> 0 then Plyr1.Angle:=  round((ArcTan((DY*2.7) / (DX))*180)/pi)
  else PLyr1.Angle:=0;
  if DX<0 then PLyr1.Angle:=PLyr1.Angle+270;
  if DX>0 then PLyr1.Angle:=PLyr1.Angle+90;
  if (DX=0) and (DY>0)  then plyr1.Angle :=180;
  if plyr1.Angle<0 then Plyr1.angle:=360-Plyr1.Angle;
  if plyr1.Angle>360 then Plyr1.angle:=Plyr1.Angle-360;
  ShowBall;
  repeat
   Dx := Marker.X-Plyr1.Ballloc.X ;
   DY := Marker.Y-Plyr1.Ballloc.Y ;
   if DX <> 0 then Plyr1.Angle:=  round((ArcTan((DY*2.7) / (DX))*180)/pi)
   else PLyr1.Angle:=0;
   if DX<0 then PLyr1.Angle:=PLyr1.Angle+270;
   if DX>0 then PLyr1.Angle:=PLyr1.Angle+90;
   if (DX=0) and (DY>0)  then plyr1.Angle :=180;
   if plyr1.Angle<0 then Plyr1.angle:=360-Plyr1.Angle;
   if plyr1.Angle>360 then Plyr1.angle:=Plyr1.Angle-360;
   ShowBall;
   if Plyr1.LieNum=Green then
   getcmd(CD,['M','K',#13,'H','P','S','X','R'])
   else
   getcmd(CD,['M','K',#13,'H','P','I','Q','S','X','R']);
   If ReqChat then
    begin
     Chat;
     ShowTheCard :=True;
     CD:='R'
    end;
   if ShowTheCard then
    begin
     ShowTheCard:=false;
     if CD <>'R' then ScoreCard;
     if plyr1.LieNum = green then
     begin
      ViewGreen(Plyr1.HoleNum);
      GetGreenData;
      ShowClub;
      Dummy :=GetGreenDist;
      ShowExitLine;
      GetGreenLie;
      ShowMarker;
     end
      else
       begin
        ViewIt(Plyr1.HoleNum);
        GetHoledata;
        ShowClub;
        EraseTeeLoc;
        Dummy :=GetRealDist;
        ShowExitLine;
        ShowMarker;
        Lie
       end;
     Score(ScoreposX,ScorePosY,true);
     ShowMsr;
     ShowBall;
    end;
   case CD of
   'Q': begin
          Plyr1.ClubNum:=Plyr1.ClubNum +1;
          if Plyr1.ClubNum >13 then Plyr1.ClubNum :=1;
          ShowClub;
        end;
   'I': begin
          Plyr1.ClubNum:=Plyr1.ClubNum -1;
          if Plyr1.ClubNum <1 then Plyr1.ClubNum :=13;
          ShowClub;
        end;
   'H': if Marker.Y >1 then
          begin
            PutSavChar( MarkSpotFColor, MarkSpotBColor,MarkChar);
            Marker.Y:=Marker.Y-1;
            GetSavChar( MarkSpotFColor, MarkSpotBColor,MarkChar);
            ShowMarker;
          end;
   'P':  if Marker.Y <16 then
          begin
            PutSavChar( MarkSpotFColor, MarkSpotBColor,MarkChar);
            Marker.Y:=Marker.Y+1;
            GetSavChar( MarkSpotFColor, MarkSpotBColor,MarkChar);
            ShowMarker;
          end;
   'M': if Marker.X <60 then
          begin
            PutSavChar( MarkSpotFColor, MarkSpotBColor,MarkChar);
            Marker.X:=Marker.X+1;
            GetSavChar( MarkSpotFColor, MarkSpotBColor,MarkChar);
            ShowMarker;
          end;
   'K': if Marker.X >1 then
          begin
            PutSavChar( MarkSpotFColor, MarkSpotBColor,MarkChar);
            Marker.X:=Marker.X-1;
            GetSavChar( MarkSpotFColor, MarkSpotBColor,MarkChar);
            ShowMarker;
          end;
   end; {case}
  until (CD in [#13]) or QuitNow or Not Online or GoOffline;

  if CD= 'K' then Backup := true else BackUp :=false;
  PutSavChar( MarkSpotFColor, MarkSpotBColor,MarkChar);
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetSnap(var XS: Byte);
  var
   CD : Char;
 begin
   Emu_Color(11,4);
   Delay(100);
   ClearReceive;
   While Keypressed Do CD:=Readkey;
   While (Not Keypressed and Not Chwaiting) and (XS>36) do
    begin
     Xs:=XS-1;
     Emu_GotoXy(XS,19);
     if (Xs=40) then ComWrite('Þ ')
     else
     if (Xs = 39) then ComWrite('Ý')
     else
     if Not (Xs in [75..79]) then ComWrite('Ý ');
     Delay(80);
     if Xs > 55 then
      begin
       While Keypressed Do CD:=Readkey;
       if ChWaiting then ClearReceive;
      end
    end;
   if Xs < 40 then
   begin
    Emu_GotoXy(40,19);
    Emu_Color(15,4);
    Comwrite('Þ');
   end;
  While Keypressed Do CD:=Readkey;
  ClearReceive;
  Emu_Color(0,BkColor);
  Emu_GotoXy(38,20);
  Comwrite('     ');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.SelectPower(var AB : boolean);
 var
  CD      : Char;
  TmpPwr  : integer;
  St      : String;
  LieSave : byte;
  Xs      : Byte;

 begin
  AB :=True;
  ClearExitLine;
  ShowReadyLine;
  Plyr1.Power :=0;
  LieSave:=Plyr1.LieNum;
  Plyr1.LieNum:= green;
  ShowBAll;
  if LieSave <> Green then
   begin
    Emu_Color(0,Bkcolor);
    Emu_GotoXy(39,20);
    Comwrite('Snap');
   end;
  Emu_Color(12,Bkcolor+8);
  Emu_GotoXy(58,20);
  Comwrite('Power');
  Emu_Color(15,0);
  Emu_GotoXy(45,CmntLocY);
  ComWrite(' Press [Space-Bar] ...');
  GetChar(CD,[' ',#27]);
  ShowBall;
  if CD <> #27 then
  begin
   Emu_Color(15,0);
   Emu_gotoxy(1,CmntLocY);
   Comwrite('                          ');
   Emu_GotoXy(41,19);
   Emu_Color(12,0);
   While Keypressed Do CD:=Readkey;
   Delay(500);
   ClearReceive;
   TmpPwr :=1;
   ComWrite('Ý');
   Emu_GotoXy(WhereX-1,Wherey);
   Delay(500);
   if GetBps =1200 then delay(1000);
   While (Not Keypressed and Not Chwaiting) and (TmpPwr<109) do
   begin
     ComWrite('Ý');
     Delay(70-(TmpPwr div 2));
     if (TmpPwr<12) then Delay(50);
     if (TmpPwr<6) then Delay(50);
     TmpPwr:= TmpPwr+1;
     if (Not Keypressed and Not Chwaiting) and (TmpPwr<109) then
      begin
       if (TmpPwr=100) or (TmpPwr=101) then Emu_Color(14,0);
       TmpPwr:= TmpPwr+1;
       if TmpPwr>14 then TmpPwr:=TmpPwr+1;
       ComWrite(#8+'Û');
       Delay(70-(TmpPwr div 2));
       if (TmpPwr<12) then Delay(50);
       if (TmpPwr<6) then Delay(50)
      end
   end;
   XS:=WhereX-1;
   ShowBall;
   Plyr1.Power:=TmpPwr;
   AB:=false;
  While Keypressed Do CD:=Readkey;
  ClearReceive;
  if LieSave <> Green then
   begin
    Emu_Color(9,Bkcolor);
    Emu_GotoXy(58,20);
    Comwrite('Power');
    Emu_Color(12,Bkcolor+8);
    Emu_GotoXy(39,20);
    Comwrite('Snap');
    GetSnap(XS);
    if Xs<> 40 then
     begin
      Plyr1.Power := PLyr1.Power -((5* abs(40-Xs)) mod (1+(Plyr1.Power div 2)));
      Plyr1.Angle := Plyr1.Angle + ((((40-XS)*2)*(1+(Plyr1.ClubNum div 2))) Mod 35);
      if plyr1.Angle<0 then Plyr1.angle:=360-Plyr1.Angle;
      if plyr1.Angle>360 then Plyr1.angle:=Plyr1.Angle-360;
     end;
   end
  end;
  Emu_Color(15,0);
  Emu_GotoXy(45,CmntLocY);
  ComWrite('                            ');
  ClearReceive;
  Emu_Color(0,BkColor);
  Emu_GotoXy(58,20);
  Comwrite('       ');
  Emu_Color(15,0);
  ClearReceive;
  While Keypressed Do CD:=Readkey;
  Plyr1.LieNum:= LieSave;
  HideBall(False);
  Showball
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetTeeLoc(var TeeLoc : PointType);
 var
  I,J : integer;
  Found : boolean;

 begin
  TeeLoc.X :=0;
  TeeLoc.Y :=0;
  found:=false;
  J:=1;
  while (J<=60) and Not found do
   begin
    I:=1;
    while (I<16) and not found do
     begin
      if CurrHole.ground[J,I].Ch ='.' then
      begin
       found :=true;
       TeeLoc.X :=J;
       TeeLoc.Y :=I
      end;
      I:=I+1
     end;
     J:=J+1
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.EraseTeeLoc;
 var
  I,J : integer;
  Found : boolean;

 begin
  found:=false;
  J:=1;
  while (J<=60) and Not found do
   begin
    I:=1;
    while (I<16) and not found do
     begin
      if CurrHole.ground[J,I].Ch ='.' then
      begin
       Emu_GotoXY(J,I);
       Emu_Color(15,2);
       ComWrite(' ');
       found :=true;
      end;
      I:=I+1
     end;
     J:=J+1
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetPinLoc(var PinLoc : PointType);
 var
  I,J : integer;
  Found : boolean;

 begin
  PinLoc.X :=0;
  PinLoc.Y :=0;
  found:=false;

  J:=1;
  while (J<=60) and Not found do
   begin
    I:=1;
    while (I<16) and not found do
     begin
      if (CurrHole.ground[J,I].Ch ='ฟ') or (CurrHole.ground[J,I].Ch ='ฺ') then
      begin
       found :=true;
       PinLoc.X :=J;
       PinLoc.Y :=I
      end;
      I:=I+1
     end;
     J:=J+1
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetGreenPinLoc(var PinLoc : PointType);
 var
  I,J : integer;
  Found : boolean;

 begin
  PinLoc.X :=0;
  PinLoc.Y :=0;
  found:=false;

  J:=1;
  while (J<=60) and Not found do
   begin
    I:=1;
    while (I<16) and not found do
     begin
      if (CurrHole.ground[J,I].Ch ='Ü') then
      begin
       found :=true;
       PinLoc.X :=J;
       PinLoc.Y :=I
      end;
      I:=I+1
     end;
     J:=J+1
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.Score( X,Y :integer; ShowStroke : boolean);
 var
  St : string;
  I  : integer;
 begin
  I:=Plyr1.score;
  str(I:3,St);
  emu_gotoxy(X,Y);
  case I of
   1..99: begin
           while st[1]=' ' do St:= copy(St,2,Length(St)-1);
           emu_color(10,0);
           if I>9 then
            begin
             St:='+'+St
            end
            else
             St:=' +'+St;
           ComWrite(St);
          end;
   -99..-1: begin
           emu_color(12,0);
           ComWrite(St);
          end;
        0 : begin
           emu_color(11,0);
           ComWrite('  E')
          end
  end;
  if ShowStroke then
  begin
   I:=Plyr1.stroke;
   str(I:2,St);
   emu_gotoxy(StrokePosX,StrokePosY);
   if Plyr1.Stroke > CourseRecord.Holedata[Plyr1.Holenum].Par then
    emu_color(11,0)
   else
   if Plyr1.Stroke =  CourseRecord.Holedata[Plyr1.Holenum].Par then
    emu_color(10,0)
   else
    emu_color(14,0);
   ComWrite(St)
  end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ClearExitLine;
 begin
   Emu_gotoxy(CmntLocX,CmntLocY);
   Emu_Color(15,0);
   Comwrite(' ');
   Emu_ClearToEndOfLine;
   ComWriteln('');
   Emu_ClearToEndOfLine
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.ShowExitLine;
 begin
  Emu_gotoxy(1,Ypenal);
  Emu_Color(15,0);
  Comwrite('    [S] Score Card       ');
  Emu_Color(11,0);
  Comwrite(' [R] Redraw Screen      ');
  Emu_Color(14,0);
  Comwriteln(' [Enter] Ready to Swing');
  Emu_Color(12,0);
  Comwrite('    [X] Exit to Menu     ');
  Emu_Color(13,0);
  Comwrite(' <ฤฤ> Move Marker     ');
  if Plyr1.LieNum <> green then
  begin
   Emu_Color(10,0);
   Comwrite(' [9-Up/3-Dn] Change CLUB');
  end
  else
   Emu_CleartoEndOfLine;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.lie;
 Const
   XLieMsgLoc =63;
   YLieMsgLoc =11;
 var
  I,J,K    : integer;
  DropDone : boolean;
  Attempt  : byte;
  C        : Char;

 begin
  I:=Plyr1.Ballloc.X;
  J:=Plyr1.Ballloc.Y;
  if (I>=MaxX) or (I<=MinX) or (J>=Maxy) or (J<=MinY) then
  begin
     Emu_color(12,8);
     Emu_gotoxy(XLieMsgLoc,YLieMsgLoc);
     ComWrite('Out of Bounds    ');
     Emu_color(12,0);
     Emu_gotoxy(Xpenal,Ypenal);
     ComWriteln('One Stroke Penalty. Ball Drop Performed ');
     plyr1.Stroke:=plyr1.Stroke+1;
     Emu_Color(15,0);
     ComWrite(' Press [Enter] ');
     GetEnterKey;
     Emu_gotoxy(Xpenal,Ypenal);
     ComWriteln('                                          ');
     Emu_ClearToEndOfLine;
     Plyr1.Ballloc.X:=Bxs;
     Plyr1.Ballloc.Y:=Bys;
     Plyr1.RealDistX:=Brx;
     Plyr1.RealDistY:=Bry;
     I:=Plyr1.Ballloc.X;
     J:=Plyr1.Ballloc.Y;
     Plyr1.LieNum :=OB
    end;
 begin
  DropDone :=true;
  Attempt:=0;
  While DropDone and (Attempt < 4 ) and Online And Not GoOffLine do
  begin
  Attempt:=Attempt+1;
  DropDone :=false;
  Emu_gotoxy(XLieMsgLoc,YLieMsgLoc);
  case  CurrHole.Ground[I,J].Ch of
         '.' :begin
                Emu_color(10,0);
                ComWrite('On The Tee.      ');
                Plyr1.LieNum :=Ontee;
              end;
         'ฐ' :begin
                Emu_color(2,0);
                ComWrite('In The Rough.    ');
                Plyr1.LieNum :=Ruff;
              end;
         'ฑ' : begin
                Emu_color(2,0);
                ComWrite('In Deep Rough.   ');
                Plyr1.LieNum :=DeepRuff;
              end;
         'ฒ' : begin
                Emu_color(14,0);
                ComWrite('In The Bunker.   ');
                 Plyr1.LieNum :=Sand;
              end;
 '.',' ',',' : begin
                Emu_color(10,0);
                ComWrite('In The FairWay.  ');
                Plyr1.LieNum :=InFairWay;
              end;

  'þ','ฟ','ฺ' :begin
                Emu_color(10,0);
                ComWrite('On The Green !!  ');
                Plyr1.LieNum :=Green;
                Emu_gotoxy(XLieMsgLoc,YLieMsgLoc+1);
                ComWrite('                  ')
              end;
     'ื','' : begin
                Emu_color(2,0);
                ComWrite('In The Trees.    ');
                Plyr1.LieNum :=trees;
              end;
     'Û'     : begin
                Emu_color(11,8);
                ComWrite('In The Water.    ');
                Emu_color(12,0);
                Emu_gotoxy(Xpenal,Ypenal);
                ComWrite('One Stroke Penalty. Ball Drop Performed ');
                DropDone:=true;
                plyr1.Stroke:=plyr1.Stroke+1;
                if BYs <=0 then BYs := CurrHole.PinLoc.Y;
                if BXs <=0 then BXs := CurrHole.PinLoc.X;
                K:=0;
                while (CurrHole.Ground[Plyr1.Ballloc.X,Plyr1.Ballloc.Y].Ch = #219)
                       and ONline and Not GoOffLine  and (K<70) do
                begin
                 K:=K+1;
                 if (Plyr1.Ballloc.Y <= Bys) and (Plyr1.Ballloc.Y< MaxY) then
                     Plyr1.Ballloc.Y := Plyr1.Ballloc.Y+1
                 else
                 if (Plyr1.Ballloc.Y >= Bys) and (Plyr1.Ballloc.Y> MinY)then
                     Plyr1.Ballloc.Y := Plyr1.Ballloc.Y-1;

                 if (Plyr1.Ballloc.X <= Bxs) and (Plyr1.Ballloc.X< MaxX) then
                     Plyr1.Ballloc.X := Plyr1.Ballloc.X+1
                 else
                 if (Plyr1.Ballloc.X >= Bxs) and (Plyr1.Ballloc.X> MinX) then
                     Plyr1.Ballloc.X := Plyr1.Ballloc.X-1;
                end;
                 if K> 69 then
                  begin
                   Plyr1.Ballloc.X:=Bxs;
                   Plyr1.Ballloc.Y:=Bys;
                   Plyr1.RealDistX:=Brx;
                   Plyr1.RealDistY:=Bry
                  end;
                Get1stDist(Plyr1.Ballloc.X,Plyr1.Ballloc.Y,
                CurrHole.PinLoc.X, CurrHole.PinLoc.Y,Plyr1.RealDist);
                I:=Plyr1.Ballloc.X;
                J:=Plyr1.Ballloc.Y;
                Emu_Color(15,0);
                Emu_gotoxy(Xpenal,Ypenal+1);
                ComWrite('Press [Enter] ');
                GetEnterKey;
                Emu_gotoxy(Xpenal,Ypenal);
                ComWriteln('                                         ');
                Emu_ClearToEndOfLine;
                Plyr1.LieNum :=Water;
              end;
     Else   begin
             Emu_color(12,8);
             Emu_gotoxy(XLieMsgLoc,YLieMsgLoc);
             ComWrite('Out of Bounds    ');
             Emu_color(12,0);
             Emu_gotoxy(Xpenal,Ypenal);
             ComWriteln('One Stroke Penalty. Ball Drop Performed ');
             plyr1.Stroke:=plyr1.Stroke+1;
             Emu_color(15,0);
             ComWrite('Press [Enter] ');
             GetEnterKey;
             Emu_gotoxy(Xpenal,Ypenal);
             ComWriteln('                                         ');
             Emu_ClearToEndOfLine;
             DropDone:=true;
             Plyr1.Ballloc.X:=Bxs;
             Plyr1.Ballloc.Y:=Bys;
             Plyr1.RealDistX:=Brx;
             Plyr1.RealDistY:=Bry;
             I:=Plyr1.Ballloc.X;
             J:=Plyr1.Ballloc.Y;
             Plyr1.LieNum :=OB;
           end;
     end {case}
   end  {while}
  end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetGreenlie;
 Const
   XLieMsgLoc =63;
   YLieMsgLoc =11;
 var
  CD : Char;
  I,J : integer;
 begin
  I:=Plyr1.Ballloc.X;
  J:=Plyr1.Ballloc.Y;
  Emu_gotoxy(XLieMsgLoc,YLieMsgLoc);
  case  CurrHole.Ground[I,J].Ch of
         'ฑ' : begin
                Emu_color(2,0);
                ComWrite('In The Rough.   ');
                Plyr1.LieNum :=Ruff;
              end;
         'ฐ' :begin
                Emu_color(2,0);
                ComWrite('On The FairWay. ');
                Plyr1.LieNum :=InFairWay;
              end;
         'ฒ' : begin
                Emu_color(14,0);
                ComWrite('In The Bunker.  ');
                 Plyr1.LieNum :=Sand;
              end;
         ' ' : begin
                Emu_color(10,0);
                ComWrite('On The Green.   ');
                Plyr1.LieNum :=Green;
              end;
  '฿','Ü'    :begin
                Emu_color(10,0);
                ComWrite('In The Cup.     ');
                Plyr1.LieNum :=InCup;
              end;
     'ื',#15 : begin
                Emu_color(2,0);
                ComWrite('In The Trees.   ');
                Plyr1.LieNum :=Trees;
              end;
     'Û'     : begin
                Emu_color(11,8);
                ComWrite('In the Water.   ');
                Plyr1.LieNum :=Water;
              end;
     Else   begin
              Emu_color(14,0);
              ComWriteln('Out of Bounds   ');
              Plyr1.LieNum :=10;
            end;
   end;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure  XXBBS.Get1stDist(X1,Y1,X2,Y2: integer; var D : Real);
 const
  XDistMsgLoc=62;
  YDistMsgLoc=12;
  var
   DX, DY : real;
   st   : string;
   Force : real;
 begin
   DX:=(X1-X2)*10;
   DY:=(Y1-Y2)*25;
   Plyr1.RealDistX:=DX;
   Plyr1.RealDistY:=DY;
   Dx:=Dx*Dx;
   DY:=DY*DY;
   D:= Sqrt(DX+DY);
   Str(D:6:2,St);
  Emu_color(15,0);
  Emu_gotoxy(XDistMsgLoc,YDistMsgLoc);
  Comwrite(' '+St+' Yds Out ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 function  XXBBS.GetRealDist : real;
 const
  XDistMsgLoc=62;
  YDistMsgLoc=12;

  var
   D,DX, DY : real;
   st   : string;
 begin
   DX:=Plyr1.RealDistX;
   DY:=Plyr1.RealDistY;
   DX:=DX*DX;
   DY:=DY*DY;
   D:= Sqrt(DX+DY);
   Str(D:0:2,St);
  if PLyr1.LieNum<>Green then
    begin
     Emu_color(15,0);
     Emu_gotoxy(XDistMsgLoc,YDistMsgLoc);
     Comwrite(' '+St+' Yds Out ')
    end;
   GetRealDist:=D
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 function  XXBBS.GetGreenDist : real;
 const
  XDistMsgLoc=62;
  YDistMsgLoc=12;
  var
   D,DX, DY : real;
   st   : string;
 begin
   DX:=Plyr1.RealDistX;
   DY:=Plyr1.RealDistY;
   DX:=DX*DX;
   DY:=DY*DY;
   D:= (Sqrt(DX+DY));
   Str(D:0:1,St);
  Emu_color(15,0);
  Emu_gotoxy(XDistMsgLoc,YDistMsgLoc);
  Comwrite(' '+St+' Feet To Cup ');
  GetGreenDist:=D
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetGreenBalloc;
 begin
    Plyr1.BallLoc.X := CurrHole.PinLoc.X+round(Plyr1.Realdistx/2);
    Plyr1.BallLoc.Y := CurrHole.PinLoc.Y+round(Plyr1.Realdisty/6);
    If Plyr1.BallLoc.X>MaxX then Plyr1.BallLoc.X:=MaxX;
    If Plyr1.BallLoc.Y>MaxY then Plyr1.BallLoc.Y:=MaxY;
    If Plyr1.BallLoc.X<MinX then Plyr1.BallLoc.X:=MinX;
    If Plyr1.BallLoc.Y<MinY then Plyr1.BallLoc.Y:=MinY
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetHoleBalloc;
 begin
    Plyr1.BallLoc.X := CurrHole.PinLoc.X+round(Plyr1.Realdistx/10);
    Plyr1.BallLoc.Y := CurrHole.PinLoc.Y+round(Plyr1.Realdisty/25);
    If Plyr1.BallLoc.X>MaxX then Plyr1.BallLoc.X:=MaxX;
    If Plyr1.BallLoc.Y>MaxY then Plyr1.BallLoc.Y:=MaxY;
    If Plyr1.BallLoc.X<MinX then Plyr1.BallLoc.X:=MinX;
    If Plyr1.BallLoc.Y<MinY then Plyr1.BallLoc.Y:=MinY
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.HitBall;
 var
  X,Y,XS,YS,
  NewBallLocX,
  NewBallLocY,
  MidX,
  MidY,
  deltax,
  deltay       : integer;
  Dx,DY       : Real;
  DXS,DYS     : Real;
  ThetA       : real;
  Force       : real;
  incx        : integer;
  incy        : integer;
  HitDone     : Boolean;
  TotalIncs   : Integer;
  OkX         : Integer;
  OkY         : Integer;
  Inker       : Integer;
 begin

  X:=Plyr1.Ballloc.X;
  Y:=Plyr1.Ballloc.Y;
  DX:=plyr1.RealDistX;
  DY:=Plyr1.RealDistY;
  ShowBall;
  if Plyr1.Power >100 then
   begin
     if Random(Plyr1.Power-100)>3 then
      begin
        Plyr1.Angle := (Plyr1.Angle-3) + (Random(Plyr1.Power-100) div 2);
        if plyr1.Angle<0 then Plyr1.angle:=360-Plyr1.Angle;
        if plyr1.Angle>360 then Plyr1.angle:=Plyr1.Angle-360;
      end
      else
     if Random(Plyr1.Power-100)>2 then
     Plyr1.Power := (Plyr1.Power-10 ) +(round (Random(20)));
   end;
  Force:=(((Plyr1.Power/100)*clubMax[plyr1.Bag[plyr1.ClubNum]])+
            clubMin[plyr1.Bag[plyr1.ClubNum]])-(Plyr1.LieNum*(Random*6));

  Theta := (3.1415* Plyr1.angle)/180;
  while (force>0) do
  begin
    Force:=force-1;
    DX:=DX+Sin(Theta)-((Random*EWWind)/60);
    DY:=DY-Cos(Theta)-((Random*NSWind)/100)
  end;

  DeltaX := round(DX/10);
  DeltaY := round(DY/25);

  NewBallLocX:=(CurrHole.PinLoc.X+ DeltaX);
  NewBallLocY:=(CurrHole.PinLoc.Y+ DeltaY);

  MidX :=(CurrHole.PinLoc.X+ (DeltaX div 2));
  MidY :=(CurrHole.PinLoc.Y+ (DeltaY div 2));

  incx:= (CurrHole.pinLoc.X+ deltax)-X;
  incy:= (CurrHole.PinLoc.Y+ deltay)-Y;

  if incx<>0 then incx:=incx div abs(incx);
  if incy<>0 then incy:=incy div abs(incy);

  Hitdone:=false;
  Plyr1.LieNum := Ontee;
  HideBall(False);
  Plyr1.LieNum := green;
  TotalIncs:= Abs(X-NewBallLocX);
  OkX := 0;
  OkY := 0;
  Inker :=0;
  if Abs(Y-NewBallLocY) > TotalIncs then TotalIncs := Abs(Y-NewBallLocY);
  if TotalIncs > 20 then
  begin
   if Abs(Y-NewBallLocY) <7 then OkY := TotalIncs div 4;
   if Abs(X-NewBallLocX) <7 then OkX := TotalIncs div 4;
  end
  else
  if TotalIncs > 10 then
  begin
   if Abs(Y-NewBallLocY) <5 then OkY := TotalIncs div 3;
   if Abs(X-NewBallLocX) <5 then OkX := TotalIncs div 3;
  end
  else
  if TotalIncs > 5 then
  begin
   if Abs(Y-NewBallLocY) <3 then OkY := TotalIncs div 2;
   if Abs(X-NewBallLocX) <3 then OkX := TotalIncs div 2;
  end;

  while not Hitdone and online and not GoOffLine do
   begin
    Inker :=Inker +1;
    if (X<> NewBallLocX) and (Inker > OkX) then X:=X+incx;
    if (Y<> NewBallLocY) and (Inker > OkY) then Y:=Y+incy;
    HitDone:= (X=NewBallLocX) and (Y=NewBallLocY);
    Xs:=X;
    Ys:=Y;
    if Xs>Maxx then Xs:=Maxx;
    if Xs<MinX then Xs:=Minx;
    if Ys>MaxY then Ys:=MaxY;
    if Ys<MinY then Ys:=MinY;
    HideBall(False);
    Plyr1.Ballloc.X := Xs;
    Plyr1.Ballloc.Y := Ys;

    if (CurrHole.Ground[Xs,Ys].Ch in [ 'ื','']) and ((Random(14+PLyr1.ClubNum) < 7)) then
     begin
      if not ((Xs in[(MidX-6)..(MidX+6)]) and (Ys in[(MidY-3)..(MidY+3)])) then
      begin
        Emu_gotoxy(CmntLocX,CmntLocY);
        Emu_color(14,8);
        ComWriteO(#7#7);
        ComWriteln(' You Hit a TREE !! ');
        ShowBall;
        delay(300);
        HideBall(True);
        Emu_gotoxy(CmntLocX,CmntLocY+1);
        Emu_color(15,0);
        ComWrite(' Press [Enter]..');
        GetEnterKey;
        HideBall(False);
        Emu_gotoxy(CmntLocX,CmntLocY+1);
        Emu_color(15,0);
        ComWrite('                   ');
        HitDone :=True;
        Get1stDist(Plyr1.Ballloc.X,Plyr1.Ballloc.Y,CurrHole.PinLoc.X, CurrHole.PinLoc.Y, Plyr1.RealDist);
        DX:=plyr1.RealDistX;
        DY:=Plyr1.RealDistY;
      end
     end;
    ShowBall;
    delay(120);
   end;

  {Check for a legal Lie }
  HideBall(False);
  Plyr1.RealDistX:=DX;
  Plyr1.RealDistY:=Dy;
  GetHoleBAlloc
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.PuttBall;
 var
  X,Y,XS,YS,
  NewBallLocX,
  NewBallLocY,
  deltax,
  deltay       : integer;
  Dx,DY : Real;
  DXS,DYS : Real;
  ThetA : real;
  Force : real;
  incx    : integer;
  incy    : integer;
  HitDone    : boolean;
 begin
  HideBall(False);
  X:=Plyr1.Ballloc.X;
  Y:=Plyr1.Ballloc.Y;
  DX:=plyr1.RealDistX;
  DY:=Plyr1.RealDistY;
  Emu_Color(15,2);
  Emu_gotoxy(X,Y);
  Force:=((Plyr1.Power/37)*clubMax[plyr1.Bag[plyr1.ClubNum]])+
          clubMin[plyr1.Bag[plyr1.ClubNum]];

  Theta := (3.1415* Plyr1.angle)/180;
  while (force>0) do
  begin
    Force:=force-1;
    DX:=DX+Sin(Theta);
    DY:=DY-Cos(Theta);
  end;

  deltax:=round(DX/2);
  deltay:=round(DY/6);

  NewBallLocX:=(CurrHole.pinLoc.X+ deltax);
  NewBallLocY:=(CurrHole.pinLoc.Y+ deltay);

  incx:= (CurrHole.pinLoc.X+ deltax)-X;
  incy:= (CurrHole.PinLoc.Y+ deltay)-Y;
  if incx<>0 then incx:=incx div (abs(Incx));
  if incy<>0 then incy:=incy div (abs(Incy));

  Hitdone:=false;
  HideBall(False);
  while not Hitdone and online and not GoOffLine do
   begin
    if X<> NewBallLocX then X:=X+incx;
    if Y<> NewBallLocY then Y:=Y+incy;
    HitDone:= (X=NewBallLocX) and (Y=NewBallLocY);
    Xs:=X;
    Ys:=Y;
    if Xs>Maxx then Xs:=Maxx;
    if Xs<MinX then Xs:=Minx;
    if Ys>MaxY then Ys:=MaxY;
    if Ys<MinY then Ys:=MinY;
    HideBall(False);
    Plyr1.Ballloc.X := Xs;
    Plyr1.Ballloc.Y := Ys;
    ShowBall;
    delay(250);
   end;
  Plyr1.RealDistX:=DX;
  Plyr1.RealDistY:=Dy;
  {Check for a legal Lie }
  GetGreenBalloc
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetWind;
  var
   Force,
   Direction : Integer;
   DStr      : string;
   VelStr    : String;
 begin
  randomize;
  NSWind :=0;
  EWWind :=0;
  Force:= round(Random*18);
  Direction:= round(Random*8) +1;
  case Direction of
  1: begin
      NSWind:= -Force;
      DStr:='N';
     end;
  2: begin
      NSWind:= -Force div 2;
      EWWind:= Force div 2;
      DStr:='NE';
     end;
  3: begin
      EWWind:= Force;
      DStr:='E';
     end;
  4: begin
      EWWind:= Force div 2;
      NSWind:= Force div 2;
      DStr:='SE';
     end;
  5: begin
      NSWind:= Force ;
      DStr:='S'
     end;
  6: begin
      EWWind:= -Force div 2;
      NSWind:= Force div 2;
      DStr:='SW'
     end;
  7: begin
      EWWind:= -Force ;
      DStr:='W'
     end;
  8: begin
      EWWind:= -Force div 2;
      NSWind:= -Force div 2;
      DStr:='NW'
     end;
  else begin
        NSWind:= -Force;
        DStr:='N';
       end
  end; {case}
  if Force=0 then Force:=2;
  Str(Force,VelStr);
  WindStr:=DStr+' '+VelStr+' mph';
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowHoleData;
 var
  stp :String;
  begin
   Emu_gotoXy(65,1);
   Emu_Color(15,0);
   ComWrite('BBS Golf');
   Emu_gotoXy(65,2);
   Emu_Color(11,0);
   ComWrite('Ver.'+Vrs);
   Emu_gotoXy(63,4);
   Emu_Color(10,0);
   ComWrite(CourseRecord.CourseName);
   Emu_gotoXy(63,6);
   Emu_Color(14,0);
   ComWrite('Hole     ');
   Emu_Color(15,0);
   Str(Plyr1.HoleNum:2,stp);
   ComWrite(Stp);
   Emu_gotoXy(63,7);
   Emu_Color(11,0);
   ComWrite('Par       ');
   Emu_Color(15,0);
   Str(CourseRecord.HoleData[Plyr1.HoleNum].Par,stp);
   ComWrite(Stp);
   Emu_gotoXy(63,8);
   Emu_Color(13,0);
   ComWrite('Distance ');
   Emu_Color(15,0);
   Str(CourseRecord.HoleData[Plyr1.HoleNum].Yards,stp);
   ComWrite(Stp+' yds');
   Emu_gotoXy(63,9);
   Emu_Color(10,0);
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowDPwrBar;
 var
  stp :String;
 begin
   Emu_gotoxy(1,18);
   Emu_Color(11,BkColor);
   Comwrite('                                       0%-------25%-------50%-----75%----100%- ');
   Emu_gotoxy(1,19);
   Comwrite(' ');
   Emu_gotoXy(XNamePos,YNamePos);
   Emu_Color(15,0);
   ComWrite(Uname);
   Emu_gotoxy(35,19);
   Emu_Color(9,0);
   Comwrite('Þ    ');
   Emu_Color(15,0);
   Comwrite('Þ');
   Emu_Color(15,0);
   Comwrite('                                      ');
   Emu_Color(0,BkColor);
   Comwrite(' ');
   Emu_gotoxy(1,20);
   Comwrite('                                                                               ');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowClub;
  begin
   Emu_gotoxy(70,14);
   Emu_Color(ClubClrF[Plyr1.Bag[Plyr1.ClubNum]],ClubClrB[Plyr1.Bag[Plyr1.ClubNum]]);
   Comwrite(Club[Plyr1.Bag[Plyr1.ClubNum]]);
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetHoleData;
 var
  stp :String;

 begin
   ShowHoleData;
   Emu_gotoXy(63,9);
   Emu_Color(10,0);
   ComWrite('Wind   ');
   Emu_Color(15,0);
   ComWrite(WindStr);
   Emu_gotoxy(63,14);
   Emu_Color(11,0);
   Comwrite('Club');
   Emu_gotoxy(63,15);
   Emu_Color(13,0);
   Comwrite('Stroke');
   Emu_gotoxy(63,16);
   Emu_Color(14,0);
   Comwrite('Score');
   ShowDPwrBar;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.GetGreenData;
 var
  stp :String;
 begin
   ShowHoleData;
   Emu_gotoXy(63,9);
   Emu_Color(7,0);
   ComWrite('Putting    ');
   Emu_gotoxy(63,14);
   Emu_Color(11,0);
   Comwrite('Club');
   Emu_gotoxy(63,15);
   Emu_Color(13,0);
   Comwrite('Stroke');
   Emu_gotoxy(63,16);
   Emu_Color(14,0);
   Comwrite('Score');
   ShowDPwrBar
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowReadyLine;
 begin
   Emu_Color(15,0);
   Emu_GotoXy(36,19);
   Comwrite('    Þ                                      ');
   Emu_Color(11,0);
   Emu_gotoxy(1,CmntLocY);
   ComWrite(' ');
   Emu_ClearToEndOfLine;
   Emu_gotoxy(1,CmntLocY);
   Comwrite('   [ESC] Change Setup..');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.MainFlow;
 var
  Dummy    : Real;
  BU       : boolean;
  C        : Char;
  pass     : byte;
  NumPasses: byte;
  I,J,K    : integer;
  Xd,Yd    : integer;
  TmpLie   : byte;
  StrokeDiff : integer;
  Abrtit     : boolean;

 begin
 Plyr1.Power :=0;
 GetWind;
 checkTimeLeft;
 showmsr;
 GameOver :=false;
 QUIT     :=false;
 ScoreCard;
 while (Plyr1.HoleNum<=18) and Not QuitNow and Online And Not GoOffLine do
 begin
 if Plyr1.LieNum<> Green then
 begin
  Viewit( Plyr1.HoleNum);
  GetWind;
  GetHoleData;
  if UsingSavedData then
   begin
    EraseTeeLoc;
    Showball;
   end
  else
   begin
    GetTeeLoc(Plyr1.Ballloc);
    Plyr1.Stroke:=0
   end;
  GetPinLoc(CurrHole.PinLoc);
  Get1stDist(Plyr1.Ballloc.X,Plyr1.Ballloc.Y,CurrHole.PinLoc.X, CurrHole.PinLoc.Y, Plyr1.RealDist);
  Lie;
  plyr1.ClubNum:=1;
 end;

 while (Plyr1.LieNum<>InCup) and OnLine And Not GoOffLine and Not QuitNow do
  begin
   AbrtIt :=False;
   while (Plyr1.LieNum<>Green) and Not GoOffLine and Online and Not QuitNow
          and (Plyr1.Stroke <=10) do
 begin
  Lie;
  ShowExitLine;
  C:=#0;
  if Not Abrtit and Not GoOffLine and Online and Not QuitNow then
  begin
   Plyr1.ClubNum:=1;
   While ((Plyr1.RealDist+20) < ClubMax[Plyr1.ClubNum]) and (Plyr1.ClubNum < 12) do
   Plyr1.ClubNum := Plyr1.ClubNum+1;
   ShowClub;
   Score(ScorePosX,ScorePosY,true);
   Marker.X:=(Plyr1.Ballloc.X+CurrHole.PinLoc.X) div 2;
   Marker.Y:=(Plyr1.Ballloc.Y+CurrHole.PinLoc.Y) div 2;
   if (Marker.X=Plyr1.Ballloc.X) and (Marker.Y=Plyr1.Ballloc.Y)
     then  Marker:=CurrHole.Pinloc;
  end;

 if Not GoOffLine and Online and Not QuitNow then
  begin
   BrX:=Plyr1.RealDistX;
   BrY:=Plyr1.RealDistY;
   Bxs:=Plyr1.Ballloc.X;
   Bys:=Plyr1.Ballloc.Y;
   SelectAngle(BU);
   ShowBall;
  end;

   if Not QuitNow and Online and Not GoOffLine then
   begin
    SelectPower(Abrtit);
    if Not AbrtIt then
    begin
     HitBall;
     lie;
     Plyr1.RealDist:= GetRealDist;
     ShowBall;
     Plyr1.Stroke :=plyr1.Stroke+1
    end
   end;

   if (Plyr1.LieNum=Green) and not QuitNow and OnLine and Not GoOfflIne then
   begin
    Emu_gotoxy(CmntLocX,CmntLocY);
    Emu_color(10,0);
    ComWriteln(' On The Green !!  ');
    Emu_color(15,0);
    ComWrite(' Press [Enter] ');
    GetEnterKey;
    BrX:=Plyr1.RealDistX;
    BrY:=Plyr1.RealDistY;
    Bxs:=Plyr1.Ballloc.X;
    Bys:=Plyr1.Ballloc.Y
   end
  end;  { doing Green action Here }

  if plyr1.Stroke >=10 then
   begin
    Plyr1.RealDist:=0;
    Plyr1.LieNum:=InCup;
   end;

  if (PLyr1.RealDist< 1.2)  and Not UsingSavedData
       and Not QuitNow then
  begin
   ClearExitLine;
   PLyr1.RealDist:=0;
   Emu_color(12,8);
   Emu_gotoxy(CmntLocX,CmntLocY);
   ComWriteO(#7#7);
   ComWriteln(' In The Hole !!!!  ');
   Emu_color(15,0);
   ComWrite(' Press [Enter]..');
   GetEnterKey;
   Emu_gotoxy(1,CmntLocY+1);
   ComWrite('                   ');
   Plyr1.LieNum:=InCup;
  end
 else
  if Not QuitNow and OnLine and Not GoOffLine and ( Plyr1.LieNum=Green) then
  begin
   ViewGreen( Plyr1.HoleNum);
   GetGreenData;
   ShowMsr;
   Plyr1.RealDist:= GetGreenDist;
  end;
  Abrtit :=False;

 while (PLyr1.RealDist>0) and OnLine and Not GoOffLine and Not QuitNow
        and (Plyr1.LieNum <> InCup) and ( Plyr1.LieNum=Green)
        and (Plyr1.Stroke <=10) do

 begin
  GetGreenPinLoc(CurrHole.PinLoc);
  GetGreenBalloc;
  if Currhole.Ground[Plyr1.Ballloc.X, Plyr1.Ballloc.Y].Ch in ['฿','Ü'] then
  Plyr1.Ballloc.Y:=Plyr1.Ballloc.Y-1;
  Score(ScorePosX,ScorePosY,true);
  GetGreenLie;
  ShowBall;
  plyr1.ClubNum:=13;
  C:=#0;
  ShowExitLine;
  if Not Abrtit and Not GoOffLine and Online and Not QuitNow then
  begin
   Marker.X:=(Plyr1.Ballloc.X+CurrHole.PinLoc.X) div 2;
   Marker.Y:=(Plyr1.Ballloc.Y+CurrHole.PinLoc.Y) div 2;
   if (Marker.X=Plyr1.Ballloc.X) and (Marker.Y=Plyr1.Ballloc.Y)
     then  Marker:=CurrHole.Pinloc;
  end;
  if not GoOffLine and Online and Not QuitNow then
  begin
   SelectAngle(BU);
  end;
  if Online and not GoOffLine and Not QuitNow then
   begin
    SelectPower(Abrtit);
    if Not Abrtit then
    begin
     puttBall;
     Plyr1.Stroke :=plyr1.Stroke+1;
     GetGreenLie;
     showBall
    end
   end;

 if plyr1.Stroke >=10 then Plyr1.LieNum:= InCup;
 if plyr1.LieNum<>InCup then Plyr1.RealDist:= GetGreenDist;
 end;  { ball is in hole or off green at this point }

 if (Plyr1.LieNum<>InCup) and OnLine and Not GoOffLine and Not QuitNow then
  begin
   Viewit( Plyr1.HoleNum);
   GetHoleData;
   SHOWMSR;
   GetPinLoc(CurrHole.PinLoc);
   GetHoleBalloc;
   Get1stDist(Plyr1.Ballloc.X,Plyr1.Ballloc.Y,
         CurrHole.PinLoc.X, CurrHole.PinLoc.Y,Plyr1.RealDist);
   Lie;
   EraseTeeLoc;
   ShowBall
  end
 end;  { ball is in hole at this point }



 if Online and not goOffLine and Not QuitNow then
 begin
  Emu_gotoxy(CmntLocX,CmntLocY);
  Emu_Color(10,0);
  ComWriteln(' In The Cup.  ');
  HideBall(False);
  CourseRecord.Holedata[Plyr1.HoleNum].Score:=Plyr1.Stroke;
  StrokeDiff :=(Plyr1.Stroke- CourseRecord.HoleData[Plyr1.HoleNum].Par);
  Plyr1.Score:= Plyr1.Score + StrokeDiff;
  Plyr1.HoleNum:= Plyr1.HoleNum+1;
  IF Plyr1.Score >99 Then Plyr1.Score :=99;
  Emu_gotoxy(CmntLocX,CmntLocY+1);
  Emu_Color(15,0);
  case (StrokeDiff+10) of
   7: begin
        ComWrite(' Albatross.. Unbelievable Job!! $5,000');
        Plyr1.Money:=PLyr1.Money+ 5000;
        if  Plyr1.Stroke =1 then
        begin
          Emu_Color(15,0);
          Emu_gotoxy(CmntLocX,CmntLocY+2);
          ComWrite(' Press [Enter]');
          Getenterkey
        end
      end;
   8: begin
        ComWrite(' EAGLE .... GREAT Job !! $1,000');
        Plyr1.Money:=PLyr1.Money+ 1000;
        if  Plyr1.Stroke =1 then
        begin
          Emu_Color(15,0);
          Emu_gotoxy(CmntLocX,CmntLocY+2);
          ComWrite(' Press [Enter]');
          Getenterkey
        end
      end;
   9: begin
       ComWrite(' BIRDIE ... Good Job !!  $50' );
        Plyr1.Money:=PLyr1.Money+ 50;
      end;
   10: ComWrite(' PAR .... Well Done !!');
   11: ComWrite(' Bogie!!');
   12: ComWrite(' Double Bogie!!');
   13: ComWrite(' Hang In There !!');
   14..20: ComWrite(' Having a bad day eh?');
  end; {case}
  if Plyr1.Stroke =1 then
  begin
   Emu_gotoxy(CmntLocX,CmntLocY+1);
   Emu_Color(15,0);
   ComWrite(' A Hole In One !!!!  $50,000                   '+#7);
   Plyr1.Money:=Plyr1.Money+50000;
   Plyr1.HoleIn1s:=Plyr1.HoleIn1s+1;
  end;
  SHOWMSR;
  Plyr1.LieNum:= onTee;
  UsingSavedData:=false;
  Score(ScorePosX,ScorePosY,true);
  Emu_Color(15,0);
  Emu_gotoxy(CmntLocX,CmntLocY+2);
  ComWrite(' Press [Enter]');
  Getenterkey
 end
 end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.RUNX( var Savem : Boolean );
 var
  C : Char;
  Yhit : boolean;
  NewPlayer : boolean;

 begin
  SHOWMSR;
  Savem := True;
  C:=#0;
  QuitNow:=false;
  ComWriteln(' BBS GOLF  Version'+ Vrs);
  if Not PlayerFound then
   begin
    if Local then
    begin
    ComWrite(' Local Mode Enabled... ');
    Yhit :=true
    end
    else
    begin
     ComWrite(' Are You Using ANSI Graphics ?? [Y/n] ');
     getYn(Yhit,False)
    end;
    if Not Yhit then
     begin
      ComWriteln('');
      ComWriteln(' Sorry. This Door Requires the Use of ANSI Graphics.... ');
      delay(2000);
      Savem :=false
     end
    end
   else
   begin
    Yhit :=true;
    Delay(1000)
   end;
  if  Yhit and OnLine And not GoOfflIne then
  begin
   GetPlayerStatus(NewPlayer);
   if NewPlayer then
    begin
     ComWriteln(' Welcome to BBS Golf!!! ');
     ComWriteln(' New Player File Initialized.... ');
     ComWrite(' Press [Enter]... ');
     GetEnterKey;
    end
   else UsingSavedData := (Plyr1.CourseNum <>0);

  repeat
  if (Online and Not GoOffLine) then
  MainMenu;
  Emu_Color(15,0);
  ComWriteln('');
  ComWrite(' Selection? =>');
  Getchar(C,['D','G','C','Y','R','P','I','Q']);
  if ReqChat then Chat
  else
  begin
  if (Online and Not GoOffLine) then
    begin
     case C of
      'C' : begin
             ShowT10;
            end;
      'G' : begin
             QuitNow:=false;
             if Plyr1.CourseNum = 0 then SelectCourse;
             if Plyr1.CourseNum> 0 then
             begin
              GetCourseRec(Plyr1.CourseNum);
              MainFlow;
              UsingSavedData:=true;
             if (Plyr1.HoleNum>18) and Online And Not GoOffLine then
              begin
               ScoreCard;
               UpdateTop10;
               Payday;
               PLyr1.RoundsPlyd:=PLyr1.RoundsPlyd+1;
               Plyr1.HoleNum:=1;
               UsingsavedData :=false;
               Plyr1.CourseNum:=0;
               CourseRecord.CourseName :=''
              end
             end
            end;
      'R' : begin
             ShowRankings;
            end;
      'I' : begin
             Instructions;
            end;
      'D' : begin
             ShowClubDist;
            end;
      'Y' : begin
             ShowStatus;
            end;
      'P' : begin
             ShowPrices;
            end;
      end {case}
    end
   end;
  if GoOffLine Then
  begin
   Emu_Color(15,0);
   Emu_ClearScreen;
  end
  until (C='Q') or Not Online or GoOffLine
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
  I          : integer;
  SecTime    : real;
  TmpSYSOPNM : String;
  LocChk     : String;


 begin
  RN:='';
  BBSNAME:='';
  SYSOPNAME :='';
  {$I-}
  assign(ConfigFile,'BBSGolf.CFG');
  reset(ConfigFile);
  if IoResult <>0 then
   begin
    Writeln;
    Writeln(' BBSGOLF.CFG File Not Found ... Execution Halted. ');
    if Not Local then
     Writeln(' To Run Local type "BBSGOLF Your Name" ');
    done;
    halt(1)
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
     close(Configfile);
     CheckRegistered
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
    Writeln(' No USER file ',BBSDIR+'\'+UFILE,' ... Execution Halted ');
    Writeln(' To Run Local type "BBSGOLF Your Name" ');
    Done;
    halt(1)
   end
  {$I-}
   else
    if Not Local then
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
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure initPlayer;
  var
    I : integer;
    CO : integer;
 begin
   CO:=0;
   for I:=1 to 13 do
    begin
     If I=2 then CO:=1;
     If I=4 then CO:=2;
     If I=8 then CO:=3;
     PLYR1.BAG[I]:=I+CO;
    end;
    UsingSavedData :=false;
    BrX:=0;
    BrY:=0;
    Bxs:=0;
    Bys:=0;
    Plyr1.Score    :=0;
    Plyr1.Stroke   :=0;
    Plyr1.HoleNum  :=1;
    Plyr1.LieNum   :=OnTee;
    Plyr1.ClubNum  :=1;
    plyr1.Angle    :=90;
    plyr1.Power    :=0;
    Plyr1.CourseNum:=0;
    Plyr1.Holein1s :=0;
    Plyr1.RoundsPlyd:=0;
    Plyr1.Wager    :=0;
    Plyr1.RealDistX :=0;
    Plyr1.RealDistY :=0;
    Plyr1.Ballloc.X :=0;
    Plyr1.Ballloc.Y :=0;
    Plyr1.Money     :=5000;
    CourseRecord.CourseName :='';
    for I:=1 to 18 do CourseRecord.HoleData[I].Score:=0
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
  Savem      : boolean;

BEGIN
 Savem :=false;
 XXX.GoOffLine:=false;
 UseRTS :=true;
 USeCTS :=true;
 abort:=false;
 textcolor(14);
 XXX.INIT;
 XXX.UserInit;
 if paramcount > 0 then
  begin
   XXX.LOCAL:=TRUE;
   XXX.UNAME:= paramStr(1)+' '+paramStr(2);
   FORMATNAME(XXX.UNAME);
   BBSNAME:='DOS';
   SYSOPNAME:='';
   XXX.TIMELIMIT:=60;
   XXX.TIMEUSED:=0;
   XXX.getdata;
   ComNum  :=0;
   BAUD:=0;
   XXX.SetBps(0);
  end
  else
   XXX.getdata;
   initPlayer;
   XXX.RUN;
   XXX.INITIALIZE;
   XXX.Emu_ClearScreen;
   XXX.SHOWMSR;
   Quit :=false;
   PLYR1.NAME :=XXX.UNAME;
   XXX.SHOWMSR;
   if (XXX.ONLINE) then
  begin
   XXX.Clearreceive;
   XXX.StartTime:=XXX.TimeNow;
   XXX.SHOWMSR;
   IF (XXX.ONLINE and Not XXX.GoOffLine) or (BAUD =0)  THEN XXX.RUNX(Savem);
   if XXX.Online then
   begin
    XXX.emu_gotoxy(1,23);
    XXX.Emu_Color(12,0);
    if XXX.TimeLeft<2 then
    XXX.COMWRITELN(' Time Limit Exceeded....');
    XXX.Emu_Color(15,0);
    XXX.COMWRITELN(' Returning to  '+BBSNAME);
    XXX.SHOWMSR
   end;
  if Savem and (XXX.Uname<>'') and (Length(xxx.Uname)>2) then UpDatePlayer;
 end;
 if not XXX.Online then
  begin
   writeln(' No Carrier Detected ');
   delay(200)
  end;
 XXX.Emu_Color(15,0);
 XXX.ComWrite(' ');
 XXX.DONE;
END.
