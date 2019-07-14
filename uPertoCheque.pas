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

unit uPertoCheque;

interface

uses Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     StdCtrls, Contnrs;

const
  E_PORTA_NAO_INI = 'Porta serial não pode ser inicializada';
  E_FALHA_NA_REC = 'Erro na recepção da resposta';

type

  EPertoChequeException = class(Exception);

  TPreenchimentoCheque = (
    tpcPreenchimentoSimples,                             // Somente preenchimento
    tpcPreenchimentoChancela,                            // Preenchimento e chancela
    tpcPreenchimentoLeituraCMC7,                         // Preenchimento e leitura de caracteres magnetizáveis CMC7
    tpcPreenchimentoChancelaLeituraCMC7,                 // Preenchimento, chancela e leitura
    tpcPreenchimentoSimplesComAno4Digitos,               // Preenchimento com ano de 4 dígitos
    tpcPreenchimentoChancelaComAno4Digitos,              // Preenchimento, chancela e ano com 4 dígitos
    tpcPreenchimentoLeituraCMC7ComAno4Digitos,           // Preenchimento, leitura e ano com 4 dígitos
    tpcPreenchimentoChancelaLeituraCMC7ComAno4Digitos,   // Preenchimento, chancela, leitura e ano com 4 dígitos
    tpcPreenchimentoSimplesCruzamento,                   // Preenchimento e cruzamento
    tpcPreenchimentoCruzamentoChancela,                  // Preenchimento, cruzamento e chancela
    tpcPreenchimentoCruzamentoLeituraCMC7,               // Preenchimento, cruzamento e leitura
    tpcPreenchimentoCruzamentoChancelaLeituraCMC7,       // Preenchimento, cruzamento, chancela e leitura
    tpcPreenchimentoCruzamentoComAno4Digitos,            // Preenchimento, cruzamento e ano com 4 dígitos
    tpcPreenchimentoCruzamentoChancelaComAno4Digitos,    // Preenchimento, cruzamento, chancela e ano com 4 dígitos
    tpcPreenchimentoCruzamentoLeituraCMC7ComAno4Digitos, // Preenchimento, cruzamento, leitura e ano com 4 dígitos
    tpcPreenchimentoCruzamentoChancelaLeituraCMC7ComAno4Digitos // Preenchimento, cruzamento, chancela, leitura e ano com 4 dígitos
     );

  RCMC7 = record
    BancoLido   : AnsiString;
    AgenciaLida : AnsiString;
    ContaLida   : AnsiString;
    ChequeLido  : AnsiString;
    CompLida    : AnsiString;
    CMC7        : AnsiString;
  end;

  TCheque = class
  private
    FMoeda: AnsiString;
    FValor: Extended;
    FFavorecido: AnsiString;
    FCidade: AnsiString;
    FData: TDateTime;
    FObservacao: AnsiString;
    FBomPara: TDateTime;
    FBanco: string;
    FTipoPreenchimentoCheque: TPreenchimentoCheque;
    FObsVerso: AnsiString;
  public
     property Banco: string read FBanco write FBanco;
     property Moeda: AnsiString read FMoeda write FMoeda;
     property Valor: Extended read FValor write FValor;
     property Data: TDateTime read FData write FData;
     property Favorecido: AnsiString read FFavorecido write FFavorecido;
     property Cidade: AnsiString read FCidade write FCidade;
     property Observacao: AnsiString read FObservacao write FObservacao;
     property BomPara: TDateTime read FBomPara write FBomPara;
     property TipoPreenchimentoCheque: TPreenchimentoCheque read FTipoPreenchimentoCheque write FTipoPreenchimentoCheque;
     property ObsVerso: AnsiString read FObsVerso write FObsVerso;
  end;

  TPertoCheque = class
  private
    FCheques: TObjectList;
    FInitCom: AnsiString;
    FConnected: Boolean;
    function GetVersao: AnsiString;
    procedure SetConnected(const Value: Boolean);
  public
    class function Iniciar(AString: AnsiString): Boolean;
    class function Fechar: Boolean;
    class function Enviar(AString: AnsiString): Boolean;
    class function Receber(var AString: AnsiString): Boolean;
    class function NaoOcupada: Boolean;
    class function TratarRetorno(ADadosRetorno: AnsiString): AnsiString;
  public
    function Add: TCheque;
    function Count: Integer;
    procedure Clear;
    procedure BeforeDestruction; override;
    procedure AfterConstruction; override;
    Property Versao: AnsiString read GetVersao;
    property Connected: Boolean read FConnected write SetConnected;
    procedure Disconnected;
    function CMC7: RCMC7;
    procedure Imprimir;
    procedure ImprimirVerso(AObs: AnsiString);
    constructor Create(APorta: AnsiString); reintroduce;
  end;

implementation

uses Windows;

var
 _Handle: THandle;

const
   _TimeOut = 20;
  _Lib = 'pertochekser.dll';

type
  TOpenCommandFunc    = function(si: PAnsichar): Boolean; stdcall;
  TCloseCommandFunc   = function(): Boolean; stdcall;
  TEnviarCommandFunc  = function(si: PAnsichar): Boolean; stdcall;
  TRetornoCommandFunc = function(t: integer;bufrx: PAnsichar): Boolean; stdcall;
  TBusyCommandFunc    = function(t : integer): Boolean; stdcall;


{$IFDEF DIRECT}
function IniComm(si :PAnsichar): boolean; far; stdcall external 'pertochekser.dll';
function EndComm: boolean; far; stdcall external 'pertochekser.dll';
function EnvComm(si : PAnsichar) :boolean; far; stdcall external 'pertochekser.dll';
function RecComm(t :integer; bufrx :PAnsichar) :boolean; far; stdcall external 'pertochekser.dll';
function SerialBusy(t :integer) :boolean; far; stdcall external 'pertochekser.dll';
{$ENDIF}

function GetFillAnsiString: AnsiString;
var
  i: SmallInt;
begin
  Result := EmptyStr;
  for i := 1 to 256 do
    Result := Result + ' ';
  Setlength(Result, 256);
end;

function OpenCommand(si: AnsiString): Boolean;
var
  Proc: TOpenCommandFunc;
  Path: AnsiString;
  _Path: PChar;
begin
  {$IFDEF DIRECT}
  Result := IniComm(PAnsiChar(si));
  {$ELSE}
  _Handle := LoadLibrary(_Lib);
  if  _Handle = 0 then
    raise Exception.Create(_Lib + ' não encontrada.');
  Proc := TOpenCommandFunc(GetProcAddress(_Handle, 'IniComm'));
  try
    Result := Proc(PAnsiChar(si));
  except
    Result := False
  end;
{$ENDIF}
end;

function CloseCommand: Boolean;
var
  Proc: TCloseCommandFunc;
begin
{$IFDEF DIRECT}
  Result := EndComm();
{$ELSE}
 _Handle := LoadLibrary(_Lib);
  if  _Handle = 0 then
    raise Exception.Create(_Lib + ' não encontrada.');
  Proc := TCloseCommandFunc(GetProcAddress(_Handle, 'EndComm'));
  Result := Proc;
{$ENDIF}
end;


function SendCommand(si : AnsiString): Boolean;
var
  Proc: TEnviarCommandFunc;
  _Comando: AnsiString;
begin
{$IFDEF DIRECT}
  Result := EnvComm(PAnsiChar(si));
{$ELSE}
  _Handle := LoadLibrary(_Lib);
  if  _Handle = 0 then
    raise Exception.Create(_Lib + ' não encontrada.');
  Proc := TEnviarCommandFunc(GetProcAddress(_Handle, 'EnvComm'));
  try
    Result := Proc(PAnsiChar(si));
  except
     Result := False;
     raise;
  end;
{$ENDIF}
end;

function ReturnCommand(t :integer; var bufrx : AnsiString): Boolean;
var
  Proc: TRetornoCommandFunc;
   _Return: AnsiString;
begin
  _Return := GetFillAnsiString;
{$IFDEF DIRECT}
  Result := RecComm(t, PAnsiChar(_Return));
  if Result then
    bufrx := _Return;
{$ELSE}
  _Handle := LoadLibrary(_Lib);
  if  _Handle = 0 then
    raise Exception.Create(_Lib + ' não encontrada.');
  Proc := TRetornoCommandFunc(GetProcAddress(_Handle, 'RecComm'));
  try
    Result := Proc(t, PAnsiChar(_Return));
    if Result then
      bufrx := _Return;
  except
    bufrx := '';
    Result := false;
  end;
{$ENDIF}
end;

function BusyCommand(t: integer): Boolean;
var
  Proc: TBusyCommandFunc;
begin
{$IFDEF DIRECT}
  Result := SerialBusy(t);
{$ELSE}
  _Handle := LoadLibrary(_Lib);
  if  _Handle = 0 then
    raise Exception.Create(_Lib + ' não encontrada.');
  Proc := TBusyCommandFunc(GetProcAddress(_Handle, 'SerialBusy'));
  try
    Result := Proc(t);
  except
    Result := False;
  end;
{$ENDIF}
end;


{ TPertoCheque }

procedure TPertoCheque.BeforeDestruction;
begin
  inherited;
  FCheques.Free;
  if Connected then
    Disconnected;
end;

function TPertoCheque.CMC7: RCMC7;
var
  Resp: AnsiString;
begin
  Connected := True;
  if Connected then
  begin
    try
      if Enviar('=') then
      begin
        if Receber(Resp) then
        begin
          TratarRetorno(Resp);
          Result.BancoLido   := copy(Resp, 5, 3);
          Result.AgenciaLida := copy(Resp, 8, 4);
          Result.ContaLida   := copy(Resp, 12, 10);
          Result.ChequeLido  := copy(Resp, 22, 6);
          Result.CompLida    := copy(Resp, 28, 3);
          Result.CMC7        := Resp;
          Enviar('>');
        end
        else
          raise EPertoChequeException.Create(E_FALHA_NA_REC);
      end
      else
        raise EPertoChequeException.Create(E_FALHA_NA_REC);
    finally
      if Connected then
        Disconnected;
    end;
  end
  else
    raise EPertoChequeException.Create(E_PORTA_NAO_INI);
end;

function TPertoCheque.GetVersao: AnsiString;
var
  Resp: AnsiString;
begin
  Connected := True;
  if Connected then
  begin
    try
      if Enviar('v') then
      begin
        if Receber(Resp) then
        begin
          Result := Resp;
        end
        else
          raise EPertoChequeException.Create(E_FALHA_NA_REC);
      end
      else
        raise EPertoChequeException.Create(E_FALHA_NA_REC);
    finally
      if Connected then
        Disconnected;
    end;
  end
  else
    raise EPertoChequeException.Create(E_PORTA_NAO_INI);
end;

procedure TPertoCheque.Imprimir;
var
  Index: Integer;
  Ch: TCheque;
  Resp: AnsiString;

  procedure _EnviarComando(AComando: AnsiString);
  begin
    if Enviar(AComando) then
    begin
      Sleep(200);
      if Receber(Resp) then
      begin
        TratarRetorno(Resp);
      end
      else
        raise EPertoChequeException.Create(E_FALHA_NA_REC);
    end
    else
      raise EPertoChequeException.Create(E_FALHA_NA_REC);
  end;

  function PreenchimentoChequeToStr(const AValue: TPreenchimentoCheque): string;
  var
    AInt: Integer;
  begin
    AInt := Integer(AValue);
    if AInt > 9 then
      Result := chr(55 + AInt)
    else
      Result := IntToStr(AInt);
  end;

  function StrToZero(const AString: string; ATamanho : Integer; AEsquerda: Boolean = true): string;
  var
  Str: string;
  begin
    Str := AString;
    while Length(Str) < ATamanho do
    begin
      if AEsquerda then
        Str := '0' + Str
      Else
        Str := Str + '0';
    end;
    Result := Str;
  end;


var
  ValStr: AnsiString;
begin
  if FCheques.Count > 0 then
  begin
    for Index := 0 to Pred(FCheques.Count) do
    begin
      Ch := TCheque(FCheques.Items[Index]);
      Connected := True;
      if Connected then
      begin
        try
          {Iniciar - Leitura do Cheque CMC7}
          _EnviarComando('=');
          {Moeda}
          if Trim(Ch.Favorecido) =  '' then
          begin
            if ch.Valor > 1 then
              _EnviarComando('MReais')
            else
              _EnviarComando('MReal');
          end
          else
          _EnviarComando('M' + Ch.Moeda);
          {Favorecido ou Beneficiario}
          if Trim(Ch.Favorecido) <> '' then
            _EnviarComando('%' + Ch.Favorecido);
          {Cidade}
          if Trim(Ch.Favorecido) <> '' then
            _EnviarComando('#' + Ch.Cidade);
          {Data}
          if Ch.Data > 0 then
            _EnviarComando('!' + FormatDateTime('ddmmyy', Ch.Data));
          {Bom Para}
          if Ch.FBomPara > 0 then
            _EnviarComando('+' + 'BOM PARA: '+ FormatDateTime('dd/mm/yy', Ch.FBomPara));
          { Comanda Preenchimento }
          ValStr := StrToZero(IntToStr(Round(Ch.Valor * 100)), 12);
          _EnviarComando(';' + PreenchimentoChequeToStr(Ch.TipoPreenchimentoCheque) + ValStr + Ch.Banco);
        finally
          if Connected then
            Disconnected;
        end;
      end
      else
        raise EPertoChequeException.Create(E_PORTA_NAO_INI);
    end;
  end
  else
  raise EPertoChequeException.Create('Nenhum cheque incluido para impressão.');
end;

procedure TPertoCheque.ImprimirVerso(AObs: AnsiString);
var
  Resp: AnsiString;
begin
  Connected := True;
  if Connected then
  begin
    if trim(AObs) <> EmptyStr then
    begin
      AObs := UpperCase(AObs);
      if Enviar('"' +  AObs + #255) then
      begin
        if Receber(Resp) then
        begin
          TratarRetorno(Resp);
          Enviar('>');
        end
        else
          raise EPertoChequeException.Create(E_FALHA_NA_REC);
      end
      else
        raise EPertoChequeException.Create(E_FALHA_NA_REC);
    end;
  end;
end;

class function TPertoCheque.Iniciar(AString: AnsiString): Boolean;
begin
  Result := OpenCommand(AString);
end;

class function TPertoCheque.NaoOcupada: Boolean;
begin
  Result := BusyCommand(_TimeOut);
end;

class function TPertoCheque.Receber(var AString: AnsiString): Boolean;
begin
  Result := ReturnCommand(_TimeOut, AString); {se igual a 0 entã oteve falha}
end;

procedure TPertoCheque.Disconnected;
begin
  if FConnected then
  begin
    FConnected := False;
    TPertoCheque.Fechar;
  end;
end;

procedure TPertoCheque.SetConnected(const Value: Boolean);
begin
  if Value then
  begin
    if not FConnected then
    begin
      FConnected := TPertoCheque.Iniciar(FInitCom);
    end;
  end
  else
    if FConnected then
    begin
      TPertoCheque.Fechar;
      FConnected := False;
    end;
end;

function TPertoCheque.Count: Integer;
begin
  Result := FCheques.Count;
end;

procedure TPertoCheque.Clear;
begin
  FCheques.Clear;
end;

function TPertoCheque.Add: TCheque;
begin
  Result := TCheque.Create;
  FCheques.Add(Result);
end;

procedure TPertoCheque.AfterConstruction;
begin
  inherited;
  FCheques := TObjectList.Create(True);
end;

constructor TPertoCheque.Create(APorta: AnsiString);
begin
  FInitCom := APorta + ':4800,N,8,1';
end;


class function TPertoCheque.Enviar(AString: AnsiString): Boolean;
begin
  Result := SendCommand(AString);
end;

class function TPertoCheque.Fechar: Boolean;
begin
  while not BusyCommand(5) do Continue;
  Result := CloseCommand;
end;

class function TPertoCheque.TratarRetorno(ADadosRetorno: AnsiString): AnsiString;
var
  _C: Integer;
begin
  _C := StrToIntDef(Copy(ADadosRetorno, 2, 3), -1);
  case _C of
    0: Result := 'Sucesso na execução do comando.';
    1: Result := 'Mensagem com dados inválidos.';
    2: Result := 'Tamanho de mensagem inválido.';
    5: Result := 'Leitura dos caracteres magnéticos inválida.';
    6: Result := 'Problemas no acionamento do motor 1.';
    8: Result := 'Problemas no acionamento do motor 2.';
    9: Result := 'Banco diferente do solicitado.';
    11: Result := 'Sensor 1 obstruído.';
    12: Result := 'Sensor 2 obstruído.';
    13: Result := 'Sensor 4 obstruído.';
    14: Result := 'Erro o posicionamento da cabeça de impressão (relativo a 54).';
    15: Result := 'Erro o posicionamento na pós-marcação.';
    16: Result := 'Dígito verificador do cheque não confere.';
    17: Result := 'Ausência de caracteres magnéticos ou cheque na posição errada.';
    18: Result := 'Tempo esgotado.';
    19: Result := 'Documento mal inserido.';
    20: Result := 'Cheque preso durante o alinhamento (51 e 52 desobstruídos).';
    21: Result := 'Cheque preso durante o alinhamento (S1 obstruído e S2 desobstruído).';
    22: Result := 'Cheque preso durante o alinhamento (51 desobstruído e S2 obstruído).';
    23: Result := 'Cheque preso durante o alinhamento (S1 e 52 obstruídos).';
    24: Result := 'Cheque preso durante o preenchimento (51 e S2 desobstruídos).';
    25: Result := 'Cheque preso durante o preenchimento (51 obstruído e 82 desobstruído).';
    26: Result := 'Cheque preso durante o preenchimento (51 desobstruído e S2 obstruído).';
    27: Result := 'Cheque preso durante o preenchimento (51 e 82 obstruídos).';
    28: Result := 'Caracter inexistente.';
    30: Result := 'Não há cheques na memória.';
    31: Result := 'Lista negra interna cheia';
    42: Result := 'Cheque ausente.';
    43: Result := 'Pin pad ou teclado ausente.';
    50: Result := 'Erro de transmissão.';
    51: Result := 'Erro de transmissão: Impressora off line, desconectada ou ocupada.';
    52: Result := 'Erro no pin pad.';
    60: Result := 'Cheque na lista negra.';
    73: Result := 'Cheque não encontrado na lista negra.';
    74: Result := 'Comando cancelado.';
    84: Result := 'Arquivo de layout cheio';
    85: Result := 'Layout inexistente na memória.';
    91: Result := 'Leitura de cartão inválida.';
    97: Result := 'Cheque na posição errada.';
    111: Result := 'Pin pad não retornou EOT.';
    150: Result := 'Pin pad não retornou NAK.';
    155: Result := 'Pin pad não responde.';
    171: Result := 'Tempo esgotado na resposta do pin pad.';
    255: Result :=  'Comando inexistente.';
  else
      Result := 'Erro Desconhecido -> ' + ADadosRetorno;
  end;

  if _C > 0 then
  begin
    Enviar('>');
    raise EPertoChequeException.Create(Result);
  end;
end;

end.
