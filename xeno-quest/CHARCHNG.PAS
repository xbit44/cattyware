unit CharChng;
interface
uses DOS, CRT;

const EGAVGA_SEQUENCER = $3C4;          { Sequencer address/data port }
      EGAVGA_MONCTR    = $3D4;                   { Monitor controller }
      EGAVGA_GRAPHCTR  = $3CE;{ Graphics controller address/data port }
      EV_STATC         = $3DA;        { EGA/VGA color status register }
      EV_STATM         = $3BA;         { EGA/VGA mono status register }
      EV_ATTR          = $3C0;   { EGA/VGA color attribute controller }

type CRDTYPE = ( EGA, VGA, NEITHERNOR );
     Chardefs = array[0..15] of byte;  { Bit pattern of one character }

Procedure ChangeChar(chardef :chardefs; ReplaceChar : Char);
Procedure ResetChars;
var
  videoc : CRDTYPE;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
implementation

procedure CLI; inline( $FA );                    { Disable interrupts }
procedure STI; inline( $FB );                     { Enable interrupts }

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
procedure SetCharWidth( hwidth : byte );

var Regs : Registers;        { Processor registers for interrupt call }
    x    : byte;                        { Value for misc. output reg. }

begin
  if ( hwidth = 8 ) then Regs.BX := $0001     { BH = horiz. direction }
                    else Regs.BX := $0800;     { BL = seq. reg. value }

  x := port[ $3CC ] and not(4+8);                 { Toggle horizontal }
  if ( hwidth = 9 ) then                          { resolution from   }
    x := x or 4;                                  { 720 to 640 pixels }
  port[ $3C2 ] := x;

  CLI;                          { Toggle sequencer from 8 to 9 pixels }
  portw[ EGAVGA_SEQUENCER ] := $0100;
  portw[ EGAVGA_SEQUENCER ] := $01 + Regs.BL shl 8;
  portw[ EGAVGA_SEQUENCER ] := $0300;
  STI;

  Regs.AX := $1000;                     { Change screen configuration }
  Regs.BL := $13;
  intr( $10, Regs );
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

Function IsEgaVga : CRDTYPE;

var Regs : Registers;        { Processor registers for interrupt call }

begin
  Regs.AX := $1a00;                { Function 1AH applies only to VGA }
  Intr( $10, Regs );
  if ( Regs.AL = $1a ) then              { Is the function available? }
    IsEgaVga := VGA
  else
    begin
      Regs.ah := $12;                            { Call function 12H, }
      Regs.bl := $10;                            { sub-function 10H   }
      intr($10, Regs);                              { Call video BIOS }
      if ( Regs.bl <> $10 ) then IsEgaVga := EGA
                            else IsEgaVga := NEITHERNOR;
    end;
end;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
procedure ResetChars;

var Regs      : Registers;   { Processor registers for interrupt call }
begin
  case VideoC of
    EGA  : begin
             Regs.AX := $1101;                   { Load new 8x14 font }
             Regs.BL := 0;
             intr( $10, Regs );
           end;

    VGA  : begin
             SetCharWidth( 9 );         { Set char. width to 9 pixels }
             Regs.AX := $1104;                   { Load new 8x16 font }
             Regs.BL := 0;
             intr( $10, Regs );
           end;
    end;
end;

{**********************************************************************
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure ChangeChar(chardef :chardefs; ReplaceChar : Char);
var Regs      : Registers;   { Processor registers for interrupt call }
    videoc    : CRDTYPE;               { Type of video card installed }
    charheight,                  { Number of scan lines per character }
    i, j, k, l : Integer;       { Loop variables }

begin
  case videoc of
    NEITHERNOR :
      begin
        writeln( 'Warning: No EGA or VGA card found' );
        exit;
      end;
    EGA       :
      charheight := 14;            { EGA: 14 scan lines per character }
    VGA       :
      begin                                                     { VGA }
        SetCharWidth( 8 );              { Set char. width to 8 pixels }
        charheight := 16;               { 16 scan lines per character }
      end;
    end;
    for k := 0 to charheight-1 do      { Execute scan lines }
      begin
        Regs.AX := $1100;          { Call BIOS video interrupt, }
        Regs.BH := charheight;     { function 10H, sub-function }
        Regs.BL := 0;              { 00H to specify new         }
        Regs.CX := 1;              { character pattern          }
        Regs.DX := ord(ReplaceChar);
        Regs.ES := seg( chardef );
        Regs.BP := ofs( chardef );
        intr( $10, Regs );
      end;

end;

{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

begin
  videoc := IsEgaVga;                          { Check for video card }
end.