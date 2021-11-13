unit clsWhoArray_u;  //Similar to Finish the Lyric

interface

uses
  clsWho_u, DBClassu, Math;

type
  TWhoArray = class
  private
    farrWho : array[1..50] of TWho;
    farrWhoQue : array[1..3] of TWho;
    fSize : integer;
  public
    constructor create;  //links database to program
    procedure RandomizeRecords;  //Randomizes questions so that not always asked same questions; takes the details of a random 3 questions from the database and places them into each of the random lyric strings using farrWhoQue
    function getQuestion(QNum : integer) : TWho;  //gets a single question from clsWho using a question number; retrieves question so details can be accessed in the game
  end;


implementation

{ TWhoArray }

var
  aADO : TDBClass;

constructor TWhoArray.create;
var
  sQuery, sTempResults, sArtistName, sLyric, sIncorrectArtist1, sIncorrectArtist2, sFileName : string;
begin  
  aADO := TDBClass.Create('dbMMAM.mdb');
  fSize := 0;
  sQuery := 'SELECT * FROM tblWhoSang';
  sTempResults := aADO.ProcessQuery(sQuery);

  While length(sTempResults) <> 0 do
  begin
    inc(fSize);

    Delete(sTempResults, 1, Pos('#', sTempResults));  //Don't need song title

    sArtistName := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    sLyric := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    sIncorrectArtist1 := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    sIncorrectArtist2 := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    sFileName := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
    Delete(sTempResults, 1, Pos('#', sTempResults));

    farrWho[fSize] := TWho.create(sArtistName, sLyric, sIncorrectArtist1, sIncorrectArtist2, sFileName);
  end;
end;

function TWhoArray.getQuestion(QNum: integer): TWho;
begin
  Result := farrWhoQue[QNum];
end;

procedure TWhoArray.RandomizeRecords;  
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
  farrWhoQue[1] := farrWho[e];
  farrWhoQue[2] := farrWho[f];
  farrWhoQue[3] := farrWho[g];
end;

end.
