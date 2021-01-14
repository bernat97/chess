program D_Chess;
uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R Chess_figure.res}

begin
  Application.Initialize;
  Application.Title := 'ChessBoard';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
