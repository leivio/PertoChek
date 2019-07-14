# PertoChek
Interface com Impressora PertoChek

Exemplos:

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
      ObsVerso := 'Pagamento de auxílio';
      TipoPreenchimentoCheque := tpcPreenchimentoChancelaLeituraCMC7ComAno4Digitos;
    end;
    Imprimir;
  finally
    Free;
  end;
