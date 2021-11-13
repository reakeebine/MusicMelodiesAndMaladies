unit frmFinishLyric_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, Buttons, ShellApi, MPlayer, DateUtils,
  clsUser_u, clsUserArray_u, clsFinish_u, clsFinishArray_u;

type
  TfrmFinishLyric = class(TForm)
    bmbBack: TBitBtn;
    bmbCheck: TBitBtn;
    bmbHelp: TBitBtn;
    bmbHome: TBitBtn;
    btnContinue: TButton;
    btnStart: TButton;
    imgBG2: TImage;
    imgBG4: TImage;
    imgBG4__: TImage;
    imgInfoFinish: TImage;
    lblBeginLyric: TLabel;
    lblCongrats: TLabel;
    lblFinishLyric: TLabel;
    lblGameTitle: TLabel;
    lblHighScore: TLabel;
    lblPoints: TLabel;
    lblQNum: TLabel;
    lblQuestion: TLabel;
    lblResult: TLabel;
    lblTimer: TLabel;
    lblUpdate: TLabel;
    mpSong: TMediaPlayer;
    pnlContinue: TPanel;
    pnlOutput: TPanel;
    rgpLyricOptions: TRadioGroup;
    tmrTimer: TTimer;
    procedure FormShow(Sender: TObject);  //Instantiates objects, resets/clears game screen
    procedure btnStartClick(Sender: TObject);  //Shows first question, starts game
    procedure rgpLyricOptionsClick(Sender: TObject);  //Enables btnCheck, part of defensive coding
    procedure bmbCheckClick(Sender: TObject);  //Verifies whether answer correct or not and updates points if necessary
    procedure btnContinueClick(Sender: TObject);  //Checks if game has ended (if so will end game if on third question); Shows user results
    procedure StartQuestion;  //Method used to reset game for new question
    procedure tmrTimerTimer(Sender: TObject);  //Shows time in timer label once timer is enabled
    procedure bmbBackClick(Sender: TObject);  //Resets entire game screen
    procedure imgInfoFinishClick(Sender: TObject);  //Opens the video screen to play tutorial video
    procedure bmbHelpClick(Sender: TObject);  //Part of external help: opens external pdf help document
    procedure bmbHomeClick(Sender: TObject);  //Goes back to main menu
    procedure FormClose(Sender: TObject; var Action: TCloseAction);  //Closing the form in the usual manner results in an error
  private
    { Private declarations }
    objFinish : TFinishArray;
    objUsers : TUserArray;
  public
    { Public declarations }
  end;

var
  frmFinishLyric : TfrmFinishLyric;
  iQNum, iTempPoints, iNumCorrect, iTimePassed : integer;
  StartTime : TDateTime;

implementation

uses
  frmMainMenu_u, frmVideo_u;

{$R *.dfm}


procedure TfrmFinishLyric.FormShow(Sender: TObject);
begin
  rgpLyricOptions.Items.Clear;
  lblQNum.Caption := '';
  lblBeginLyric.Caption := '';
  lblHighScore.Caption := '';
  lblPoints.Caption := '';
  btnStart.Visible := true;
  pnlOutput.Visible := false;
  bmbCheck.Visible := false;
  lblBeginLyric.Visible := false;
  lblQNum.Visible := false;
  lblQuestion.Visible := false;
  lblTimer.Visible := false;
  lblPoints.Visible := false;
  lblHighScore.Visible := false;
  rgpLyricOptions.Visible := false;
  pnlContinue.Visible := false;
  objFinish := TFinishArray.create;  //Must be created here or else shows error due to "free" in Back and Close (if player does not press start)
  objUsers := TUserArray.create;  //Must be created here or else shows error due to "free" in Back and Close (if player does not press start)
end;

procedure TfrmFinishLyric.btnStartClick(Sender: TObject);
begin
  bmbCheck.Visible := true;
  lblBeginLyric.Visible := true;
  lblQNum.Visible := true;
  lblQuestion.Visible := true;
  lblTimer.Visible := true;
  lblPoints.Visible := true;
  lblHighScore.Visible := true;
  rgpLyricOptions.Visible := true;
  btnStart.Visible := false;
  iQNum := 1;
  iTempPoints := 0;
  iNumCorrect := 0;
  objFinish := TFinishArray.create;
  objFinish.RandomizeRecords;
  objUsers := TUserArray.create;      
  lblHighScore.Caption := 'Your high score is:' + #13 + IntToStr(objUsers.getCurrentUser.getHighScore);
  StartQuestion;
end;

procedure TfrmFinishLyric.rgpLyricOptionsClick(Sender: TObject);
begin
  bmbCheck.Enabled := true;
end;

procedure TfrmFinishLyric.bmbCheckClick(Sender: TObject);
var
  sTempUpdate : string;
begin
  tmrTimer.Enabled := false;
  bmbCheck.Enabled := false;

  if (TrimRight(rgpLyricOptions.Items[rgpLyricOptions.ItemIndex]) = TrimRight(objFinish.getQuestion(iQNum).getCorrectLyric)) then  //This is to play the correct/incorrect tone and show a message saying whether correct/incorrect
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
  mpSong.FileName := objFinish.getQuestion(iQNum).getFileName;  //Plays correct song
  mpSong.Open;
  ShowMessage('Please wait while the song extract plays.');
  mpSong.Play;
end;

procedure TfrmFinishLyric.btnContinueClick(Sender: TObject);
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

procedure TfrmFinishLyric.StartQuestion;
begin
  lblQNum.Caption := 'Q' + IntToStr(iQNum);
  lblTimer.Caption := '0s';
  lblPoints.Caption := IntToStr(iTempPoints) + #13 + 'points';

  lblBeginLyric.Caption := objFinish.getQuestion(iQNum).getBeginLyric;
  objFinish.getQuestion(iQNum).RandomizeLyrics;

  rgpLyricOptions.Items.Clear;
  rgpLyricOptions.Items.Add(objFinish.getQuestion(iQNum).sRandLyr1);
  rgpLyricOptions.Items.Add(objFinish.getQuestion(iQNum).sRandLyr2);
  rgpLyricOptions.Items.Add(objFinish.getQuestion(iQNum).sRandLyr3);
  
  bmbCheck.Enabled := false;
  StartTime := Now;
  tmrTimer.Enabled := true;
end;

procedure TfrmFinishLyric.tmrTimerTimer(Sender: TObject);
var
  Hour, Min, Sec, MSec : Word;
begin
  DecodeTime(TimeOf(StartTime - Now), Hour, Min, Sec, MSec);  //Borrowed code: http://stackoverflow.com/questions/23420818/convert-hhmmss-to-seconds-or-minutes-with-delphi
  iTimePassed := Hour * 3600 + Min * 60 + Sec;  //Borrowed code
  lblTimer.Caption := IntToStr(iTimePassed) + 's';
end;

procedure TfrmFinishLyric.bmbBackClick(Sender: TObject);
begin
  lblResult.Caption := '';
  pnlOutput.Visible := false;
  bmbCheck.Visible := false;
  lblBeginLyric.Visible := false;
  lblQNum.Visible := false;
  lblQuestion.Visible := false;
  lblPoints.Visible := false;
  lblHighScore.Visible := false;
  lblTimer.Visible := false;
  rgpLyricOptions.Visible := false;
  btnStart.Visible := true;
  bmbHome.Enabled := true;
  mpSong.Stop;
end;

procedure TfrmFinishLyric.imgInfoFinishClick(Sender: TObject);
begin
  frmVideo.fFileName := 'FinishLyric.avi';
  frmVideo.Show; 
end;

procedure TfrmFinishLyric.bmbHelpClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar('AcroRd32.exe'), PChar('Help.pdf'), nil, SW_SHOW);  //Borrowed code
end;

procedure TfrmFinishLyric.bmbHomeClick(Sender: TObject);
begin
  frmFinishLyric.Hide;
  frmMainMenu.Show;
  objFinish.Free;
  objUsers.Free;
  mpSong.Close;
end;

procedure TfrmFinishLyric.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmFinishLyric.Hide;
  frmMainMenu.Show;
  objFinish.Free;
  objUsers.Free;
  mpSong.Close;
end;

end.
