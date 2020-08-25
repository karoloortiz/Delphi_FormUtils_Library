unit KLib.WaitForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.StdCtrls, RzLabel, dxActivityIndicator,
  KLib.Types;

const
  WM_TWAITFORM_START = WM_USER + 1000;
  WM_TWAITFORM_PROCEDURE_OK = WM_USER + 1001;
  WM_TWAITFORM_PROCEDURE_ERR = WM_USER + 1002;

procedure executeProcedureInWaitForm(syncProcedure: TProcedureOfObject; textWait: string; font: TFont = nil);

type
  TWaitForm = class(TForm)
    activityIndicator: TdxActivityIndicator;
    lbl_title: TLabel;
    procedure FormShow(Sender: TObject);
  private
    e: Exception;
    myCustomProcedure: TProcedureOfObject;
    procedure on_start(var Msg: TMessage); message WM_TWAITFORM_START;
    procedure on_procedure_ok(var Msg: TMessage); message WM_TWAITFORM_PROCEDURE_OK;
    procedure on_procedure_err(var Msg: TMessage); message WM_TWAITFORM_PROCEDURE_ERR;
  public
    { Public declarations }
  end;

var
  WaitForm: TWaitForm;

implementation

{$r *.dfm}


uses
  klib.utils;

procedure executeProcedureInWaitForm(syncProcedure: TProcedureOfObject; textWait: string; font: TFont = nil);
var
  _waitForm: TWaitForm;
  errorMsg: string;
begin
  _waitForm := TWaitForm.Create(nil);
  _waitForm.myCustomProcedure := syncProcedure;
  if font <> nil then
  begin
    _waitForm.lbl_title.Font := font;
  end
  else
  begin
    _waitForm.lbl_title.Font.Size := 20;
  end;
  _waitForm.lbl_title.Caption := textWait;
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
var
  _reply: TAsyncifyProcedureReply;
begin
  activityIndicator.Enabled := true;
  self.Caption := Application.Name;
  PostMessage(Handle, WM_TWAITFORM_START, 0, 0);
end;

procedure TWaitForm.on_start(var Msg: TMessage);
var
  _reply: TAsyncifyProcedureReply;
begin
  if Assigned(myCustomProcedure) then
  begin
    with _reply do
    begin
      handle := self.Handle;
      msg_resolve := WM_TWAITFORM_PROCEDURE_OK;
      msg_reject := WM_TWAITFORM_PROCEDURE_ERR;
    end;
    asyncifyProcedure(myCustomProcedure, _reply);
  end;
end;

procedure TWaitForm.on_procedure_ok(var Msg: TMessage);
begin
  activityIndicator.Enabled := false;
  Close;
end;

procedure TWaitForm.on_procedure_err(var Msg: TMessage);
var
  _errorMsg: string;
begin
  activityIndicator.Enabled := false;
  _errorMsg := PansiChar(msg.LParam);
  e := Exception.Create(_errorMsg);
  close;
end;

end.
