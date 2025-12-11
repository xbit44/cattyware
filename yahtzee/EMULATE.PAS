 Unit Emulate;
 InterFace
 Uses Nodes,Ansi_X,Dos,Crt,BBSScrn;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Type

 Emulat   = record
    Name    : String[20];
    Header  : String[3];
    Offset  : Byte;
    Literal : Boolean;
    XYOrder : Boolean;
    GotoXY  : String[5];
    CursUp  : String[2];
    CursDn  : String[2];
    CursLf  : String[2];
    CursRt  : String[2];
    ClrScr  : String[2];
    ClrTop  : String[2];
    ClrEOS  : String[2];
    ClrEOL  : String[2];
    Color   : String[5];
    Reverse : String[2];
    Normal  : String[2];
    ScrlUp  : String[2];
    ScrlDn  : String[2];
    InsLine : String[2];
    DelLine : String[2];
    InsChar : String[2];
    DelChar : String[2];
  end;

  Emul = Object(Node)
          TType : Byte;
          Color : Boolean;
          Emu   : Emulat;
          Procedure   Init (ComNum : byte);
          Procedure   ComWrite(Strn : String);
          Procedure   ComWriteln(Strn : String);
          Procedure   ComWriteO(Strn : String);
          Procedure   IComWriteO(I : Integer);
          Function    LoadEmulation(Fname : String) : Boolean;
          Procedure   GetEmulation(T : Byte);
          Procedure   Emu_GotoXY( X, Y : Byte);
          Procedure   Emu_CursorUp;
          Procedure   Emu_CursorDown;
          Procedure   Emu_CursorLeft;
          Procedure   Emu_CursorRight;
          Procedure   Emu_ClearScreen;
          Procedure   Emu_ClearToTop;
          Procedure   Emu_ClearToEndOfScreen;
          Procedure   Emu_ClearToEndOfLine;
          Procedure   Emu_ReverseVideo;
          Procedure   Emu_NormalVideo;
          Procedure   Emu_ScrollUp;
          Procedure   Emu_ScrollDown;
          Procedure   Emu_InsertLine;
          Procedure   Emu_DeleteLine;
          Procedure   Emu_InsertChar(CHH :Char);
          Procedure   Emu_DeleteChar;
          Procedure   Emu_Color(Fore, Back : Byte);
         end;

 Implementation
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Emul.Init (ComNum : byte);
 var
  Regs : Registers;
 begin
  inherited Init(ComNum);
  TType :=2;
  Color := False;
  Emu.GotoXY := '';
  Emu.CursUp := '';
  Emu.CursDn := #10;
  Emu.CursLf := #8;
  Emu.CursRt := '';
  Emu.ClrScr := #12;
  Emu.ClrTop := '';
  Emu.ClrEOS := '';
  Emu.ClrEOL := '';
  Emu.Reverse := '';
  Emu.Normal := '';
  Emu.ScrlUp := '';
  Emu.ScrlDn := '';
  Emu.InsLine := '';
  Emu.DelLine := '';
  Emu.InsChar := '';
  Emu.DelChar := '';
  Emu.Color := '';
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Emul.LoadEmulation(Fname : String) : Boolean;
 Var
   F    : File of Emulat;
   Dir  : Dirstr;
   Name : NameStr;
   Ext  : ExtStr;

 Begin
   LoadEmulation := False;
   FSplit(ParamStr(0), Dir, Name, Ext);
   Assign(F, Dir + Fname + '.EMU');
   {$I-}
   Reset(F);
   Read(F, Emu);
   Close(F);
   {$I+}
   if (IOResult = 0) then LoadEmulation := True
   else
    Begin
      Assign(F, Fname + '.EMU');
      {$I-}
      Reset(F);
      Read(F, Emu);
      Close(F);
      {$I+}
      if (IOResult = 0) then LoadEmulation := True
    end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Emul.GetEmulation(T : Byte);
 var
  Pup : PopUp;
 begin
   Pup.ScrSave;
   case T of
    1:if not LoadEmulation('ansi') then Pup.Init(25,18,53,22,15,1,30,'Unable to Load Ansi.');
    2:if not LoadEmulation('tty') then Pup.Init(25,18,53,22,15,1,30,'Unable to Load TTY.');
    3:if not LoadEmulation('vt52') then Pup.Init(25,18,53,22,15,1,30,'Unable to Load VT52.');
   end;
   Pup.Done;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.ComWrite(Strn : String);
 Var
   X : Byte;
 Begin
  if Local then
     begin
      For X:=1 to Length(Strn) do
      Display_Ansi(Strn[X])
     end
  else
   Begin
    for X := 1 to Length(Strn) do
     begin
      Display_Ansi(Strn[X]);
      CWrite(Strn[X])
     end
   end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.ComWriteLn(Strn : String);
 Begin
   ComWrite(Strn+#13+#10);
 end;
{--------------------------------------------------------------------}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.ComWriteO(Strn : String);
 Var
   X : Byte;
 Begin
  if Not Local then
   Begin
    for X := 1 to Length(Strn) do
     begin
      CWrite(Strn[X])
     end
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.IComWriteO(I : Integer);
 Var
   X    : Byte;
   Strn : String;
 Begin
   Str(I,Strn);
   ComWriteO(Strn)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

Procedure Emul.Emu_GotoXY(X, Y : Byte);
 Begin
   if (Emu.GotoXY <> '') then
    Begin
      ComWriteO(Emu.Header);
      if (Emu.XYOrder) then  { X, Y }
       Begin
         ComWriteO(Copy(Emu.GotoXY, 1, Pos('เ', Emu.GotoXY) - 1));
         if (Emu.Literal) then IComWriteO(X)
         else ComWriteO(Chr(X + Emu.Offset));
         ComWriteO(Copy(Emu.GotoXY, Pos('เ', Emu.GotoXY) + 1, (Pos('แ', Emu.GotoXY) - Pos('เ', Emu.GotoXY)) - 1));
         if (Emu.Literal) then IComWriteO(Y)
         else ComWriteO(Chr(Y + Emu.Offset));
         ComWriteO(Copy(Emu.GotoXY, Pos('แ', Emu.GotoXY) + 1, 5));
       end
      else                   { Y, X }
       Begin
         ComWriteO(Copy(Emu.GotoXY, 1, Pos('เ', Emu.GotoXY) - 1));
         if (Emu.Literal) then IComWriteO(Y)
         else ComWriteO(Chr(Y + Emu.Offset));
         ComWriteO(Copy(Emu.GotoXY, Pos('เ', Emu.GotoXY) + 1, (Pos('แ', Emu.GotoXY) - Pos('เ', Emu.GotoXY)) - 1));
         if (Emu.Literal) then IComWriteO(X)
         else ComWriteO(Chr(X + Emu.Offset));
         ComWriteO(Copy(Emu.GotoXY, Pos('แ', Emu.GotoXY) + 1, 5))
       end;
       if X<1 then X:=1;
       If Y<1 then Y:=1;
       GotoXY(X, Y)
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Emul.Emu_CursorUp;
  Begin
   if (Emu.CursUp <> '') then
    Begin
     if Ttype=3 then
      begin
       Emu_GotoXy(WhereX,WhereY-1);
      end
     else
     begin
      ComWriteO(Emu.Header + Emu.CursUp);
      GotoXy(WhereX,WhereY-1)
     end
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_CursorDown;
 Begin
   if (Emu.CursDn <> '') then
    Begin
     ComWriteO(Emu.Header + Emu.CursDn);
     GotoXy(WhereX,WhereY+1);
    end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_CursorLeft;
 Begin
   if (Emu.CursLf <> '') then
    Begin
      ComWriteO(Emu.Header + Emu.CursLf);
      GotoXY(WhereX - 1, WhereY);
      if TType =3 then
       begin
        Write(' ');
        GotoXY(WhereX - 1, WhereY)
       end
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_CursorRight;
 Begin
   if (Emu.CursRt <> '') then
    Begin
      ComWriteO(Emu.Header + Emu.CursRt);
      GotoXY(WhereX + 1, WhereY)
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_ClearScreen;
 var I : integer;

 Begin
   if (Emu.ClrScr <> '') then
    Begin
      ComWriteO(Emu.Header + Emu.ClrScr);
      IF TType =3 then
      begin
       Emu_GotoXY(0,0);
       Emu_ClearToEndOfScreen
      end;
      TextBackGround(0);
      ClrScr;
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_ClearToTop;
 var
    Y, SX, SY : Byte;

 Begin
   if (Emu.ClrTop <> '') then
    Begin
      SX := WhereX;
      SY := WhereY;
      for Y := WhereY downto 0 do
       Begin
         Emu_GotoXY(0, Y);
         Emu_ClearToEndOfLine
       end;
      Emu_GotoXY(SX, SY)
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_ClearToEndOfScreen;
 Var
   Y, SX, SY, TY : Byte;
 Begin
   if (Emu.ClrEOS <> '') then
    Begin
      SX := WhereX;
      SY := WhereY;
      if TType =3 then TY :=WhereY-1 else Ty :=WhereY;
      for Y := TY to 24 do
       Begin
         Emu_GotoXY(0, Y);
         Emu_ClearToEndOfLine
       end;
      Emu_GotoXY(SX, SY)
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_ClearToEndOfLine;
 Begin
   if (Emu.ClrEOL <> '') then
    Begin
      ComWriteO(' '+#8);
      ComWriteO(Emu.Header + Emu.ClrEOL);
      ClrEOL;
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_ReverseVideo;
 Begin
   if (Emu.Reverse <> '') then
    Begin
      ComWriteO(Emu.Header + Emu.Reverse);
      TextColor(Black);
      TextBackground(LightGray)
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_NormalVideo;
 Begin
   if (Emu.Normal <> '') then
    Begin
      ComWriteO(Emu.Header + Emu.Normal);
      TextColor(LightGray);
      TextBackground(Black)
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_ScrollUp;
 Var
   SX, SY : Byte;
 Begin
   if (Emu.ScrlUp <> '') then
    Begin
      ComWriteO(Emu.ScrlUp + #1#1#1#50#80);
      SX := WhereX;
      SY := WhereY;
      GotoXY(1, 1);
      DelLine;
      GotoXY(SX, SY)
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_ScrollDown;
 Var
   SX, SY : Byte;
 Begin
   if (Emu.ScrlDn <> '') then
    Begin
      ComWriteO(Emu.ScrlDn + #1#1#1#50#80);
      SX := WhereX;
      SY := WhereY;
      GotoXY(1, 1);
      InsLine;
      GotoXY(SX, SY)
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_InsertLine;
 Begin
   if (Emu.InsLine <> '') then
    Begin
      ComWriteO(Emu.ScrlDn + #1 + Chr(WhereY) + #1#50#80);
      InsLine
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_DeleteLine;
 Begin
   if (Emu.DelLine <> '') then
    Begin
      ComWriteO(Emu.ScrlUp + #1 + Chr(WhereY) + #1#50#80);
      DelLine
    end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_InsertChar(CHH :Char);
 Var
   SX, SY : Byte;
   Strn   : String;
   Moveneeded : boolean;
   IC         : Integer;
   LS,I       : Integer;
 Begin
      MoveNeeded:=false;
      SX := WhereX;
      SY := WhereY;
      GetScreenStr(SX, 80, SY , Strn);
      Ls:=Length(Strn);
      if Ls>0 then
      Begin
      I := 1;
      while Not Moveneeded and (I<LS) do
       Begin
        if Strn[I]<>' ' then
         Begin
          Moveneeded :=true;
          Strn:=Copy(Strn,1,Length(Strn)-1);
          While Strn[Length(Strn)] =' ' do Strn:=Copy(Strn,1,Length(Strn)-1)
         end;
        I:=I+1
       end
      end;
      ComWrite(Chh);
      if Moveneeded then ComWrite(Strn);
      Emu_GotoXY(SX+1, SY)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_DeleteChar;
 Var
   SX, SY : Byte;
   Strn   : String;
 Begin
      SX := WhereX;
      SY := WhereY;
      GetScreenStr(SX, 80, SY, Strn);
      While Strn[Length(Strn)] =' ' do Strn:=Copy(Strn,1,Length(Strn)-1);
      ComWrite(Copy(Strn, 2, Length(Strn))+' ');
      Emu_GotoXY(SX, SY)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Emul.Emu_Color(Fore, Back : Byte);
 Begin
   if (Emu.Color <> '') and Color then
    Begin
       Begin
         ComWrite(Emu.Header);
         ComWrite(Copy(Emu.Color, 1, Pos('เ', Emu.Color) - 1));
         case Fore of
           Black, DarkGray       : ComWrite('30');
           Red, LightRed         : ComWrite('31');
           Green, LightGreen     : ComWrite('32');
           Brown, Yellow         : ComWrite('33');
           Blue, LightBlue       : ComWrite('34');
           Magenta, LightMagenta : ComWrite('35');
           Cyan, LightCyan       : ComWrite('36');
           LightGray, White      : ComWrite('37')
         end;
         if (Fore > 7) then ComWrite(';1');
         ComWrite(Copy(Emu.Color,Pos('เ',Emu.Color)+1,(Pos('แ',Emu.Color)-Pos('เ',Emu.Color))-1));
         case Back of
           Black, DarkGray       : ComWrite(';40');
           Red, LightRed         : ComWrite(';41');
           Green, LightGreen     : ComWrite(';42');
           Brown, Yellow         : ComWrite(';43');
           Blue, LightBlue       : ComWrite(';44');
           Magenta, LightMagenta : ComWrite(';45');
           Cyan, LightCyan       : ComWrite(';46');
           LightGray, White      : ComWrite(';47')
         end;
         if (Back > 7) then ComWrite(';5');
         ComWrite(Copy(Emu.Color, Pos('แ', Emu.Color) + 1, 5))
       end
    end
 end;
{--------------------------------------------------------------------}

 end.