unit clsFinishArray_u;

interface

uses
  clsFinish_u, DBClassu, Math;

type
  TFinishArray = class
  private
    farrFinish : array[1..50] of TFinish;
    farrFinQue : array[1..3] of TFinish;
    fSize : integer;
  public
    constructor create;  //links database to program
    procedure RandomizeRecords;  //Randomizes questions so that not always asked same questions; takes the details of a random 3 questions from the database and places them into each of the random lyric strings using farrFinQue
    function getQuestion(pQNum : integer) : TFinish;  //gets a single question from clsFinish using a question number; retrieves question so details can be accessed in the game
  end;


implementation

{ TFinishArray }

var
  aADO : TDBClass;

constructor TFinishArray.create;
var
  sQuery, sTempResults, sBeginLyric, sCorrectLyric, sIncorrectLyric1, sIncorrectLyric2, sFileName : string;
begin
  aADO := TDBClass.Create('dbMMAM.mdb');
  fSize := 0;
  sQuery := 'SELECT * FROM tblFinishLyric';
  sTempResults := aADO.ProcessQuery(sQuery);

  While length(sTempResults) <> 0 do
  begin
    inc(fSize);

    Delete(sTempResults, 1, Pos('#', sTempResults));  //Don't need song title
    Delete(sTempResults, 1, Pos('#', sTempResults));  //Don't need artist name

    sBeginLyric := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    sCorrectLyric := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    sIncorrectLyric1 := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    sIncorrectLyric2 := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    sFileName := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    farrFinish[fSize] := TFinish.create(sBeginLyric, sCorrectLyric, sIncorrectLyric1, sIncorrectLyric2, sFileName);
  end;
end;

function TFinishArray.getQuestion(pQNum : integer): TFinish;
begin
  Result := farrFinQue[pQNum];  //Retrieves the details of the question from individual class
end;

procedure TFinishArray.RandomizeRecords;
var
  e, f, g : integer;
begin
  e := 0;  //initialises the integer variables
  f := 0;
  g := 0;
  While (e = f) OR (f = g) OR (e = g) do  //makes sure that they are not the same
    begin
      Randomize;
      e := Random(fSize)+1;  //chooses a random integer within the number of questions
      f := Random(fSize)+1;
      g := Random(fSize)+1;
    end;
  farrFinQue[1] := farrFinish[e];  //places each random question into one of the three array options
  farrFinQue[2] := farrFinish[f];
  farrFinQue[3] := farrFinish[g];
end;

end.
