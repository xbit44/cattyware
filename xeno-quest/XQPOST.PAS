 Unit XQPost;
 Interface
 Uses crt,DOS,BBSGam,XQMESS;
 type
  PointType = record
                X,Y: integer
              end;
  WallPiece = record
               Level : Byte;
               Rmnum : Byte;
               Owner : Byte;
               Scrnloc : PointType;
              end;

  Wallsegs  =  record
                 NumOfSegs : Byte;
                 Segment   :  array [1..10] of Wallpiece;
               end;
  SpcThings = record
               Num  : Byte;
               List : Array[1..10] of Byte;
              end;
  Players = Record
             Active    : Boolean;
             Dead      : Boolean;
             Alias     : NameString;
             Name      : NameString;
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

 Procedure CheckRegistered(var BR : BBSData);
 Procedure TradingPost(Var XXX : TBBS; var AP: Players; Vrs : String);
 Function HasKey(AP : Players; C : Byte) : Boolean;
 Function HasJewel(AP:Players; C : Byte) : Boolean;
 Function ItoStr( I : Integer ): string;
 Function CommaPut( Num : real ): string;
 Implementation

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure CheckRegistered(var BR : BBSData);

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
     Sum:= Sum Mod 58;
     Sum :=Sum+48;
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
    Writeln('   XENO-QUEST');
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
 Function CommaPut( Num : real ): string;
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
  CommaPut :=St+' ';
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function ItoStr( I : Integer ): string;
 var
   St : String;
 begin
  Str(I:5, St);
  ItoStr :=St;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function HasKey(AP : Players; C : Byte) : Boolean;
 var
  I     : Byte;
  Hasit : Boolean;
 begin
  I := 0;
  HasIt :=false;
  While (I < AP.Keys.Num) and Not HasIt do
    begin
     I :=I+1;
     if AP.Keys.List[I] = C then
     HasIt := True
    end;
 HasKey :=Hasit;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function HasJewel(AP : Players; C : Byte) : Boolean;
 var
  I     : Byte;
  Hasit : Boolean;
 begin
  I := 0;
  HasIt :=false;
  While (I < AP.Jewels.Num) and Not HasIt do
    begin
     I :=I+1;
     if AP.Jewels.List[I] = C then
     HasIt := True
    end;
 HasJewel :=Hasit;
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure TradingPost(Var XXX : TBBS; var AP: Players; Vrs : String);
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function PickJewels : Boolean;
 Type
    Precord = Record
               Clr : Byte;
              end;

  var
    I     : Integer;
    J     : Integer;
    Count : Byte;
    ListJew : Array [1..7] of Precord;
    Colr  : Byte;

 begin
 with XXX do
 begin
  PickJewels :=False;
 if AP.Jewels.Num < 7 then
  begin
  Emu_Color(15,0);
  emu_ClearScreen;
  ComWriteln('');
  ComWriteln(' XENO-QUEST Version'+Vrs);
  Emu_Color(14,0);
  ComWriteln('      Supply Store');
  Emu_Color(12,0);
  ComWriteln('อออออออออออออออออออออออออ');
  Emu_Color(11,0);
  ComWriteln('      Buy Jewels ');
  ComWriteln('');
  ComWrite('    ');
       Count :=0;
       For Colr := 9 to 15 do
       begin
         if Not HasJewel(AP,Colr) then
            begin
              Emu_Color(Colr,0);
              ComWrite(' ');
              Count :=Count +1;
              ListJew[Count].Clr :=Colr;
            end
       end;
       ComWriteln('');
       ComWrite('    ');
       For I := 1 to Count do
        begin
         Emu_Color(ListJew[I].Clr,0);
         ComWrite(IntToStr(I)+' ');
        end;
       ComWriteln('');
       ComWriteln('');
       ComWrite(' Buy Which One ? ##  ');
       GetNum(J,7);
       if J in [1..Count] then
        begin
          AP.Jewels.Num := AP.Jewels.Num +1;
          AP.Jewels.List[AP.Jewels.Num] := ListJew[J].Clr;
          Emu_Color(10,0);
          ComWriteln(' SOLD !!! ');
          PickJewels :=True;
          GetCR(15)
        end
     end
    else
     begin
        Emu_Color(12,0);
        ComWriteln(' You Don''t Need any Jewels !!! ');
        GetCR(15)
     end;
  end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function PickKeys : Boolean;
 type
    Precord = Record
               Clr : Byte;
              end;

  var
    I     : Integer;
    J     : Integer;
    Count : Byte;
    ListJew : Array [1..7] of Precord;
    Colr  : Byte;

 begin
 With XXX do
 begin
  PickKeys :=False;
  if AP.Keys.Num < 7 then
  begin
  Emu_Color(15,0);
  emu_ClearScreen;
  ComWriteln('');
  ComWriteln(' XENO-QUEST Version'+Vrs);
  Emu_Color(14,0);
  ComWriteln('      Supply Store');
  Emu_Color(12,0);
  ComWriteln('อออออออออออออออออออออออออ');
  Emu_Color(11,0);
  ComWriteln('      Buy Keys  ');
  ComWriteln('');
  ComWrite('    ');
       Count :=0;
       For Colr := 9 to 15 do
       begin
         if Not HasKey(AP,Colr) then
            begin
              Emu_Color(Colr,0);
              ComWrite('ิ ');
              Count :=Count +1;
              ListJew[Count].Clr :=Colr;
            end
       end;
       ComWriteln('');
       ComWrite('    ');
       For I := 1 to Count do
        begin
         Emu_Color(ListJew[I].Clr,0);
         ComWrite(IntToStr(I)+' ');
        end;
       ComWriteln('');
       ComWriteln('');
       ComWrite(' Buy Which One ? ##  ');
       GetNum(J,7);
       if J in [1..Count] then
        begin
          AP.Keys.Num := AP.Keys.Num +1;
          AP.Keys.List[AP.Keys.Num] := ListJew[J].Clr;
          Emu_Color(10,0);
          ComWriteln(' SOLD !!! ');
          GetCR(15);
          PickKeys :=True;
        end
     end
    else
     begin
        Emu_Color(12,0);
        ComWriteln(' You Don''t Need any Keys !!! ');
        GetCR(15)
     end;
  end
 end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 const
    Itm : array[1..13] of String[18] =
              ('50 Rounds Ammo   ',
               'CrossBow         ',
               '+1 CrossBow      ',
               '+3 CrossBow      ',
               '357 Magnum       ',
               '+2 Yag Laser     ',
               '+5 Co2 Laser     ',
               'Jewels           ',
               'Keys             ',
               'Wall Segments    ',
               'Hyper-Jumps      ',
               'TelePorts        ',
               'OverView Map     ');
    ItmPrice : array[1..13] of LongInt =
              (100,
               200,
               500,
               1000,
               2000,
               3000,
               5000,
               6000,
               7000,
               8000,
               9000,
               20000,
               30000);
 var
  C        : char;
  I        : Integer;
  N        : Integer;
  NB       : Byte;
  Finished : Boolean;

 begin
{  AP.Cash := 20000;}
 with XXX do
 begin
  Finished := False;
  While Not Finished and Online and Not GoOffLine do
  begin
  Emu_Color(15,0);
  emu_ClearScreen;
  ComWriteln('');
  ComWriteln('        XENO-QUEST Version'+Vrs);
  Emu_Color(14,0);
  ComWriteln('             Supply Store');
      begin
         Emu_Color(13,0);
         ComWriteln('       Prices Of Available Items');
         Emu_Color(9,0);
         ComWriteln('ออออออออออออออออออออออออออออออออออออออออ');
         For I :=1 to 13 do
          begin
           Emu_Color(15,0);
           ComWrite(ItoStr(I)+'.');
           Emu_Color(11,0);
           ComWrite('   '+Itm[I]);
           Emu_Color(10,0);
           ComWriteln('     $'+CommaPut(ItmPrice[I]));
          end;
         Emu_Color(9,0);
         ComWriteln('ออออออออออออออออออออออออออออออออออออออออ');
         Emu_Color(15,0);
         ComWrite(' You Have ');
         Emu_Color(10,0);
         ComWriteln('$'+ CommaPut(AP.Cash));
         ComWriteln('');
         Emu_Color(14,0);
         ComWrite(' Buy Which Item ##  [Enter=Quit] ?? ');
         GetNum(N,13);
          NB := N;
         if NB in [1..13] then
          begin
            if ItmPrice[N] > AP.Cash then
             begin
              Emu_Color(12,0);
              ComWriteln(' You Don''t Have Enough Bucks for that...');
               GetCR(15)
             end
            else
             begin
              Emu_Color(10,0);
              Case NB of
               1: AP.Ammo := AP.Ammo +50;
               10: if AP.Walls.NumOfSegs <10 then
                  begin
                    AP.Walls.NumOfSegs:=AP.Walls.NumOfSegs+1;
                    AP.Walls.Segment[AP.Walls.NumOfSegs].Owner :=0;
                  end;
               11: AP.HypJumps := AP.HypJumps +1;
               2: AP.Weapon := 25;
               3: AP.Weapon := 26;
               4: AP.Weapon := 27;
               5: AP.Weapon := 28;
               6: AP.Weapon := 29;
               7: AP.Weapon := 30;
               8: if PickJewels then
                   AP.Cash := AP.Cash -ItmPrice[N];
               9: if PickKeys then
                   AP.Cash := AP.Cash -ItmPrice[N];
              12: AP.Tports := AP.Tports +1;
              13: AP.Map := 1;
               end; {Case}
               if Not (NB in [8,9]) then
                begin
                 AP.Cash := AP.Cash -ItmPrice[N];
                 ComWriteln(' SOLD !!! ');
                 GetCR(15)
               end
            end
          end
         else
          Finished := True
        end
    end
  end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
end.