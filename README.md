# PertoChek

Interface com Impressora PertoChek

## Samples

with TPertoCheque.Create('COM3') do

```pascal
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
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
