unit KLib.RTFForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.OleCtrls,
  Vcl.ComCtrls, RzEdit, Vcl.StdCtrls, dxGDIPlusClasses,
  KLib.Types;

type
  TSizeRTF = (medium, small, large);

  TRTFFormCreate = record
    sizePDF: TSizeRTF;
    pathRTF: string;
    showScrollbar: boolean;
    titleCaption: string;
    checkboxCaption: string;
    confirmButtonCaption: string;
    colorRGBConfirmButton: string;
  end;

  TRTFForm = class(TForm)
    pnl_bottom: TPanel;
    _img_checkBox_unCheck: TImage;
    _img_checkBox_check: TImage;
    checkBox_img: TImage;
    _pnl_bottom: TPanel;
    lbl_checkBox: TLabel;
    buttom_pnl_confirm: TPanel;
    _pnl_head: TPanel;
    button_exit: TImage;
    pnl_checkbox: TPanel;
    lbl_title: TLabel;
    richEdit_bodyText: TRzRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure checkBox_imgClick(Sender: TObject);
    procedure button_exitClick(Sender: TObject);
    procedure buttom_pnl_confirmClick(Sender: TObject);
  private
    sizeRTF: TSizeRTF;
    pathRTF: string;
    showScrollbar: boolean;
    colorRGBConfirmButton: string;

    colorButtom: TColorButtom;
    isCheckBoxChecked: boolean;

    procedure disableConfirmButtom;
    procedure enableConfirmButtom;
    procedure setSizeRTF;
    procedure setColorButtom;
    procedure initializeGraphicSettings;
    procedure initializeVariables;
    procedure loadRTFFromFile;
  public
    result: boolean;
    constructor Create(AOwner: TComponent; createInfo: TRTFFormCreate); reintroduce; overload;
  end;

procedure showRTF(myRTFPath: string; mytitleCaption: string = '');
function showCustomRTF(infoCreate: TRTFFormCreate): boolean;

var
  RTFForm: TRTFForm;

implementation

{$r *.dfm}


uses
  KLib.Graphics;

const
  RGBCOLOR_DISABLED_BUTTON = '180180180';

procedure showRTF(myRTFPath: string; mytitleCaption: string = '');
var
  _RTFFormCreate: TRTFFormCreate;
begin
  with _RTFFormCreate do
  begin
    pathRTF := myRTFPath;
    titleCaption := mytitleCaption;
    showScrollbar := true;
  end;
  showCustomRTF(_RTFFormCreate);
end;

function showCustomRTF(infoCreate: TRTFFormCreate): boolean;
var
  _RTFForm: TRTFForm;
  _result: boolean;
begin
  infoCreate.pathRTF := ExpandFileName(infoCreate.pathRTF);
  _RTFForm := TRTFForm.Create(nil, infoCreate);
  _RTFForm.ShowModal;
  _result := _RTFForm.result;
  result := _result;
  FreeAndNil(_RTFForm);
end;

constructor TRTFForm.Create(AOwner: TComponent; createInfo: TRTFFormCreate);
var
  _sizes: set of TSizeRTF;
begin
  Create(AOwner);
  _sizes := [small, medium, large];

  with createInfo do
  begin
    if (sizePDF in _sizes) then
    begin
      self.sizeRTF := sizePDF;
    end
    else
    begin
      self.sizeRTF := TSizeRTF.medium;
    end;
    self.pathRTF := pathRTF;
    Self.showScrollbar := showScrollbar;
    self.lbl_title.Caption := titleCaption;
    self.lbl_checkBox.Caption := checkboxCaption;
    self.buttom_pnl_confirm.Caption := confirmButtonCaption;
    self.colorRGBConfirmButton := colorRGBConfirmButton;
  end;

  initializeVariables;
  initializeGraphicSettings;
end;

procedure TRTFForm.initializeVariables;
begin
  result := false;
  isCheckBoxChecked := false;
  setColorButtom;
end;

procedure TRTFForm.setColorButtom;
begin
  colorButtom.disabled := RGBStringToTColor(RGBCOLOR_DISABLED_BUTTON);
  if colorRGBConfirmButton <> '' then
  begin
    colorButtom.enabled := RGBStringToTColor(colorRGBConfirmButton);
  end
  else
  begin
    colorButtom.enabled := buttom_pnl_confirm.Color;
  end;
end;

procedure TRTFForm.initializeGraphicSettings;
begin
  Caption := Application.Title;
  makePanelVisibleOnlyIfStringIsNotNull(pnl_checkbox, lbl_checkBox.Caption);
  makePanelVisibleOnlyIfStringIsNotNull(buttom_pnl_confirm, buttom_pnl_confirm.Caption);
  pnl_bottom.Visible := pnl_checkbox.Visible or buttom_pnl_confirm.Visible;
  setComponentInMiddlePosition(lbl_title);
  setComponentInMiddlePosition(buttom_pnl_confirm);
  setComponentInMiddlePosition(_pnl_bottom);
  setSizeRTF;
  disableConfirmButtom;

  richEdit_bodyText.HideScrollBars := not showScrollbar;
end;

procedure TRTFForm.setSizeRTF;
var
  _modifiedHeight: integer;
begin
  if sizeRTF <> TSizeRTF.medium then
  begin
    _modifiedHeight := trunc(richEdit_bodyText.Height / 2.5);
    if sizeRTF = TSizeRTF.small then
    begin
      _modifiedHeight := -_modifiedHeight;
    end;
    self.Height := self.Height + _modifiedHeight;
  end;
end;

procedure TRTFForm.FormCreate(Sender: TObject);
begin
  loadRTFFromFile;
end;

procedure TRTFForm.loadRTFFromFile;
var
  _fiileStream: TFileStream;
begin
  _fiileStream := TFileStream.Create(pathRTF, fmOpenRead);
  richEdit_bodyText.PlainText := False;
  richEdit_bodyText.Lines.LoadFromStream(_fiileStream);
  FreeAndNil(_fiileStream);
end;

procedure TRTFForm.checkBox_imgClick(Sender: TObject);
begin
  isCheckBoxChecked := not isCheckBoxChecked;
  if isCheckBoxChecked then
  begin
    checkBox_img.Picture := _img_checkBox_check.Picture;
    enableConfirmButtom;
  end
  else
  begin
    checkBox_img.Picture := _img_checkBox_unCheck.Picture;
    disableConfirmButtom;
  end;
end;

procedure TRTFForm.disableConfirmButtom;
begin
  buttom_pnl_confirm.Enabled := false;
  setTColorToTPanel(buttom_pnl_confirm, colorButtom.disabled);
end;

procedure TRTFForm.enableConfirmButtom;
begin
  setTColorToTPanel(buttom_pnl_confirm, colorButtom.enabled);
  buttom_pnl_confirm.Enabled := true;
end;

procedure TRTFForm.buttom_pnl_confirmClick(Sender: TObject);
begin
  result := true;
  close;
end;

procedure TRTFForm.button_exitClick(Sender: TObject);
begin
  close;
end;

end.
