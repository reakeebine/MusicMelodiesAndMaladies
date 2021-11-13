unit frmVideo_u;  //Most of this is borrowed code

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, jpeg, StdCtrls, Buttons, ComCtrls, MPlayer, ShellApi;

type
  TfrmVideo = class(TForm)
    mpVideo: TMediaPlayer;
    trkLength: TTrackBar;
    bmbBack: TBitBtn;
    imgBG1: TImage;
    pnlTime: TPanel;
    pnlVideoDisp: TPanel;
    tmrLength: TTimer;
    bmbHelp: TBitBtn;
    procedure FormShow(Sender: TObject);  //Retrieves file name from text file and opens video file
    procedure FormResize(Sender: TObject);  //Allows for the video to resize if the form is resized
    procedure tmrLengthTimer(Sender: TObject);  //Tracks length of video
    procedure bmbBackClick(Sender: TObject);  //Goes back to screen from which user came and stops video playback
    procedure FormClose(Sender: TObject; var Action: TCloseAction);  //frees memory of media player
    procedure bmbHelpClick(Sender: TObject);  //Closing the form normally results in an error
  private
    { Private declarations }
  public
    { Public declarations }    
    fFileName : string;
  end;

var
  frmVideo: TfrmVideo;

implementation

uses frmMainMenu_u;

{$R *.dfm}

procedure TfrmVideo.FormShow(Sender: TObject);
begin
  tmrLength.Enabled := false;
  mpVideo.Close;
  mpVideo.FileName := fFileName;
  mpVideo.Open;
  mpVideo.DisplayRect := pnlVideoDisp.ClientRect;
  tmrLength.Enabled := True;
  mpVideo.Play;
end;

procedure TfrmVideo.FormResize(Sender: TObject);
begin
  mpVideo.DisplayRect := pnlVideoDisp.ClientRect;
end;

procedure TfrmVideo.tmrLengthTimer(Sender: TObject);  //borrowed code
begin
  mpVideo.TimeFormat := tfMilliseconds;
  pnlTime.Caption := FormatDateTime('hh:mm:ss', mpVideo.Position/1000/(24*60*60));
  trkLength.Max := mpVideo.Length;
  trkLength.Position := mpVideo.Position;
end;

procedure TfrmVideo.bmbBackClick(Sender: TObject);
begin
  frmVideo.Hide;
  mpVideo.Stop;
end;

procedure TfrmVideo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmVideo.Hide;
  mpVideo.Stop;
end;

procedure TfrmVideo.bmbHelpClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar('AcroRd32.exe'), PChar('Help.pdf'), nil, SW_SHOW);  //Borrowed code
end;

end.
