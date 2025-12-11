 Unit XQMess;
 Interface
 Uses crt,DOS,BBSGam,BBSScrn;

 Procedure DoMess(var XXX: TBBS; Vrs : String; PN,PA : NameString);
 Implementation

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure DoMess(var XXX: TBBS; Vrs : String; PN,PA : NameString);
 const bb =1;
  var
   NumberOfMessages,
   I,M,code         : Integer;
   Messagfil        : Text;
   Msglog           : Text;
   USERNAME         : NAMESTRING;
   FromNAME         : NAMESTRING;
   MessNum          : ARRAY[1..2000] of word;
   messAll          : ARRAY[1..2000] of Byte;
   TmpStr           : String;
   TmpStr1          : String;
   InChar           : Char;
   Cmd,FromWho      : String;
   READIT           : Boolean;
   Killed           : Boolean;
   Finish           : Boolean;
   NextMessage      : Boolean;
   ContinueNext     : Boolean;
   IntChrSet        : CharSet;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure EnterMessage(Reply: boolean; ReplyName : String);
 Const
  MaxLines =23;
  PromptLine = 6;
  PPromptLine =7;


 var
  K,InChar, Ychar : Char;
  XU,YU,I         : integer;
  YHIT            : boolean;
  SubjStr         : string;
  SerStr          : string;
  ToSTR,WW2       : String;
  ToNStr          : NameString;
  Num             : word;
  InsertOn        : Boolean;
  TmpStr          : String;
  Ulist           : Text;
  Quit            : boolean;
  DoingSearch     : boolean;
  Receiver        : String[25];
  FastExit        : Boolean;
  Abort           : Boolean;
  ClearPrompt     : Boolean;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure SaveMessage(Var NumMessages: word; ToWhom : NAMESTRING );
  var
   Messagfil  : text;
   MsglogIn   : text;
   I,J        : integer;
   StrLine    : String;
   USERNAME   : NAMESTRING;
   MesNum     : integer;
   BlankLine  : Boolean;
   BlineCount : Integer;

  begin
   While Length(ToWhom)<25 do ToWhom:=ToWhom+' ';
    begin
     if Not Exist('Message.Num') then
      begin
        Assign(Messagfil,'Message.Num');
        Rewrite(Messagfil);
        Writeln(Messagfil,1);
        NumMessages :=1;
        Close(Messagfil)
      end
      else
       begin
        Assign(Messagfil,'Message.Num');
        reset(Messagfil);
        readln(Messagfil,NumMessages);
        NumMessages :=NumMessages+1;
        Rewrite(Messagfil);
        Writeln(Messagfil,NumMessages);
        close(Messagfil);
       end;

     if Not Exist('User.Msg') then
      begin
       Assign(MsglogIn,'User.Msg');
       ReWrite(MsgLogIn);
       Close(MsgLogIn)
      end;
     Assign(MsglogIn,'User.Msg');
     APPEND(MsgLogIn);
     if IoResult<>0 then
     begin
      Rewrite(MsgLogIn);
      writeln(MsglogIn,ToWhom,' ',NumMessages,' ',PA);
      Close(MsgLogIn);
     end
   else
  begin
   writeln(MsglogIn,ToWhom,' ',NumMessages,' ',PA);
   close(MsgLogIn);
  end;
     if Not Exist('Message.fil') then
      begin
       Assign(Messagfil,'Message.fil');
       Rewrite(Messagfil);
       Close(Messagfil);
      end;
     Assign(Messagfil,'Message.fil');
     Append(Messagfil);
     if IoResult<>0 then Rewrite(Messagfil);
     writeln(MessagFil,'Message Number ',NumMessages,'           ',Time,' ',Date);
     for I:= 2 to 4 do
      begin
       GetScreenStr(1,42,I,StrLine);
       Writeln(Messagfil,StrLine);
      end;
     Writeln(Messagfil);
     BLineCount:=0;
     for I:= 7 to 23 do
      begin
       GetScreenStr(1,79,I,StrLine);
       J:=0;
       BlankLine :=True;
       While (J<79) and Blankline do
        begin
         J:=J+1;
         Blankline := StrLine[J] =' '
        end;
         if Not BlankLine then
            begin
             While BlineCount>0 do
              begin
               Writeln(Messagfil);
               BlineCount:=BlineCount-1;
              end;
             Writeln(Messagfil,StrLine)
            end
          else
           BLineCount:=BLineCount+1
      end;
      Writeln(Messagfil,'EOMซฌ');
     close(Messagfil)
    end
   {I+}
  end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

 begin
 With XXX do
 begin
  Window(1,1,80,25);
  InsertOn := True;
  FastExit:=False;
  Abort := False;
  begin
   if Reply then
    begin
     SubjStr :=' Reply ';
     ToStr:= ReplyName;
    end
      else
      begin
       SubjStr:='';
       ToStr:='<ALL>';
     end;
   repeat
    emu_color(15,0);
    emu_clearscreen;
    emu_color(10,0);
    ComWriteln(' Entering a Message ');
    emu_color(15,0);
    ComWriteln(' From     : '+PA);
    ComWrite(' To       : ');
    ComWriteln(ToStr);
    ComWrite(' Subject  : ');
    ComWriteln(SubjStr);
    emu_color(13,0);
    ComWriteln('ออออออออออออออออออออออออออออออออออออออออออ'+
               'อออออออออออออออออออออออออออออออออออออ');
   emu_color(15,0);
   emu_gotoxy(2,PromptLine);
   ComWrite(' Change AnyThing ? ');
   GETYN(YHIT);
   If YHIT then
    begin
     Emu_GotoXy(2,PromptLine);
     ComWrite(' Change ...  [T].TO    [S].Subject    [Q].Quit ?> ');
     GetChar(Inchar,['S','Q','T']);
     Emu_GotoXy(1,PromptLine);
     Emu_ClearToEndOfLine;
      CASE InChar of
      'Q' : Yhit :=true;
      'S' : begin
             Emu_GotoXy(2,PromptLine);
             GetString(SubjStr,' Enter Subject : ', false)
            end;
      'T' : begin
             Emu_GotoXy(1,PromptLine);
             GetString(ToStr,#13+' Send Message TO : ',false);
              if ToStr<> '<ALL>' then
              begin
               ToNStr:=ToStr;
               FormatName(ToNStr);
               Emu_GotoXy(1,PPromptLine);
               Emu_ClearToEndOfLine;
              end
            end;
      end;{case}
    end;
  until Not Yhit or GoOffLine or Not Online;
   emu_color(14,0);
   Emu_gotoxy(1,PromptLine);
   Emu_ClearToEndOfLine;
   Emu_gotoxy(1,PPromptLine);
   Emu_ClearToEndOfLine;
   Emu_gotoxy(1,PromptLine);
   emu_color(10,0);
   ComWrite(' Enter Your Message Now.....  ');
   emu_gotoxy(60,1);
   emu_color(7,0);
   ComWrite('Cntrl-Y Insert Mode');
   emu_gotoxy(60,2);
   emu_color(12,0);
   ComWrite('Cntrl-X ...... Quit');
   emu_gotoxy(60,3);
   emu_color(14,0);
   ComWrite('Cntrl-Z ...... Save');
   emu_gotoxy(60,4);
   emu_color(11,0);
   ComWrite('<Esc>   ...... Stop');
   FastExit :=false;
   ClearPrompt :=true;
   XU:=1;
   YU:=7;
   emu_color(11,0);
   emu_gotoxy(XU,YU);
  repeat
   CheckTimeLeft;
   if Online and Not GoOffLine then
   begin
    repeat
     if InComing then
      begin
       if ClearPrompt then
        begin
         Emu_gotoxy(1,PromptLine);
         Emu_ClearToEndOfLine;
         ClearPrompt :=false;
         Emu_gotoxy(1,PPromptLine);
       end;
       Ychar:=CReadKEY;

       case Ychar of
       #26  : begin
               Ychar :=#27;
               FastExit :=true
              end;
       #24  : begin
               Ychar :=#27;
               Abort :=true;
               FastExit :=true
              end;
        #25  : Begin
               InsertOn :=Not InsertOn;
               emu_gotoxy(60,1);
               emu_color(0,7);
               if InsertON then ComWrite('    Insert ON     ') else
               ComWrite('    Insert OFF     ');
               emu_color(11,0);
               Emu_gotoxy(XU,YU);
              End;
       #127 : begin
               WW2 :='';
               Emu_DeleteChar;
              end;
     #27, #0 : begin
                if Chwaiting or Local then Ychar:=CReadKEY;
                delay(15);
                while YChar = #0 do Ychar:= CReadkey;
                while YChar = '[' do Ychar:= CReadkey;
                delay(15);
                while Chwaiting and Not Local do Ychar:=CReadkey;
               case Ychar of
        'R',' ': Begin
                  InsertOn :=Not InsertOn;
                  emu_gotoxy(60,1);
                  emu_color(0,7);
                  if InsertON then ComWrite('   Insert ON    ') else
                  ComWrite('   Insert OFF    ');
                  emu_color(14,0);
                  Emu_gotoxy(XU,YU);
                 End;
            'S': begin
                  WW2:='';
                  Emu_DeleteChar; {Local delete Key}
                 end;
            'H': begin {Home}
                  WW2:='';
                  if Local then
                  begin
                   Ychar:=#0;
                   if YU>7 then
                    begin
                     Ychar:=#0;
                     EMU_CURSORUp;
                     YU:=YU-1
                    end
                  end
                  else
                  begin
                   Ychar:=#0;
                   XU:=1;
                   emu_gotoxy(XU,YU)
                  end;
                 end;
            'G': begin {Home Local}
                   WW2:='';
                   Ychar:=#0;
                   XU:=1;
                   emu_gotoxy(XU,YU)
                 end;
            'K': begin {End}
                  WW2:='';
                  if Local then
                  begin
                   Ychar:=#0;
                   if XU>1 then
                    begin
                     Ychar:=#0;
                     EMU_CURSORleft;
                     XU:=XU-1
                    end
                  end
                  else
                  begin
                   Ychar:=#0;
                   XU:=79;
                   GetScreenStr(1,79,YU,TmpStr);
                   while (XU >2) and (TmpStr[XU-1] =' ') do XU:=XU-1;
                   emu_gotoxy(XU,YU)
                  end
                 end;
            'O': begin {End Local}
                   WW2:='';
                   Ychar:=#0;
                   XU:=79;
                   GetScreenStr(1,79,YU,TmpStr);
                   while (XU >2) and (TmpStr[XU-1] =' ') do XU:=XU-1;
                   emu_gotoxy(XU,YU)
                 end;
        'M','C': begin {arrow right}
                  WW2:='';
                  Ychar:=#0;
                  if XU<78 then
                  begin
                   EMU_CURSORRIGHT;
                   XU:=XU+1
                  end
                end;
           'D': begin {Left}
                 WW2:='';
                 Ychar:=#0;
                 if XU>1 then
                  begin
                   Ychar:=#0;
                   EMU_CURSORleft;
                   XU:=XU-1
                  end
                end;
       'P','B': begin  {Down}
                 WW2:='';
                 Ychar:=#0;
                 if YU<MaxLines then
                  begin
                   Ychar:=#0;
                   EMU_CURSORDown;
                   YU:=YU+1
                  end
                end;
           'A': begin  {Up}
                 WW2:='';
                 Ychar:=#0;
                 if YU>7 then
                 begin
                  Ychar:=#0;
                  EMU_CURSORUp;
                  YU:=YU-1
                 end
               end
            end { case extended key }
           end;
         #27: ;
         #9: begin
              WW2:='';
              Ychar:=#0;
              for I:=1 to 8 do
              if wherex< 79 then Emu_Cursorright;
              XU:=WhereX;
              YU:=whereY;
             end;
       #15 : begin
              WW2:='';
              Ychar:=#0;
              for I:=1 to 8 do if wherex >1 then Emu_Cursorleft;
              XU:=WhereX;
              YU:=whereY;
             end;
       #8  : begin
              if (wherex=1) AND (WHEREY> PPromptLine) then emu_cursorup
              else if WhereY>PromptLine then
              begin
               ComWrite(#8+' '+#8);
               if length(WW2) >0 then delete(WW2,Length(WW2),1);
              end;
              XU:=WhereX;
              YU:=whereY
             end;
      #32: begin
            WW2:='';
            If InsertOn then EMU_InsertChar(' ')
            else ComWrite(' ');
           end;
 #33..#126: begin
            if (length(WW2) > 0 ) and (XU >=78) then
             begin
              for I:= 1 to length(WW2) do
               ComWrite(#8+' '+#8);
               ComWriteln('');
               XU:=1;
               YU:=whereY;
               if Yu>MaxLines then  Emu_CursorUp;
               YU:=whereY;
               Emu_gotoXy(XU,YU);
               ComWrite(WW2);
               XU:=WhereX;
               YU:=whereY;
               WW2:=''
             end;
            Emu_gotoXy(XU,YU);
            If InsertOn then EMU_InsertChar(YChar)
            else ComWrite(Ychar);
            WW2:=WW2+YChar;
            if length(WW2)> 15 then WW2:='';
           end;
      #13  : begin
               WW2:='';
               if (YU<MaxLines) then ComWriteln('')
                else
                begin
                 XU:=1;
                 emu_gotoxy(XU,YU)
                end
             end
        end; {case}
      if (Ychar<>#27 ) and (YChar<>#0) and (YChar<>#127) then
      XU:=WhereX;
      YU:=whereY;
      if Yu> MaxLines then Yu:=MaxLines
     end;
    until (Ychar=#27) or Not Online or GoOffline;
  end;
  if Not FastExit then
  begin
   XU:=wherex;
   YU:=wherey;
   emu_gotoxy(1,PromptLine);
   Emu_ClearToEndOfLine;
   emu_gotoxy(1,PromptLine);
   Emu_Color(14,0);
   ComWrite(' Change AnyThing ? ');
   GETYN(YHIT);
   YChar:=#0;
   emu_gotoxy(1,PromptLine);
   Emu_ClearToEndOfLine;
   if YHIT then
   begin
    Emu_Color(11,0);
    emu_GotoXY(XU,YU)
   end
  end;
  until not YHIT or not Online or GoOffLine or FastExit;
  if Not FastExit then
  begin
   ComWriteln('');
   emu_gotoxy(1,PromptLine);
   emu_color(13,0);
   ComWrite(' [');
   emu_color(15,0);
   ComWrite('S');
   emu_color(13,0);
   ComWrite(']');
   emu_color(15,0);
   ComWrite(' Save');
   emu_color(13,0);
   ComWrite('       [');
   emu_color(12,0);
   ComWrite('Q');
   emu_color(13,0);
   ComWrite(']');
   emu_color(12,0);
   ComWrite(' Quit/Don''t Save.');
   emu_color(15,0);
   ComWrite('  ?> ');
   GetChar(Inchar,['Q','S',#24,#26]);
   if Not Hotkeys then  ComWriteln('')
  end;
   if (Inchar in ['S',#26]) or FastExit then
   if not Abort then
   begin
     emu_gotoxy(1,PromptLine);
     Emu_ClearToEndOfLine;
     emu_gotoxy(1,PromptLine);
     Emu_color(14,0);
     ComWrite('Saved Message # ');
     Emu_color(15,0);
     SaveMessage(Num,ToStr);
     str(Num , ToStr);
     ComWrite(ToStr);
     delay(1500)
   end
   end
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure ReadMessage(I:integer; var Isread:boolean;
                             var Fwho : string);
 var
   Messagfil   : text;
   MessNum     : integer;
   DumString   : String[14];
   DString     : String[12];
   StrLine     : String[80];
   TmpStr      : String;
   EOM         : boolean;

 begin
  With XXX do
  begin
   Emu_Color(15,0);
   ComWriteln('');
   IsRead :=false;
   Assign(Messagfil,'Message.fil');
   {$I-}
   Reset(Messagfil);
   if IoResult<>0 then Rewrite(Messagfil)
   {$I+}
   else
   begin
    StrLine:='';
    while Not Eof(Messagfil) and Online and Not IsRead do
    begin
     Readln(MessagFil,DumString,MessNum,StrLine);
     EOM :=false;
     If MessNum=I then
      begin
       Str(MessNum,TmpStr);
       if MessNum=I then
       begin
        ComWriteln(DumString+' '+TmpStr+StrLine);
        Readln(MessagFil,DString,StrLine);
        FWho := Copy(Strline,1,30);
        ComWriteln(DString+StrLine);
        Readln(MessagFil,DString,StrLine);
        ComWriteln(DString+StrLine);
       end;
       while Not Eof(Messagfil) and Online and Not IsRead do
        begin
          Readln(MessagFil,StrLine);
          If copy(StrLine,1,5)='EOMซฌ' then IsRead :=True
          else
          if Not IsRead then ComWriteln(StrLine)
        end
      end
      else
       begin
        while Not Eof(Messagfil) and Online and Not IsRead and Not EOM do
         begin
          Readln(MessagFil,StrLine);
          If copy(StrLine,1,5)='EOMซฌ' then EOM :=True;
         end
       end
   end
  end
  end;
   close(Messagfil)
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 procedure KillMessage( I : integer; var IsKilled : boolean);
 var
   Messagfil,
   MessagNUMfil,
   TMessfil       : text;
   UMfile,TUMfile : text;
   MessNum        : integer;
   DumString      : String[15];
   StrLine        : String[80];
   TmpStr         : String;
   ToWhom,FromWhom: NameString;
   EOM            : boolean;
   DumChar        : char;

 begin
 {$I-}
   {ComWriteln('');}
   Assign(Messagfil,'Message.fil');
   Assign(TMessfil,'Message1.fil');
   Reset(Messagfil);
   if IoResult<>0 then
    begin
     Rewrite(Messagfil);
     Reset(Messagfil)
    end;
   Rewrite(TMessfil);
   StrLine:='';
   IsKilled := false;
   EOM      := false;
   while Not Eof(Messagfil) do
    begin
     Readln(MessagFil,DumString,MessNum,StrLine);
     EOM :=false;
     If (MessNum=I) and not IsKilled then
      begin
       while not EOM and Not Eof(Messagfil) do
        begin
          Readln(MessagFil,StrLine);
          If copy(StrLine,1,5)='EOMซฌ' then
          begin
           EOM :=true;
           IsKilled :=True
          end
        end
      end
      else
       begin
        if IsKilled then MessNum := MessNum -1;
        Writeln(TMessFil,DumString,MessNum,StrLine);
        while Not EOM do
         begin
          Readln(MessagFil,StrLine);
          Writeln(TMessFil,StrLine);
          If copy(StrLine,1,5)='EOMซฌ' then EOM :=True
         end
       end
    end;
   close(TMessfil);  { TmessFil now has the new messages }
   close(Messagfil); { old message file }
   erase(Messagfil);
   rename(Tmessfil,'Message.fil');

   if IsKilled then
    begin
     Assign(MessagNUMfil,'Message.Num');
     reset(MessagNUMfil);
     if IoResult<>0 then Rewrite(MessagNUMfil)
     else
      if not eof(MessagNUMfil) then
      begin
       readln(MessagNUMfil,MessNum);
       MessNum :=MessNum-1;
       Rewrite(MessagNUMfil);
       Writeln(MessagNUMfil,MessNum);
       close(MessagNUMfil)
      end;

      Assign(TUMfile,'User1.Msg');
      ReWrite(TUMfile);
      Assign(UMfile,'User.Msg');
      reset(UMfile);
     if IoResult<>0 then
      begin
       Rewrite(UMfile);
      end
     else
      begin
       EOM :=false;
       while not eof(UMfile) do
       begin
        Readln(UMfile,ToWhom,MessNum,Dumchar,FromWhom);
        if MessNum = I then
        begin
          EOM :=true;
        end
        else
         begin
          if EOM then MessNum := MessNum - 1;
          Writeln(TUMfile,ToWhom,' ',MessNum,' ',FromWhom);
         end
       end
      end;
     close(UMfile);
     close(TUMfile);
     erase(UMfile);
     Rename(TUMfile,'USER.MSG')
    end;
  IsKilled :=IsKilled and EOM
 {$I+}
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 begin
 With XXX do
  begin
   Hotkeys:=true;
   IntChrSet:=['R','E','Q'];
   SetIntchar(IntChrSet);
   FINISH :=FALSE;
   Inchar:=#0;
   ContinueNext :=false;
  while NOT finish and Online and not GoOffLine do
  begin
   NumberOfMessages :=0;
   if Not Exist('User.Msg') then
    begin
     Assign(MsgLog,'User.Msg');
     Rewrite(MsgLog);
     Close(MsgLog);
    end;
   Assign(MsgLog,'User.Msg');
   reset(MsgLog);
   while Not Eof(MsgLog) and (NumberOfMessages<2000) do
    begin
     Readln(MsgLog,USERNAME,MessNum[NumberOfMessages+1],FromName);
     NumberOfMessages:=NumberOfMessages+1;
     MessAll[NumberOfMessages] :=3;
    end;
   Close(MsgLog);

    InChar:=#0;
    Emu_color(15,0);
    emu_clearscreen;
    ComWriteln('');
    ComWriteln('   XENO-QUEST Version'+Vrs);
    ComWriteln('');
    TimePrompt;
    Str(NumberOfMessages,TmpStr);
    ComWriteln('');
    Emu_color(10,0);
    if NumberOfMessages =1 then
    ComWrite(' There is '+TmpStr+ ' Message To Read..')
    else
    ComWrite(' There are '+TmpStr+ ' Messages To Read..');
    Emu_color(10,0);
    ComWriteln('');
    TMenuWrite(bb,2,15,'     Message  Menu        ');
    MenuWrite(bb,5,14,'Read Message       ',InChar);
    MenuWrite(bb,3,14,'Enter Message      ',InChar);
    MenuWrite(bb,4,14,'Quit to Main Menu  ',InChar);
    ComWriteln('');
    Emu_color(15,0);
    Showmsr;
    ComWrite(' Your Choice is.. ');
    if InChar =#0 then GetChar(Inchar,IntChrSet);
    ComWriteln('');
    clearreceive;
    cleartransmit;
    Emu_color(15,0);
    if ReqChat Then Chat
    else
    begin
      If Online and Not GoOffLine and Not Finish then
       begin
        Case InChar of
         'R' : begin{6}
               Emu_Color(15,0);
               if NumberOfMessages >0 then
               begin{5}
                ComWriteln('');
                ComWrite(' Read Which Message # or [L] List  # ');
                ReadlnX(CMD,5);
                iF (UPcase(Cmd[1]) ='L') or (Cmd='') then
                  begin
                   ComWriteln('');
                   ComWrite(' Messages That You Have...');
                   ComWriteln('');
                   for I:=1 to NumberOfMessages do
                    begin
                     Str(MessNum[I],TmpStr);
                     Emu_Color(15,0);
                     ComWrite(' Message # ');
                     if MessAll[I]=3 then
                      begin
                       Emu_Color(14,0);
                       ComWrite(TmpStr+' ... ');
                       ComWriteln(' <ALL>.....')
                      end
                    end;
                   Emu_Color(15,0);
                   ComWrite(' Read Which Message # ');
                   ReadlnX(CMD,5);
                 end;

                 VAL(CMD,M,code);
                 if code <> 0 then
                  begin
                   ComWriteO(#7);
                   ComWriteln('');
                   ComWriteln(' Message Not Found ');
                   GetCr(15);
                  end
                  else
                  begin {4}
                   I:=1;
                   while (I<=NumberOfMessages) and (M<>MessNum[I]) do
                   I:=I+1;
                   if I>NumberOfMessages then
                    begin
                     ComWriteln('');
                     ComWriteln(' Message Not Found ');
                     GetCr(15);
                    end
                   else
                   begin{3}
                    ContinueNext :=True;
                    while ContinueNext and Online and Not GoOffline do
                    begin{2}
                     emu_color(14,0);
                     emu_clearscreen;
                     Emu_Color(10,0);
                     ReadMessage(M,READIT,FromWho);
                     ContinueNext :=False;
                     ComWriteln('');
                     Emu_Color(15,0);
                     if ReadIt then
                      begin{1}
                       Emu_color(11,0);
                       ComWrite(' [R] Reply.   ');
                       Emu_color(14,0);
                       ComWrite('[N] Next Msg.   ');
                       if  (Messall[I] < 3) or (Pos(Brec.SysopName,PN) >0) then
                        begin
                          Emu_color(13,0);
                          ComWrite('[D] Delete Msg.   ');
                          Emu_color(10,0);
                          ComWrite('[K] Kill/Reply.   ');
                        end;
                       Emu_color(12,0);
                       ComWrite('[Q] Quit  ');
                       Emu_color(15,0);
                       Inchar :=#0;
                       if  (Messall[I] < 3) or (Pos(BRec.SysopName,PN) >0) then
                        GetChar(Inchar,['R','K','D','Q','N'])
                       else
                        GetChar(Inchar,['R','Q','N']);
                        ComWriteln('');
                        Case Inchar of
                        'Q' : Inchar:=#0;
                        'N' : begin
                               if (NumberOfMessages >1) or
                               (MessNum[NumberOfMessages] > M) then
                                begin
                                 I:=1;
                                 while (I<NumberOfMessages) and
                                     Not ContinueNext do
                                  begin
                                   I:=I+1;
                                   ContinueNext :=( MessNum[I] > M);
                                  end;
                                 if Not ContinueNext then
                                  begin
                                   ComWriteln(' End Of Messages..');
                                   GetCr(15)
                                  end
                                 else M:=MessNum[I]
                                end
                               else
                                begin
                                 ComWriteln(' End Of Messages..');
                                 GetCr(15)
                                end
                             end;
                       'D' : if  (Messall[I] < 3) or (Pos(BRec.SysopName,PN) >0) then
                             begin
                              ComWriteln(' Deleting....');
                              ComWriteln('');
                              KillMessage( M, Killed );
                              Str(M,TmpStr);
                              if Killed then
                               begin
                                ComWriteln(' Message #'+TmpStr+ ' Killed..');
                                delay(500)
                               end
                               else
                                begin
                                 ComWriteln(' Unable to Kill Message #'+TmpStr+'..');
                                 delay(500)
                                end
                             end;
                       'R' : begin
                              EnterMessage(true,FromWho)
                             end;
                       'K' : if  (Messall[I] < 3) or (Pos(BRec.SysopName,PN) >0) then
                             begin
                              ComWriteln(' Deleting....');
                              ComWriteln('');
                              KillMessage( M, Killed );
                              Str(M,TmpStr);
                              if Killed then
                               begin
                                ComWriteln(' Message #'+TmpStr+ ' Killed..');
                                delay(500)
                               end
                               else
                                begin
                                 ComWriteln(' Unable to Kill Message #'+TmpStr+'..');
                                 delay(500)
                                end;
                              EnterMessage(true,FromWho)
                             end
                        end {case}
                      end{1}
                    end{2}{While}
                   end{3}
                  end{4}
                 end{5}
                else
                begin
                  Emu_Color(15,0);
                  ComWriteln('');
                  ComWrite(' There are No Messages....');
                  GetCr(15);
                  InChar:=#0
                end
               end;
         'E' : EnterMessage(false,'');
      #27,'Q' : FINISH:=TRUE;
        end {case}
       end
     end
   end
  end
  {I+}
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
end.