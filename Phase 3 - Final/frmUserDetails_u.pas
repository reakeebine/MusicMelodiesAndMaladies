unit frmUserDetails_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, Mask, jpeg, ExtCtrls, Buttons, clsUser_u, clsUserArray_u, ShellApi;

type
  TfrmUserDetails = class(TForm)
    imgBG3: TImage;
    lblGameTitle: TLabel;
    lblUserDetails: TLabel;
    lblUserName: TLabel;
    lblPassword: TLabel;
    lblHigh: TLabel;
    gbxYours: TGroupBox;
    edtUsername: TEdit;
    medPassword: TMaskEdit;
    btnShowPass: TButton;
    redUsers: TRichEdit;
    gbxLeaderboard: TGroupBox;
    btnBack: TButton;
    bmbHelp: TBitBtn;
    btnChangeUser: TButton;
    btnChangePass: TButton;
    imgInfoName: TImage;
    lblPoints: TLabel;
    lblDispHigh: TLabel;
    lblDispPoints: TLabel;
    lblSortBy: TLabel;
    btnSortName: TButton;
    btnSortPoints: TButton;
    btnSortHigh: TButton;
    bmbHome: TBitBtn;
    procedure FormShow(Sender: TObject);  //Instantiates object, shows user details
    procedure btnChangeUserClick(Sender: TObject);  //Allows existing user to change username (see class)
    procedure btnChangePassClick(Sender: TObject);  //Allows existing user to change password (see class)
    procedure btnShowPassClick(Sender: TObject);  //Shows/Hides password
    procedure btnSortNameClick(Sender: TObject);  //Sorts the leaderboard by username
    procedure btnSortPointsClick(Sender: TObject);  //Sorts the leaderboard by number of total points
    procedure btnSortHighClick(Sender: TObject);  //Sorts the leaderboard by high scores
    procedure bmbHelpClick(Sender: TObject);  //Part of external help: opens external pdf help document
    procedure bmbHomeClick(Sender: TObject);  //Goes back to main menu
    procedure FormClose(Sender: TObject; var Action: TCloseAction);  //Closing the form normally results in an error
    procedure imgInfoNameClick(Sender: TObject);  //Part of internal help: gives information on what is onscreen
  private
    { Private declarations }
    objUsers : TUserArray;
  public
    { Public declarations }
  end;

var
  frmUserDetails: TfrmUserDetails;

implementation

uses frmMainMenu_u;

{$R *.dfm}


procedure TfrmUserDetails.FormShow(Sender: TObject);
begin
  objUsers := TUserArray.create;

  //Leaderboard
  redUsers.Paragraph.TabCount := 2;
  redUsers.Paragraph.Tab[0] := 120;
  redUsers.Paragraph.Tab[1] := 170;
  redUsers.Lines.Clear;        
  objUsers.sortHighS;
  redUsers.Lines.Add(objUsers.displayUsers);

  //Your Details
  edtUsername.Text := objUsers.getCurrentUser.getUsername;
  medPassword.Text := objUsers.getCurrentUser.getPassword;
  medPassword.PasswordChar := '*';
  lblDispPoints.Caption := (IntToStr(objUsers.getCurrentUser.getNumPoints));
  lblDispHigh.Caption := (IntToStr(objUsers.getCurrentUser.getHighScore));
end;

procedure TfrmUserDetails.btnChangeUserClick(Sender: TObject);
var
  sUsername : string;
begin
  sUsername := InputBox('Change username', 'What would you like your new username to be?', '');
  objUsers.changeUserORPass(sUsername, true);  //This checks and updates username
  edtUsername.Text := objUsers.getCurrentUser.getUsername;
  redUsers.Lines.Clear;
  objUsers.sortHighS;
  redUsers.Lines.Add(objUsers.displayUsers);
end;

procedure TfrmUserDetails.btnChangePassClick(Sender: TObject);
var
  sPassword : string;
begin
  sPassword := InputBox('Change password', 'What would you like your new password to be?', '');
  objUsers.changeUserORPass(sPassword, false);  //This checks and updates password
  medPassword.Text := objUsers.getCurrentUser.getPassword;
end;

procedure TfrmUserDetails.btnShowPassClick(Sender: TObject);
begin
  if medPassword.PasswordChar = '*' then
    medPassword.PasswordChar := #0  //Advanced code: never unmasked MaskEdit in class
  else
    medPassword.PasswordChar := '*';
end;

procedure TfrmUserDetails.btnSortNameClick(Sender: TObject);
begin
  objUsers.sortNames;
  redUsers.Lines.Clear;
  redUsers.Lines.Add(objUsers.displayUsers);
end;

procedure TfrmUserDetails.btnSortPointsClick(Sender: TObject);
begin
  objUsers.sortPoints;
  redUsers.Lines.Clear;
  redUsers.Lines.Add(objUsers.displayUsers);
end;

procedure TfrmUserDetails.btnSortHighClick(Sender: TObject);
begin
  objUsers.sortHighS;
  redUsers.Lines.Clear;
  redUsers.Lines.Add(objUsers.displayUsers);
end;

procedure TfrmUserDetails.bmbHelpClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar('AcroRd32.exe'), PChar('Help.pdf'), nil, SW_SHOW); //Borrowed code
end;

procedure TfrmUserDetails.bmbHomeClick(Sender: TObject);
begin
  frmUserDetails.Hide;
  frmMainMenu.Show;
  objUsers.Free;
end;

procedure TfrmUserDetails.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmUserDetails.Hide;
  frmMainMenu.Show;
  objUsers.Free;
end;

procedure TfrmUserDetails.imgInfoNameClick(Sender: TObject);
begin
  ShowMessage('Your username and password are in the box below.' + #13 +
  'Click on the "Show/Hide" button to show or hide your password.' + #13 +
  'Click on one of the change buttons to change your username/password' + #13 +
  #13 +
  objUsers.showGuidelines + #13 +
  #13 +
  'The box below is the leaderboard, showing the name, number of points and high scores of every user. Click on the buttons Username, Points or High Score to order the users by username, total points or high score respectively.' + #13 +
  'The "Help" button opens a PDF explaining all features of the game');
end;

end.
