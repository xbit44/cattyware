 program combinedata;
 uses Dos,Crt;
 var
  outfile  : text;
  infile1  : text;
  infile2  : text;
  I,J,K,L  : Integer;
  St       : String;

 begin
  Clrscr;
  assign (outfile,'Xqlevel.dta');
  rewrite(Outfile);
  assign (Infile1,'Xq1.dta');
  reset(Infile1);
  while Not Eof(INfile1) do
  begin
  readln(Infile1, I, J);
  write(Outfile,I,' ',J,' ');
  For K:= 2 to 9 do
   begin
    Str(K,St);
    L:=0;
    assign (Infile2,'Xq'+St+'.dta');
    reset(Infile2);
    While L< I do
     begin
      readln(Infile2);
      L:=L+1;
     end;
    Readln(Infile2,L,J);
    if K=9 then
     writeln(Outfile,J)
    else
     write(Outfile,J,' ');
    close(infile2);
   end
  end;
  close (Outfile);
  Close(Infile1)
 end.