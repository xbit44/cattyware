 unit Ansi_X;
 Interface
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Display_Ansi(ch : char);
 Implementation
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Uses Crt;

 Var
    Esc,Saved_X,
    Saved_Y               : Byte;
    Control_Code          : String;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function GetNumber(var Line:string):integer;
 var
  I,J,K          : Integer;
   Temp0,Temp1   : String;
  Begin
    Temp0 := line;
    val(Temp0,I,J);
   If j = 0 then Temp0 :=''
    else
      begin
        Temp1:= copy(Temp0,1,J-1);
        delete(Temp0,1,J);
        val(Temp1,I,J)
      end;
    line := Temp0;
    GetNumber :=I
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure ClrSt;
    begin
      Esc := 0;
      Control_Code := ''
    end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Ansi_Cursor_move;
 var
   x,y   : Integer;
  begin
    y := GetNumber(Control_Code);
    If y = 0 then y := 1;
    x := GetNumber(Control_Code);
    If x = 0 then x := 1;
    If y > 25 then y := 25;
    If x > 80 then x := 80;
    Gotoxy(x,y);
    ClrSt
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Ansi_Cursor_up;
  Var
   y,new_y,offset : Integer;
  Begin
   Offset := getnumber(Control_Code);
   If Offset = 0 then offset := 1;
   y := WhereY;
   If (y - Offset) < 1 then New_y := 1
   else  New_y := y - offset;
   Gotoxy(WhereX,new_y);
   ClrSt
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Ansi_Cursor_Down;
 Var
   y,new_y,offset : Integer;
  Begin
    Offset := getnumber(Control_Code);
    If Offset = 0 then offset := 1;
    y := WhereY;
    If (y + Offset) > 25 then New_y := 25
    else  New_y := y + offset;
    Gotoxy(WhereX,new_y);
    ClrSt
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Ansi_Cursor_Left;
  Var
   x,new_x,offset          :Integer;
  Begin
   Offset := getnumber(Control_Code);
   If Offset = 0 then offset := 1;
   x := WhereX;
   If (x - Offset) < 1 then New_x := 1
   else  New_x := x - offset;
   Gotoxy(new_x,WhereY);
   ClrSt
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Ansi_Cursor_Right;
 Var
   x,new_x,offset : Integer;
   Begin
     Offset := getnumber(Control_Code);
     If Offset = 0 then offset := 1;
     x := WhereX;
     If (x + Offset) > 80 then New_x := 1
     else New_x := x + offset;
     Gotoxy(New_x,WhereY);
    ClrSt
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Reverse_Video;
 var
      TempAttr,tblink,TempAttrlo,TempAttrhi : Byte;
 begin
    LowVideo;
    TempAttrlo := (TextAttr and $7);
    TempAttrHi := (TextAttr and $70);
    tblink     := (TextAttr and $80);
    Tempattrlo :=  Tempattrlo * 16;
    Tempattrhi :=  Tempattrhi div 16;
    TextAttr   :=  TempAttrhi+TempAttrLo+TBlink;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Ansi_Set_Colors;
 var
   Temp0,Color_Code : Integer;
   begin
      If length(Control_Code) = 0 then Control_Code :='0';
       while (length(Control_Code) > 0) do
         begin
           Color_Code := getNumber(Control_Code);
           case Color_Code of
           0    :  begin
                     LowVideo;
                     TextColor(LightGray);
                     TextBackground(Black);
                    end;
           1     : HighVideo;
           5     : TextAttr := (TextAttr or $80);
           7     : Reverse_Video;
           30    : TextAttr := (TextAttr And $F8) + black;
           31    : TextAttr := (TextAttr And $f8) + red;
           32    : TextAttr := (TextAttr And $f8) + green;
           33    : TextAttr := (TextAttr And $f8) + brown;
           34    : TextAttr := (TextAttr And $f8) + blue;
           35    : TextAttr := (TextAttr And $f8) + magenta;
           36    : TextAttr := (TextAttr And $f8) + cyan;
           37    : TextAttr := (TextAttr And $f8) + Lightgray;
           40    : Textbackground(black);
           41    : Textbackground(red);
           42    : Textbackground(green);
           43    : Textbackground(yellow);
           44    : Textbackground(blue);
           45    : Textbackground(magenta);
           46    : Textbackground(cyan);
           47    : Textbackground(white)
           end {case}
         end;
       ClrSt
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Ansi_Save_Cur_pos;
    Begin
      Saved_X := WhereX;
      Saved_Y := WhereY;
      ClrSt;
    end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Ansi_Restore_cur_pos;
    Begin
      GotoXY(Saved_X,Saved_Y);
      ClrSt;
    end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Ansi_check_Code( ch : char);
   begin
       case ch of
       '0'..'9',';' : Control_Code := Control_Code + ch;
       'H','f'    : Ansi_Cursor_Move;
       'A'        : Ansi_Cursor_up;
       'B'        : Ansi_Cursor_Down;
       'C'        : Ansi_Cursor_Right;
       'D'        : Ansi_Cursor_Left;
       'J'        : Begin
                      Clrscr;
                      ClrSt
                    end;
       'K'        : Begin
                      ClrEol;
                      ClrSt
                    end;
       'm'        : Ansi_Set_Colors;
       's'        : Ansi_Save_Cur_Pos;
       'u'        : Ansi_Restore_Cur_pos
        else ClrSt
       end {case}
   end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Display_Ansi(ch : char);
 var
  Temp0      :Integer;
 begin
 If Esc > 0 then
    begin
     case Esc of
      1 : begin
          If ch = '[' then
             begin
              Esc := 2;
              Control_Code := ''
             end
            else Esc := 0
           end;
      2 : Ansi_Check_Code(ch);
      else
          begin
           Esc := 0;
           Control_Code := ''
          end
         end {case}
    end
  else
      Case Ch of
        #0  :;
        #27 : Esc := 1;
        ^G  : begin
               Sound(2000);
               Delay(50);
               NoSound;
              end;
        ^H  : if WhereX >1 then Write(^H,' ',^H);
        #9  : begin
                Temp0:= WhereX;
                Temp0 := Temp0 div 8;
                Temp0 := Temp0 + 1;
                Temp0 := Temp0 * 8;
                Gotoxy(Temp0,WhereY)
              end;
        ^L  : ClrScr;
        ^J  : Write(^J);
        ^K  : GotoXY(1,1);
        ^M  : begin
                Write(^M);
              end;
        else
           begin
             Write(ch);
             if WhereX =1 then GotoXy(80,WhereY-1);
             Esc := 0
          end
      end {case}
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
end.
