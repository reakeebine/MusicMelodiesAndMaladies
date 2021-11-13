unit clsWho_u;

interface

uses
  SysUtils;

type
  TWho = class
  private
    fArtistName, fLyric, fIncorrectArtist1, fIncorrectArtist2, fFileName : string;  //Do not need SongTitle as this was just to keep track of in database
  public
    sRandArt1, sRandArt2, sRandArt3 : string;  //public variables so that they can be accessed outside of the class
    constructor create(pArtistName, pLyric, pIncorrectArtist1, pIncorrectArtist2, pFileName : string);  //uses the details inputted from the array class to store into one object
    function getLyric : string;  //used to check if answer chosen is correct
    function getArtistName : string;  //returns the question; used in mini-game as question
    //Never need to access IncorrectArtists outside of this class
    function getFileName : string;  //used to get name of song file
    procedure RandomizeArtists;  //Used to randomize lyrics so that the order of them in the radiogroup is not the same
  end;


implementation

var
  arrRandomArt : array[1..3] of string;  //This is used when randomizing order of artists

{ TWho }

constructor TWho.create(pArtistName, pLyric, pIncorrectArtist1, pIncorrectArtist2, pFileName: string);
begin
  fArtistName := pArtistName;
  fLyric := pLyric;
  fIncorrectArtist1 := pIncorrectArtist1;
  fIncorrectArtist2 := pIncorrectArtist2;
  fFileName := pFileName;
end;

function TWho.getArtistName: string;
begin
  Result := TrimRight(fArtistName);
end;

function TWho.getFileName: string;
begin
  Result := TrimRight(fFileName);
end;

function TWho.getLyric: string;
begin
  Result := TrimRight(fLyric);
end;

procedure TWho.RandomizeArtists;  //used to randomize the artists so that the order of them in the radio group is not the same in order to confuse the user; returns the artists as separate strings which are publically stored; uses a temporary array of artists
var
  e, f, g : integer;
begin
  arrRandomArt[1] := fArtistName;  //Link a temporary array to artists
  arrRandomArt[2] := fIncorrectArtist1;
  arrRandomArt[3] := fIncorrectArtist2;
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
  sRandArt1 := arrRandomArt[e];
  sRandArt2 := arrRandomArt[f];
  sRandArt3 := arrRandomArt[g];
end;

end.
