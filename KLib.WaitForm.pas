unit KLib.WaitForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.StdCtrls, RzLabel, dxActivityIndicator,
  KLib.Types;

const
  WM_TWAITFORM_START = WM_USER + 1000;
  WM_TWAITFORM_METHOD_OK = WM_USER + 1001;
  WM_TWAITFORM_METHOD_ERR = WM_USER + 1002;

procedure executeMethodInWaitForm(syncMethod: TMethod; textWait: string; font: TFont = nil);

type
  TWaitForm = class(TForm)
    activityIndicator: TdxActivityIndicator;
    lbl_title: TLabel;
    procedure FormShow(Sender: TObject);
  private
    e: Exception;
    customMethod: TMethod;
    function getTitle: string;
    procedure setTitle(value: string);
    procedure onStart(var Msg: TMessage); message WM_TWAITFORM_START;
    procedure onMethodOk(var Msg: TMessage); message WM_TWAITFORM_METHOD_OK;
    procedure onMethodErr(var Msg: TMessage); message WM_TWAITFORM_METHOD_ERR;
  public
    property title: string read getTitle write setTitle;
    procedure close; overload;
  end;

implementation

{$r *.dfm}


uses
  Klib.Async;

procedure executeMethodInWaitForm(syncMethod: TMethod; textWait: string; font: TFont = nil);
var
  _waitForm: TWaitForm;
  errorMsg: string;
begin
  _waitForm := TWaitForm.Create(nil);
  _waitForm.customMethod := syncMethod;
  if font <> nil then
  begin
    _waitForm.lbl_title.Font := font;
  end
  else
  begin
    _waitForm.lbl_title.Font.Size := 20;
  end;
  _waitForm.title := textWait;
  _waitForm.ShowModal;

  if Assigned(_waitForm.e) then
  begin
    errorMsg := _waitForm.e.Message;
  end;

  FreeAndNil(_waitForm);

  if errorMsg <> '' then
  begin
    raise Exception.Create(errorMsg);
  end;
end;

procedure TWaitForm.FormShow(Sender: TObject);
begin
  activityIndicator.Enabled := true;
  self.Caption := Application.Name;
  PostMessage(Handle, WM_TWAITFORM_START, 0, 0);
end;

function TWaitForm.getTitle: string;
begin
  Result := lbl_title.Caption;
end;

procedure TWaitForm.setTitle(value: string);
begin
  lbl_title.Caption := value;
end;

procedure TWaitForm.onStart(var Msg: TMessage);
var
  _reply: TAsyncifyProcedureReply;
begin
  if Assigned(customMethod) then
  begin
    with _reply do
    begin
      handle := self.Handle;
      msg_resolve := WM_TWAITFORM_METHOD_OK;
      msg_reject := WM_TWAITFORM_METHOD_ERR;
    end;
    asyncifyMethod(customMethod, _reply);
  end;
end;

procedure TWaitForm.onMethodOk(var Msg: TMessage);
begin
  activityIndicator.Enabled := false;
  close;
end;

procedure TWaitForm.onMethodErr(var Msg: TMessage);
var
  _errorMsg: string;
begin
  activityIndicator.Enabled := false;
  _errorMsg := PansiChar(msg.LParam);
  e := Exception.Create(_errorMsg);
  close;
end;

procedure TWaitForm.close;
begin
  Release;
  inherited close;
end;

end.
