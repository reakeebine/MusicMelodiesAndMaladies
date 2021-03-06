unit frmLogin_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Mask, jpeg, Buttons,
  clsUser_u, clsUserArray_u, frmMainMenu_u, ShellApi;  //ShellApi is borrowed code used to access Help document

type
  TfrmLogin = class(TForm)
    imgBG1: TImage;
    lblGameTitle: TLabel;
    lblLogin: TLabel;
    lblUsername: TLabel;
    edtUserName: TEdit;
    lblPassword: TLabel;
    medPassword: TMaskEdit;
    btnLogin: TButton;
    imgInfoName: TImage;
    btnCreate: TButton;
    bmbHelp: TBitBtn;
    bmbClose: TBitBtn;
    procedure btnLoginClick(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
    procedure imgInfoNameClick(Sender: TObject);
    procedure bmbHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    objUsers : TUserArray;
  public
    { Public declarations }
    fCurrentUser : string;  //received help from Caileigh Bench; this stores the current user's username so that it can be accessed by clsUserArray and ultimately by all other forms.
    procedure LogIn(pUsername, pPassword : string);  //a procedure is used and is public so that it can be used by the method createUser in clsUserArray
  end;                                  

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

procedure TfrmLogin.btnLoginClick(Sender: TObject);  //This assigns the user's username and password so it can go to LogIn procedure
var
  sUsername, sPassword : string;
begin
  sUsername := edtUsername.Text;
  sPassword := medPassword.Text;
  LogIn(sUsername, sPassword);
end;

procedure TfrmLogin.btnCreateClick(Sender: TObject);  //This assigns the user's username and password so it can go to createUser procedure in clsUserArray
var
  sUsername, sPassword : string;
begin
  sUsername := InputBox('Input username', 'What would you like your username to be?', '');
  sPassword := InputBox('Input password', 'What would you like your password to be?', '');
  objUsers.createUser(sUsername, sPassword);  //Adds user to database
end;

procedure TfrmLogin.LogIn(pUsername, pPassword: string);  //This is a procedure that is used on click of Log In button and used by clsUserArray after creating a user.
begin
  objUsers.create;  //Needed if user has just created username and password.
  if objUsers.checkUserValid(pUsername, pPassword) then
    begin
      fCurrentUser := pUsername;  //changes public variable
      ShowMessage('Welcome ' + objUsers.getCurrentUser.getUsername + '! Your login attempt was successful!');
      frmLogin.Hide;
      frmMainMenu.Show;
      objUsers.Free;  //destructs object to save memory
    end
  else
    ShowMessage('You have inputted your username/password incorrectly.');
end;

procedure TfrmLogin.imgInfoNameClick(Sender: TObject);  //This is part of internal help: gives information on what is onscreen
begin
  ShowMessage('Input your username and password in the boxes on the screen then click "Log In" to log in.' + #13 +
  'Click the "Create New" button to create a username and password.' + #13 +
  #13 +
  objUsers.showGuidelines + #13 +  //uses show guidelines from clsUser as it limits repetition of code
  #13 +
  'The "Help" button opens a PDF explaining all features of the game.');
end;

procedure TfrmLogin.bmbHelpClick(Sender: TObject);  //Part of external help: opens external pdf help document(newest version of Adobe needed)
begin
  ShellExecute(Handle, 'open', PChar('AcroRd32.exe'), PChar('Help.pdf'), nil, SW_SHOW);  //Borrowed code
end;

procedure TfrmLogin.FormShow(Sender: TObject);  //Resets for when frmLogin is reopened after user clicks Back to Log In on Main Menu
begin
  edtUserName.Text := '';
  medPassword.Text := '';
  objUsers := TUserArray.create;
end;

end.
