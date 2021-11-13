unit clsFinish_u;

interface

uses
  SysUtils;

type
  TFinish = class
  private
    fBeginLyric, fCorrectLyric, fIncorrectLyric1, fIncorrectLyric2, fFileName : string;  //Do not need ArtistName or SongTitle as this was just to keep track of in database
  public
    sRandLyr1, sRandLyr2, sRandLyr3 : string;  //public variables so that they can be accessed outside of the class
    constructor create(pBeginLyric, pCorrectLyric, pIncorrectLyric1, pIncorrectLyric2, pFileName : string);  //uses the details inputted from the array class to store into one object
    function getBeginLyric : string; //returns the question; used in mini-game as question
    function getCorrectLyric : string;  //used to check if answer chosen is correct
    //Never need to access IncorrectLyrics outside of this class so don't need get IncorrectLyrics
    function getFileName : string;  //used to get name of song file
    procedure RandomizeLyrics;  //Used to randomize lyrics so that the order of them in the radiogroup is not the same
  end;


implementation

var
  arrRandomLyr : array[1..3] of string;  //This is used when randomizing order of lyrics

{ TFinish }

constructor TFinish.create(pBeginLyric, pCorrectLyric, pIncorrectLyric1, pIncorrectLyric2, pFileName: string);
begin
  fBeginLyric := pBeginLyric;
  fCorrectLyric := pCorrectLyric;
  fIncorrectLyric1 := pIncorrectLyric1;
  fIncorrectLyric2 := pIncorrectLyric2;
  fFileName := pFileName;
end;

function TFinish.getBeginLyric: string;
begin
  Result := TrimRight(fBeginLyric);
end;

function TFinish.getCorrectLyric: string;
begin
  Result := TrimRight(fCorrectLyric);
end;

function TFinish.getFileName: string;
begin
  Result := TrimRight(fFileName);
end;

procedure TFinish.RandomizeLyrics;  //used to randomize the lyrics so that the order of them in the radio group is not the same in order to confuse the user; returns the lyrics as separate strings which are publically stored; uses a temporary array of lyrics
var
  e, f, g : integer;
begin
  arrRandomLyr[1] := fCorrectLyric;  //Link a temporary array to lyrics
  arrRandomLyr[2] := fIncorrectLyric1;
  arrRandomLyr[3] := fIncorrectLyric2;
  e := 0;
  f := 0;
  g := 0;
  While (e = f) OR (f = g) OR (e = g) do
    begin
      Randomize;
      e := Random(3)+1;
      f := Random(3)+1;
      g := Random(3)+1;
    end;
  sRandLyr1 := arrRandomLyr[e];
  sRandLyr2 := arrRandomLyr[f];
  sRandLyr3 := arrRandomLyr[g];
end;

end.
