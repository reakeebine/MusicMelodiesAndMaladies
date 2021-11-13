unit frmWhoSang_u;  //Similar to Finish the Lyric

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, Buttons, ShellApi, MPlayer, DateUtils,
  clsUser_u, clsUserArray_u, clsWho_u, clsWhoArray_u;

type
  TfrmWhoSang = class(TForm)
    bmbBack: TBitBtn;
    bmbCheck: TBitBtn;
    bmbHelp: TBitBtn;
    bmbHome: TBitBtn;
    btnContinue: TButton;
    btnStart: TButton;
    imgBG2: TImage;
    imgBG4: TImage;
    imgBG4__: TImage;
    imgInfoWho: TImage;
    lblCongrats: TLabel;
    lblGameTitle: TLabel;
    lblHighScore: TLabel;
    lblLyric: TLabel;
    lblPoints: TLabel;
    lblQNum: TLabel;
    lblQuestion: TLabel;
    lblResult: TLabel;
    lblTimer: TLabel;
    lblUpdate: TLabel;
    lblWhoSang: TLabel;
    mpSong: TMediaPlayer;
    pnlContinue: TPanel;
    pnlOutput: TPanel;
    rgpArtistOptions: TRadioGroup;
    tmrTimer: TTimer;
    procedure FormShow(Sender: TObject);  //Instantiates objects, resets/clears game screen
    procedure btnStartClick(Sender: TObject);  //Shows first question, starts game
    procedure rgpArtistOptionsClick(Sender: TObject);  //Enables btnCheck, part of defensive coding
    procedure bmbCheckClick(Sender: TObject);  //Verifies whether answer correct or not and updates points if necessary
    procedure btnContinueClick(Sender: TObject);  //Checks if game has ended (if so will end game if on third question); Shows user results
    procedure StartQuestion;  //Method used to reset game for new question
    procedure tmrTimerTimer(Sender: TObject);  //Shows time in timer label once timer is enabled
    procedure bmbBackClick(Sender: TObject);  //Resets entire game screen
    procedure imgInfoWhoClick(Sender: TObject);  //Opens the video screen to play tutorial video
    procedure bmbHelpClick(Sender: TObject);  //Part of external help: opens external pdf help document
    procedure bmbHomeClick(Sender: TObject);  //Goes back to main menu
    procedure FormClose(Sender: TObject; var Action: TCloseAction);  //Closing the form in the usual manner results in an error
  private
    { Private declarations }
    objWho : TWhoArray;
    objUsers : TUserArray;
  public
    { Public declarations }
  end;

var
  frmWhoSang: TfrmWhoSang;
  iQNum, iTempPoints, iNumCorrect, iTimePassed : integer;
  StartTime : TDateTime;          

implementation

uses
  frmMainMenu_u, frmVideo_u;

{$R *.dfm}


procedure TfrmWhoSang.FormShow(Sender: TObject);
begin
  rgpArtistOptions.Items.Clear;
  lblQNum.Caption := '';
  lblLyric.Caption := ''; 
  lblHighScore.Caption := '';
  lblPoints.Caption := '';
  btnStart.Visible := true;
  pnlOutput.Visible := false;
  bmbCheck.Visible := false;
  lblLyric.Visible := false;
  lblQNum.Visible := false;
  lblQuestion.Visible := false;
  lblTimer.Visible := false;
  lblPoints.Visible := false;
  lblHighScore.Visible := false;
  rgpArtistOptions.Visible := false;
  pnlContinue.Visible := false;
  objWho := TWhoArray.create;  //Must be created here or else shows error due to "free" in Back and Close (if player does not press start)
  objUsers := TUserArray.create;  //Must be created here or else shows error due to "free" in Back and Close (if player does not press start)
end;

procedure TfrmWhoSang.btnStartClick(Sender: TObject);
begin
  bmbCheck.Visible := true;
  lblLyric.Visible := true;
  lblQNum.Visible := true;
  lblQuestion.Visible := true;
  lblTimer.Visible := true;   
  lblPoints.Visible := true;
  lblHighScore.Visible := true;
  rgpArtistOptions.Visible := true;
  btnStart.Visible := false;
  iQNum := 1;
  iTempPoints := 0;
  iNumCorrect := 0;
  objWho := TWhoArray.create;
  objWho.RandomizeRecords;
  objUsers := TUserArray.create; 
  lblHighScore.Caption := 'Your high score is:' + #13 + IntToStr(objUsers.getCurrentUser.getHighScore);
  StartQuestion;
end;

procedure TfrmWhoSang.rgpArtistOptionsClick(Sender: TObject);
begin
  bmbCheck.Enabled := true;
end;

procedure TfrmWhoSang.bmbCheckClick(Sender: TObject);
var
  sTempUpdate : string;
begin
  tmrTimer.Enabled := false;
  bmbCheck.Enabled := false;
  
  if (TrimRight(rgpArtistOptions.Items[rgpArtistOptions.ItemIndex]) = TrimRight(objWho.getQuestion(iQNum).getArtistName)) then
    begin
      inc(iNumCorrect);
      iTempPoints := iTempPoints + 10 + objUsers.awardBonus(iTimePassed, sTempUpdate);  //runs awardBonus from objUsers which calculates the number of bonus points the user gets
      lblUpdate.Caption := sTempUpdate;
      mpSong.FileName := 'Correct.mp3';
      mpSong.Open;
      mpSong.Play;
      Sleep(mpSong.Length);
    end
  else
    begin
      lblUpdate.Caption := 'Unfortunately, you got that question incorrect.';
      mpSong.FileName := 'Incorrect.mp3';
      mpSong.Open;
      mpSong.Play;
      Sleep(mpSong.Length);
    end;    

  pnlContinue.Visible := true;
  lblPoints.Caption := IntToStr(iTempPoints) + #13 + 'points';
  mpSong.FileName := objWho.getQuestion(iQNum).getFileName;  //Plays correct song
  mpSong.Open;
  ShowMessage('Please wait while the song extract plays.');
  mpSong.Play;
end;

procedure TfrmWhoSang.btnContinueClick(Sender: TObject);
begin
  pnlContinue.Visible := false;
  lblTimer.Caption := '0s';
  if iQNum <3 then  //If game is not over
    begin
      mpSong.Stop;
      inc(iQNum);  //Move on to next question
      StartQuestion;
    end
  else  //If game is over
    begin
      if iNumCorrect = 3 then //This awards bonus points
        begin
          iTempPoints := iTempPoints + 10;
          ShowMessage('You got every question correct in this round and you receive a bonus of 10 points!');
          lblPoints.Caption := IntToStr(iTempPoints) + #13 + 'points';
        end;
      pnlOutput.Visible := true;
      if iTempPoints = 0 then
        lblResult.Caption := 'Unfortunately, ' + objUsers.getCurrentUser.getUserName + ', you did not receive any points from this game. Play again to get points! Good luck!'
      else
        lblResult.Caption := 'Well done, ' + objUsers.getCurrentUser.getUserName + '! You received ' + IntToStr(iTempPoints) + ' point(s) from this game!';
      objUsers.incPoints(iTempPoints);
      objUsers.updateHighScore(iTempPoints);
      bmbCheck.Enabled := false;  //So that they cannot attempt to continue game until closed Result panel
      bmbHome.Enabled := false;
    end;
end;

procedure TfrmWhoSang.StartQuestion;
begin
  lblQNum.Caption := 'Q' + IntToStr(iQNum);
  lblTimer.Caption := '0s';
  lblPoints.Caption := IntToStr(iTempPoints) + #13 + 'points';

  lblLyric.Caption := objWho.getQuestion(iQNum).getLyric;
  objWho.getQuestion(iQNum).RandomizeArtists;

  rgpArtistOptions.Items.Clear;            
  rgpArtistOptions.Items.Add(objWho.getQuestion(iQNum).sRandArt1);
  rgpArtistOptions.Items.Add(objWho.getQuestion(iQNum).sRandArt2);
  rgpArtistOptions.Items.Add(objWho.getQuestion(iQNum).sRandArt3);

  bmbCheck.Enabled := false;
  StartTime := Now;
  tmrTimer.Enabled := true;
end;

procedure TfrmWhoSang.tmrTimerTimer(Sender: TObject);
var
  Hour, Min, Sec, MSec : Word;
begin
  DecodeTime(TimeOf(StartTime - Now), Hour, Min, Sec, MSec);  //Borrowed code: http://stackoverflow.com/questions/23420818/convert-hhmmss-to-seconds-or-minutes-with-delphi
  iTimePassed := Hour * 3600 + Min * 60 + Sec;  //Borrowed code
  lblTimer.Caption := IntToStr(iTimePassed) + 's';
end;

procedure TfrmWhoSang.bmbBackClick(Sender: TObject);
begin
  lblResult.Caption := '';
  pnlOutput.Visible := false;
  bmbCheck.Visible := false;
  lblLyric.Visible := false;
  lblQNum.Visible := false;
  lblQuestion.Visible := false;
  lblPoints.Visible := false;
  lblHighScore.Visible := false;
  lblTimer.Visible := false;
  rgpArtistOptions.Visible := false;
  btnStart.Visible := true;
  bmbHome.Enabled := true;
  mpSong.Stop;
end;

procedure TfrmWhoSang.imgInfoWhoClick(Sender: TObject);
begin
  frmVideo.fFileName := 'WhoSang.avi';
  frmVideo.Show;
end;

procedure TfrmWhoSang.bmbHelpClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar('AcroRd32.exe'), PChar('Help.pdf'), nil, SW_SHOW);  //Borrowed code
end;

procedure TfrmWhoSang.bmbHomeClick(Sender: TObject);
begin
  frmWhoSang.Hide;
  frmMainMenu.Show;
  objWho.Free;
  objUsers.Free;
  mpSong.Close;
end;

procedure TfrmWhoSang.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmWhoSang.Hide;
  frmMainMenu.Show;
  objWho.Free;
  objUsers.Free;
  mpSong.Close;
end;

end.


