unit clsUserArray_u;  //This class is needed to store all the users' details and to enable the program to access and update their details. This class also contains some coding that is used in all three games so it is in this class to reduce repetition of code and store code in a centralised, easy to access location.

interface

uses
  clsUser_u, SysUtils, DBClassu, Dialogs;

type
  TUserArray = class
  private
    farrUser : array[1..100] of TUser;
    fSize : integer;
    function getCurUserNum : integer;  //This returns the user's position in the array so that can update user in array not just their user details. The username is taken from frmLogIn. This is used as opposed to getCurrentUser as if you were to set the username/password/points etc. using getCurrentUser, it wouldn't update it in the array.
  public
    constructor create;  //Takes the details from the database and places them into the array. Had to put user details in array as it would be too much coding to update points in text file
    procedure sortPoints;  //For leaderboard: to sort by total number of points, with best (largest) score at top
    procedure sortHighS;  //For leaderboard: to sort by user's high scores, with best (largest) score at top
    procedure sortNames;  //For leaderboard: to sort by usernames, alphabetically
    function getCurrentUser : TUser;  //This is used many times in the program to update the user's details. The username is taken from frmLogIn. This is used as opposed to getCurUserNum because the array cannot be accessed outside of this class.
    function checkUserValid(pUsername, pPassword : string) : boolean;  //This is for when a user logs in (i.e. their details already exist, just checking that they entered them correctly)
    function displayUsers : string;  //This is used in leaderboard, lists all users and their points
    procedure incPoints(pByNumPoints : integer);  //This is used when the user gains points in the mini-games
    procedure createUser(pUsername, pPassword : string);  //Used when creating a new user
    function checkUserORPassValid(const pNewUserPass: string; const pIsUsername: boolean; out pError : string): boolean;  //This is for when an old user changes their username or password (one method to limit repetition of code) or when a user is created
    procedure changeUserORPass(pNewUserPass: string; pIsUsername: boolean);  //This is for when an old user changes their username or password
    procedure updateHighScore(pNewScore : integer);  //This is used to check if the new score is higher than high score. If so, the score is changed
    //The following functions are not part of the user details, they are placed here because it is a centralised location for the forms to use
    function showGuidelines : string;  //This text is used many times in the forms Log In and User Details so it is best to put it here so it can be easily accessed
    function awardBonus(const pTimePassed : integer; out pUpdate : string) : integer;  //This returns the number of bonus points and returns the update message. It is not particularly a user method, it is just placed here as it makes awarding bonus points easier as it limits repetition of code across games
  end;

var
  aADO : TDBClass;

implementation

{ TUserArray }

uses
  frmLogin_u;


function TUserArray.awardBonus(const pTimePassed: integer; out pUpdate: string): integer;  //out is borrowed code http://delphi.about.com/od/beginners/a/return-multiple-values-from-a-delphi-function.htm
var
  iTempBonus : integer;
  sTempUpdate : string;
begin
  iTempBonus := 0;
  sTempUpdate := '';
  if pTimePassed <= 5 then
    begin
      iTempBonus := (-2 * pTimePassed) + 12;
      sTempUpdate := 'You answered that question correctly in ' + IntToStr(pTimePassed) + ' second(s) and receive a bonus of ' + IntToStr(iTempBonus) + ' points!' + #13 + 'You got ' + IntToStr(iTempBonus + 10) + ' points for that question!';
    end
  else
  if pTimePassed <= 10 then
    begin
      iTempBonus := 1;
      sTempUpdate := 'You answered that question correctly in less than 10 seconds and received a bonus of 1 point!' + #13 + 'You got 11 points for that question!';
    end
  else
    sTempUpdate := 'Well done! You got that question correct! You got 10 points for that question!';
  pUpdate := sTempUpdate;
  Result := iTempBonus;
end;

procedure TUserArray.changeUserORPass(pNewUserPass: string;
  pIsUsername: boolean);
var
  sError, sUserPass, sQuery : string;
begin
  if pIsUsername then
    sUserPass := 'username'
  else
    sUserPass := 'password';
  if checkUserORPassValid(pNewUserPass, pIsUsername, sError) = false then
    ShowMessage('Sorry, the ' + sUserPass + ' you chose is invalid.' + #13 +
    sError + #13 +
    #13 +
    'You can check username and password guidelines by clicking the "i" icon.' + #13 +
    'Please type in a different ' + sUserPass + '.')
  else
    begin
      try
        sQuery := 'UPDATE tblUserDetails SET s' + sUserPass + ' = "' + pNewUserPass + '" WHERE sUsername = "' + getCurrentUser.getUserName + '"';  //Checks for username as passwords can be same / not unique
        aADO.ProcessUpdate(sQuery);
        if pIsUsername then
          begin
            farrUser[getCurUserNum].setUsername(pNewUserPass);
            frmLogin.fCurrentUser := pNewUserPass;
          end
        else
          farrUser[getCurUserNum].setPassword(pNewUserPass);
      except
        ShowMessage('An error occurred. The program was unable to update your ' + sUserPass + '. Please try again.');
      end;
    end;
end;

function TUserArray.checkUserORPassValid(const pNewUserPass: string;
  const pIsUsername: boolean; out pError: string): boolean;  //out is borrowed code http://delphi.about.com/od/beginners/a/return-multiple-values-from-a-delphi-function.htm
var
  sUserPass : string;
  iLoop : integer;
  bValid : boolean;
begin
  bValid := true;
  pError := '';
  if pIsUsername then
    sUserPass := 'username'
  else
    sUserPass := 'password';

  try
    for iLoop := 1 to Length(pNewUserPass) do  //Can't use checkNameValid here because password already exists so would say that the password is invalid but it is the same user
      if pNewUserPass[iLoop] IN ['#', ' '] then  //Cannot have hashes or spaces
        begin
          bValid := false;
          pError := #13 + ' *  Your ' + sUserPass + ' contains one or more hashes or spaces. These are forbidden characters.';
        end;
    if (Length(pNewUserPass) < 8) OR (Length(pNewUserPass) > 16) then  //Password cannot be too long or short
      begin
        bValid := false;
        pError := pError + #13 + ' *  Your ' + sUserPass + ' is either too long or too short. It must be between 8 and 16 characters long.';
      end;
    if pIsUsername then
      for iLoop := 1 to fSize do  //Usernames must be unique
        if UpperCase(farrUser[iLoop].getUsername) = UpperCase(pNewUserPass) then  //Username not case sensitive
          begin
            bValid := false;
            pError := pError + #13 + ' *  Your username is too similar to that of another user. Please choose a different username.';
          end;
  except
    ShowMessage('An error occurred. The program was unable to verify if your ' + sUserPass + ' is within the specifications. Please try again.');
  end;
  Result := bValid;
end;

function TUserArray.checkUserValid(pUsername, pPassword : string): boolean;
var
  iLoop : integer;
  bFound : boolean;
begin
  bFound := false;
  for iLoop := 1 to fSize do
    if (Uppercase(farrUser[iLoop].getUsername) = Uppercase(pUsername)) AND (farrUser[iLoop].getPassword = pPassword) then  //Username is uppercase because it is not case sensitive
      bFound := true;
  Result := bFound;
end;

constructor TUserArray.create;
var
  sQuery, sTempResults, sUsername, sPassword : string;
  iNumPoints, iHighScore : integer;
begin
  fSize := 0;
  aADO := TDBClass.Create('dbMMAM.mdb');  //db = database; MMAM = Music Melodies and Maladies
  sQuery := 'SELECT * FROM tblUserDetails';
  sTempResults := aADO.ProcessQuery(sQuery);

  While Length(sTempResults) <> 0 do
    begin
      inc(fSize);

      sUsername := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
      Delete(sTempResults, 1, Pos('#', sTempResults));

      sPassword := Copy(sTempResults, 1, Pos('#', sTempResults)-1);
      Delete(sTempResults, 1, Pos('#', sTempResults));

      iNumPoints := StrToInt(Trim(Copy(sTempResults, 1, Pos('#', sTempResults)-1)));
      Delete(sTempResults, 1, Pos('#', sTempResults));

      iHighScore := StrToInt(Trim(Copy(sTempResults, 1, Pos('#', sTempResults)-1)));
      Delete(sTempResults, 1, Pos('#', sTempResults));

      farrUser[fSize] := TUser.create(sUsername, sPassword, iNumPoints, iHighScore);
    end;
end;

procedure TUserArray.createUser(pUsername, pPassword: string);
var
  sQuery, sPassError, sUserError : string;
begin
  try
    if (checkUserORPassValid(pUsername, true, sUserError) = false) OR (checkUserORPassValid(pPassword, false, sPassError) = false) then  //Checks if username and password are valid (see method)
      ShowMessage('Sorry, the username/password you chose is invalid.' + #13 +
      sUserError +
      sPassError + #13 +
      #13 +
      'You can check username and password guidelines by clicking the "i" icon.' + #13 +
      'Please try again and choose a different username/password.')
    else
      begin
        sQuery := 'INSERT INTO tblUserDetails (sUsername, sPassword, iNumPoints, iHighScore) VALUES ("' + pUsername + '", "' + pPassword + '", 0, 0)';  //Points are zero because they have not played yet
        aADO.ProcessUpdate(sQuery);
        ShowMessage('Your username and password details were correctly updated.');
        frmLogin.LogIn(pUsername, pPassword);  //This automatically logs the user in if their details are correct.
      end;
  except
    ShowMessage('An error occurred. The program was unable to create your username and password. Please try again.');
  end;
end;

function TUserArray.displayUsers: string;
var
  sTemp : string;
  iLoop : integer;
begin
  for iLoop := 1 to fSize do
    sTemp := sTemp + farrUser[iLoop].toString + #13;
  Result := sTemp;
end;

function TUserArray.getCurrentUser: TUser;
var
  iLoop : integer;
begin
  try
    for iLoop := 1 to fSize do
      if (Uppercase(farrUser[iLoop].getUsername) = Uppercase(frmLogin.fCurrentUser)) then  //Username is not case sensitive
        Result := farrUser[iLoop];  //No else because user has been checked previously and therefore will definitely be found
  except
    ShowMessage('An error occurred. Your user details cannot be accessed. Please try again.');  //This is needed in case an error occurs in finding the current user.
  end;
end;

function TUserArray.getCurUserNum: integer;
var
  iLoop : integer;
begin
  try
    for iLoop := 1 to fSize do
      if (Uppercase(farrUser[iLoop].getUsername) = Uppercase(frmLogin.fCurrentUser)) then  //Username is not case sensitive
        Result := iLoop;
  except
    ShowMessage('An error occurred. Your user details cannot be accessed. Please try again.');  //This is needed in case an error occurs in finding the current user.
  end;
end;

procedure TUserArray.incPoints(pByNumPoints: integer);
var
  sQuery : string;
begin
  try
    sQuery := 'UPDATE tblUserDetails SET iNumPoints = iNumPoints + ' + IntToStr(pByNumPoints) + ' WHERE sUsername = "' + getCurrentUser.getUsername + '"';  //Search using username because username is unique
    aADO.ProcessUpdate(sQuery);
    farrUser[getCurUserNum].setNumPoints(pByNumPoints);
  except
    ShowMessage('An error has occured. Unfortunately, your points could not be updated.');
  end;
end;

function TUserArray.showGuidelines: string;
begin
  Result := 'Username and password guidelines:' + #13 +
            ' *  Neither your username nor your password can have hashes (#) or spaces.' + #13 +
            ' *  Your username must be at least 8 characters long and cannot be longer than 16 characters.' + #13 +
            ' *  Your username must be unique (i.e. it must not be the same username as any other player).' + #13 +
            ' *  Usernames are not case sensitive but passwords are case sensitive.' + #13 +
            ' *  Your password must be at least 8 characters long and cannot be longer than 16 characters.' + #13 +
            ' *  It is recommended that your password have abnormal characters (such as numbers and symbols).';
end;

procedure TUserArray.sortHighS;
var
  X, Y : integer;
  objTemp : TUser;
begin
  sortNames;  //sort by name first in case people have the same high score
  for X := 1 to fSize -1 do
    for Y := X +1 to fSize do
      if farrUser[X].getHighScore < farrUser[Y].getHighScore then 
        begin
          objTemp := farrUser[X];
          farrUser[X] := farrUser[Y];
          farrUser[Y] := objTemp;
        end;
end;

procedure TUserArray.sortNames;
var
  X, Y : integer;
  objTemp : TUser;
begin
  for X := 1 to fSize -1 do
    for Y := X +1 to fSize do
      if Uppercase(farrUser[X].getUsername) > Uppercase(farrUser[Y].getUsername) then //must be uppercase because lowercase letters have different ASCII values
        begin
          objTemp := farrUser[X];
          farrUser[X] := farrUser[Y];
          farrUser[Y] := objTemp;
        end;
end;

procedure TUserArray.sortPoints;
var
  X, Y : integer;
  objTemp : TUser;
begin
  sortNames;  //sort by name first in case people have the same number of points
  for X := 1 to fSize -1 do
    for Y := X +1 to fSize do
      if farrUser[X].getNumPoints < farrUser[Y].getNumPoints then
        begin
          objTemp := farrUser[X];
          farrUser[X] := farrUser[Y];
          farrUser[Y] := objTemp;
        end;
end;

procedure TUserArray.updateHighScore(pNewScore: integer);
var
  sQuery : string;
begin
  try
    if pNewScore > getCurrentUser.getHighScore then
      begin
        ShowMessage('You beat your high score! Well done!');
        sQuery := 'UPDATE tblUserDetails SET iHighScore = ' + IntToStr(pNewScore) + ' WHERE sUsername = "' + getCurrentUser.getUsername + '"';  //Search using username because username is unique
        aADO.ProcessUpdate(sQuery);
        farrUser[getCurUserNum].setHighScore(pNewScore);
      end;
  except
    ShowMessage('Unfortunately, your high score could not be updated.');
  end;
end;

end.
