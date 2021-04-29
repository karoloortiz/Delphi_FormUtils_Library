{
  KLib Version = 1.0
  The Clear BSD License

  Copyright (c) 2020 by Karol De Nery Ortiz LLave. All rights reserved.
  zitrokarol@gmail.com

  Redistribution and use in source and binary forms, with or without
  modification, are permitted (subject to the limitations in the disclaimer
  below) provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  * Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

  NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY
  THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
  CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
}
unit KLib.WaitForm;

interface

uses
  KLib.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  cxLookAndFeelPainters, cxGraphics, cxControls, cxLookAndFeels, dxActivityIndicator;

const
  WM_TWAITFORM_START = WM_USER + 1000;
  WM_TWAITFORM_METHOD_OK = WM_USER + 1001;
  WM_TWAITFORM_METHOD_ERR = WM_USER + 1002;

procedure executeMethodInWaitForm(syncMethod: TMethod; textWait: string; font: TFont = nil);

type
  TWaitForm = class(TForm)
    activityIndicator: TdxActivityIndicator;
    title_lbl: TLabel;
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
  errMsg: string;
begin
  _waitForm := TWaitForm.Create(nil);
  _waitForm.customMethod := syncMethod;
  if font <> nil then
  begin
    _waitForm.title_lbl.Font := font;
  end
  else
  begin
    _waitForm.title_lbl.Font.Size := 20;
  end;
  _waitForm.title := textWait;
  _waitForm.ShowModal;

  if Assigned(_waitForm.e) then
  begin
    errMsg := _waitForm.e.Message;
  end;

  FreeAndNil(_waitForm);

  if errMsg <> '' then
  begin
    raise Exception.Create(errMsg);
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
  Result := title_lbl.Caption;
end;

procedure TWaitForm.setTitle(value: string);
begin
  title_lbl.Caption := value;
end;

procedure TWaitForm.onStart(var Msg: TMessage);
var
  _reply: TAsyncifyMethodReply;
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
  _errMsg: string;
begin
  activityIndicator.Enabled := false;
  _errMsg := string(PansiChar(msg.LParam));
  e := Exception.Create(_errMsg);
  close;
end;

procedure TWaitForm.close;
begin
  Release;
  inherited close;
end;

end.
