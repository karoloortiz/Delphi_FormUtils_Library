unit KLib.ShowMessageForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, RzLabel,
  RzPanel, dxGDIPlusClasses, PngImage,
  KLib.Types, Vcl.ComCtrls, RzEdit;

type
  TSizeText = (small, medium, large);

  TShowMessageFormCreate = record
    colorRGB: string;
    sizeText: TSizeText;
    title: string;
    text: string;
    textIsRTFResource: boolean;
    confirmButtonCaption: string;
    cancelButtonCaption: string;
    checkboxCaption: string;
    imgIsResource: boolean;
    imgName: string;
  end;

  TShowMessageFormResult = record
    isConfirmButtonPressed: boolean;
    isCheckBoxChecked: boolean;
  end;

  TShowMessageForm = class(TForm)
    pnl_title: TPanel;
    _spacer_title_top: TRzSpacer;
    _spacer_title_bottom: TRzSpacer;
    pnl_bottom: TPanel;
    pnl_body: TPanel;
    lbl_title: TLabel;
    pnl_button_confirm: TPanel;
    pnl_button_cancel: TPanel;
    lbl_button_cancel: TLabel;
    lbl_button_confirm: TLabel;
    _shape_button_cancel: TShape;
    _shape_button_confirm: TShape;
    _pnl_body: TPanel;
    _pnl_bodyCenter: TPanel;
    img_bodyCenter: TImage;
    richEdit_bodyText: TRzRichEdit;
    _spacer_body_bottom: TRzSpacer;
    _spacer_body_left: TRzSpacer;
    _spacer_body_right: TRzSpacer;
    _spacer_body_top: TRzSpacer;
    pnl_checkBox: TPanel;
    _spacer_checkBox_upper: TRzSpacer;
    _spacer_checkBox_bottom: TRzSpacer;
    _pnl_checkBox: TPanel;
    checkBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure pnl_button_confirmClick(Sender: TObject);
    procedure pnl_button_cancelClick(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure lbl_button_confirmClick(Sender: TObject);
    procedure lbl_button_cancelClick(Sender: TObject);
  private
    returnValue: TShowMessageFormResult;
    resourceRTFName: string;
    isCancelButtonActive: boolean;
    isCheckboxActive: boolean;
    text: string;
    img: TdxSmartImage;
    sizeText: TSizeText;
    mainColorRGB: string;
    mainColorDarker: TColor;
    procedure loadRTF;
    procedure setMainColor;
    procedure setSizeText;
    procedure setColorButtonConfirm;
    procedure setColorButtonCancel;
    procedure makePanelVisibleOnlyIfStringIsNotNull(myPanel: TPanel; myString: String);
    procedure myClose(isConfirmButtonPressed: boolean = true);
  public
    constructor Create(AOwner: TComponent; createInfo: TShowMessageFormCreate); reintroduce; overload;
  published
  end;

function myShowMessage(infoCreate: TShowMessageFormCreate): TShowMessageFormResult;

var
  ShowMessageForm: TShowMessageForm;

implementation

{$r *.dfm}


uses
  KLib.Graphics, KLib.Utils;

const
  TYPE_RESOURCE = 'RTF';

function myShowMessage(infoCreate: TShowMessageFormCreate): TShowMessageFormResult;
var
  _showMessageForm: TShowMessageForm;
  _showMessageFormCreate: TShowMessageFormCreate;
  _result: TShowMessageFormResult;
begin
  _showMessageForm := TShowMessageForm.Create(nil, infoCreate);
  _showMessageForm.ShowModal;
  _result := _showMessageForm.returnValue;
  FreeAndNil(_showMessageForm);
  result := _result;
end;

procedure TShowMessageForm.makePanelVisibleOnlyIfStringIsNotNull(myPanel: TPanel; myString: String);
begin
  if myString <> '' then
  begin
    myPanel.Visible := true;
  end
  else
  begin
    myPanel.Visible := false;
  end;
end;

constructor TShowMessageForm.Create(AOwner: TComponent; createInfo: TShowMessageFormCreate);
var
  _sizes: set of TSizeText;
begin
  _sizes := [small, medium, large];
  Create(AOwner);

  Caption := Application.Title;

  with returnValue do
  begin
    isConfirmButtonPressed := false;
    isCheckBoxChecked := false;
  end;
  with createInfo do
  begin
    self.mainColorRGB := colorRGB;
    if (sizeText in _sizes) then
    begin
      self.sizeText := sizeText;
    end
    else
    begin
      self.sizeText := TSizeText.medium;
    end;

    self.lbl_title.Caption := title;
    if textIsRTFResource then
    begin
      self.resourceRTFName := text;
    end
    else
    begin
      self.text := text;
    end;
    self.lbl_button_confirm.Caption := confirmButtonCaption;
    self.lbl_button_cancel.Caption := cancelButtonCaption;
    self.checkBox.Caption := checkboxCaption;
    if imgName <> '' then
    begin
      Self.img := TdxSmartImage.Create;
      if imgIsResource then
      begin
        Self.img.LoadFromResource(HInstance, pchar(imgName), pchar('PNG'));
      end
      else
      begin
        Self.img.LoadFromFile(imgName);
      end;
      Self.img_bodyCenter.Picture.Graphic := self.img;
    end;
  end;

  setMainColor;
  setSizeText;
  makePanelVisibleOnlyIfStringIsNotNull(pnl_title, lbl_title.Caption);
  makePanelVisibleOnlyIfStringIsNotNull(pnl_checkBox, checkBox.Caption);
  makePanelVisibleOnlyIfStringIsNotNull(pnl_button_cancel, lbl_button_cancel.Caption);
end;

procedure TShowMessageForm.setMainColor;
var
  _color: Tcolor;
  _RGB: TRGB;
begin
  if mainColorRGB <> '' then
  begin
    _RGB.loadFromString(mainColorRGB);
    setTColorToTPanel(pnl_title, _RGB.getTColor);
    mainColorDarker := getDarkerTColor(_RGB.getTColor, 1);
    setColorButtonConfirm;
    setColorButtonCancel;
  end;
end;

procedure TShowMessageForm.setSizeText;
var
  _modifiedHeightBodyText: integer;
begin
  if sizeText <> TSizeText.medium then
  begin
    _modifiedHeightBodyText := trunc(richEdit_bodyText.Height / 2);
    if sizeText = TSizeText.small then
    begin
      _modifiedHeightBodyText := -_modifiedHeightBodyText;
    end;
    pnl_body.Height := pnl_body.Height + _modifiedHeightBodyText;
    richEdit_bodyText.Height := richEdit_bodyText.Height + _modifiedHeightBodyText;
  end;
end;

procedure TShowMessageForm.setColorButtonConfirm;
begin
  _shape_button_confirm.Brush.Color := mainColorDarker;
  _shape_button_confirm.Pen.Color := mainColorDarker;
end;

procedure TShowMessageForm.setColorButtonCancel;
begin
  _shape_button_cancel.Brush.Color := clWhite;
  _shape_button_cancel.Pen.Color := mainColorDarker;
  lbl_button_cancel.Font.Color := mainColorDarker;
end;

procedure TShowMessageForm.FormCreate(Sender: TObject);
begin
  richEdit_bodyText.Lines.Text := text;
  if resourceRTFName <> '' then
  begin
    loadRTF;
  end;

  img_bodyCenter.Visible := Assigned(img);
end;

procedure TShowMessageForm.loadRTF;
var
  _resourceStream: TResourceStream;
begin
  _resourceStream := getResourceAsStream(resourceRTFName, TYPE_RESOURCE);
  richEdit_bodyText.PlainText := False;
  richEdit_bodyText.Lines.LoadFromStream(_resourceStream);
  FreeAndNil(_resourceStream);
end;

procedure TShowMessageForm.lbl_button_cancelClick(Sender: TObject);
begin
  pnl_button_cancelClick(Sender);
end;

procedure TShowMessageForm.pnl_button_cancelClick(Sender: TObject);
begin
  myClose(false);
end;

procedure TShowMessageForm.lbl_button_confirmClick(Sender: TObject);
begin
  pnl_button_confirmClick(Sender);
end;

procedure TShowMessageForm.Panel2Click(Sender: TObject);
begin
  pnl_button_confirmClick(Sender);
end;

procedure TShowMessageForm.pnl_button_confirmClick(Sender: TObject);
begin
  myClose;
end;

procedure TShowMessageForm.myClose(isConfirmButtonPressed: boolean = true);
begin
  returnValue.isConfirmButtonPressed := isConfirmButtonPressed;
  returnValue.isCheckBoxChecked := checkBox.Checked;
  close;
end;

end.
