unit clsGuessArray_u;

interface

uses
  clsGuess_u, DBClassu, Math;

type
  TGuessArray = class
  private
    farrGuess : array[1..50] of TGuess;
    farrGueQue : array[1..3] of TGuess;
    fSize : integer;
  public
    constructor create;  //links database to program
    procedure RandomizeRecords;  //Randomizes questions so that not always asked same questions; takes the details of a random 3 questions from the database and places them into each of the random lyric strings using farrGueQue
    function getQuestion(pQNum : integer) : TGuess;  //gets a single question from clsGuess using a question number; retrieves question so details can be accessed in the game
  end;


implementation

{ TGuessArray }

var
  aADO : TDBClass;

constructor TGuessArray.create;
var
  sQuery, sTempResults, sSongTitle, sGuessFile, sIncorrectTitle1, sIncorrectTitle2, sFileName : string;
begin 
  aADO := TDBClass.Create('dbMMAM.mdb');
  fSize := 0;
  sQuery := 'SELECT * FROM tblGuessSong';
  sTempResults := aADO.ProcessQuery(sQuery);

  While length(sTempResults) <> 0 do
  begin
    inc(fSize);

    sSongTitle := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    Delete(sTempResults, 1, Pos('#', sTempResults));  //Don't need artist name

    sGuessFile := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    sIncorrectTitle1 := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    sIncorrectTitle2 := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    sFileName := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    farrGuess[fSize] := TGuess.create(sSongTitle, sGuessFile, sIncorrectTitle1, sIncorrectTitle2, sFileName);
  end;
end;

function TGuessArray.getQuestion(pQNum: integer): TGuess;
begin
  Result := farrGueQue[pQNum];
end;

procedure TGuessArray.RandomizeRecords;  
var
  e, f, g : integer;
begin
  e := 0;
  f := 0;
  g := 0;
  While (e = f) OR (f = g) OR (e = g) do
    begin
      Randomize;
      e := Random(fSize)+1;
      f := Random(fSize)+1;
      g := Random(fSize)+1;
    end;
  farrGueQue[1] := farrGuess[e];
  farrGueQue[2] := farrGuess[f];
  farrGueQue[3] := farrGuess[g];
end;

end.
