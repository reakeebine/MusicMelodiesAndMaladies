unit frmMainMenu_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, Buttons, StdCtrls, ShellApi,
  frmUserDetails_u, frmFinishLyric_u, frmGuessSong_u, frmVideo_u, frmWhoSang_u;

type
  TfrmMainMenu = class(TForm)
    imgBG3: TImage;
    lblGameTitle: TLabel;
    lblMainMenu: TLabel;
    lblUserName: TLabel;
    btnFinishLyric: TButton;
    btnGuessSong: TButton;
    btnWhoSang: TButton;
    btnUser: TButton;
    imgInfoFinish: TImage;
    imgInfoGuess: TImage;
    imgInfoWho: TImage;
    bmbHelp: TBitBtn;
    btnBack: TButton;
    procedure bmbHelpClick(Sender: TObject);  //Part of external help: opens external pdf help document
    procedure btnBackClick(Sender: TObject);  //Goes back to Login screen
    procedure btnUserClick(Sender: TObject);  //Opens the User Details screen
    procedure btnFinishLyricClick(Sender: TObject);  //Opens the Finish the Lyric game screen
    procedure btnGuessSongClick(Sender: TObject);  //Opens the Guess the Song game screen
    procedure btnWhoSangClick(Sender: TObject);  //Opens that Who Sang That? game screen
    procedure imgInfoFinishClick(Sender: TObject);  //Opens the video screen to play tutorial video
    procedure imgInfoGuessClick(Sender: TObject);  //Opens the video screen to play tutorial video
    procedure imgInfoWhoClick(Sender: TObject);  //Opens the video screen to play tutorial video
    procedure FormClose(Sender: TObject; var Action: TCloseAction);  //Closing the form in the usual way results in an error, unless closed from frmLogin. This method sends the user back to the Log In screen where they can close safely
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMainMenu: TfrmMainMenu;

implementation

uses
  frmLogin_u;   

{$R *.dfm}

procedure TfrmMainMenu.bmbHelpClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar('AcroRd32.exe'), PChar('Help.pdf'), nil, SW_SHOW);  //Borrowed code
end;

procedure TfrmMainMenu.btnBackClick(Sender: TObject);
begin
  frmLogin.Show;
  frmMainMenu.Hide;
end;

procedure TfrmMainMenu.btnUserClick(Sender: TObject);
begin
  frmUserDetails.Show;
  frmMainMenu.Hide;
end;

procedure TfrmMainMenu.btnFinishLyricClick(Sender: TObject);
begin
  frmFinishLyric.Show;
  frmMainMenu.Hide;
end;

procedure TfrmMainMenu.btnGuessSongClick(Sender: TObject);
begin
  frmGuessSong.Show;
  frmMainMenu.Hide;
end;

procedure TfrmMainMenu.btnWhoSangClick(Sender: TObject);
begin
  frmWhoSang.Show;
  frmMainMenu.Hide;
end;

procedure TfrmMainMenu.imgInfoFinishClick(Sender: TObject);  //Borrowed code, never done DblClick in class
begin
  frmVideo.fFileName := 'FinishLyric.avi';
  frmVideo.Show;
end;

procedure TfrmMainMenu.imgInfoGuessClick(Sender: TObject);  //Same as previous
begin
  frmVideo.fFileName := 'GuessSong.avi';
  frmVideo.Show;
end;

procedure TfrmMainMenu.imgInfoWhoClick(Sender: TObject);  //Same as above
begin
  frmVideo.fFileName := 'WhoSang.avi';
  frmVideo.Show;
end;

procedure TfrmMainMenu.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmLogin.Show;
  frmMainMenu.Hide;
end;

end.
