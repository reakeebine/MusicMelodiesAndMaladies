unit clsGuess_u;

interface

uses
  SysUtils;

type
  TGuess = class
  private
    fSongTitle, fGuessFile, fIncorrectTitle1, fIncorrectTitle2, fFileName : string;  //Do not need ArtistName as this was just to keep track of in database
  public
    sRandTitle1, sRandTitle2, sRandTitle3 : string;  //public variables so that they can be accessed outside of the class
    constructor create(pSongTitle, pGuessFile, pIncorrectTitle1, pIncorrectTitle2, pFileName : string);  //uses the details inputted from the array class to store into one object
    function getSongTitle : string;  //used to check if answer chosen is correct
    function getGuessFile : string;  //returns the question; used in mini-game as question
    //Never need to access IncorrectTitles outside of this class
    function getFileName : string;  //used to get name of song file
    procedure RandomizeTitles;  //Used to randomize titles so that the order of them in the radiogroup is not the same
  end;


implementation

var
  arrRandomTitle : array[1..3] of string;  //This is used when randomizing order of titles

{ TGuess }

constructor TGuess.create(pSongTitle, pGuessFile, pIncorrectTitle1, pIncorrectTitle2, pFileName: string);
begin
  fSongTitle := pSongTitle;
  fGuessFile := pGuessFile;
  fIncorrectTitle1 := pIncorrectTitle1;
  fIncorrectTitle2 := pIncorrectTitle2;
  fFileName := pFileName;
end;

function TGuess.getFileName: string;
begin
  Result := TrimRight(fFileName);
end;

function TGuess.getGuessFile: string;
begin
  Result := TrimRight(fGuessFile);
end;

function TGuess.getSongTitle: string;
begin
  Result := TrimRight(fSongTitle);
end;

procedure TGuess.RandomizeTitles;  //used to randomize the titles so that the order of them in the radio group is not the same in order to confuse the user; returns the titles as separate strings which are publically stored; uses a temporary array of titles
var
  e, f, g : integer;
begin
  arrRandomTitle[1] := fSongTitle;  //Link a temporary array to titles
  arrRandomTitle[2] := fIncorrectTitle1;
  arrRandomTitle[3] := fIncorrectTitle2;
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
  sRandTitle1 := arrRandomTitle[e];
  sRandTitle2 := arrRandomTitle[f];
  sRandTitle3 := arrRandomTitle[g];
end;

end.
