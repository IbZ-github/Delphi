unit pingthread;

interface

uses
  Classes,NMICMP;

type
  TPingThread = class(TThread)
  private
    { Private declarations }
    nmpng: TNMPing;
    procedure doOnPingReply;
  protected
    procedure Execute; override;
  public
    Host : string;
    constructor Create(index: integer);
  end;


implementation

constructor TPingThread.Create(index: integer);
begin
  inherited Create(false);
  nmpng := TNMPing.Create(nil);
  nmpng.Host := Host;
  self.FreeOnTerminate := true;
end;

procedure TPingThread.doOnPingReply;
begin
  Mmo1.lines.add(host);
end;

procedure TPingThread.Execute;
begin
  { Place thread code here }
inherited;

  Synchronize(doOnPingReply);
end;

end.
