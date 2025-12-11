{$M 32768,0,655360}

PROGRAM XenoQuest;

uses XQInit,Crt,Dos,BBSGam,BBSScrn,XQMess,XQPost,XQChChg;

{$O XQMESS}
{$O XQChChg}
{$O XQPost}
{$O BBSGam}
{$O BBSScrn}


const
 Vrs  =' 1.54';
 MAXX =53;
 MINX =1;
 MAXY =15;
 MINY =1;
 MaxPlayers = 100;
 MaxBullets = 10;
 MaxItems   = 1000;
 MaxThings  = 10;

TYPE

  CharSet    = set of Char;



  Bullet    = record
               ScLoc      : PointType;
               PrevLoc    : PointType;
               Owner      : byte;
               Direction  : Byte;
               Rmnum      : Byte;
               BulletType : Byte;
              end;

  ShotArray  = Array [1..MaxBullets] of Bullet;


  Item      = record
                ItemLoc : PointType;
                ItemNum : Byte;
                RmNum   : Byte;
                Visible : Boolean;
              end;


  Items     = Array [1..MaxItems] of Item;


  Monsters = Object
             Active    : Boolean;
             Dead      : Boolean;
             Weapon    : Byte;
             Level     : Byte;
             RoomNum   : Byte;
             HitPoints : Integer;
             ScrnLoc   : PointType;
           end;

 Playerstat = array[1..MaxPlayers] of Players;
 Monsterstat = array[1..MaxPlayers] of Monsters;

 VisPlayers = Record
               NumVisible : Byte;
               CurrPlayer : Array[1..MaxPlayers] of Byte;
              end;

 VisWall = Record
              Owner      : Byte;
              SegmentNum : Byte;
              Hits       : Byte;
              ScrnLoc    : PointType;
            end;

 VisWalls =  Record
               NumVisible : Byte;
               CurrWall : Array[0..MaxItems] of VisWall;
              end;


 Contents  = Record
              Attr : Byte;
              Ch   : Char;
             end;

 PlayField =  RECORD
                 GROUND  : array [MINX..MAXX,MINY..MAXY] of Contents;
              end;

  XXBBS = OBJECT(TBBS)
           procedure ClearMPrompt;
           procedure IncCash(Amt: Integer);
           Function  GetAlias : NameString;
           procedure ShowNews;
           procedure ShowIMenu;
           procedure ClearMenu(ReShow : Boolean);
           Function  Valid( X,Y: byte) : Boolean;
           procedure InitBullet(PNum : Byte);
           procedure BInitBullet(ScnLoc : PointType; Rand : Boolean; BT : Byte);
           procedure MInitBullet(PNum : Byte);
           Function  BulletHit( P : PointType; BulTyp : Byte) : Boolean;
           procedure EraseBullet( P : PointType);
           procedure IncBullets;
           procedure DoTicks;
           procedure DoHit(ScrLoc: PointType;ScrnCh: Char; BulType : Byte);
           procedure Tport;
           procedure Jump;
           procedure Fire;
           procedure UsePotion;
           Function  DropThing(D,C : Char): Boolean;
           procedure DropItem;
           procedure ShowWall(P,I: Byte);
           Function  PutWall(C : Char): Boolean;
           procedure BuildWall;
           procedure ShowMonster(Num: byte);
           procedure HideMonster(Num: byte);
           procedure MoveMonster(PNum : Byte);
           procedure PutPlayers(RmNum: byte);
           procedure PutMonsters(RmNum: byte);
           procedure WriteItem(Loc: PointType;Clr : Byte; C : Char);
           procedure ShowItem(I: Integer);
           procedure PutItems(RmmNum: byte);
           procedure ProcessMove;
           procedure ShowDeadPlayer;
           procedure ReDrawChar(ScL : PointType; MF,MB:Byte; CH : Char);
           procedure ShowPlayer;
           Procedure SetNewPlayer (PName  : NameString);
           procedure MainFlow;
           procedure Instructions;
           procedure ShowStatus;
           procedure ShowHallOfFame;
           procedure ShowRankings;
           procedure GetCmd(var Ychar : char; Cset: CharSet);
           procedure ViewIt(RmNum: byte);
           procedure ShowHJumps;
           procedure ShowTports;
           procedure ShowWeapon;
           procedure ShowWalsegs;
           procedure ShowAmmo;
           procedure ShowBucks;
           procedure ShowRoom;
           procedure ShowLevel;
           procedure ShowKeys;
           procedure ShowPotions;
           procedure ShowJewels;
           procedure ShowHealth;
           procedure ShowInfo;
           procedure ShowLogo;
           procedure Initialize;
           procedure mainmenu;
           procedure RUNX( var Savem : Boolean );
          end;
var
  XXX           : XXBBS;
  CURRField     : PlayField;
  AllPlayers    : PlayerStat;
  AllMonsters   : MonsterStat;
  VisiblePlyrs  : VisPlayers;
  VisibleMnstrs : VisPlayers;
  VisibleWalls  : VisWalls;
  Junk          : Items;
  Shots         : ShotArray;
  PlayerCnt     : Integer;
  GameOver      : boolean;
  Pn            : integer;
  Quit          : Boolean;
  TickSav       : Word;
  IntChrSet     : CharSet;
  DelayFactor   : Byte;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure InitItems( All : Boolean);
 var I : Integer;
 begin
   for I:= 1 to MaxItems do
   with Junk[I] do
   if All or Not Visible then
    begin
     ItemLoc.X :=3+Round(Random(49));
     ItemLoc.Y :=2+Round(Random(12));
     ItemNum   := 1+Round(Random(60));
     if ItemNum >40 then ItemNum := 1;
     RmNum           := Random(99);
     Visible         := True;
    end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure ReviveMonsters(All : Boolean);
 var
   I : integer;
 begin
   I := 1;
    While (I< MaxPlayers) do
    with AllMonsters[I] do
    begin
     if Dead or All then
      begin
       Hitpoints := 3 + Round(Random(15));
       if Random(1000) > 997 Then Hitpoints := Hitpoints +Round(random(5));
       Dead := False;
       RoomNum         := 1+Round(Random(99));
       if RoomNum>99 then RoomNum := 1+Round(Random(98));
       ScrnLoc.X       := 3+Round(Random(49));
       ScrnLoc.Y       := 2+Round(Random(12))
      end;
      I:=I+1
    end;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure InitPlayers;
  var
    I : integer;
    J : Integer;
 begin
   InitItems(True);
   ReviveMonsters(True);
   for I:= 1 to MaxPlayers do
    begin
   with AllPlayers[I] do
    begin
     Walls.NumOfSegs :=0;
     Active          := false;
     Dead            := false;
     Name            :='';
     Alias           :='';
     Weapon          := 25;
     Ammo            :=100;
     HypJumps        :=0;
     Tports          :=0;
     Map             :=0;
     LastDate        := Date;
     Keys.Num        :=0;
     Jewels.Num      :=0;
     Potions.Num     :=0;
     RoomNum         :=0;
     Level           :=1;
     XENOS           :=0;
     HitPoints       :=3;
     ScrnLoc.X       :=3;
     ScrnLoc.Y       :=3+ round(Random(8));
     Kills           :=0;
     Dies            :=0;
     Cash            :=500;
    end;
    end;
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
  ComWriteln('            XENO-QUEST Version'+Vrs);
  Emu_Color(14,0);
  ComWriteln('                Your Status');
  ComWriteln('');
  Emu_Color(12,0);
  ComWriteln('ออออออออออออออออออออออออออออออออออออออออออออออ');
  ComWriteln('');
  Emu_Color(15,0);
  With AllPlayers[PN] do
  begin
  ComWrite(' Player Name...... ');
  Emu_Color(14,0);
  ComWriteln(Name);
  Emu_Color(15,0);
  ComWrite(' Player Alias..... ');
  Emu_Color(11,0);
  ComWriteln(Alias);
  Emu_Color(15,0);
  ComWrite(' Cash............. ');
  Emu_Color(10,0);
  ComWriteln('$'+CommaPut(Cash));
  Emu_Color(15,0);
  ComWrite(' Status........... ');
  Emu_Color(13,0);
  if Dead then
   begin
    Emu_Color(12,0);
    ComWriteln('Dead ');
   end
  else
   begin
    Emu_Color(14,0);
    ComWriteln('Alive ');
   end;
  Emu_Color(15,0);
  ComWrite(' Level............  ');
  Emu_Color(10,0);
  Str(Level,st);
  ComWriteln(St);
  Emu_Color(15,0);
  ComWrite(' Current Room.....  ');
  Emu_Color(11,0);
  Str(RoomNum,St);
  ComWriteln(St);
  Emu_Color(15,0);
  ComWrite(' AMMO on Hand.....  ');
  Emu_Color(14,0);
  Str(AMMO,St);
  ComWriteln(St);
  Emu_Color(15,0);
  ComWrite(' Your Weapon...... ');
  Emu_Color(11,0);
  ShowWeapon;
  ComWriteln('');
  Emu_Color(15,0);
  ComWrite(' Jewels on Hand...  ');
  Emu_Color(12,0);
  Str(Jewels.Num,St);
  ComWriteln(St);
  Emu_Color(15,0);
  ComWrite(' Potions on Hand..  ');
  Emu_Color(14,0);
  Str(Potions.Num,St);
  ComWriteln(St);
  Emu_Color(15,0);
  ComWrite(' Keys on Hand.....  ');
  Emu_Color(10,0);
  Str(Keys.Num,St);
  ComWriteln(St);
  Emu_Color(15,0);
  ComWrite(' Hyper-Jump Modules ');
  Emu_Color(11,0);
  Str(HypJumps,St);
  ComWriteln(St);
  Emu_Color(15,0);
  ComWrite(' Wall Kits........  ');
  Emu_Color(13,0);
  Str(Walls.NumOfSegs,St);
  ComWriteln(St);
  Emu_Color(15,0);
  ComWrite(' TelePortals......  ');
  Emu_Color(11,0);
  Str(TPorts,St);
  ComWriteln(St);
  Emu_Color(15,0);
  ComWrite(' Owns a MAP.......  ');
  if (Map=1) then
   begin
    Emu_Color(14,8);
    ComWriteln('YES');
   end
  else
   begin
    Emu_Color(7,0);
    ComWriteln('NO');
   end;
  ComWriteln('');
  GetCr(15)
 end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.Instructions;
 var
  C : Char;
 begin
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    Clrscr;
    emu_color(0,7);
    Comwrite('                     Instructions For Playing Xeno Quest                        ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    if Exist('XQ.INS') then TypeFileMore('XQ.INS',C)
    else
    ComWriteln('Instruction File Missing or Corrupted......');
    ComWriteln('');
    GetCr(10)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure ShellSort(var SortList :PlayerStat; Count: integer);
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
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure ReNigPlayers;
  var
    I      : integer;
    DayNum : Integer;
    DayNow : Integer;
    Code   : Integer;
 begin
  ShellSort(AllPlayers,PlayerCnt);
  I:=PlayerCnt+1;
  While I > 1 do
   begin
   I:=I-1;
   with AllPlayers[I] do
    begin
     if Active then
     begin
      If Dead then
       begin
        Val(Copy(LastDate,4,2),DayNum,Code);
        Val(Copy(Date,4,2),DayNow,Code);
        if (Level =1) and (RoomNum=0) and (Cash<501) then
         begin
          DayNow :=30;
          DayNum :=0
         end;
        if (DayNum > DayNow) then LastDate :=Date
        else
         begin
          if (DayNow-DayNum) > 15 then
           begin
             Walls.NumOfSegs :=0;
             Active          := false;
             Dead            := false;
             Name            :='';
             Alias           :='';
             Weapon          := 25;
             Ammo            :=100;
             HypJumps        :=0;
             Tports          :=0;
             Map             :=0;
             LastDate        := Date;
             Keys.Num        :=0;
             Jewels.Num      :=0;
             Potions.Num     :=0;
             RoomNum         :=0;
             Level           :=1;
             XENOS           :=0;
             HitPoints       :=3;
             ScrnLoc.X       :=3;
             ScrnLoc.Y       :=3+ round(Random(8));
             Kills           :=0;
             Dies            :=0;
             Cash            :=500;
             I:=0;
           end
         end
       end
     end
    end;
    end;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure UpDatePlayer;
 var
  PlyrFile     : File of PlayerStat;

 begin
   Assign(PlyrFile,'PlyrFile.Dta');
   ReWrite(PlyrFile);
   Write(PlyrFile,AllPlayers);
   Close(PlyrFile);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure UpDateItems;
 var
  ItemFile  : File of Items;
 begin
   Assign(ItemFile,'Items.Dta');
   ReWrite(ItemFile);
   Write(ItemFile,Junk);
   Close(ItemFile);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure UpDateMonsters;
 var
  PlyrFile     : File of MonsterStat;

 begin
   Assign(PlyrFile,'Monster.Dta');
   ReWrite(PlyrFile);
   Write(PlyrFile,AllMonsters);
   Close(PlyrFile);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure DateChk;
  var
    I : integer;
    J : Integer;
   DFile    : text;
   Datstr   : String[8];

 begin
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
    if Copy(DatStr,4,2)<> Copy(Date,4,2) then
     begin
      InitItems(False);
      ReviveMonsters(True);
     end;
    if Copy(DatStr,1,2)<> Copy(Date,1,2) then
      InitItems(True);
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure ReviveJewels(Num : Integer);
 var
  I,J : integer;
  begin
   I:=1;
   J:=1;
   while (I < MaxItems) and ( J < Num ) do
   with Junk[I] do
    begin
     if (ItemNum in [11..17]) and (Not Visible) then
      begin
       Visible := True;
       ItemLoc.X := 3+Round(Random(49));
       ItemLoc.Y := 2+Round(Random(12));
       RmNum     := Random(99);
       J:= J+1
      end;
     I:=I+1;
    end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure ReviveKeys(Num : Integer);
 var
  I,J : integer;
  begin
   I:=1;
   J:=1;
   while (I < MaxItems) and ( J < Num ) do
   with Junk[I] do
    begin
     if (ItemNum in [18..24]) and Not Visible then
      begin
       Visible := True;
       ItemLoc.X := 3+Round(Random(49));
       ItemLoc.Y := 2+Round(Random(12));
       RmNum     := Random(99);
       J:= J+1
      end;
     I:=I+1;
    end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetPlayers;
 var
  PlyrFile     : File of PlayerStat;
  MonsFile     : File of MonsterStat;
  ItemFile     : File of Items;

 begin
   if Not Exist('PlyrFile.Dta') then
    With XXX do
     begin
      ComWriteln('Welcome to Xeno-Quest !!! ');
      ComWriteln('New Player File Initialized.... ');
      PN :=1;
      UpdatePlayer;
      UpdateMonsters;
      GetCr(15);
    end
   else
     begin
      Assign(PlyrFile,'PlyrFile.Dta');
      ReSet(PlyrFile);
      Read(PlyrFile,AllPlayers);
      Close(PlyrFile);
      if Exist('Monster.Dta') then
       begin
         Assign(MonsFile,'Monster.Dta');
         ReSet(MonsFile);
         Read(MonsFile,AllMonsters);
         Close(MonsFile)
       end;
      if Exist('Items.Dta') then
       begin
         Assign(ItemFile,'Items.Dta');
         ReSet(ItemFile);
         Read(ItemFile,Junk);
         Close(ItemFile)
       end
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function PlayerFound(NName : NameString) : Boolean;
 var
  I         : Integer;
  Ufound    : boolean;
  begin
   UFound:=false;
   DateChk;
   PlayerCnt := 0;
   PN        := 0;
   ReviveMonsters(False);
   InitItems(False);
   I := 1;
   While (I< MaxPlayers) and (AllPlayers[I].Active = True) do
    begin
     if AllPlayers[I].dead then AllPlayers[I].Hitpoints :=3;
     if AllPlayers[I].Hitpoints < 3 then AllPlayers[I].Hitpoints :=3;
     FormatName(AllPlayers[I].Name);
     FormatName(NNAme);
     if AllPlayers[I].Name =NName then
      begin
       Ufound :=true;
       Pn := I;
      end;
     I :=I + 1
    end;
   PlayerCnt := I-1;
   PlayerFound :=Ufound;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function XXBBS.GetAlias : NameString;
 var
  Cstr : NameString;
  Cstr1: String;
 begin
    Cstr :='';
    ComWriteln('');
    Emu_Color(15,0);
    ComWriteln('Enter Your Xeno-Quest Adventurer''s Name (20 Characters)...');
    ComWrite(' ');
    Emu_Color(0,7);
    ComWrite('                     ');
    Emu_GotoXy(2,WhereY);
    Emu_Color(15,7);
    ClearReceive;
    ReadlnX(Cstr1,20);
    Cstr:=Cstr1;
    if Cstr ='' then Cstr :=AllPlayers[PN].Name;
    FormatName(Cstr);
    GetAlias := Cstr;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure XXBBS.SetNewPlayer (PName  : NameString);
 var
  I         : Integer;
  Ufound    : boolean;
  MaxAllowed : Integer;
  begin
   UFound:=false;
   I :=PLayerCnt+ 1;
   if Not Brec.Registered then MaxAllowed :=20
   else MAxAllowed := MaxPLayers;
    if I > MaxAllowed then
     begin
      Pn :=0;
     end
    else
     begin
      AllPlayers[I].Name := PName;
      Pn := I;
      AllPlayers[PN] := AllPlayers[I];
      AllPlayers[PN].Active :=true;
      AllPlayers[PN].Dead   :=false;
      AllPlayers[PN].HitPoints := 3;
      AllPlayers[PN].Alias:= GetAlias
     end;
   PlayerCnt := I;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure AddHof;
 var
   HOFFile   : Text;
   TMpFile    : Text;
   PyrName    : NameString;
   Kills      : Integer;
   Bucks      : LongInt;
   Count      : Integer;
   DumChar    : Char;
   DatStr     : string[8];
   Added      : Boolean;

  begin
      While Length(AllPlayers[PN].Alias) < 25 do AllPlayers[PN].Alias:=AllPlayers[PN].Alias+' ';
      if not exist('XQ.Hof') then
       begin
        Assign(HOFFile,'XQ.Hof');
        Rewrite(HOFFile);
        Writeln(HOFFile, AllPlayers[PN].Alias,' ', ROUND(AllPlayers[PN].Cash),' ',
                         AllPlayers[PN].Kills,' ',Date);
        close(HOFFile)
       end
       else
       begin
        Assign(HOFFile,'XQ.Hof');
        Assign(TMPFile,'XQ.Tmp');
        Reset(HOFFile);
        ReWrite(TMPFile);
        Count :=0;
        added:=False;
      while (Not Eof(HofFile)) and (Count <15) do
       begin
        Count :=Count +1;
        Readln(HoFFile, PyrName,Bucks,Kills,DumChar,Datstr);
        if (AllPlayers[Pn].Cash >Bucks) and Not Added then
         begin
          Writeln(TmpFile, AllPlayers[PN].Alias,' ', ROUND(AllPlayers[PN].Cash),' ',
                         AllPlayers[PN].Kills,' ',Date);
          Writeln(TmpFile, PyrName,' ', Bucks,' ',Kills,' ',Datstr);
          Added:=true
         end
        else
          Writeln(TmpFile, PyrName,' ', Bucks,' ',Kills,' ',Datstr);
       end;
        if (Not Added) and (Count <15) then
         begin
          Writeln(TmpFile, AllPlayers[PN].Alias,' ', ROUND(AllPlayers[PN].Cash),' ',
                         AllPlayers[PN].Kills,' ',Date);
         end;
        close(HOFFile);
        close(TmpFile);
        Erase(HOFFile);
        Rename(TmpFile,'XQ.Hof');
      end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowHallOfFame;
 var
  Rfile       : text;
  CNT,I       : integer;
  Money1      : Real;
  PName       : NameString;
  Kills       : Integer;
  LineCount   : integer;
  Continue    : Boolean;
  DtStr       : String[8];
  DumChar     : char;

 begin
   if Brec.Registered then
   Begin
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    emu_color(0,7);
    Comwrite('                          XENO-Quest HALL of FAME                               ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    ComWrite('   Player Name    ');
    emu_color(11,0);
    ComWrite('               Bucks    ');
    emu_color(10,0);
    ComWrite('     Kills     ');
    emu_color(15,0);
    ComWriteln('         Date');
    emu_color(9,0);
    ComWrite('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
    emu_color(15,0);
    ComWriteln('');
    CNT :=1;
    LineCount:=0;
    Continue:=true;
    If Exist('XQ.Hof') then
   begin
    Assign(Rfile,'XQ.Hof');
    Reset(Rfile);
    while Not Eof(Rfile) and Online and Not GoOffLine and Continue do
     begin
      Readln(Rfile,Pname,Money1,Kills,DumChar,DtStr);
      Emu_Color(14,0);
      ComWrite('  '+PName+' ');
      Emu_Color(10,0);
      ComWrite('    $'+CommaPut(Money1)+ '   ');
      Emu_GotoXy(45,WhereY);
      Emu_Color(12,0);
      ComWrite(' '+ItoStr(Kills)+ '     ');
      Emu_Color(11,0);
      ComWriteln('          '+DtStr);
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
    emu_ClearScreen;
    emu_color(0,7);
    Comwrite('                          XENO-Quest HALL of FAME                               ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    ComWrite('   Player Name    ');
    emu_color(11,0);
    ComWrite('          Bucks    ');
    emu_color(10,0);
    ComWrite('         Kills     ');
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
     ComWriteln(' The Hall of Fame Is Empty....... ');
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
     ComWriteln('Rankings Option is Only Available With Registered Version..');
     ComWriteln('');
    end;
    emu_color(15,0);
    GetCr(15)
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowRankings;
 var
  RFile       : text;
  CNT,I       : integer;
  Cash1       : LongInt;
  Players     : Playerstat;
  LineCount   : integer;
  Continue    : Boolean;

 begin
   if Brec.Registered then
   Begin
    Players :=AllPlayers;
    ShellSort(Players,PlayerCnt);
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    emu_color(0,7);
    Comwrite('                     XENO-QUEST List of Champions                               ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    ComWrite('   Player Name    ');
    emu_color(11,0);
    ComWrite('       Bucks     ');
    emu_color(13,0);
    ComWrite(' Status ');
    emu_color(15,0);
    ComWrite(' Level ');
    emu_color(14,0);
    ComWrite(' Room #');
    emu_color(12,0);
    ComWrite('  Kills');
    emu_color(11,0);
    ComWrite(' Deaths');
    emu_color(13,0);
    ComWriteln('  Ratio');
    emu_color(9,0);
    ComWriteln('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
    emu_color(15,0);
    ComWriteln('');
    CNT :=1;
    LineCount:=0;
    Continue:=true;
    while Not (CNT > PlayerCnt) and Online and Not GoOffLine and Continue do
     begin
      Emu_Color(14,0);
      ComWrite(' '+Players[Cnt].Alias);
      Emu_GotoXy(23,WhereY);
      Emu_Color(10,0);
      ComWrite('   $'+CommaPut(Players[CNT].Cash));
      Emu_GotoXy(38,WhereY);
      if Players[CNT].Dead then
       begin
         Emu_Color(12,0);
         ComWrite('Dead  ');
       end
      else
       begin
         Emu_Color(11,0);
         ComWrite('Alive ');
       end;
        Emu_Color(15,0);
        ComWrite(IToStr(Players[CNT].Level)+' ');
        Emu_Color(14,0);
        ComWrite(' '+IToStr(Players[CNT].RoomNum)+' ');
        Emu_Color(12,0);
        ComWrite(' '+IToStr(Players[CNT].Kills)+' ');
        Emu_Color(11,0);
        ComWrite(' '+IToStr(Players[CNT].Dies)+' ');
        if Players[CNT].Kills =0 then
         begin
          Emu_Color(13,0);
          ComWriteln('  '+IToStr((Players[CNT].Kills*100))+'%');
         end
         else
         begin
          Emu_Color(13,0);
          ComWriteln('  '+IToStr((Players[CNT].Kills*100) div (Players[CNT].Kills+Players[CNT].Dies))+'%');
         end;
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
    emu_color(14,0);
    textbackground(0);
    emu_ClearScreen;
    emu_color(0,7);
    Comwrite('                     XENO-QUEST List of Champions                               ');
    emu_color(14,0);
    ComWriteln('');
    ComWriteln('');
    ComWrite('   Player Name    ');
    emu_color(11,0);
    ComWrite('       Bucks     ');
    emu_color(13,0);
    ComWrite(' Status ');
    emu_color(15,0);
    ComWrite(' Level ');
    emu_color(14,0);
    ComWrite(' Room #');
    emu_color(12,0);
    ComWrite('  Kills');
    emu_color(11,0);
    ComWrite(' Deaths');
    emu_color(13,0);
    ComWriteln('  Ratio');
    emu_color(9,0);
    ComWriteln('ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
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
     ComWriteln('Rankings Option is Only Available With Registered Version..');
     ComWriteln('');
    end;
    GetCr(12)
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 function WallBlocking(Xs,Ys,DX,DY : Integer) : Boolean;
 Const
  InvalidChrs : Charset = ['ร','ด','ณ','ฤ','ู','ฺ','ฟ','ภ','ล'];
 var
   IX       : Integer;
   IY       : Integer;
   I        : Integer;
   Blocked  : Boolean;
   C        : Char;
 begin
   If DX = 0 then IX :=0
   else IX := DX Div Abs(Dx);
   If DY = 0 then IY :=0
   else IY := DY Div Abs(DY);
   Blocked :=False;
   if (Abs(DX)=Abs(DY)) and (DX<>0) then
    begin
      While (DX <>0) and Not Blocked do
       begin
         DX:= DX - IX;
         DY:= DY - IY;
         GetScreenChar(Xs-DX,Ys-DY,C);
         Blocked := (C in InvalidChrs)
       end
    end
   else
   if DX = 0 then
    begin
      While (DY<> 0) and Not Blocked do
       begin
         DY:= DY - IY;
         GetScreenChar(Xs,Ys-DY,C);
         Blocked := (C in InvalidChrs)
       end
    end
   else
   if DY = 0 then
    begin
      While (DX <> 0) and Not Blocked do
       begin
         DX:= DX - IX;
         GetScreenChar(Xs-DX,Ys,C);
         Blocked := (C in InvalidChrs)
       end
    end
   else
    Blocked := True;
  WallBlocking :=Blocked
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetLineOfFire(ScrLoc: PointType; var D : Byte);

 var
   DltaX        : Integer;
   DltaY        : Integer;
 begin
  D:=0;
  DltaX := ScrLoc.X - AllPlayers[Pn].ScrnLoc.X;
  DltaY := ScrLoc.Y - AllPlayers[Pn].ScrnLoc.Y;
   case DltaX of
      0: begin
           if Not WallBlocking(ScrLoc.X,ScrLoc.Y,DltaX,DltaY) then
            begin
             if DltaY >0 then D := 8
             else
             if DltaY <0 then D := 2
            end
         end;
-50..-1: begin
           if Not WallBlocking(ScrLoc.X,ScrLoc.Y,DltaX,DltaY) then
           begin
            if DltaY =0 then D := 6
            else
            if DltaY >0 then D := 9
            else
            if DltaY <0 then D := 3
           end;
         end;
  1..50: begin
           if Not WallBlocking(ScrLoc.X,ScrLoc.Y,DltaX,DltaY) then
           begin
            if DltaY =0 then D := 4
            else
            if DltaY >0 then D := 7
            else
            if DltaY <0 then D := 1
           end
         end
  end {case}
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.InitBullet(PNum : Byte);
 var
   I         : Integer;
  PcanShoot : Boolean;

 begin
  I:=0;
  PcanShoot := True;
  While (I< MaxBullets) and PcanShoot do
   begin
    I := I+1;
    With Shots[I] Do
     begin
      if Owner =0 then
       begin
         PcanShoot :=False;
         GetLineOfFire(AllPlayers[PNum].ScrnLoc,Direction);
         if Direction <> 0 then
          begin
           Owner := PNum;
           ScLoc := AllPlayers[PNum].ScrnLoc;
           if Random(1000) >998 then BulletType :=1 else
           BulletType :=AllPlayers[PNum].Weapon;
          end
       end
     end
   end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.MInitBullet(PNum : Byte);
 var
   I         : Integer;
  PcanShoot : Boolean;

 begin
  I:=0;
  PcanShoot := True;
  While (I< MaxBullets) and PcanShoot do
   begin
    I := I+1;
    With Shots[I] Do
     begin
      if Owner =0 then
       begin
         PcanShoot :=False;
         GetLineOfFire(AllMonsters[PNum].ScrnLoc,Direction);
         if Direction <> 0 then
          begin
           Owner := PNum;
           ScLoc := AllMonsters[PNum].ScrnLoc;
           if Random(1000) >990 then BulletType:=1 else
           BulletType := 31+Round(random(5));
          end
       end
     end
   end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.BInitBullet(ScnLoc : PointType; Rand : Boolean; BT : Byte);
 var
   I         : Integer;
  PcanShoot : Boolean;

 begin
  I:=0;
  PcanShoot := True;
  While (I< MaxBullets) and PcanShoot do
   begin
    I := I+1;
    With Shots[I] Do
     begin
      if Owner =0 then
       begin
         PcanShoot :=False;
         if Not Rand then GetLineOfFire(ScnLoc,Direction);
          if (Direction =0) and (AllPlayers[Pn].Level >2) or Rand then
          begin
           Direction := Round(Random(10));
            if Direction in [5,10] then Direction := 0;
          end;
         if Direction <> 0 then
          begin
           Owner := PN;
           ScLoc := ScnLoc;
           if Random(1000) >990 then BulletType:=1 else
           BulletType := BT;
          end
       end
     end
   end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.MoveMonster(PNum : Byte);
 var
   I         : Integer;
  PcanShoot  : Boolean;
  Att        : Byte;
  Ch         : Char;
  Direction  : Byte;
  ValSPot    : Charset;
  Jspot      : CHarSet;
  Step       : Byte;



 begin
  I:=0;
  ValSpot :=[' '];
  JSpot := [];
  if AllPlayers[Pn].Level >4 then JSpot := ['อ','บ'];;
  if AllPlayers[Pn].Level >5 then JSpot := Jspot +['ฐ'];
  With AllMonsters[PNum] do
  begin
    GetLineOfFire(ScrnLoc,Direction);
     if Direction = 0 then
       begin
        if (ScrnLoc.X < AllPlayers[Pn].ScrnLoc.X) then
          begin
           GetScreenWord(ScrnLoc.X+1,ScrnLoc.Y,Att,Ch);
           Step :=1;
           if Ch in Jspot then
            begin
             GetScreenWord(ScrnLoc.X+2,ScrnLoc.Y,Att,Ch);
             Step :=2;
            end;
           if Ch in ValSpot then
            begin
             HideMonster(Pnum);
             ScrnLoc.X :=ScrnLoc.X +Step;
             ShowMonster(Pnum);
            end;
          end
        else
          begin
           GetScreenWord(ScrnLoc.X-1,ScrnLoc.Y,Att,Ch);
           Step :=1;
           if Ch in Jspot then
            begin
             GetScreenWord(ScrnLoc.X+2,ScrnLoc.Y,Att,Ch);
             Step :=2;
            end;
           if Ch in ValSpot then
            begin
             HideMonster(Pnum);
             ScrnLoc.X :=ScrnLoc.X -Step;
             ShowMonster(Pnum);
            end;
          end;
         if (ScrnLoc.Y < AllPlayers[Pn].ScrnLoc.Y) then
          begin
           GetScreenWord(ScrnLoc.X,ScrnLoc.Y+1,Att,Ch);
           Step :=1;
           if Ch in Jspot then
            begin
             GetScreenWord(ScrnLoc.X,ScrnLoc.Y+2,Att,Ch);
             Step :=2;
            end;
           if Ch in ValSpot then
            begin
             HideMonster(Pnum);
             ScrnLoc.Y :=ScrnLoc.Y +Step;
             ShowMonster(Pnum);
            end;
          end
         else
          begin
           GetScreenWord(ScrnLoc.X,ScrnLoc.Y-1,Att,Ch);
           Step :=1;
           if Ch in Jspot then
            begin
             GetScreenWord(ScrnLoc.X,ScrnLoc.Y-2,Att,Ch);
             Step :=2;
            end;
           if Ch in ValSpot then
            begin
             HideMonster(Pnum);
             ScrnLoc.Y :=ScrnLoc.Y -Step;
             ShowMonster(Pnum);
            end;
          end
      end
    end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure InitFire(D,T: Byte);
 var
   I         : Integer;
  PcanShoot : Boolean;

 begin
  I:=0;
  PcanShoot := True;
  While (I< MaxBullets) and PcanShoot do
   begin
    I := I+1;
    With Shots[I] Do
     begin
      if Owner =0 then
       begin
         PcanShoot :=False;
         Direction :=D;
         Owner := PN;
         ScLoc := AllPlayers[PN].ScrnLoc;
         BulletType :=T;
         if BulletType = 1 then
           AllPlayers[PN].Potions.Num := AllPlayers[PN].Potions.Num -1
         else
           begin
            AllPlayers[PN].Ammo := AllPlayers[PN].Ammo -1;
            BulletType := AllPlayers[PN].Weapon
           end
       end
     end
   end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.EraseBullet( P : PointType);
 var
  Att          : Byte;
  Ch           : Char;

 begin
  if P.X >0 then
  begin
   GetScreenChar(P.X,P.Y,CH);
   if Ch <> '' then
    begin
     Emu_GotoXy(P.X,P.Y);
     ComWrite(' ')
    end
  end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function XXBBS.BulletHit( P : PointType; BulTyp : Byte): Boolean;
 var
  Att          : Byte;
  Ch           : Char;

 begin
   GetScreenChar(P.X,P.Y,Ch);
   if Ch <>' ' then
    begin
     BulletHit := True;
     DoHit(P,Ch,BulTyp);
     Emu_Color(14,0)
    end
   else
   begin
    BulletHit := False;
    Emu_GotoXy(P.X,P.Y);
    Case BulTyp of
    0: ComWrite('๚');
    1: begin
        Emu_Color(10+Round(Random(5)),0);
        ComWrite('');
        Emu_Color(14,0)
       end;
25..27:begin
        ComWrite('๙');
       end;
  28  :begin
        ComWrite('๘');
       end;
31..35:begin
        Emu_Color(12,0);
        ComWrite('');
        Emu_Color(14,0)
       end;
    else
        ComWrite('')
    end; {case}
      Delay(10)
   end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.IncBullets;
 var
  I            : Byte;
  HitSomeThing : Boolean;
  Att          : Byte;
  Ch           : Char;
  ScrnChar     : Char;
 begin
  I:=0;
  While I< MaxBullets do
   begin
    I := I+1;
    With Shots[I] Do
     begin
      HitSomething :=False;
      if Owner >0 then
       begin
        Emu_Color(14,0);
        case Direction of
        9: begin {up/right}
            if (ScLoc.Y > MinY) and (ScLoc.X < MaxX) then
             begin
              ScLoc.X :=ScLoc.X+1;
              ScLoc.Y :=ScLoc.Y-1
             end
            else
              HitSomeThing := true
           end; { case 9 }
        7: begin {up/Left}
            if (ScLoc.Y > MinY) and (ScLoc.X > MinX) then
             begin
              ScLoc.X :=ScLoc.X-1;
              ScLoc.Y :=ScLoc.Y-1
             end
            else
              HitSomeThing := true
           end; { case 7 }
        1: begin {dn/Left}
            if (ScLoc.Y < MaxY) and (ScLoc.X > MinX) then
             begin
              ScLoc.X :=ScLoc.X-1;
              ScLoc.Y :=ScLoc.Y+1
             end
            else
              HitSomeThing := true
           end; { case 1 }
       3,5: begin {dn/Right}
            if (ScLoc.Y < MaxY) and (ScLoc.X < MaxX) then
             begin
              ScLoc.X :=ScLoc.X+1;
              ScLoc.Y :=ScLoc.Y+1
             end
            else
              HitSomeThing := true
           end; { case 3 }
        8: begin {up}
            if ScLoc.Y > MinY then
              ScLoc.Y :=ScLoc.Y-1
            else
              HitSomeThing := true
           end; { case 8 }
        2: begin {Down}
            If ScLoc.Y < MaxY then
              ScLoc.Y :=ScLoc.Y+1
            else
              HitSomeThing := true
           end; { case 2 }
        4: begin {Left}
            If ScLoc.X > MinX then
              ScLoc.X :=ScLoc.X-1
            else
              HitSomeThing := true;
           end; { case 4 }
        6: begin {Right}
            If ScLoc.X < MaxX then
              ScLoc.X :=ScLoc.X+1
            else
              HitSomeThing := true;
           end { case 6 }
        end; {case}
       EraseBullet(PrevLoc);
       if Not HitSomething then
        begin
         HitSomething :=BulletHit(ScLoc,BulletType);
         PrevLoc:=ScLoc;
        end;
       if HitSomething then
        begin
         Owner :=0;
         PrevLoc.X :=0;
         PrevLoc.Y :=0
        end
       end
    end
   end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function TimeTIck : Word;
  var
  h, m, s, hund : Word;
begin
  GetTime(h,m,s,hund);
  TimeTick:= Hund;
end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.DoTicks;

 var
  I            : Byte;
  VisPlayNum   : Byte;

  begin
   if TimeTick > 98 then ClearReceive;
   if TimeTick > (DelayFactor-AllPlayers[PN].Level) then
   begin
    TickSav :=TimeTick;
   I:=0;
   while I < VisiblePlyrs.NumVisible do
    begin
     I:=I+1;
     VisPlayNum := VisiblePlyrs.CurrPlayer[I];
     if Not AllPlayers[VisPlayNum].Dead then
      if (AllPlayers[VisPlayNum].RoomNum >0) or (AllPlayers[VisPlayNum].Level>1) then
      if Random(100+AllPlayers[VisPlayNum].HitPoints) >90 then InitBullet(VisPlayNum);
     end;
    I:=0;
    while I < VisibleMnstrs.NumVisible do
    begin
     I:=I+1;
     VisPlayNum := VisibleMnstrs.CurrPlayer[I];
     if Not AllMonsters[VisPlayNum].Dead then
      begin
       if Random(1000+(AllPlayers[PN].Level*5)+ (AllMonsters[VisPlayNum].HitPoints*2)+
                AllMonsters[VisPlayNum].Weapon) >995 then
         MInitBullet(VisPlayNum)
       else
       if Random(1000+(AllPlayers[PN].Level*8)+(AllMonsters[VisPlayNum].HitPoints*2)) >990 then MoveMonster(VisPlayNum)
      end
    end
   end
  end;
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
     DoTicks;
     if EO then
      begin
       IncBullets;
       EO:=false;
      end
     else
      EO :=True;
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
       Emu_GotoXY(57,16);
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
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.Initialize;
 begin
  SetFlowControl(BRec.UseCTS,BRec.UseRTS);
  SHOWMSR;
  if not LoadEmulation('xq') then
   begin
     writeln(' Unable to Load XQ.EMU..');
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
 if Exist('XQ.Scr') then
  begin
   TypeFile('XQ.Scr',Chh);
  end
 else
 begin
  emu_color(14,0);
  Comwriteln('');
  Comwriteln('                          X E N O -- Q U E S T  ');
 end;
 emu_color(7,0);
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
 Comwrite('       [B]  Begin Quest for XENOS             ');
 emu_color(11,0);
 Comwriteln(' [Y]  Your Status');
 emu_color(14,0);
 Comwrite('       [R]  Rankings                          ');
 emu_color(13,0);
 Comwriteln(' [H]  Hall Of Fame');
 emu_color(11,0);
 Comwrite('       [I]  Instructions                      ');
 emu_color(15,0);
 Comwriteln(' [S]  Supply Post');
 emu_color(13,0);
 Comwrite('       [C]  Commit Suicide                    ');
 emu_color(10,0);
 Comwriteln(' [M]  Message Base');
 emu_color(12,0);
 Comwrite('       [Q]  Quit Back to BBS                  ');
 emu_color(14,0);
 Comwriteln(' [A]  Alias Change');
 showMsr;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.PutPlayers(RmNum: byte);
  var
   I,J       : integer;
   StillMore : Boolean;

  begin
   I:=0;
   VisiblePlyrs.NumVisible :=0;
   VisibleWalls.NumVisible :=0;
   StillMore := true;
    While (I<MaxPlayers) and StillMore do
     begin
      I:=I+1;
      If (AllPlayers[I].Active) then
       begin
        If (AllPlayers[I].Walls.NumOfSegs > 0) then
         begin
          J:=0;
          While (J < AllPlayers[I].Walls.NumOfSegs) do
            Begin
             J:=J+1;
             if (AllPlayers[I].Walls.Segment[J].Owner > 0 ) then
              if AllPlayers[I].Walls.Segment[J].RmNum = RmNum then
               if AllPlayers[I].Walls.Segment[J].Level = AllPlayers[PN].Level then
               begin
                ShowWall(I,J);
                VisibleWalls.NumVisible := VisibleWalls.NumVisible +1;
                VisibleWalls.CurrWall[VisibleWalls.NumVisible].Owner :=I;
                VisibleWalls.CurrWall[VisibleWalls.NumVisible].SegmentNum :=J;
                VisibleWalls.CurrWall[VisibleWalls.NumVisible].Hits := 1 + Round(Random(5));
                VisibleWalls.CurrWall[VisibleWalls.NumVisible].ScrnLoc :=
                       AllPlayers[I].Walls.Segment[J].ScrnLoc
               end
            end
         end;
        if (not AllPlayers[I].Dead) and
               (AllPlayers[I].Level=AllPlayers[PN].Level) then
         begin
          if (AllPlayers[I].RoomNum= RmNum) And (I<>Pn) then
           begin
            Emu_GotoXy(AllPlayers[I].ScrnLoc.X,AllPlayers[I].ScrnLoc.Y);
            VisiblePlyrs.NumVisible := VisiblePlyrs.NumVisible +1;
            VisiblePlyrs.CurrPlayer[VisiblePlyrs.NumVisible] :=I;
            if AllPlayers[I].XENOS >0  then Emu_Color(11,6)
            else Emu_Color(11,0);
            ComWrite('');
           end
         end
       end
      else
      StillMore :=false;
     end
  end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowMonster(Num: byte);

 begin
   Emu_GotoXy(AllMonsters[Num].ScrnLoc.X,AllMonsters[Num].ScrnLoc.Y);
   case AllMonsters[Num].Hitpoints of
   1:   Emu_Color(7,0);
   2:   Emu_Color(6,0);
   3:   Emu_Color(5,0);
   4:   Emu_Color(13,0);
   5:   Emu_Color(14,0);
 6..50 :   Emu_Color(12,0);
   end; {case}
   Case AllPlayers[Pn].Level of
 1,4,5,8: ComWrite('');
   2,6: ComWrite('๊');
   3,7: ComWrite('๏');
     9: ComWrite('');
   end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.HideMonster(Num: byte);
 begin
   Emu_GotoXy(AllMonsters[Num].ScrnLoc.X,AllMonsters[Num].ScrnLoc.Y);
   ComWrite(' ');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.PutMonsters(RmNum: byte);

 Const
  InvalidChrs : Charset = ['ล','ม','ย','ร','ด','ณ','ฤ','ู','ฺ','ฟ','ภ','','ฐ','ฑ'];

  var
   I          : integer;
   Xpos, Ypos : Byte;
   VacantSpot : Boolean;
   Att        : Byte;
   Ch         : Char;
  begin
   I:=0;
   VisibleMnstrs.NumVisible :=0;
    While (I<MaxPlayers) do
     begin
      I:=I+1;
        if (not AllMonsters[I].Dead) then
         begin
          if (AllMonsters[I].RoomNum= RmNum) then
           begin
            Xpos := AllMonsters[I].ScrnLoc.X;
            Ypos := AllMonsters[I].ScrnLoc.Y;
            if Xpos>MaxX then Xpos := MaxX -2;
            if Xpos<MinX then Xpos := MinX +2;
            if Ypos>MaxY then Ypos := MaxY -1;
            if Ypos<MinY then Ypos := MinY +1;
            VacantSpot :=False;
            While Not VacantSpot  and Online do
            begin
             GetScreenWord(Xpos,Ypos,Att,Ch);
             VacantSpot := Not (Ch in InValidChrs);
             if Not VacantSpot then
              begin
               If Xpos < (MaxX-2)  then Xpos :=Xpos +1
                else Xpos :=Xpos -1;
               If Ypos < (MaxY-1)  then Ypos :=Ypos +1
                else Ypos :=Ypos -1;
              end
            end;
            AllMonsters[I].ScrnLoc.X := Xpos;
            AllMonsters[I].ScrnLoc.Y := Ypos;
            VisibleMnstrs.NumVisible := VisibleMnstrs.NumVisible +1;
            VisibleMnstrs.CurrPlayer[Visiblemnstrs.NumVisible] :=I;
            ShowMonster(I);
           end
         end
     end
  end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.WriteItem(Loc: PointType;Clr : Byte; C : Char);
 begin
   Emu_GotoXy(Loc.X,Loc.Y);
   Emu_Color(Clr,0);
   ComWrite(C);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowItem(I: Integer);
  begin
    With Junk[I] do
      if (ItemNum >0) and Visible then
         begin
            case ItemNum of
            1 : begin
                   WriteItem (ItemLoc,12,'')
                  end;
           2..10 : begin
                   WriteItem (ItemLoc,9+(ItemNum Mod 7),'#')
                  end;
           11..17: begin
                    if Not HasJewel(AllPlayers[PN],ItemNum-2) then
                      WriteItem (ItemLoc,ItemNum-2 ,'')
                    else
                      WriteItem (ItemLoc,ItemNum-2 ,'$')
                  end;
          18..24 : if Not HasKey(AllPlayers[PN],Junk[I].ItemNum-9) then
                      WriteItem (Junk[I].ItemLoc,ItemNum-9,'ิ');
          25..30: begin
                   if AllPlayers[PN].Weapon >= ItemNum then
                    begin
                     if (Random(500) > (480+ AllPlayers[PN].Level)) and
                        (AllPlayers[PN].Map =0 )  then
                       begin
                        if (Random(50) > 48) then  WriteItem (ItemLoc,11,'‘')
                        else WriteItem (ItemLoc,11,'ý')
                       end
                     else
                      WriteItem (ItemLoc,12,'')
                    end
                   else
                   begin
                    case ItemNum of
                     25: WriteItem (ItemLoc,ItemNum-15,'(');
                     26: WriteItem (ItemLoc,ItemNum-15,'๎');
                     27: WriteItem (ItemLoc,ItemNum-15,'{');
                     28: WriteItem (ItemLoc,ItemNum-15,'ฉ');
                     29: if AllPlayers[Pn].Level > 2 then
                           WriteItem (ItemLoc,ItemNum-15,'ๅ');
                     30: if AllPlayers[Pn].Level > 3 then
                           WriteItem (ItemLoc,ItemNum-15,'เ');
                    end {case}
                   end
                  end;
          31..37: WriteItem (ItemLoc,ItemNum-22,'ญ');
              38: WriteItem (ItemLoc,7,'ฯ');
              39: if Random(10) > Allplayers[PN].HypJumps then
                    WriteItem (ItemLoc,9+Round(Random(6)),'');
              40: WriteItem (ItemLoc,10,'$');
            end {case}
           end;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.PutItems(RmmNum: byte);

  var
   I          : integer;
   Xpos, Ypos : Byte;
   VacantSpot : Boolean;
   Att        : Byte;
   Ch         : Char;
   Attempts   : Byte;
  begin
   I:=0;
    While (I<MaxItems) do
     begin
      I:=I+1;
          if (Junk[I].RmNum = RmmNum) then
           begin
            Xpos := Junk[I].ItemLoc.X;
            Ypos := Junk[I].ItemLoc.Y;
            if Xpos>MaxX then Xpos := MaxX -2;
            if Xpos<MinX then Xpos := MinX +2;
            if Ypos>MaxY then Ypos := MaxY -1;
            if Ypos<MinY then Ypos := MinY +1;
            VacantSpot :=False;
            Attempts := 0;
            While Not VacantSpot and Online and (Attempts < 10) do
            begin
             Attempts := Attempts +1;
             GetScreenWord(Xpos,Ypos,Att,Ch);
             VacantSpot := (Ch =' ');
             if Not VacantSpot then
              begin
               If Xpos < (MaxX-2)  then Xpos :=Xpos +1
                else Xpos :=Xpos -1;
               If Ypos < (MaxY-1)  then Ypos :=Ypos +1
                else Ypos :=Ypos -1;
              end
            end;
            Junk[I].ItemLoc.X :=Xpos;
            Junk[I].ItemLoc.Y :=Ypos;
           if Attempts <9 then ShowItem(I)
         end
     end
  end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowLogo;
 var
  stp :String;

 begin
   Emu_gotoXy(63,1);
   Emu_Color(15,0);
   ComWrite('XENO-Quest');
   Emu_gotoXy(63,2);
   Emu_Color(11,0);
   ComWrite('Ver.'+Vrs);
   Emu_gotoXy(57,3);
   Emu_Color(9,0);
   ComWrite('ออออออออออออออออออออออ');

 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowHealth;
 var
  I  : integer;
  HP : Integer;
 begin
   Hp := AllPlayers[Pn].Hitpoints;
   if Hp >14 then Hp :=14;
   Emu_gotoXy(65,7);
   Emu_Color(12,0);
   for I := 1 to Hp do ComWrite('');
   ComWrite('  ')
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowWeapon;
 var
  I : integer;
 begin
   Emu_Color(AllPlayers[Pn].Weapon-15,0);
   case AllPlayers[Pn].Weapon of
    25: ComWrite(' CrossBow    ');
    26: ComWrite('+1 CrossBow  ');
    27: ComWrite('+3 CrossBow  ');
    28: ComWrite(' 357 Magnum  ');
    29: ComWrite('+2 Yag Laser ');
    30: ComWrite('+5 Co2 Laser ');
    else
      begin
          Emu_Color(7,8);
          ComWrite(' Pea Shooter')
      end
   end;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowTports;
 var
  I : integer;
 begin
   Emu_Color(12,0);
   Emu_GotoXy(72,14);
   ComWrite(IntToStr(AllPLayers[PN].Tports)+' ');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowRoom;
 var
  I : integer;
 begin
   Emu_gotoXy(75,5);
   Emu_Color(14,0);
   ComWrite(IntToStr(AllPlayers[PN].RoomNum));
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowLevel;
 var
  I : integer;
 begin
   Emu_gotoXy(65,5);
   Emu_Color(14,0);
   ComWrite(IntToStr(AllPlayers[PN].Level));
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowBucks;
 var
  I : integer;
 begin
   Emu_gotoXy(66,6);
   Emu_Color(10,0);
   ComWrite('$'+Commaput(AllPlayers[PN].Cash));
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowAmmo;
 var
  I : integer;
 begin
   Emu_gotoXy(66,11);
   Emu_Color(14,0);
   ComWrite(Commaput(AllPlayers[PN].Ammo));
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowHJumps;
 var
  I : integer;
 begin
   Emu_gotoXy(72,13);
   Emu_Color(11,0);
   ComWrite(Commaput(AllPlayers[PN].HypJumps));
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowWalsegs;
 var
  I,J : integer;
 begin
   Emu_gotoXy(66,12);
   Emu_Color(14,0);
   J:=1;
   I:=0;
   While J<=AllPlayers[PN].Walls.NumOfSegs do
   begin
    if AllPlayers[PN].Walls.SegMent[J].Owner =0 then I:=I+1;
    J:=J+1
   end;
   ComWrite(Commaput(I))
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowKeys;
 var
  I : integer;
 begin
   Emu_gotoXy(66,9);
   for I := 1 to AllPlayers[Pn].Keys.Num do
    begin
     Emu_Color(AllPlayers[Pn].Keys.List[I],0);
     ComWrite('ิ');
    end;
   ComWrite(' ');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowPotions;
 var
  I : integer;
 begin
   Emu_gotoXy(66,10);
   for I := 1 to AllPlayers[Pn].Potions.Num do
    begin
     Emu_Color(AllPlayers[Pn].Potions.List[I],0);
     ComWrite('ญ');
    end;
   ComWrite(' ');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowJewels;
 var
  I : integer;
 begin
   Emu_gotoXy(66,8);
   for I := 1 to AllPlayers[Pn].Jewels.Num do
    begin
     Emu_Color(AllPlayers[Pn].Jewels.List[I],0);
     ComWrite('');
    end;
   ComWrite(' ');
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowInfo;
 var
  stp :String;

 begin
   Emu_gotoXy(58,4);
   Emu_Color(15,0);
   ComWrite(AllPlayers[Pn].Alias);
   Emu_gotoXy(58,5);
   Emu_Color(7,0);
   ComWrite('Level      Room ');
   Emu_gotoXy(58,6);
   ComWrite('Bucks');
   Emu_gotoXy(58,7);
   ComWrite('Health');
   Emu_gotoXy(58,8);
   ComWrite('Jewels');
   Emu_gotoXy(58,9);
   ComWrite('Keys');
   Emu_gotoXy(58,10);
   ComWrite('Potions');
   Emu_gotoXy(58,11);
   ComWrite('Ammo');
   Emu_gotoXy(58,12);
   ComWrite('Walls');
   Emu_gotoXy(58,13);
   ComWrite('Hyper-Jumps');
   Emu_gotoXy(58,14);
   ComWrite('Teleports');
   Emu_gotoXy(58,15);
   ComWrite('Weapon');
   ShowBucks;
   ShowLevel;
   ShowRoom;
   ShowHealth;
   ShowJewels;
   ShowKeys;
   ShowPotions;
   ShowAmmo;
   ShowWalSegs;
   ShowHJumps;
   Emu_gotoXy(65,15);
   ShowWeapon;
   ShowTPorts;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure InitBullets;
 var
   I : integer;
 begin
  For I := 1 to MaxBullets do
   begin
   with Shots[I] do
    begin
       ScLoc.X    :=0;
       ScLoc.Y    :=0;
       PrevLoc.X  :=0;
       PrevLoc.Y  :=0;
       Owner      :=0;
       Direction  :=0;
       Rmnum      :=0;
       BulletType :=0;
    end
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ViewIt(RmNum: byte);
 var
  st          : string;
  I,J,K,L     : Integer;
  RoomArray   : Array [0..99] of Byte;
  ArrayFile   : Text;


  begin
  Str(AllPlayers[PN].Level,St);
  St:='XQLevel.Dta';
  If Exist(St) then
   begin
    Assign(ArrayFile, St);
    Reset(ArrayFile);
    I:=0;
    While (I< 100) and Not Eof(ArrayFile) do
     begin
      Read(ArrayFile,J);
      K:=1;
      While K< AllPlayers[PN].Level do
      begin
       Read(ArrayFile,L);
       K:=K+1;
      end;
       Readln(ArrayFile,RoomArray[J]);
      I :=I+1;
     end;
     Close(ArrayFile);
   end
   else
    begin
     Writeln(' XQ data file missing......');
     Delay(10000);
     GoOffLine :=True;
    end;

  If Online And Not GoOffLine then
  begin
   emu_color(15,0);
   emu_clearscreen;
   emu_gotoxy(1,1);
   TYPEHole('XQ.DTA',RoomArray[RmNum]);
   for I:=MinY to MaxY do
    begin
     for j:=MinX to MaxX do
     begin
      GetScreenWord(J, I, CURRField.Ground[J,I].Attr,CURRField.Ground[J,I].Ch)
     end
    end
   end;
   PutPLayers(RmNum);
   PutMonsters(RmNum);
   PutItems(RmNum);
   InitBullets;
   ShowLogo;
   ShowInfo;
   EMU_GOTOXY(57,16);
   TimePrompt;
   ShowIMenu;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowPlayer;
  begin
   with AllPlayers[PN] do
   begin
    Emu_GotoXy(ScrnLoc.X,ScrnLoc.Y);
    if XENOS >0 then
     begin
      Emu_Color(14,6);
      ComWrite('');
      Emu_Color(15,0)
     end
    else
    begin
     Emu_Color(15,0);
     ComWrite('')
    end
   end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowDeadPlayer;
  begin
   with AllPlayers[PN] do
   Emu_GotoXy(ScrnLoc.X,ScrnLoc.Y);
   Emu_Color(15,0);
   ComWrite('_');
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure RemoveItem(X,Y: byte);
  var
   I          : Integer;
   VN         : Byte;
  begin
   I:=0;
     While I < MaxItems do
       begin
        I:=I+1;
        if Junk[I].RmNum = Allplayers[PN].RoomNum then
        if (Junk[I].ItemLoc.X = X) then
         if(Junk[I].ItemLoc.Y = Y) then
         begin
          Junk[I].Visible := False;
         end
       end
  end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.IncCash(Amt: Integer);
 begin
   if AllPlayers[PN].CASH <999000000 then
   AllPlayers[PN].Cash :=AllPlayers[PN].Cash +Amt;
   ClearMPrompt;
   Emu_Color(15,0);
   ComWrite(' You Have NO Need For That...');
   ShowBucks;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ClearMPrompt;
  begin
    Emu_GotoXy(1,17);
    ComWrite(' ');
    Emu_CleartoEndOfLine;
    Emu_GotoXy(2,17);
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure RestoreItems(FromPn : Byte; Strip : Boolean);
  var
   I          : integer;
 begin
  with  AllPlayers[FromPN] do
   begin
    if Level >1 then Level:= Level -1;
    RoomNum         := 0;
    ScrnLoc.X       := 3;
    ScrnLoc.Y       := 3+ round(Random(8));
    Ammo := ((Ammo+1) div 10);
    if Ammo < 50 then ammo :=50;

  if Strip then
   begin
    Keys.Num        := 0;
    Potions.Num     := 0;
    Jewels.Num      := 0;
    Walls.NumOfSegs := 0;
    HypJumps        := 0;
    Weapon          := 25;
   end;

  end;
   I:=0;
   While (I< MaxItems) do
    begin
     I:=I+1;
     With Junk[I] do
     if Not Visible then
       begin
        ItemLoc.X :=3+Round(Random(49));
        ItemLoc.Y :=2+Round(Random(12));
        ItemNum   := 1+Round(Random(60));
        if ItemNum >40 then ItemNum := 1;
        RmNum           := Random(99);
        Visible         := True;
       end
    end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function XXbbs.Valid( X,Y: byte) : Boolean;
 Const
  InvalidChrs : Charset = ['ล','ม','ย','ร','ด','ณ','ฤ','‘',
                           'ู','ฺ','ฟ','ภ','','','๊','๏','๋',''];

 var
  ChkChar : Char;
  Att     : Byte;
  HasIt   : Boolean;
  I       : Integer;
  Colr    : Byte;
  CS      : Integer;

 begin
  ChkChar :=CurrField.Ground[X,Y].Ch;
  if (X<MinX) or (X>MaxX) or (Y<MinY) or (Y>MaxY) then
    Valid :=false
  else
  if ChkChar in InvalidChrs then
    Valid :=false
  else
   begin
    GetScreenWord(X,Y,Att,ChkChar);
    if ChkChar in InvalidChrs then
     Valid :=false
    else
    begin
    Valid:=true;
    Colr :=Att Mod 16;
    case ChkChar of
    '่' : begin
           if AllPLayers[PN].Jewels.Num > 6 then
           begin
            AllPlayers[PN].Level:= AllPlayers[PN].Level+1;
            if AllPlayers[PN].Level >9 then
             begin
              AddHof;
              RestoreItems(PN,True);
              AllPlayers[PN].Cash :=500;
              AllPlayers[PN].Level :=1;
              Emu_ClearScreen;
              ComWriteln('');
              Emu_color(15,0);
              ComWriteln(' You Have Just Won this Adventure of XENO-Quest.');
              ComWriteln('');
              Emu_color(14,0);
              ComWriteln(' Your Name has been added to the Hall of Fame.');
              ComWriteln('');
              Emu_color(14,0);
              ComWriteln(' You Will Be Known as one of the Greatest XENOS.');
              ComWriteln('');
              GetCR(15);
              GoOffLine :=true
             end
            else
             begin
              Emu_ClearScreen;
              ComWriteln('');
              Emu_color(15,0);
              ComWriteln(' You Have Just Completed Level '+InttoStr(AllPLayers[PN].Level-1)+'.');
              ComWriteln('');
              ComWrite(' You are Awarded ');
              Emu_color(10,0);
              ComWriteln('$1000 ');
              Emu_color(14,0);
              ComWriteln(' Congratulations !!!!.');
              ComWriteln('');
              GetCR(15);
              ReviveMonsters(False);
              AllPLayers[PN].Cash:= AllPLayers[PN].Cash + 1000;
              AllPLayers[PN].Jewels.Num :=0;
              AllPLayers[PN].KEYS.Num :=0;
              AllPLayers[PN].Map :=0;
              ReviveJewels(7);
              ReviveKeys(7);
              ViewIt(AllPlayers[PN].RoomNum);
             end
            end
           else
            begin
              ClearMPrompt;
              Emu_Color(12,0);
              ComWriteln(' You Need ALL SEVEN Jewels to Move there.. ');
              Valid :=False;
            end;
          end;
    '(' : begin
           if AllPlayers[PN].Weapon < 25 then
           begin
            AllPlayers[PN].Weapon := 25;
            RemoveItem(X,Y);
            ClearMPrompt;
            Emu_Color(15,0);
            ComWrite(' You Found ');
            ShowWeapon;
            Emu_gotoXy(65,15);
            ShowWeapon
           end
          else
           begin
            IncCash(1);
           end;
          end;
    '' : begin
           if AllPlayers[PN].HypJumps < 10 then
            begin
             AllPlayers[PN].HypJumps := AllPlayers[PN].HypJumps +1;
             RemoveItem(X,Y);
             ClearMPrompt;
             Emu_Color(11,0);
             ComWrite(' You Found ');
             ComWrite('A Hyper-Jump Module. ');
             ShowHJumps
            end
           else
              IncCash(10);
          end;
    'ý' : begin
           if AllPlayers[PN].Map =0 then
            begin
             AllPlayers[PN].Map := 1;
             RemoveItem(X,Y);
             ClearMPrompt;
             Emu_Color(7,0);
             ComWrite(' You Found a ');
             Emu_Color(15,8);
             ComWrite('MAP !!!');
            end
           else
             begin
              IncCash(10);
             end;
           end;
    '' : begin
             RemoveItem(X,Y);
             ClearMPrompt;
             Emu_Color(7,0);
             ComWrite(' You Found a ');
             Emu_Color(14,8);
             ComWrite('XENO SHIELD !!!');
             AllPlayers[PN].XENOS :=AllPlayers[PN].XENOS +25;
           end;
  '฿','Ü' : begin
               ClearMPrompt;
              if AllPlayers[PN].Xenos = 0 then
               begin
                 Emu_Color(7,0);
                 Emu_Color(14,0);
                 ComWrite('XENO SHIELDS Increased !!!');
                 AllPlayers[PN].XENOS :=AllPlayers[PN].XENOS +25;
                end
              else
               begin
                AllPlayers[PN].Xenos := -1;
                Emu_Color(7,0);
                ComWrite('XENO SHIELDS LOST !!!');
               end
            end;
    '๎' : begin
           if AllPlayers[PN].Weapon < 26 then
           begin
            AllPlayers[PN].Weapon := 26;
            RemoveItem(X,Y);
            ClearMPrompt;
            Emu_Color(15,0);
            ComWrite(' You Found ');
            ShowWeapon;
            Emu_gotoXy(65,15);
            ShowWeapon
           end
           else
            begin
             IncCash(1);
            end
          end;
    '{' : begin
           if AllPlayers[PN].Weapon < 27 then
           begin
            AllPlayers[PN].Weapon := 27;
            RemoveItem(X,Y);
            ClearMPrompt;
            Emu_Color(15,0);
            ComWrite(' You Found ');
            ShowWeapon;
            Emu_gotoXy(65,15);
            ShowWeapon
           end
           else
            begin
             IncCash(1);
            end
          end;
    'ฉ' : begin
           if AllPlayers[PN].Weapon < 28 then
           begin
            AllPlayers[PN].Weapon := 28;
            RemoveItem(X,Y);
            ClearMPrompt;
            Emu_Color(15,0);
            ComWrite(' You Found ');
            ShowWeapon;
            Emu_gotoXy(65,15);
            ShowWeapon
           end
           else
            begin
             IncCash(1);
            end
          end;
    'ๅ' : begin
           if AllPlayers[PN].Weapon < 29 then
           begin
            AllPlayers[PN].Weapon := 29;
            RemoveItem(X,Y);
            ClearMPrompt;
            Emu_Color(15,0);
            ComWrite(' You Found ');
            ShowWeapon;
            Emu_gotoXy(65,15);
            ShowWeapon
           end
           else
            begin
             IncCash(1);
            end
          end;
    'เ' : begin
           if AllPlayers[PN].Weapon < 30 then
           begin
            AllPlayers[PN].Weapon := 30;
            RemoveItem(X,Y);
            ClearMPrompt;
            Emu_Color(15,0);
            ComWrite(' You Found ');
            ShowWeapon;
            Emu_gotoXy(65,15);
            ShowWeapon
           end
           else
            begin
             IncCash(1);
            end
          end;
    '๐': begin
           Valid :=False;
           ClearMPrompt;
           Emu_Color(7,0);
           ComWriteln(' A Built Wall Blocks You... ');
         end;

  'อ','บ':begin
           Valid := True;
           if Not HasKey(AllPlayers[PN],Colr) then
            begin
             Valid :=False;
             ClearMPrompt;
             Emu_Color(15,0);
             ComWrite(' You Need the ');
             Emu_Color(Colr,0);
             ComWriteln('KEY. ');
           end
        end;

    '':begin
         if AllPlayers[PN].HitPoints <10+AllPlayers[PN].Level then
          begin
           AllPlayers[PN].HitPoints :=AllPlayers[PN].HitPoints +1;
           ClearMPrompt;
           Emu_Color(15,0);
           ComWrite(' You Found ');
           Emu_Color(12,0);
           ComWriteln('Life Force. ');
           ShowHealth;
           RemoveItem(X,Y);
          end
         else
          IncCash(5);
        end;
    '$':begin
         if AllPlayers[PN].CASH <999000000 then
          begin
           CS:=Round(Random(1000));
           AllPlayers[PN].Cash :=AllPlayers[PN].Cash +CS;
           ShowBucks;
           ClearMPrompt;
           Emu_Color(15,0);
           ComWrite(' You Collected ');
           Emu_Color(10,0);
           ComWriteln('$'+IntToStr(CS));
           RemoveItem(X,Y);
         end
        end;
    'ฯ':begin
         if AllPlayers[PN].Walls.NumOfSegs <10 then
          begin
           AllPlayers[PN].Walls.NumOfSegs :=
            AllPlayers[PN].Walls.NumOfSegs +1;
            AllPlayers[PN].Walls.Segment[AllPlayers[PN].Walls.NumOfSegs].Level := 0;
            AllPlayers[PN].Walls.Segment[AllPlayers[PN].Walls.NumOfSegs].RmNum := 0;
            AllPlayers[PN].Walls.Segment[AllPlayers[PN].Walls.NumOfSegs].Owner := 0;
            ClearMPrompt;
            Emu_Color(15,0);
            ComWrite(' You Found ');
            Emu_Color(11,0);
            ComWriteln('A Wall Building Kit ');
           ShowWalSegs;
           RemoveItem(X,Y);
         end
        else
          IncCash(5);
        end;
    '#':begin
         if AllPlayers[PN].Ammo <30000 then
          begin
           AllPlayers[PN].Ammo :=AllPlayers[PN].Ammo +3+(5*(Att mod 8));
            ClearMPrompt;
            Emu_Color(15,0);
            ComWrite(' You Found ');
            Emu_Color(Att Mod 16,0);
            ComWriteln('Ammunition ');
           ShowAmmo;
           RemoveItem(X,Y);
         end
         else
          IncCash(5);
        end;
    '':begin
         if AllPlayers[PN].Jewels.Num < MaxThings then
          begin
           if Not HasJewel(AllPlayers[PN],Att Mod 16) then
           begin
            AllPlayers[PN].Jewels.Num :=AllPlayers[PN].Jewels.Num +1;
            AllPlayers[PN].Jewels.List[AllPlayers[PN].Jewels.Num] := Att mod 16;
            ClearMPrompt;
            Emu_Color(15,0);
            ComWrite(' You Found ');
            Emu_Color(Att Mod 16,0);
            ComWriteln('One of the SEVEN JEWELS. ');
            ShowJewels;
            RemoveItem(X,Y)
           end
          else
            IncCash(1);
         end
        end;
    'ิ':begin
         if AllPlayers[PN].Keys.Num < MaxThings then
          begin
           if Not HasKey(AllPlayers[PN],Att Mod 16) then
           begin
            AllPlayers[PN].Keys.Num :=AllPlayers[PN].Keys.Num +1;
            AllPlayers[PN].Keys.List[AllPlayers[PN].Keys.Num] := Att mod 16;
            ClearMPrompt;
            Emu_Color(15,0);
            ComWrite(' You Found ');
            Emu_Color(Att Mod 16,0);
            ComWriteln('A KEY. ');
            ShowKeys;
            RemoveItem(X,Y)
           end
          else
           IncCash(1);
         end;
        end;
    'ญ':begin
         if AllPlayers[PN].Potions.Num < MaxThings then
          begin
           I := 0;
           HasIt :=false;
           While (I < AllPlayers[PN].Potions.Num) and Not HasIt do
            begin
             I :=I+1;
             if AllPlayers[PN].Potions.List[I] = Colr then
               HasIt := True
            end;
           if Not Hasit then
           begin
            AllPlayers[PN].Potions.Num :=AllPlayers[PN].Potions.Num +1;
            AllPlayers[PN].Potions.List[AllPlayers[PN].Potions.Num] := Att mod 16;
            ClearMPrompt;
            Emu_Color(15,0);
            ComWrite(' You Found ');
            Emu_Color(Att Mod 16,0);
            ComWriteln('A Potion. ');
            ShowPotions;
            RemoveItem(X,Y)
           end
          else
           IncCash(1);
         end
        end
     end; {case}
    end
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 function WallsegNumber(X,Y: Byte) : Integer;
  var
    I         : Integer;
    WallFound : Boolean;
 begin
   I :=0 ;
   WallFound := False;
   WallSegNumber :=0;
   While (I < VisibleWalls.NumVisible ) and Not WallFound do
    begin
      I:=I+1;
      if (VisibleWalls.CurrWall[I].ScrnLoc.X =X ) and
         (VisibleWalls.CurrWall[I].ScrnLoc.Y =Y ) then
         begin
          WallFound :=true;
          WallSegNumber :=I;
          if VisibleWalls.CurrWall[I].Hits >1 then
           VisibleWalls.CurrWall[I].Hits :=VisibleWalls.CurrWall[I].Hits -1
          else
          begin
           AllPlayers[VisibleWalls.CurrWall[I].Owner].Walls.Segment[VisibleWalls.CurrWall[I].SegmentNum].Owner :=0;
           VisibleWalls.CurrWall[I].Hits := 0
          end
         end
    end;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure AddNews(Killey,Killer :NameString; CommentStr : String);
 Var
   NewsFile : text;
  begin
    While Length(Killey) < 25 do Killey :=Killey +' ';
    While Length(Killer) < 25 do Killer :=Killer +' ';
    begin
     if Not Exist('XQNews.Dta') then
      begin
       Assign(NewsFile,'XQNews.Dta');
       Rewrite(NewsFile)
      end
     else
      begin
       Assign(NewsFile,'XQNews.Dta');
       Append(NewsFile)
      end;
     Writeln(NewsFile,Killey,Killer,CommentStr);
     Close(NewsFile)
    end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXbbs.ShowNews;
 Var
   NewsFile : text;
   NewFile  : text;
   Killer   : NameString;
   Killey   : NameString;
   FrstFound  : Boolean;
   CommentStr : String;

  begin
   Emu_Color(14,0);
   Emu_ClearScreen;
   FrstFound := true;
   if Exist('XQNews.Dta') then
    begin
     Assign(NewsFile,'XQNews.Dta');
     Reset(NewsFile);
     Assign(NewFile,'XQNews.Tmp');
     ReWrite(NewFile);
     while (Not Eof(NewsFile)) and Online and Not GoOffLine and (DosError=0) do
     begin
      Readln(NewsFile,Killey,Killer,CommentStr);
      FormatName(Killey);
       if Killey = AllPlayers[PN].Name then
       begin
        if FrstFound then
         begin
          FrstFound:=false;
          ComWriteln('');
          ComWriteln('                              XENO Quest Version'+Vrs);
          Emu_Color(12,0);
          ComWriteln('');
          ComWriteln('                          W H A T    H A P P E N E D ???');
          Emu_Color(11,0);
          ComWriteln(' ____________________________________________________________________________');
          ComWriteln('');
          Emu_Color(15,0)
         end;
           Emu_Color(14,0);
           ComWrite(' You got Killed by ');
           Emu_Color(11,0);
           ComWriteln(Killer);
           Emu_Color(7,0);
           ComWriteln(' Comment from Your Murderer.... ');
           Emu_Color(15,0);
           ComWriteln(' '+CommentStr)
       end
      else
       Writeln(NewFile,Killey,Killer,CommentStr)
     end;
     Close(NewFile);
     Close(NewsFile);
     Erase(NewsFile);
     Rename(NewFile,'XQNews.Dta')
    end;
   if Not FrstFound then
   begin
     ComWriteln('');
     GetCR(7)
   end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 procedure XXBBS.DoHit(ScrLoc: PointType;ScrnCh: Char; BulType : Byte);
 Const
  InvalidChrs : Charset = ['ร','ด','ณ','ฤ','ู','ฺ','ฟ','ภ'];
  MonsChrs    : Charset = ['๊','','๏','๋',''];
 var
  I,J        : Byte;
  VisPlayNum : Byte;
  VisMonsNum : Byte;
  Segnum     : Integer;
  CStr       : String;
  BounceChrs : Charset;
 begin
  BounceChrs  := ['','ิ','ญ','',''];
  if AllPlayers[PN].Level >2 then BounceChrs := BounceChrs +['บ','ฐ','ฑ','๘'];
  if AllPlayers[PN].Level >4 then BounceChrs := BounceChrs +['-','อ','','#',''];
   I:=0;
  if (ScrnCh in BounceChrs) then
    begin
     if ((ScrnCh ='ญ') and (BulType =1 )) then
      begin
        if Random(10) > 8 then
         begin
          Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
          Emu_Color(11,0);
          ComWrite('‘');
          BInitBullet(ScrLoc,False,BulType)
         end
         else
        if Random(10) > 3 then
         begin
          Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
          Emu_Color(12,0);
          ComWrite('๐');
          BInitBullet(ScrLoc,False,BulType)
         end
      end
      else
      if AllPlayers[PN].Level >4 then
        BInitBullet(ScrLoc,False,BulType)
      else
        BInitBullet(ScrLoc,True,BulType)
    end
   else
   if Not (ScrnCh in InvalidChrs) then
    begin
     if (ScrnCh ='๐') and (BulType =1 ) then
      begin
        SegNum := WallSegNumber(ScrLoc.X,ScrLoc.Y);
        if (SegNum =0) or (VisibleWalls.CurrWall[SegNum].Hits <1) then
         begin
          Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
          ComWrite(' ');
         end
      end;
     if ((ScrnCh ='‘') and (BulType =1)) then
      begin
        if Random(10) > 5 then
         begin
          Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
          Emu_Color(14,8);
          ComWrite('');
         end
      end;
     if ((ScrnCh ='ý') or (ScrnCh ='#')) and (BulType =1 ) then
      begin
        if Random(10) > 4 then
         begin
          Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
          Emu_Color(6,0);
          ComWrite('‘');
         end
      end;
     if (ScrnCh ='') then
      begin
      if (AllPlayers[PN].ScrnLoc.X = ScrLoc.X) and
         (AllPlayers[PN].ScrnLoc.Y = ScrLoc.Y) then
        With AllPlayers[PN] do
         begin
           if XENOS >0 then
           begin
            BInitBullet(ScrLoc,False,BulType);
            XENOS:=XENOs-1
           end
          else
          begin
           Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
           Emu_Color(12,0);
           ComWrite('*');
          if Hitpoints >0 then
           begin
             Hitpoints :=Hitpoints -1;
             if Hitpoints >0 then
              if BulType =1 then
               begin
                ShowHealth;
                Hitpoints :=Hitpoints -1;
                if Hitpoints >0 then Hitpoints :=Hitpoints -1;
               end;
              ShowHealth;
              delay(50);
              Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
              Emu_Color(15,0);
              ComWrite(ScrnCh);
            end
          else
           begin
            Dead:=True;
            Quit:=True
           end
          end
        end
       else
       While I < VisiblePlyrs.NumVisible do
       begin
        I:=I+1;
        VisPlayNum :=VisiblePlyrs.CurrPlayer[I];
        if (AllPlayers[VisPlayNum].ScrnLoc.X = ScrLoc.X) and
         (AllPlayers[VisPlayNum].ScrnLoc.Y = ScrLoc.Y) then
         With AllPlayers[VisPlayNum] do
         begin
          if XENOS >0 then
           begin
            BInitBullet(ScrLoc,False,BulType);
            XENOS:=XENOs-1
           end
          else
          begin
          Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
          Emu_Color(15,0);
          ComWrite('*');
          if HitPoints >0 then HitPoints :=HitPoints-1;
           if HitPoints >1 then if BulType =1 then
            HitPoints :=HitPoints-2;
          if AllPlayers[VisPlayNum].HitPoints >0 then
           begin
            delay(100);
            Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
            Emu_Color(11,0);
            ComWrite(ScrnCh);
           end
           else
             begin
               Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
               Emu_Color(12,0);
               ComWrite('');
               AllPlayers[Pn].Kills :=AllPlayers[Pn].Kills +1;
               ClearMenu(False);
               ComWrite('You Killed ');
               Emu_Color(15,0);
               ComWriteln(AllPlayers[VisPlayNum].Alias);
               Emu_Color(14,0);
               ComWriteln('Enter Your Comment to Your Opponent.(50 Characters).');
               Emu_GotoXy(1,19);
               Emu_Color(0,7);
               ComWriteln('                                                    ');
               Emu_GotoXy(2,19);
               Emu_Color(15,7);
               ClearReceive;
               ReadlnX(Cstr,50);
               Emu_Color(15,0);
               ClearMenu(False);;
               ComWrite(' You Collected ');
               Emu_Color(10,0);
               ComWrite('$'+CommaPut(AllPlayers[VisPlayNum].Cash));
               if (AllPlayers[VisPlayNum].Map >0 ) and(AllPlayers[PN].Map =0) then
                begin
                 Emu_Color(15,0);
                 ComWrite('...  And You Got a ');
                 Emu_Color(12,0);
                 ComWriteln('MAP !!!');
                 AllPlayers[VisPlayNum].Map:=0;
                 AllPlayers[PN].Map:=1
                end;
               AllPlayers[PN].Cash := AllPlayers[PN].Cash + AllPlayers[VisPlayNum].Cash;
               ShowBucks;
               AllPlayers[VisPlayNum].Cash :=500;
               AddNews(AllPlayers[VisPlayNum].Name,AllPlayers[PN].Alias,Cstr);
               Emu_GotoXy(2,18);
               GetCR(15);
               ClearMenu(True);;
               AllPlayers[VisPlayNum].Dead :=True;
               AllPlayers[VisPlayNum].Dies := AllPlayers[VisPlayNum].Dies+1;
               RestoreItems(VisPlayNum,True);
               While I < VisiblePlyrs.NumVisible do
                begin
                 VisiblePlyrs.CurrPlayer[I]:=VisiblePlyrs.CurrPlayer[I+1];
                 I:=I+1
                end;
                VisiblePlyrs.NumVisible :=VisiblePlyrs.NumVisible -1
             end
            end
         end;
       end
      end;
     if (ScrnCh in MonsChrs) then
      begin
       I:=0;
       While I < VisibleMnstrs.NumVisible do
       begin
        I:=I+1;
        VisMonsNum :=VisibleMnstrs.CurrPlayer[I];
        if (AllMonsters[VisMonsNum].ScrnLoc.X = ScrLoc.X) and
         (AllMonsters[VisMonsNum].ScrnLoc.Y = ScrLoc.Y) then
         begin
          Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
          Emu_Color(15,0);
          ComWrite('*');
          if AllMonsters[VisMonsNum].HitPoints >0 then
           if Random(20+(BulType*2)) >(15+AllPlayers[PN].Level) then
           AllMonsters[VisMonsNum].HitPoints :=
                   AllMonsters[VisMonsNum].HitPoints-1;
          if AllMonsters[VisMonsNum].HitPoints >3 then
           if BulType =1 then AllMonsters[VisMonsNum].HitPoints :=
                   AllMonsters[VisMonsNum].HitPoints Div 2;
          if AllMonsters[VisMonsNum].HitPoints >0 then
           begin
            delay(50);
            ShowMonster(VisMonsNum);
           end
           else
             begin
               AllMonsters[VisMonsNum].HitPoints:=0;
               Emu_GotoXy(ScrLoc.X,ScrLoc.Y);
               Emu_Color(9+Trunc(Random(7)),0);
               case Round(Random(50)) of
                8,0: ComWrite('#');
               1..5: ComWrite('');
              10..14: ComWrite('ิ');
             17..23: ComWrite('ญ');
             27..34: ComWrite('$');
             38..39: ComWrite('');
             46,47 : ComWrite('ý');
                48 : ComWrite('');
                49 : ComWrite('‘');
                  else
                   begin
                    Emu_Color(12,0);
                    ComWrite('')
                   end
                end;
               AllPlayers[Pn].Kills :=AllPlayers[Pn].Kills +1;
               AllPlayers[Pn].Cash :=AllPlayers[Pn].Cash +(50*AllPlayers[Pn].Level);
               ClearReceive;
               ClearMPrompt;
               Emu_Color(15,0);
               ComWrite(' You Are Awarded ');
               Emu_Color(10,0);
               ComWrite('$'+IntToStr(100*AllPlayers[Pn].Level));
               Emu_Color(15,0);
               ComWrite(' For The Kill... ');
               ShowBucks;
               AllMonsters[VisMonsNum].Dead :=True;
               While I < VisibleMnstrs.NumVisible do
                begin
                 VisibleMnstrs.CurrPlayer[I]:=VisibleMnstrs.CurrPlayer[I+1];
                 I:=I+1
                end;
               VisibleMnstrs.NumVisible :=VisibleMnstrs.NumVisible -1
             end
         end
       end
      end
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.Fire;
 var
  C            : Char;
  Weapon       : Byte;

 begin
  if AllPlayers[Pn].Ammo <1 then
   begin
    ClearMPrompt;
    Emu_Color(12,0);
    ComWriteln(' Out Of Ammo !!  ');
   end
  else
  begin
  ClearMPrompt;
  Emu_Color(12,0);
  ComWrite('FIRE !!  ');
  Emu_Color(15,0);
  ComWrite(' Direction ?');
  getcmd(C,['I','Q','G','O','M','K',#13,'H','P','Q']);
  ClearMPrompt;
  Weapon:= AllPlayers[Pn].Weapon;
  case C of
   'O': begin {dn/left}
         InitFire(1,Weapon);
         ShowAmmo;
        end;
   'G': begin {up/left}
         InitFire(7,Weapon);
         ShowAmmo;
        end;
   'Q': begin {dn/right}
         InitFire(3,Weapon);
         ShowAmmo;
        end;
   'I': begin {up/Right}
         InitFire(9,Weapon);
         ShowAmmo;
        end;
   'H': begin {up}
         InitFire(8,Weapon);
         ShowAmmo;
        end;
   'P': begin {down}
         InitFire(2,Weapon);
         ShowAmmo;
        end;
   'M': begin {right}
         InitFire(6,Weapon);
         ShowAmmo;
        end;
   'K': begin {Left}
         InitFire(4,Weapon);
         ShowAmmo;
        end
     end
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.Jump;
 var
  C            : Char;

 begin
  with AllPlayers[PN] do
  begin
  ClearMPrompt;
  Emu_Color(12,0);
  ComWrite('JUMP !!  ');
  Emu_Color(15,0);
  ComWrite(' Direction ?');
  getcmd(C,['M','K',#13,'H','P','Q']);
  ClearMPrompt;
  Weapon:= AllPlayers[Pn].Weapon;
  case C of
   'H': begin {up}
         if RoomNum <10 then RoomNum:=RoomNum +90
         else RoomNum :=RoomNum-10;
         HypJumps:=HypJumps-1;
         Viewit(RoomNum);
         ShowHJumps;
        end;
   'P': begin {down}
         if RoomNum >89 then RoomNum:=RoomNum -90
         else RoomNum :=RoomNum+10;
         HypJumps:=HypJumps-1;
         Viewit(RoomNum);
         ShowHJumps;
        end;
   'M': begin  {right}
         if RoomNum =99 then RoomNum:= 0
         else RoomNum :=RoomNum+1;
         HypJumps:=HypJumps-1;
         Viewit(RoomNum);
         ShowHJumps;
        end;
   'K': begin  {Left}
         if RoomNum =0 then RoomNum:=99
         else RoomNum :=RoomNum-1;
         HypJumps:=HypJumps-1;
         Viewit(RoomNum);
         ShowHJumps
        end
  end
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.Tport;
 var
  C            : Char;
  RN           : Integer;
 begin
  with AllPlayers[PN] do
  begin
   ClearMPrompt;
   Emu_Color(12,0);
   ComWrite('Teleport !!  ');
   Emu_Color(15,0);
   ComWrite('Which Room..##>');
   GetNum(RN,99);
   if RN >0 then
    begin
     RoomNum := RN;
     Viewit(RoomNum);
     Tports:=Tports -1
    end
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.UsePotion;

 var
  C            : Char;
 begin
  if AllPlayers[Pn].Potions.Num <1 then
   begin
    ClearMPrompt;
    Emu_Color(12,0);
    ComWriteln(' Out Of Potions !!      ');
   end
  else
  begin
   ClearMPrompt;
  Emu_Color(12,0);
  ComWrite('USE POTION !!  ');
  Emu_Color(15,0);
  ComWrite('Which Direction ? ');
  getcmd(C,['I','Q','G','O','M','K',#13,'H','P','Q']);
  ClearMPrompt;
  case C of
   'O': begin {dn/left}
         InitFire(1,1);
         ShowPotions;
        end;
   'G': begin {up/left}
         InitFire(7,1);
         ShowPotions;
        end;
   'Q': begin {dn/right}
         InitFire(3,1);
         ShowPotions;
        end;
   'I': begin {up/Right}
         InitFire(9,1);
         ShowPotions;
        end;
   'H': begin {up}
         InitFire(8,1);
         ShowPotions;
        end;
   'P': begin {down}
         InitFire(2,1);
         ShowPotions;
        end;
   'M': begin {right}
         InitFire(6,1);
         ShowPotions;
        end;
   'K': begin {Left}
         InitFire(4,1);
         ShowPotions;
        end
  end
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ClearMenu( ReShow : Boolean);
 begin
  Emu_GotoXy(1,17);
  ComWrite(' ');
  Emu_ClearToEndOfLine;
  ComWriteln(' ');
  Emu_ClearToEndOfLine;
  ComWriteln(' ');
  Emu_ClearToEndOfLine;
  ComWriteln(' ');
  Emu_ClearToEndOfLine;
  ComWriteln(' ');
  Emu_ClearToEndOfLine;
  ComWriteln(' ');
  Emu_ClearToEndOfLine;
  ComWriteln(' ');
  Emu_ClearToEndOfLine;
  if ReShow then  ShowIMenu
  else
   Emu_GotoXy(1,17)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function XXBBS.DropThing(D,C : Char): boolean;
  var
    Xpos, Ypos : Byte;
    Att        : Byte;
    Ch         : Char;
    I,J        : Integer;
    SpotFound  : Boolean;
    WallAvailable : Boolean;
 begin
  Xpos := AllPlayers[PN].ScrnLoc.X;
  Ypos := AllPlayers[PN].ScrnLoc.Y;
  Case C of
   'H': begin {up}
         Ypos:=Ypos-1;
        end;
   'P': begin {down}
         Ypos:=Ypos+1;
        end;
   'M': begin {right}
         Xpos:=Xpos+1;
        end;
   'K': begin {Left}
         Xpos:=Xpos-1;
        end
  end; {case}
  GetScreenWord(Xpos,Ypos,Att,Ch);
  if Ch<>' ' then DropThing :=false
  else
  begin
   I :=0;
   SpotFound :=false;
   While (I< MaxItems) and Not SpotFound do
    begin
     I :=I+1;
     if Not Junk[I].Visible then SpotFound := True;
    end;
    if SpotFound then
    begin
    with AllPlayers[PN] do
     begin
      DropThing :=True;
      case D of
      'K' : begin
              Junk[I].ItemNum:= Keys.List[Keys.Num]+9;
              Junk[I].ItemLoc.X:= Xpos;
              Junk[I].ItemLoc.Y:= Ypos;
              Junk[I].RmNum :=RoomNum;
              Junk[I].Visible:= True;
              Keys.Num :=Keys.Num-1;
              ShowKeys;
              ShowItem(I);
            end;
      'J' : begin
              Junk[I].ItemNum   := Jewels.List[Jewels.Num]+2;
              Junk[I].ItemLoc.X := Xpos;
              Junk[I].ItemLoc.Y := Ypos;
              Junk[I].RmNum     := RoomNum;
              Junk[I].Visible   := True;
              Jewels.Num        := Jewels.Num-1;
              ShowJewels;
              ShowItem(I);
             end;
      'F' : begin
              Junk[I].ItemNum   := Weapon;
              Weapon            := 0;
              Junk[I].ItemLoc.X := Xpos;
              Junk[I].ItemLoc.Y := Ypos;
              Junk[I].RmNum     := RoomNum;
              Junk[I].Visible   := True;
              Emu_gotoXy(65,15);
              ShowWeapon;
              ShowItem(I);
            end;
      'P' : begin
              Junk[I].ItemNum   := Potions.List[Potions.Num]+22;
              Junk[I].ItemLoc.X := Xpos;
              Junk[I].ItemLoc.Y := Ypos;
              Junk[I].RmNum     := RoomNum;
              Junk[I].Visible   := True;
              Potions.Num       := Potions.Num-1;
              ShowPotions;
              ShowItem(I);
            end;
      'W' : begin
              Junk[I].ItemNum   := 38;
              Junk[I].ItemLoc.X := Xpos;
              Junk[I].ItemLoc.Y := Ypos;
              Junk[I].RmNum     := RoomNum;
              Junk[I].Visible   := True;
              J:=0;
              WallAvailable :=false;
              While (J < Walls.NumOfSegs) and Not WallAvailable do
               begin
                J :=J+1;
                if Walls.Segment[J].Owner = 0 then
                 begin
                   Emu_Color(11,0);
                   WallAvailAble :=True;
                   While (J < Walls.NumOfSegs) do
                    begin
                     Walls.Segment[J] :=Walls.Segment[J+1];
                     J:=J+1
                    end;
                   Walls.NumOfSegs :=Walls.NumOfSegs-1
                 end
                end;
              ShowWalsegs;
              ShowItem(I);
            end;
      'L' : begin
              Junk[I].ItemNum    := 1;
              Junk[I].ItemLoc.X  := Xpos;
              Junk[I].ItemLoc.Y  := Ypos;
              Junk[I].RmNum      := RoomNum;
              Junk[I].Visible    := True;
              HitPoints          := HitPoints-1;
              ShowHealth;
              ShowItem(I);
            end;
    'A','H' : begin
              Junk[I].ItemNum   := 2 + Round(random(7));
              Junk[I].ItemLoc.X := Xpos;
              Junk[I].ItemLoc.Y := Ypos;
              Junk[I].RmNum     := RoomNum;
              Junk[I].Visible   := True;
              if Ammo > 50 then Ammo:= Ammo-50
              Else Ammo :=50;
              ShowAmmo;
              ShowItem(I);
            end;
      end{case}
     end
    end
    else
    DropThing :=false;
  end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.DropItem;

 var
  C,D           : Char;
  KeySet        : CharSet;
  I             : Integer;
  WallAvailable : Boolean;

 begin
  KeySet :=['Q',#13];
  ClearMenu(False);;
  Emu_GotoXy(1,17);
  if AllPlayers[PN].Weapon >0 then
   Begin
    Emu_Color(12,0);
    ComWriteln( ' [F] FireArm');
    KeySet := KeySet +['F'];
   end;
  if AllPlayers[PN].Keys.Num >0 then
   Begin
    Emu_Color(10,0);
    ComWriteln( ' [K] Keys ');
    KeySet := KeySet +['K'];
   end;
  if AllPlayers[PN].Jewels.Num >0 then
   Begin
    Emu_Color(15,0);
    ComWriteln( ' [J] Jewels ');
    KeySet := KeySet +['J'];
   end;
  if AllPlayers[PN].Potions.Num >0 then
   Begin
    Emu_Color(14,0);
    ComWriteln( ' [P] Potions ');
    KeySet := KeySet +['P'];
   end;
  if AllPlayers[PN].Ammo >0 then
   Begin
    Emu_Color(13,0);
    ComWriteln( ' [A] Ammo  ');
    KeySet := KeySet +['A','H'];
   end;
  if AllPlayers[PN].Walls.NumOfSegs >0 then
   Begin
    I :=0;
    WallAvailable := false;
    While (I < AllPlayers[PN].Walls.NumOfSegs) and Not WallAvailable do
     begin
      I :=I+1;
      if AllPlayers[PN].Walls.Segment[I].Owner = 0 then
      begin
       Emu_Color(11,0);
       ComWriteln( ' [W] Walls  ');
       KeySet := KeySet +['W'];
       WallAvailable :=True;
      end;
     end
   end;
   Emu_GotoXy(1,23);
   Emu_Color(15,0);
   ComWrite(' Leave Which Item ? [Q]uit ..>');
   GetCmd(D,KeySet);
   ClearMenu(False);;
  if Not (D in ['Q',#13]) then
   begin
    Emu_Color(15,0);
    ComWrite(' Which Side ? [Q]uit ..>');
    getcmd(C,['M','K',#13,'H','P','Q']);
    ClearMPrompt;
    if Not DropThing(D,C) then
    begin
     ClearMPrompt;
     Emu_Color(12,0);
     ComWrite(' Unable to Put an Item There ....');
     GetCR(15)
    end;
  end;
   ClearMenu(True);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowWall(P,I: Byte);
  begin
    Emu_GotoXy(AllPlayers[P].Walls.Segment[I].ScrnLoc.X,
               AllPlayers[P].Walls.Segment[I].ScrnLoc.Y);
    Emu_Color(7,0);
    ComWrite('๐');
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function XXBBS.PutWall(C:Char): boolean;
  var
    Xpos, Ypos : Byte;
    Att        : Byte;
    Ch         : Char;
    I          : Integer;
    WallFound  : Boolean;
    MaxWalls   : Byte;
 begin
  Xpos := AllPlayers[PN].ScrnLoc.X;
  Ypos := AllPlayers[PN].ScrnLoc.Y;
  Case C of
   'H': begin {up}
         Ypos:=Ypos-1;
        end;
   'P': begin {down}
         Ypos:=Ypos+1;
        end;
   'M': begin  {right}
         Xpos:=Xpos+1;
        end;
   'K': begin  {Left}
         Xpos:=Xpos-1;
        end
  end; {case}
  GetScreenWord(Xpos,Ypos,Att,Ch);
  if Ch<>' ' then PutWall :=false
  else
  begin
   I :=0;
   WallFound := False;
   MaxWalls := AllPlayers[PN].Walls.NumOfSegs;
   While (I<MaxWalls) and Not WallFound do
    Begin
     I:=I+1;
     If AllPLayers[PN].Walls.Segment[I].Owner = 0 then
        WallFound :=True;
    End;
   if WallFound then
    begin
     AllPLayers[PN].Walls.Segment[I].Owner := PN;
     AllPLayers[PN].Walls.Segment[I].Level := AllPLayers[PN].Level;
     AllPLayers[PN].Walls.Segment[I].RmNum := AllPLayers[PN].RoomNum;
     AllPLayers[PN].Walls.Segment[I].Scrnloc.X :=Xpos;
     AllPLayers[PN].Walls.Segment[I].Scrnloc.Y :=Ypos;
     ShowWall(PN,I);
     ShowWalSegs;
     VisibleWalls.NumVisible := VisibleWalls.NumVisible +1;
     VisibleWalls.CurrWall[VisibleWalls.NumVisible].Owner :=PN;
     VisibleWalls.CurrWall[VisibleWalls.NumVisible].SegmentNum :=I;
     VisibleWalls.CurrWall[VisibleWalls.NumVisible].Hits := 1 + Round(Random(5));
     VisibleWalls.CurrWall[VisibleWalls.NumVisible].ScrnLoc :=
                       AllPlayers[Pn].Walls.Segment[I].ScrnLoc
    end
    else
    begin
     ClearMPrompt;
     Emu_Color(14,0);
     ComWriteln(' All Your Walls are Already Built....');
    end;
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.BuildWall;

 var
  C,D          : Char;
  KeySet       : CharSet;

 begin
  KeySet :=['Q'];
  ClearMPrompt;
  if AllPlayers[PN].Walls.NumOfSegs >0 then
   Begin
    Emu_Color(11,0);
    ComWrite( ' Build Wall... ');
    Emu_Color(15,0);
    ComWrite(' Which Side?  [Q]uit ..>');
    getcmd(C,['M','K',#13,'H','P','Q']);
    ClearMPrompt;
    if Not (C in [#13,'Q']) then
    if Not PutWall(C) then
    begin
     ClearMPrompt;
     Emu_Color(12,0);
     ComWriteln(' Unable to Build Wall There ....');
    end;
   end;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ShowIMenu;
 begin

   Emu_GotoXy(1,17);
   Emu_Color(15,0);
   ComWriteln('Use Arrow Keys     ');
   with AllPlayers[PN] do
   begin
    Emu_GotoXy(1,19);
    Emu_Color(7,0);
    ComWrite('[F] Fire Weapon       ');
    ComWrite('[U] Use Potion        ');
    ComWriteln('[W] Build Wall');
    ComWrite('[J] Use Hyper Jump    ');
    ComWrite('[T] Use TelePort      ');
    ComWriteln('[V] View Map');
    ComWrite('[L] Leave Item        ');
    ComWrite('[R] ReDraw Screen     ');
    ComWriteln('[S] Supply Store');
    Emu_Color(12,0);
    ComWrite('[X] Exit');
   end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure GetReDrawChar(ScL : PointType; var MF,MB:Byte; var CH : Char);
 begin
    MF:=CurrField.Ground[ScL.X,ScL.Y].Attr Mod 16;
    MB:=CurrField.Ground[ScL.X,ScL.Y].Attr Div 16;
    Ch:=CurrField.Ground[ScL.X,ScL.Y].Ch;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ReDrawChar(ScL : PointType; MF,MB:Byte; CH : Char);
 begin
   Emu_gotoxy(ScL.X,ScL.Y);
   if Ch<> ' ' then Emu_Color( MF, MB);
   ComWrite(Ch);
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.ProcessMove;
 var
 CD             : Char;
 MarkSpotFColor : byte;
 MarkSpotBColor : byte;
 MarkChar       : Char;
 KeySet         : CharSet;
 RN             : Integer;

  begin
   With AllPlayers[PN] do
   begin
    GetReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
    ShowPLayer;
    KeySet :=['M','K','I','G','O','H','P','F','Q','T','X','L','U','S','J',#13,' ','V','R','W'];
   getcmd(CD,KeySet);
   If ReqChat then
    begin
     Chat;
     CD:=#0;
     ViewIt(RoomNum);
    end;
   case CD of
   'S' : begin
          TradingPost(XXX,AllPlayers[PN],VRS);
          ViewIt(RoomNum);
         end;
   'R' : ViewIt(RoomNum);
   'V' : begin
          if Map >0 then
          begin
           if Exist('XQMAP.dta') then
            begin
             Emu_ClearScreen;
             TypeHole('XQMAP.dta',AllPlayers[PN].Level);
             Emu_GotoXy(1,15);
             Emu_Color(10,0);
             ComWriteln(' You are in');
             ComWrite  ('  Room ');
             Emu_Color(14,0);
             ComWrite(InTToStr(AllPlayers[PN].RoomNum)+'  ');
             Emu_GotoXy(1,24);
             GetCR(15);
             ViewIt(RoomNum);
            end
           else
            begin
             ClearMPrompt;
             ComWrite('MAP File NOT Found...');
            end
           end
          else
           begin
            ClearMPrompt;
            Emu_Color(12,0);
            ComWriteln('You have to Find or Buy the Map first......');
           end;
         end;
   ' ': begin
         ClearReceive;
        end;
   '?': begin
         ShowIMenu;
        end;
   'J': begin
         if HypJumps >0 then Jump;
        end;
   'T': begin
         if Tports >0 then Tport;
        end;
   #13: begin
        If (Pos('Chris Neubauer',Name) >0 ) or
           (Pos(BRec.SysOpName,Name) >0) then
        begin
         Xenos:=Xenos+5;
         ClearMPrompt;
         Emu_Color(12,0);
         ComWrite('Jump !!  ');
         Emu_Color(15,0);
         ComWrite('Which Level/Room..>');
         GetNum(RN,999);
         Level := RN div 100;
         if Level =0 then Level :=1;
         RoomNum := RN Mod 100;
         Viewit(RoomNum);
        end
        end;
   'X': begin
         Quit :=true;
        end;
   'F': begin
         Fire;
        end;
   'U': begin
         UsePotion;
        end;
   'L': begin
         DropItem;
        end;
   'W': begin
         if RoomNum >50 then
           BuildWall
         else
         begin
          ClearMPrompt;
          Emu_Color(12,0);
          ComWriteln(' Unable to Build Wall In this Room ....');
         end;
        end;
   'O': begin  {Diagonal down left}
           ReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
           If (ScrnLoc.Y < MaxY) and (ScrnLoc.X > MinX) then
           if Valid(ScrnLoc.X-1,ScrnLoc.Y+1) then
            begin
             ScrnLoc.X:=ScrnLoc.X-1;
             ScrnLoc.Y:=ScrnLoc.Y+1;
             GetReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
             ShowPlayer
            end
           else ClearReceive;
        end;
   'G': begin  {Diagonal Up left}
           ReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
           If (ScrnLoc.Y > MinY) and (ScrnLoc.X > MinX) then
           if Valid(ScrnLoc.X-1,ScrnLoc.Y-1) then
            begin
             ScrnLoc.X:=ScrnLoc.X-1;
             ScrnLoc.Y:=ScrnLoc.Y-1;
             GetReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
             ShowPlayer
            end
           else ClearReceive;
        end;
   'I': begin  {Diagonal Up right}
           ReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
           If (ScrnLoc.Y > MinY) and (ScrnLoc.X < MaxX) then
           if Valid(ScrnLoc.X+1,ScrnLoc.Y-1) then
            begin
             ScrnLoc.X:=ScrnLoc.X+1;
             ScrnLoc.Y:=ScrnLoc.Y-1;
             GetReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
             ShowPlayer
            end
           else ClearReceive;
        end;
   'Q': begin  {Diagonal down right}
           ReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
           If (ScrnLoc.Y < MaxY) and (ScrnLoc.X < MaxX) then
           if Valid(ScrnLoc.X+1,ScrnLoc.Y+1) then
            begin
             ScrnLoc.X:=ScrnLoc.X+1;
             ScrnLoc.Y:=ScrnLoc.Y+1;
             GetReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
             ShowPlayer
            end
           else ClearReceive;
        end;
   'H': begin  {Up}
           ReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
           If ScrnLoc.Y =MinY then
            begin
             if RoomNum >9 then
              RoomNum:=RoomNum-10
              else RoomNum:=RoomNum+90;
             if RoomNum <0 then RoomNum :=100+RoomNum;
             Viewit(RoomNum);
             ScrnLoc.Y := MaxY;
            end
           else
           if Valid(ScrnLoc.X,ScrnLoc.Y-1) then
            begin
             ScrnLoc.Y:=ScrnLoc.Y-1;
             GetReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
             ShowPlayer
            end
           else ClearReceive;
        end;
   'P': begin {dn}
           ReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
           If ScrnLoc.Y =MaxY then
            begin
             RoomNum:=RoomNum+10;
             if RoomNum >99 then RoomNum :=RoomNum-100;
             Viewit(RoomNum);
             ScrnLoc.Y := MinY;
            end
           else
           if Valid(ScrnLoc.X,ScrnLoc.Y+1) then
            begin
             ScrnLoc.Y:=ScrnLoc.Y+1;
             GetReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
             ShowPlayer
            end
           else ClearReceive;
        end;
   'M': begin
           ReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
           If ScrnLoc.X =MaxX then
            begin
             RoomNum:=RoomNum+1;
             if RoomNum >99 then RoomNum :=0;
             Viewit(RoomNum);
             ScrnLoc.X := MinX;
            end
           else
           if Valid(ScrnLoc.X+1,ScrnLoc.Y) then
            begin
             ScrnLoc.X:=ScrnLoc.X+1;
             GetReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
             ShowPlayer
            end
           else ClearReceive;
         end;
   'K': begin
           ReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
           If ScrnLoc.X =MinX then
            begin
            if RoomNum >0 then
               RoomNum:=RoomNum-1;
             Viewit(RoomNum);
             ScrnLoc.X := MaxX;
            end
           else
           if Valid(ScrnLoc.X-1,ScrnLoc.Y) then
            begin
             ScrnLoc.X:=ScrnLoc.X-1;
             GetReDrawChar(ScrnLoc,MarkSpotFColor,MarkSpotBColor,MarkChar);
             ShowPlayer
            end
           else ClearReceive;
        end;

   end; {case}
   end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.MainFlow;
 begin
  checkTimeLeft;
  showmsr;
  GameOver := True;
  repeat
  if AllPlayers[Pn].Hitpoints <1 then AllPlayers[Pn].Hitpoints :=3;
  ShowNews;
  Viewit( AllPlayers[PN].RoomNum);
  Quit :=False;
  repeat
   ProcessMove;
  until GoOffLine or Not Online or Quit;
  SHOWMSR;
  Emu_gotoxy(1,22);
  If AllPlayers[Pn].Hitpoints >0 then
   begin
    ClearMenu(False);;
    Emu_Color(15,0);
    ComWriteln('Returning to Main Menu ');
    AllPlayers[Pn].Dead :=False;
    GetCR(15);
    GameOver :=False;
   end
   else
   begin
    AllPlayers[Pn].Dies :=AllPlayers[Pn].Dies +1;
    ShowDeadPlayer;
    ClearMenu(False);;
    Emu_Color(15,0);
    ComWrite('You''ve been Killed ......  Continue  ?? ');
    RestoreItems(PN,False);
    GetYN(GameOver);
    if GameOver then AllPlayers[Pn].Dead :=False;
   end
  until Not GameOver;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure XXBBS.RUNX( var Savem : Boolean );
 var
  C : Char;
  Yhit : boolean;
  I    : Integer;

 begin
  SHOWMSR;
  if (GetBps > 2400) or Local then
    DelayFactor  :=90
  else
    DelayFactor  :=70;
  Savem := True;
  C:=#0;
  ComWriteln('XENO-Quest Version'+ Vrs);
   if Local then
    begin
     Emu_Color(14,0);
     ComWriteln('Local Mode Enabled... ');
     Yhit :=true
    end;
  GetPlayers;
  if Not PlayerFound(BRec.UName) then
   begin
    if Not Local then
    begin
     ComWriteln('');
     ComWriteln('Detecting Ansi...');
     Yhit :=DetectAnsi;
     if Not Yhit then
     begin
      ComWrite('Are You Using ANSI Graphics ?? [Y/n] ');
      getYn(Yhit)
     end
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
   end;
  if  Yhit and OnLine And not GoOfflIne then
  begin
  if Pn = 0 then SetNewPlayer(BRec.UNAME);
  if Pn = 0 then
   begin
     Emu_Color(15,0);
     ComWriteln('Sorry, Xeno-Quest is Full !!! ');
     if Not BRec.Registered then
     ComWriteln('Unregistered Versions allow a Maximum of 20 players... ');
     ComWriteln('Check Back in a few days or... ');
     ComWriteln('Help Your SysOp Register this Game... ');
     GetCR(14)
   end;

 if  Pn > 0 then
  repeat
  if (Online and Not GoOffLine) then
  MainMenu;
  Emu_Color(15,0);
  ComWriteln('');
  ComWrite(' Selection? =>');
  Getchar(C,['A','B','Y','H','I','Q','S','R','M','C']);
  if ReqChat then Chat
  else
  begin
  if (Online and Not GoOffLine) then
    begin
     case C of
      'M' : Domess(XXX,VRS,AllPlayers[PN].Name,AllPlayers[PN].Alias);
      'C' : begin
              ClearMenu(False);;
              Emu_GotoXy(1,18);
              ComWriteln('');
              Emu_Color(14,0);
              ComWriteln('The XENO-Gods have Mercy and Revive you in Room 0...');
              AllPlayers[PN].RoomNum :=0;
              AllPlayers[PN].ScrnLoc.X       :=3;
              AllPlayers[PN].ScrnLoc.Y       :=3+ round(Random(8));
              RestoreItems(PN,False);
              AllPlayers[PN].Dead :=False;
              GetCR(15)
            end;
      'A' : begin
              ClearMenu(False);;
              Emu_GotoXy(1,20);
              Emu_CursorUp;
              AllPlayers[PN].Alias :=GetAlias;
            end;
      'B' : begin
              AllPlayers[PN].dead := False;
              MainFlow;
            end;
      'S' : begin
              TradingPost(XXX,AllPlayers[PN],VRS);
            end;
      'R' : begin
             ShowRankings;
            end;
      'H' : begin
             ShowHallOfFame;
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
 procedure GetData(var BR : BBSData; var ComNum : Byte; Var BD : LongInt;
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
   DelayFactor :=85;
  end;
  assign(ConfigFile,'XQ.CFG');
  reset(ConfigFile);
  if IoResult <>0 then
   begin
    Writeln;
    Writeln('XQ.CFG File Not Found ... Execution Halted.');
    if Not Local then
     Writeln('To Run Local type "XQ Your Name"');
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
    Writeln('To Run Local type "XQ Your Name" ');
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
  end
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
 ClrScr;
 Savem :=false;
 GetData(BBRec,Cport,BDRate,Lcl);
 XXX.INIT(Cport,BDRate,BBRec,Lcl);
 XXX.RUN;
 XXX.INITIALIZE;
 CheckRegistered(XXX.BRec);
 InitPlayers;
 XXX.Emu_ClearScreen;
 XXX.SHOWMSR;
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
  if Savem and (XXX.Brec.Uname<>'') and (Length(XXX.BRec.Uname)>2) then
    begin
     AllPlayers[PN].Dead :=False;
     AllPlayers[PN].LastDate :=Date;
     ReNigPlayers;
     UpDatePlayer;
     UpDateMonsters;
     UpdateItems;
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
 ResetChars;
 TextColor(15);
 TextBacKground(0);
END.
