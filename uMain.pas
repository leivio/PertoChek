{******************************************************************************}
{ Direitos Autorais Reservados (c) 2019 Leivio Ramos de Fontenele              }
{                                                                              }
{  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la }
{ sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a versão 2.1 da Licença, ou (a seu critério) }
{ qualquer versão posterior.                                                   }

{  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU      }
{ ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)              }

{  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto}
{ com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,  }
{ no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Você também pode obter uma copia da licença em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Leivio Fontenele - leivio@yahoo.com.br | https://br.linkedin.com/in/leivio   }
{******************************************************************************}

unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, uPertoCheque;

type
  TForm21 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    Button6: TButton;
    btnCmC7: TButton;
    Button4: TButton;
    Button7: TButton;
    Button8: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure btnCmC7Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form21: TForm21;

{$IFDEF DIRECT}
function IniComm(si :PAnsichar): boolean; far; stdcall external 'pertochekser.dll';
function EndComm:boolean; far; stdcall external 'pertochekser.dll';
function EnvComm(si : PAnsichar) :integer; far; stdcall external 'pertochekser.dll';
function RecComm(t :integer; bufrx :PAnsichar) :integer; far; stdcall external 'pertochekser.dll';
function SerialBusy(t :integer) :integer; far; stdcall external 'pertochekser.dll';
{$ENDIF}

implementation

{$R *.dfm}

procedure TForm21.Button5Click(Sender: TObject);
var
  conf: AnsiString;
   ticks: integer;
   resp : AnsiString;
   r,i : integer;
  _conf: AnsiString;
  D: Boolean;
  codigo: Integer;
  Rep: array[0..255] of char;
begin
{$IFDEF DIRECT}
  //strpcopy (conf, 'COM3:9600,N,8,1');
  _conf := 'COM3:4800,N,8,1';
  D := False;
  D := IniComm(PAnsiChar(_conf));
  conf := '=';
  codigo := -1;
  codigo := EnvComm(PAnsiChar(conf));
  codigo := -1;
  for i := 1 to 256 do resp := resp + ' ';
  setlength(resp, 256);
  codigo := RecComm(20, PAnsiChar(resp));
  ShowMessage(resp);
  D := EndComm;
{$ENDIF}  
end;

procedure TForm21.Button6Click(Sender: TObject);
var
  conf: AnsiString;
   ticks: integer;
   resp : AnsiString;
   r, i: integer;
  _conf: AnsiString;
  D: Boolean;
  codigo: Integer;
  Rep: array[0..255] of char;
begin
{$IFDEF DIRECT}
  //strpcopy (conf, 'COM3:9600,N,8,1');
  _conf := 'COM3:4800,N,8,1';
  D := False;
  D := IniComm(PAnsiChar(_conf));
  conf := '#Fortaleza';
  codigo := -1;
  codigo := EnvComm(PAnsiChar(conf));
  codigo := -1;
  for i := 1 to 256 do resp := resp + ' ';
  setlength(resp, 256);
  codigo := RecComm(20, PAnsiChar(resp));
  ShowMessage(resp);
  D := EndComm;
{$ENDIF}  
end;


procedure TForm21.Button7Click(Sender: TObject);
begin
  with TPertoCheque.Create('COM3') do
  try
    ImprimirVerso('Pagamento de Auxilio');
  finally
    Free;
  end;
end;

procedure TForm21.Button8Click(Sender: TObject);
begin
  Close;
end;

procedure TForm21.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose := True;
end;

procedure TForm21.Button1Click(Sender: TObject);
var
 S: string;
begin
  with TPertoCheque.Create('COM3') do
  try
    S := Versao;
    ShowMessage(S);
  finally
    Free;
  end;
end;

procedure TForm21.Button2Click(Sender: TObject);
const
  _Com = 'COM3:9600,N,8,1';
begin
  if TPertoCheque.Iniciar(_Com) then
    ShowMessage('ok');
end;

procedure TForm21.Button3Click(Sender: TObject);
begin
  if TPertoCheque.Fechar then
    ShowMessage('ok');
end;

procedure TForm21.Button4Click(Sender: TObject);
begin
  with TPertoCheque.Create('COM3') do
  try
    with Add do
    begin
      Banco := '104';
      Moeda := 'Reais';
      Valor := 22.25;
      Data := Now;
      Favorecido := 'Leivio Ramos de Fontenele';
      Cidade := 'Fortaleza';
      BomPara := Now + 5;
      ObsVerso := 'Pagamento de Auxilio';
      TipoPreenchimentoCheque := tpcPreenchimentoChancelaLeituraCMC7ComAno4Digitos;
    end;
    Imprimir;
  finally
    Free;
  end;
end;


procedure TForm21.btnCmC7Click(Sender: TObject);
var
 S: string;
 CM: RCMC7;
begin
  with TPertoCheque.Create('COM3') do
  try
    CM := CMC7;
    S := 'Banco: ' + CM.BancoLido + #10#13 +
         'Agencia: ' + CM.AgenciaLida + #10#13 +
         'Conta: ' + CM.ContaLida + #10#13 +
         'Cheque: ' + CM.ChequeLido + #10#13 +
         'Comp: ' + CM.CompLida;
    ShowMessage(S);
  finally
    Free;
  end;
end;

end.
