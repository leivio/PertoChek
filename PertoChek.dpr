program PertoChek;

uses
  Forms,
  uMain in 'uMain.pas' {Form21},
  uPertoCheque in 'uPertoCheque.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm21, Form21);
  Application.Run;
end.
