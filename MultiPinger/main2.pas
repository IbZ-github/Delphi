unit main2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NMICMP, StdCtrls;

type
  TFormMain = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TPingThread = class(TThread)
  private
    { Private declarations }
    nmpng: TNMPing;
    PingHost: String;
    PingName : string;
    PingSize:Integer;
    PingTime: Integer;
    PingStatus: Integer;
    PingTotal: Integer;
    PingSuccess: Integer;
    PingSumTime: Real;
    PingLabel : TLabel;
    PingMemo : TMemo;
    procedure doOnPingReply;
    procedure NMPingPing(Sender: TObject; Host: String; Size, Time: Integer);
    procedure NMPingStatus(Sender: TObject; Status: Integer; Host: String);
  protected
    procedure Execute; override;
  public
    logstring: string;
    constructor Create(Host: string; Name: string; lbl: TLabel; mmo:TMemo);
  end;


var
  FormMain: TFormMain;
  NumPings: Integer = 0;
  PT: array[1..100] of record
         PingThread: TPingThread;
         Lbl: TLabel;
         Mmo: TMemo;
      end;
implementation

{$R *.dfm}

constructor TPingThread.Create(Host: string; Name: string; lbl: TLabel; mmo:TMemo);
begin
  inherited Create(false);
  nmpng := TNMPing.Create(nil);
  nmpng.Host := Host;
  nmpng.Pings := 1;
  nmpng.OnPing := NMPingPing;
  nmpng.OnStatus := NMPingStatus;
  PingLabel := lbl;
  PingMemo := mmo;
  PingTotal := 0;
  PingSuccess := 0;
  PingSumTime := 0;
  PingName := Name;
  self.FreeOnTerminate := true;
end;

procedure TPingThread.doOnPingReply;
var
  s: string;
begin
  Inc(PingTotal);
  if PingStatus = 0 then begin
    PingMemo.Lines.Append('����� �� '+PingHost+': ����� ����='+IntToStr(PingSize) + ' �����='+IntToStr(PingTime)+'��');
    PingSumTime := PingSumTime + PingTime;
    Inc(PingSuccess);
    PingLabel.Color := clMoneyGreen;
    PingLabel.Font.Color := clBlack;
  end
  else begin
    case PingStatus of
      11001: PingMemo.Lines.Add('����� �� '+PingHost+': ����� ������� ���');
      11002: PingMemo.Lines.Add('����� �� '+PingHost+': �������� ���� ����������');
      11003: PingMemo.Lines.Add('����� �� '+PingHost+': �������� ���� ����������');
      11004: PingMemo.Lines.Add('����� �� '+PingHost+': �������� �������� ����������');
      11005: PingMemo.Lines.Add('����� �� '+PingHost+': �������� ���� ����������');
      11006: PingMemo.Lines.Add('��� ��������');
      11007: PingMemo.Lines.Add('������ ������');
      11008: PingMemo.Lines.Add('������ ������������');
      11009: PingMemo.Lines.Add('����� �� '+PingHost+': ����� ������� �������');
      11010: PingMemo.Lines.Add('�������� �������� �������� ��� �������');
      11011: PingMemo.Lines.Add('�������� ������');
      11012: PingMemo.Lines.Add('�������� �������');
      11013: PingMemo.Lines.Add('�������� TTL');
      11014: PingMemo.Lines.Add('�������� TTL ������');
      11015: PingMemo.Lines.Add('������������ ��������');
      11017: PingMemo.Lines.Add('�������� ������� �����');
      11018: PingMemo.Lines.Add('����� �� '+PingHost+': ������ ����� ����������');
      11050: PingMemo.Lines.Add('����� ������');
      else  PingMemo.Lines.Add('����� �� '+PingHost+': ������='+IntToStr(PingStatus));
    end;
    PingLabel.Color := clMaroon;
    PingLabel.Font.Color := clWhite;
  end;
  PingMemo.Perform(EM_LINESCROLL,0,-1);
  logstring := nmpng.Host+'('+PingName+'): ��������='+IntToStr(PingSuccess)+' �� ����� ���������='+IntToStr(PingTotal);
  s := PingName + ': '+IntToStr(PingSuccess)+'/'+IntToStr(PingTotal);
  if PingTotal > 0 then begin
    s := s + '=' + Format('%0.0f',[PingSuccess/PingTotal*100])+'%';
    logstring := logstring + ' ����.='+Format('%0.2f',[PingSuccess/PingTotal*100])+'%';
  end;
  if PingSuccess > 0 then begin
    s := s + ' ��.�����:'+Format('%0.2f',[PingSumTime/PingSuccess])+'��';
    logstring := logstring + ' ����.�����:'+Format('%0.2f',[PingSumTime/PingSuccess])+'��';
  end;
  PingLabel.Caption := s;
end;

procedure TPingThread.Execute;
begin
  { Place thread code here }
  inherited;
  while True do begin
    nmpng.Ping;
    Synchronize(doOnPingReply);
    Sleep(1000);
  end;
end;

procedure TPingThread.NMPingPing(Sender: TObject; Host: String; Size, Time: Integer);
begin
  PingHost := Host;
  PingSize := Size;
  PingTime := Time;
end;

procedure TPingThread.NMPingStatus(Sender: TObject; Status: Integer; Host: String);
begin
  PingHost := Host;
  PingStatus := Status;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  i: Integer;
  CONFIG: TStringList;
begin
//  ShowMessage(IntToStr(FormMain.ClientWidth)+'x'+IntToStr(FormMain.ClientHeight));
  CONFIG := TStringList.Create;
  if(FileExists('mpinger.conf')) then CONFIG.LoadFromFile('mpinger.conf')
                                 else begin
                                   ShowMessage('��������� MultiPinger / MPinger ��������� ��� ���������� � ������ ��������� �������'#13+
                                               '�� 96 ������ ������������. �������� ��������� �� ������� �������� � ����������� 1920�1080'#13+
                                               '� ������� �������� ��������� ���������� ������� ������ ���� mpinger.conf � ���� ��������'#13+
                                               '���������� ����� � ������ ������ �������� � ���� '#13#13+
                                               '<��-�����>=<�������� �����>'#13#13+
                                               '����� ������ ��-������ � �������� ������ ��� ����������'#13+
                                               '���������� ��� �������� ��������� ����� �������� � ���-���� mpinger.log');
                                   Application.Terminate;
                                 end;


  for i := 1 to CONFIG.Count do begin
    if CONFIG.Strings[i-1] = '' then Continue;
    Inc(NumPings);
    if NumPings > 96 then begin
      Dec(NumPings);
      ShowMessage('� ������-����� ������� ������ 96 ������, �� ����� ������������ ������ ������ 96');
      Break;
    end;
    PT[NumPings].Lbl := TLabel.Create(self);
    PT[NumPings].Lbl.Parent := FormMain;
    PT[NumPings].Lbl.Top := ((NumPings-1) div 8) * 90+4;
    PT[NumPings].Lbl.Left := ((NumPings-1) mod 8) * 240;
    PT[NumPings].Lbl.Width := 240;
    PT[NumPings].Lbl.OnMouseDown := FormMouseDown;

    PT[NumPings].Mmo := TMemo.Create(self);
    PT[NumPings].Mmo.Parent := FormMain;
    PT[NumPings].Mmo.Top := ((NumPings-1) div 8) * 90+20;
    PT[NumPings].Mmo.Left := ((NumPings-1) mod 8) * 240;
    PT[NumPings].Mmo.Width := 240;
    PT[NumPings].Mmo.Height := 70;

    PT[NumPings].Mmo.Lines.Clear;
    PT[NumPings].Mmo.Color := clBlack;
    PT[NumPings].Mmo.Font.Color := clWhite;
    PT[NumPings].Mmo.Font.Size := 7;

    PT[NumPings].PingThread := TPingThread.Create(CONFIG.Names[i-1], CONFIG.ValueFromIndex[i-1], PT[NumPings].Lbl, PT[NumPings].Mmo);
  end;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  F: TextFile;
  i: Integer;
begin
  AssignFile(F, 'MPinger.log');
  If FileExists('MPinger.log') then Append(F)
                               else Rewrite(F);
  Writeln(F,'++++++++++++++++++++++++++++++++++++++++++++++++++');
  Writeln(F,DateTimeToStr(Now));
  for i := 1 to NumPings do begin
    Writeln(F,PT[i].PingThread.logstring);
    PT[i].PingThread.Terminate;
  end;
  WriteLn(F,'');
  CloseFile(F);
end;

procedure TFormMain.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
  SC_DragMove = $F012;  { a magic number }
begin
  ReleaseCapture;
  perform(WM_SysCommand, SC_DragMove, 0);
  FormMain.WindowState := wsMaximized;
end;

end.
