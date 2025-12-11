

PROGRAM Xqvert;

uses Crt,Dos,BBSGam,BBSScrn,XQMess,XQPost;

const
 MaxPlayers = 100;
type
  TPlayers = Record
             Active    : Boolean;
             Dead      : Boolean;
             Alias     : TNameString;
             Name      : TNameString;
             Weapon    : Byte;
             Ammo      : Integer;
             HypJumps  : Byte;
             TPorts    : Byte;
             Keys      : SpcThings;
             Walls     : Wallsegs;
             Jewels    : SpcThings;
             Potions   : SpcThings;
             Level     : Byte;
             RoomNum   : Byte;
             Cash      : LongInt;
             XENOS     : Integer;
             Kills     : LongInt;
             Dies      : LongInt;
             HitPoints : Integer;
             ScrnLoc   : PointType;
             Map       : Byte;
             LastDate  : String[8];
           end;
 Playerstat = array[1..MaxPlayers] of Players;
 TPlayerstat = array[1..MaxPlayers] of TPlayers;
 var
  A    : PlayerStat;
  T    : TPlayerStat;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure FormatName1(var FNAME :STRING);
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
   Fname:=Copy(Fname,1,25)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure UpDatePlayer;
 var
  PlyrFile      : File of PlayerStat;
  TPlyrFile     : File of TPlayerStat;
  I             : Integer;


 begin
  Assign(PlyrFile,'PlyrFile.Dta');
  ReSet(PlyrFile);
  Read(PlyrFile,A);
  Close(PlyrFile);
  for I :=1 to 100 do
   begin
   T[I].Active    :=A[I].Active;
   T[I].Dead      :=A[I].Dead;
   T[I].Alias     :=A[I].Alias;
   T[I].Name      :=A[I].Name;
   FormatName(T[I].Alias);
   FormatName(T[I].Name);
   T[I].Weapon    := A[I].Weapon;
   T[I].Ammo      := A[I].Ammo;
   T[I].HypJumps  := A[I].HypJumps;
   T[I].TPorts    := A[I].TPorts;
   T[I].Keys      := A[I].Keys;
   T[I].Walls     := A[I].Walls;
   T[I].Jewels    := A[I].Jewels;
   T[I].Potions   := A[I].Potions;
   T[I].Level     := A[I].Level ;
   T[I].RoomNum   := A[I].RoomNum ;
   T[I].Cash      := A[I].Cash;
   T[I].XENOS     := A[I].XENOS;
   T[I].Kills     := A[I].Kills;
   T[I].Dies      := A[I].Dies;
   T[I].HitPoints := A[I].HitPoints;
   T[I].ScrnLoc   := A[I].ScrnLoc;
   T[I].Map       := A[I].Map;
   T[I].LastDate  := A[I].LastDate;
   end;
   Assign(TPlyrFile,'PlyrFile.Dta');
   ReWrite(TPlyrFile);
   Write(TPlyrFile,T);
   Close(TPlyrFile);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
begin
 UpdatePlayer;
end.