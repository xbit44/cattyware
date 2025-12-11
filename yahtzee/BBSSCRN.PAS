 Unit BBSScrn;
 InterFace
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 type
  Vel   = Record
               Case Boolean of
                True  : (Character, Attribute : Byte);
                False : (Contents :Word);
          end;
  VioRam  = Array[1..25,1..80] of Vel;
  VioPtr  =^Vioram;

   PopUp = Object
          VCS   : VioRam;
          TXA   : Word;
          XP,YP : Byte;
          Procedure Init(X1,Y1,X2,Y2,C1,C2,C3:Byte; Msg : String);
          Procedure ScrSave;
          Procedure Done;
         end;
 Var
  Vioseg  : Word;
  VP      : VioPtr;

 Procedure GetScreenWord(X, Y : Byte; var Attr : Byte; var Ch : Char);
 Procedure GetScreenChar(X, Y : Byte; var Ch : Char);
 Procedure GetScreenStr(X1, X2, Y : Byte; var St : String);

 Implementation
 Uses Crt,Dos;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure GetScreenChar(X, Y : Byte; var Ch : Char);
 Begin
   Ch   := Chr(VP^[Y,X].Character)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure GetScreenWord(X, Y : Byte; var Attr : Byte; var Ch : Char);
 Begin
   Attr := VP^[Y,X].Attribute;
   Ch   := Chr(VP^[Y,X].Character)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure GetScreenStr(X1, X2, Y : Byte; var St : String);
 Var
   I : Integer;
   A : Byte;
   C : Char;
 Begin
   St := '';
   for I := X1 to X2 do
    Begin
      GetScreenWord(I, Y, A, C);
      St := St + C
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure PopUp.Init(X1,Y1,X2,Y2,C1,C2,C3:Byte; Msg : String);
 var
  I : Byte;
  T,B,M : String;
 begin
  Xp :=WhereX;
  Yp :=WhereY;
  TxA :=TextAttr;
  I := X1;
  T:='ษ';
  B:='ศ';
  M:='บ';
  While I < X2 do
   begin
    I:=I+1;
    T:=T+('อ');
    B:=B+('อ');
    M:=M+' '
   end;
  T:=T+('ป');
  B:=B+('ผ');
  M:=M+'บ';
  I:=Y1+1;
  Textcolor(C1);
  TextBackGround(C2);
  VCS:=Vp^;
  GotoXy(X1,Y1);
  Write(T);
  While I < Y2 do
   begin
    GotoXy(X1,I);
    Write(M);
    I:=I+1;
   end;
   GotoXy(X1,I);
   Write(B);
   GotoXy((X1+((X2-X1) Div 2))-(Length(Msg) Div 2), Y1+((Y2-Y1) Div 2));
   Textcolor(C3);
   Write(Msg);
   GotoXy(Xp,Yp);
   TextAttr:=TxA;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure PopUp.ScrSave;
 begin
  Xp :=WhereX;
  Yp :=WhereY;
  TxA :=TextAttr;
  VCS:=Vp^;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure PopUp.Done;
 begin
  Vp^ :=VCS;
  GotoXy(Xp,Yp);
  TextAttr:=TxA;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 var
  Regs : Registers;
 begin
  Regs.AH :=15;
  Intr($10,Regs);
  If Regs.AL =7 Then Vioseg :=$B000 else Vioseg:=$B800;
  VP:=Vioptr(ptr(Vioseg,$0000));
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 end.