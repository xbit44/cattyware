 Unit CommRout;
 Interface
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Type
   Com_parity = (Com_none, Com_even, Com_odd, Com_zero, Com_one);

 Function  Com_Ringing : Boolean;
 Function  Com_carrier : Boolean;
 Function  Com_RX      : Char;
 Function  Com_RXW     : Char;
 Function  Com_TX_ready: Boolean;
 Function  Com_TX_empty: Boolean;
 Function  Com_RX_empty: Boolean;
 Function  AChWaiting  : Boolean;
 Procedure Com_flush_RX;
 Procedure Com_flush_TX;
 Procedure Com_TX         (ch: Char);
 Procedure Com_TX_String  (st: String);
 Procedure Com_TX_Stringln(st: String);
 Procedure Com_lower_dtr;
 Procedure Com_raise_dtr;
 Procedure Com_UnSet_RTS;
 Procedure Com_Set_RTS;
 Procedure Com_UnSet_CTS;
 Procedure Com_Set_CTS;
 Procedure Com_Set_Speed (speed: Word);
 Function  Com_Get_Speed: LongInt;
 Procedure Com_Set_parity (parity: Com_parity; stop_bits: Byte);
 Procedure Com_install( Portnum  : Word; var error: Word );
 Procedure Com_deinstall;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
 Implementation
 Uses Dos;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{Maximum Portnumber (minimum is 1) }

Const
  max_Port= 4;                 {Base i/o address for each Com Port}
  TX_queue_size = 16;
  RX_queue_size = 128;
  Uart_base     : ARRAY [1..max_Port] OF Integer = ($3F8, $2F8, $3E8, $2E8);
  IntNums       : ARRAY [1..max_Port] OF Byte = ($0C, $0B, $0C, $0B);
  I8259levels   : ARRAY [1..max_Port] OF Byte = (4, 3, 4, 3);
  Com_installed : Boolean = False;
  Use_CTS       : Boolean = False;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

var
  Uart_data: Word;             {Data register}
  Uart_ier : Word;             {Interrupt Enable register}
  Uart_iir : Word;             {Interrupt identification register}
  Uart_lcr : Word;             {Line control register}
  Uart_mcr : Word;             {Modem control register}
  Uart_lsr : Word;             {Line status register}
  Uart_msr : Word;             {Modem status register}
  Uart_spr : Word;             {Scratch pad register}
  old_ier  : Byte;
  old_mcr  : Byte;
  old_vector    : Pointer;
  old_I8259_mask: Byte;
  I8259bit      : Byte;
  intnum        : Byte;
  RX_queue: ARRAY [1..RX_queue_size] OF Byte;
  RX_in   : Word;        {Index of where to store next character}
  RX_out  : Word;        {Index of where to retrieve next character}
  RX_chars: Word;        {Number of chars in queue}
  TX_queue: ARRAY [1..TX_queue_size] OF Byte;
  TX_in   : Integer;     {Index of where to store next character}
  TX_out  : Integer;     {Index of where to retrieve next character}
  TX_chars: integer;     {Number of chars in queue}
  Exit_save: Pointer;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Disable_interrupts;
INLINE ( $FA {CLI} );
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Enable_interrupts;
INLINE ( $FB {STI} );
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{$F+$R-,S-}
Procedure Com_interrupt_driver; INTERRUPT;
var
  ch   : Char;
  iir  : Byte;
  dummy: Byte;

begin
 iir := Port[Uart_iir];
 While NOT Odd (iir) DO
  begin
   Case iir SHR 1 OF
    0: dummy := Port[Uart_msr];

    1: if (TX_chars <= 0) then Port[Uart_ier] := Port[Uart_ier] and NOT 2
       else
       if Odd (Port[Uart_lsr] SHR 5) then
        begin
         Port[Uart_data] := TX_queue [TX_out];
         TX_out := TX_out +1;
         if TX_out > TX_queue_size then TX_out := 1;
         TX_chars := TX_chars -1
        end;

    2: begin
        ch := Char (Port[Uart_data] );
        if (RX_chars <= RX_queue_size) then
         begin
          RX_queue[RX_in] := Ord (ch);
          RX_in := RX_in +1;
          if RX_in > RX_queue_size then RX_in := 1;
          RX_chars := Succ(RX_chars)
         end
       end;

    3: dummy := Port[Uart_lsr]
   end; {case}
    iir := Port[Uart_iir]
    end;
  Port[$20] := $20
end;
{$F-$R+,S+}

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_flush_RX;
begin
  Disable_interrupts;
  RX_chars := 0;
  RX_in    := 1;
  RX_out   := 1;
  Enable_interrupts
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_flush_TX;
begin
  Disable_interrupts;
  TX_chars := 0;
  TX_in    := 1;
  TX_out   := 1;
  Enable_interrupts
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Com_carrier: Boolean;
begin
  Com_carrier := Com_installed and Odd (Port[Uart_msr] SHR 7)
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Com_Ringing: Boolean;
begin
  Com_Ringing := Com_installed and ((Port[Uart_msr] and $40)>0)
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function ClearToSend: Boolean;
begin
  CLearToSend := Com_installed and ((Port[Uart_msr] and $10)>0)
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Com_RX: char;
begin
  if NOT Com_installed OR (RX_chars = 0) then Com_RX := #0
  else
    begin
     Disable_interrupts;
     Com_RX := Chr (RX_queue [RX_out] );
     RX_out := RX_out +1;
     if RX_out > RX_queue_size then  RX_out := 1;
     RX_chars := RX_chars -1;
     Enable_interrupts
    end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Com_RXW: char;
begin
  if NOT Com_installed then Com_RXW := #0
  else
    begin
     Repeat Until (RX_chars >0);
     Disable_interrupts;
     Com_RXW := Chr (RX_queue [RX_out] );
     RX_out := RX_out +1;
     if RX_out > RX_queue_size then RX_out := 1;
     RX_chars := RX_chars -1;
     Enable_interrupts
    end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Com_TX_ready: Boolean;
begin
  Com_TX_ready := ((TX_chars < TX_queue_size) OR NOT Com_installed)
                  and (Not Use_CTS or( Use_CTS and ClearToSend))
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Com_TX_empty: Boolean;
begin
  Com_TX_empty := (TX_chars = 0) OR NOT Com_installed
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Com_RX_empty: Boolean;
begin
  Com_RX_empty := (RX_chars = 0) OR NOT Com_installed
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function AChWaiting: Boolean;
begin
 AChWaiting := (RX_Chars >0)
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_TX (ch: Char);
begin
  if Com_installed then
    begin
    REPEAT UNTIL Com_TX_ready;
    Disable_interrupts;
    TX_queue [TX_in] := Ord (ch);
    if TX_in < TX_queue_size then
    TX_in :=TX_in +1
    else
      TX_in := 1;
    TX_chars := TX_chars +1;
    Port[Uart_ier] := Port[Uart_ier] OR 2;
    Enable_interrupts
    end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_TX_String (st: String);
var
  I: Byte;
begin
  FOR i := 1 TO Length (st) DO Com_TX (st [i] )
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_TX_Stringln (st: String);
var
  I: Byte;
begin
  St:=St+#13+#10;
  FOR i := 1 TO Length (st) DO Com_TX (st [i] )
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_lower_dtr;
begin
  if Com_installed then
   begin
    Disable_interrupts;
    Port[Uart_mcr] := Port[Uart_mcr] and NOT 1;
    Enable_interrupts
   end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

Procedure Com_raise_dtr;
begin
  if Com_installed then
   begin
    Disable_interrupts;
    Port[Uart_mcr] := Port[Uart_mcr] OR 1;
    Enable_interrupts
   end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_Set_RTS;
begin
 if Com_installed then
   begin
    Disable_interrupts;
    Port[Uart_mcr] := Port[Uart_mcr] OR 2;
    Enable_interrupts
   end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_UnSet_RTS;
begin
 if Com_installed then
   begin
    Disable_interrupts;
    Port[Uart_mcr] := Port[Uart_mcr] and $FD;
    Enable_interrupts
   end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_Set_CTS;
begin
  if Com_installed then
    begin
     Use_CTS := true
    end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_UnSet_CTS;
begin
  if Com_installed then
    begin
     Use_CTS :=false
    end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_Set_speed (speed: Word);
var
  divisor: Word;
begin
 if Com_installed then
   begin
    if speed < 2 then speed := 2;
    divisor := 115200 DIV speed;
    Disable_interrupts;
    Port [Uart_lcr]  := Port[Uart_lcr] OR $80;
    Portw [Uart_data] := divisor;
    Port [Uart_lcr]  := Port[Uart_lcr] and NOT $80;
    Enable_interrupts
   end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Function Com_Get_Speed: Longint;
var
   I,J,K      : word;
   Temp       : longint;
  begin
    K := Port[Uart_Lcr];
    Port[Uart_Lcr] := K OR $80;
    I := Port[Uart_Data];
    J := Port[Uart_ier];
    J := J * $100;
    J := J + I;
    Port[Uart_Lcr] := K;
    Temp := 115200;
    Temp := Temp div J;
    Com_Get_Speed := Temp
  end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_Set_parity (parity: Com_parity; stop_bits: Byte);
var
  lcr: Byte;
begin
  Case parity OF
    Com_none: lcr := $00 OR $03;
    Com_even: lcr := $18 OR $02;
    Com_odd : lcr := $08 OR $02;
    Com_zero: lcr := $38 OR $02;
    Com_one : lcr := $28 OR $02
  end;
  if stop_bits = 2 then lcr := lcr OR $04;
  Disable_interrupts;
  Port[Uart_lcr] := Port[Uart_lcr] and $40 OR lcr;
  Enable_interrupts
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{Error codes returned are:
  0 - No error
  1 - Invalid Portnumber
  2 - Uart for that Portis not present
  3 - Already installed, new installation ignored}

Procedure Com_install(Portnum  : Word; var error: Word);
var
  ier: Byte;
begin
  if Com_installed then error := 3
  else
    if (Portnum < 1) OR (Portnum > max_Port) then error := 1
    else
      begin
       Uart_data := Uart_base [Portnum];
       Uart_ier  := Uart_data + 1;
       Uart_iir  := Uart_data + 2;
       Uart_lcr  := Uart_data + 3;
       Uart_mcr  := Uart_data + 4;
       Uart_lsr  := Uart_data + 5;
       Uart_msr  := Uart_data + 6;
       Uart_spr  := Uart_data + 7;
       intnum    := intnums [Portnum];
       I8259bit  := 1 SHL I8259levels [Portnum];
       old_ier := Port[Uart_ier];
       Port[Uart_ier] := 0;
       if Port[Uart_ier] <> 0 then error := 2
       else
        begin
         error := 0;
         Disable_interrupts;
         old_I8259_mask := Port[$21];
         Port[$21] := old_I8259_mask OR I8259bit;
         Enable_interrupts;
         Com_flush_TX;
         Com_flush_RX;
         GetIntVec (intnum, old_vector);
         SetIntVec (intnum, @Com_interrupt_driver);
         Com_installed := True;
         Port[Uart_lcr] := 3;
         Disable_interrupts;
         old_mcr := Port[Uart_mcr];
         Port[Uart_mcr] := $A OR (old_mcr and 1);
         Enable_interrupts;
         Port[Uart_ier] := 1;
         Disable_interrupts;
         Port[$21] := Port[$21] and NOT I8259bit;
         Enable_interrupts
        end
      end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure Com_deinstall;
begin
  if Com_installed then
    begin
     Com_installed := False;
     Port[Uart_mcr] := old_mcr or 3;{added or 3}
     Port[Uart_ier] := old_ier;
     Disable_interrupts;
     Port[$21] := Port[$21] and NOT I8259bit OR
     old_I8259_mask and I8259bit;
     Enable_interrupts;
     SetIntVec (intnum, old_vector)
    end
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{$F+}
Procedure Exit_Procedure; {$F-}
begin
  Com_deinstall;
  ExitProc := Exit_save;
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
begin
  Exit_save := ExitProc;
  ExitProc := @Exit_Procedure;
end.
