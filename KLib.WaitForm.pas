unit KLib.WaitForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.StdCtrls, RzLabel, dxActivityIndicator;

type
  TWaitForm = class(TForm)
    activityIndicator: TdxActivityIndicator;
    lbl_title: TRzLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WaitForm: TWaitForm;

implementation

{$r *.dfm}


procedure TWaitForm.FormShow(Sender: TObject);
begin
  activityIndicator.Enabled := true;
  self.Caption := Application.Name;
end;

end.
