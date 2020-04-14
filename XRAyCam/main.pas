unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, PasLibVlcPlayerUnit;

type
  TForm1 = class(TForm)
    pslbvlcplyr1: TPasLibVlcPlayer;
    pslbvlcplyr2: TPasLibVlcPlayer;
    pslbvlcplyr3: TPasLibVlcPlayer;
    pslbvlcplyr4: TPasLibVlcPlayer;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  pslbvlcplyr1.Play('rtsp://10.10.0.101:7447/vod/d219c2de-75dc-33b5-9e58-d5ad5d6a177e_1');
  pslbvlcplyr2.Play('rtsp://10.10.0.101:7447/vod/8382c9e5-a9f6-396f-a2e4-bf55fdb9974b_1');
  pslbvlcplyr3.Play('rtsp://10.10.0.101:7447/vod/b8b00f6d-c19b-3461-a2e8-86552a6fb112_1');
  pslbvlcplyr4.Play('rtsp://10.10.0.100:7447/34efd7fa-db8e-365f-a731-ddc8c90da2c6_1');
end;

end.
