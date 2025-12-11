 Unit Nodes;
 InterFace

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 type
   Node = Object
           ComPort    : Byte;
           Baud       : LongInt;
           Local      : Boolean;
           PortErrMsg : String;
           Procedure   Init    (ComNum : byte);
           Procedure   Done;
           Procedure   SetBps (BD: LongInt);
           Procedure   ClearRX;
           Procedure   ClearTX;
           Procedure   OpenPort;
           Procedure   ClosePort;
           Procedure   SetRts(On_Off : Boolean);
           Procedure   SetCts(On_Off : Boolean);
           Procedure   SetFlowControl(CTS, RTS : Boolean);
           Function    WaitFor(Strn : String; Timeout : Word) : Boolean;
           Function    SendAT(Cmd : String) : Boolean;
           Procedure   PickupPhone;
           Function    Hangup    : Boolean;
           Function    HangDown  : Boolean;
           Procedure   CWrite (Ch: Char);
           Function    ChWaiting : Boolean;
           Function    COnlyKey  : Char;
           Function    CReadKey  : Char;
           Function    Online    : Boolean;
           Function    Ringing   : Boolean;
          end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Implementation

 uses CommRout,Crt,Dos;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Node.Init(ComNum : byte);
 begin
   ComPort    := ComNum;
   Baud       := 0;
   Local      := (Comport=0);
   PortErrmsg := '';
   OpenPort
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Node.SetBps (BD: LongInt);
 begin
  if Not Local then
   begin
    Com_Set_Speed(BD);
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Node.SetRts(On_Off : Boolean);
 begin
  if Not Local then
   begin
    if On_Off then Com_Set_RTS
    else Com_UnSet_RTS;
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Node.SetCts(On_Off : Boolean);
 begin
  if Not Local then
   begin
    if On_Off then Com_Set_CTS
    else Com_UnSet_CTS;
   end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Node.SetFlowControl(CTS, RTS : Boolean);
 begin
  SetRts(Rts);
  SetCts(Cts);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Node.CWrite(Ch: Char);
 begin
  Com_Tx(Ch);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Node.WaitFor(Strn : String; Timeout : Word) : Boolean;
 Var
   Rcv             : String;
   Ch              : Char;
   SS, ES, X, Y, Z : Word;
   Ticker          : Integer;
   Found           : Boolean;

 Begin
  if Local then
  WaitFor :=True
  else
  begin
   WaitFor := False;
   Rcv := '';
   Found := False;
   Ticker := 0;
   for X := 1 to Length(Strn) do
    Begin
      Strn[X] := UpCase(Strn[X]);
    end;
   GetTime(X, Y, SS, Z);
   while ((Ticker <> Timeout) and (Timeout > 0)) and (not Found) do
    Begin
       if KeyPressed then
        begin
         if Readkey =#27 then
          begin
           Ticker :=TimeOut;
           Found:=False
          end
     end;
      IF ChWaiting then
        begin
         Ch := UpCase(Com_RxW);
         if (Length(Rcv) = Length(Strn)) then
         Begin
          Rcv := Copy(Rcv, 2, Length(Rcv) - 1);
         end;
         Rcv := Rcv + Ch;
         if (Pos(Strn, Rcv) > 0) then
          Begin
            Found := True
          end
        end;
       ES := SS;
      GetTime(X, Y, SS, Z);
      if (ES <> SS) then Ticker:=ticker+1
    end;
   WaitFor := Found
  end
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Node.SendAT(Cmd : String) : Boolean;
 Begin
    If ComPort < 1 then
     begin
      SendAt :=False;
     end
    else
     begin
      Com_Lower_DTR;
      Delay(900);
      Com_Raise_DTR;
      Delay(500);
      Com_Tx_Stringln('+++');
      Delay(900);
      Com_Tx_Stringln(Cmd);
      SendAT := WaitFor('OK', 5)
     end;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Node.PickupPhone;
 Begin
   Com_Tx_Stringln('+++');
   Delay(900);
   Com_Tx_Stringln('ATA');
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Node.Hangup : Boolean;
 Var
   TCount : Integer;
 Begin
   TCount := 0;
   Hangup := False;
   if Online then
    Begin
      Com_Lower_Dtr;
      Delay(1000);
      Com_Raise_Dtr;
      if OnLine then
       Begin
         ClearTX;
         ClearRX;
        repeat
         Com_Raise_Dtr;
         Tcount :=Tcount+1;
         Delay(1000);
         Com_Tx_StringLn('+++');
         Delay(1000);
         Com_Tx_StringLn('ATH0');
         Delay(500);
         Until (Not Com_Carrier) or (TCount >3) or (Local)
       end
    end;
   Hangup := not Com_Carrier
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Node.HangDown : Boolean;
 Begin
   HangDown := False;
   Com_Lower_Dtr;
   Delay(500);
   Com_Raise_Dtr;
   ClearTX;
   ClearRX;
   Com_Raise_Dtr;
   Delay(800);
   Com_Tx_StringLn('+++');
   Delay(1000);
   Com_Tx_StringLn('ATH1');
   Delay(500);
   HangDown := Waitfor('OK',5);
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Node.Ringing   : Boolean;
 begin
  Ringing :=Com_Ringing;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Node.ChWaiting : Boolean;
 begin
   ChWaiting := AChWaiting and Not Local;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Node.CReadKey : Char;
 begin
  if (Keypressed) then CReadKey := ReadKey
  else
  if AChWaiting and Not Local then CReadKey := Com_RxW
  else CReadKey := #0;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Function Node.COnlyKey : Char;
 begin
   COnlyKey := Com_Rx
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Node.Online : Boolean;
 Begin
   if Local then Online:=true
   else Online := Com_Carrier;
 end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Node.ClearRX;
 var
  Ch : Char;
  begin
   if Not Local then
    begin
      Com_Flush_Rx;
    end;
    While KeyPressed do Ch:=Readkey;
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Node.ClearTX;
  begin
   if Not Local then
    begin
      Com_Flush_Tx;
    end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Node.ClosePort;
  begin
   if Not Local then
    begin
     Com_Flush_Rx;
     Com_Flush_Tx;
     Com_DeInstall;
    end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Node.OpenPort;
 var
   PortError : Word;
  begin
   if Not Local then
    begin
     Com_Install(ComPort,PortError);
     if PortError >0 then
       begin
        Local := True;
        ComPort :=0;
        PortErrMsg:= ' Unable to Open Port...'
       end
     else
     begin
      Com_set_parity (com_None, 1);
      Com_Raise_Dtr;
      Com_Flush_Rx;
      Com_Flush_Tx;
     end
    end
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Procedure Node.Done;
  begin
   if Not Local then
    begin
     ClosePort
    end;
   TextColor(7);
   TextBackGround(0);
   ClrScr
  end;
end.