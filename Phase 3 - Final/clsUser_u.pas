unit clsUser_u;  //This class is needed to store a single user's details so that it can be stored in the array.

interface

uses
  SysUtils;

type
  TUser = class
  private
    fUsername : string;  //stores the user's username
    fPassword : string;  //stores the user's password
    fNumPoints : integer;  //stores the user's total number of points
    fHighScore : integer;  //stores the user's high score
  public
    constructor create(pUsername, pPassword : string; pNumPoints, pHighScore : integer);  //stores the details of the user (inputted from the table in the database) into the fields
    function getUsername : string;  //This is used in User Details as well as in checking for user validity
    function getPassword : string;  //Used for logging in and returns
    function getNumPoints : integer;  //Updated as user plays game. Shown in User Details
    function getHighScore : integer;  //Updated when user plays a game and if that score is higher than high score. Shown in User Details
    procedure setUsername(pUsername : string);  //updated if the user changes their username
    procedure setPassword(pPassword : string);  //updated if the user changes their password
    procedure setNumPoints(pByNumPoints : integer);  //updated as user plays game
    procedure setHighScore(pNewScore : integer);  //updated as user plays game
    function toString : string;  //Used in leaderboard; separates user info with tabs
  end;


implementation

{ TUser }

constructor TUser.create(pUsername, pPassword: string;
  pNumPoints, pHighScore: integer);
begin
  fUserName := pUserName;
  fPassword := pPassword;
  fNumPoints := pNumPoints;
  fHighScore := pHighScore;
end;

function TUser.getHighScore: integer;
begin
  Result := fHighScore;
end;

function TUser.getNumPoints: integer;
begin
  Result := fNumPoints;
end;

function TUser.getPassword: string;
begin
  Result := TrimRight(fPassword);
end;

function TUser.getUsername: string;
begin
  Result := TrimRight(fUsername);
end;

procedure TUser.setHighScore(pNewScore: integer);
begin
  fHighScore := pNewScore;
end;

procedure TUser.setNumPoints(pByNumPoints: integer);
begin
  fNumPoints := fNumPoints + pByNumPoints;
end;

procedure TUser.setPassword(pPassword: string);
begin
  fPassword := pPassword;
end;

procedure TUser.setUsername(pUsername: string);
begin
  fUsername := pUsername;
end;

function TUser.toString: string;
begin
  Result := fUsername + #9 + IntToStr(fNumPoints) + #9 + IntToStr(fHighScore);  //Passwords not needed as that is sensitive information
end;

end.
