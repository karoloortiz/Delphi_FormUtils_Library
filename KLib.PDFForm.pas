unit KLib.PDFForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.OleCtrls,
  AcroPDFLib_TLB, SHDocVw, Vcl.StdCtrls, dxGDIPlusClasses,
  KLib.Types, RzBckgnd, bsawebbrowser, Vcl.OleCtnrs;

type
  TSizePDF = (medium, small, large);

  TPDFFormCreate = record
    sizePDF: TSizePDF;
    pathPDF: string;
    showToolbar: boolean;
    showNavpanes: boolean;
    showScrollbar: boolean;
    titleCaption: string;
    checkboxCaption: string;
    confirmButtonCaption: string;
    colorRGBConfirmButton: string;
  end;

  TPDFForm = class(TForm)
    pnl_bottom: TPanel;
    browser: TWebBrowser;
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
    procedure FormCreate(Sender: TObject);
    procedure checkBox_imgClick(Sender: TObject);
    procedure button_exitClick(Sender: TObject);
    procedure buttom_pnl_confirmClick(Sender: TObject);
  private
    sizePDF: TSizePDF;
    pathPDF: string;
    showToolbar: boolean;
    showNavpanes: boolean;
    showScrollbar: boolean;
    colorRGBConfirmButton: string;

    colorButtom: TColorButtom;
    openPDFParameters: string;
    isCheckBoxChecked: boolean;

    procedure disableConfirmButtom;
    procedure enableConfirmButtom;
    procedure setSizePDF;
    procedure setOpenPDFParameters;
    procedure addOpenPDFParameter(parameter: string);
  public
    result: boolean;
    constructor Create(AOwner: TComponent; createInfo: TPDFFormCreate); reintroduce; overload;
  end;

procedure showPDF(myPDFPath: string; mytitleCaption: string = '');
function showCustomPDF(infoCreate: TPDFFormCreate): boolean;

var
  PDFForm: TPDFForm;

implementation

{$r *.dfm}


uses
  KLib.Graphics, MSHTML;

const
  HIDE_TOOLBAR_PARAMETER = 'toolbar=0';
  HIDE_NAVPANES_PARAMETER = 'navpanes=0';
  HIDE_SCROLLBAR_PARAMETER = 'scrollbar=0';
  RGBCOLOR_DISABLED_BUTTON = '180180180';

procedure showPDF(myPDFPath: string; mytitleCaption: string = '');
var
  _PDFFormCreate: TPDFFormCreate;
begin
  with _PDFFormCreate do
  begin
    pathPDF := myPDFPath;
    titleCaption := mytitleCaption;
    showToolbar := false;
    showNavpanes := false;
    showScrollbar := true;
  end;
  showCustomPDF(_PDFFormCreate);
end;

function showCustomPDF(infoCreate: TPDFFormCreate): boolean;
var
  _PDFForm: TPDFForm;
  _result: boolean;
begin
  _PDFForm := TPDFForm.Create(nil, infoCreate);
  _PDFForm.ShowModal;
  _result := _PDFForm.result;
  result := _result;
end;

constructor TPDFForm.Create(AOwner: TComponent; createInfo: TPDFFormCreate);
var
  _sizes: set of TSizePDF;
begin
  Create(AOwner);
  _sizes := [small, medium, large];

  with createInfo do
  begin
    if (sizePDF in _sizes) then
    begin
      self.sizePDF := sizePDF;
    end
    else
    begin
      self.sizePDF := TSizePDF.medium;
    end;
    self.pathPDF := pathPDF;
    self.showToolbar := showToolbar;
    Self.showNavpanes := showNavpanes;
    Self.showScrollbar := showScrollbar;
    self.lbl_title.Caption := titleCaption;
    self.lbl_checkBox.Caption := checkboxCaption;
    self.buttom_pnl_confirm.Caption := confirmButtonCaption;
    self.colorRGBConfirmButton := colorRGBConfirmButton;
  end;

  Caption := Application.Title;

  colorButtom.disabled := RGBStringToTColor(RGBCOLOR_DISABLED_BUTTON);
  if colorRGBConfirmButton <> '' then
  begin
    colorButtom.enabled := RGBStringToTColor(colorRGBConfirmButton);
  end
  else
  begin
    colorButtom.enabled := buttom_pnl_confirm.Color;
  end;
  result := false;
  isCheckBoxChecked := false;

  makePanelVisibleOnlyIfStringIsNotNull(pnl_checkbox, lbl_checkBox.Caption);
  makePanelVisibleOnlyIfStringIsNotNull(buttom_pnl_confirm, buttom_pnl_confirm.Caption);
  pnl_bottom.Visible := pnl_checkbox.Visible or buttom_pnl_confirm.Visible;

  setComponentInMiddlePosition(lbl_title);
  setComponentInMiddlePosition(buttom_pnl_confirm);
  setComponentInMiddlePosition(_pnl_bottom);

  setSizePDF;
  setOpenPDFParameters;
  disableConfirmButtom;
end;

procedure TPDFForm.setSizePDF;
var
  _modifiedHeight: integer;
begin
  if sizePDF <> TSizePDF.medium then
  begin
    _modifiedHeight := trunc(browser.Height / 2.5);
    if sizePDF = TSizePDF.small then
    begin
      _modifiedHeight := -_modifiedHeight;
    end;
    self.Height := self.Height + _modifiedHeight;
  end;
end;

procedure TPDFForm.setOpenPDFParameters;
begin
  openPDFParameters := '';
  if not showToolbar then
  begin
    addOpenPDFParameter(HIDE_TOOLBAR_PARAMETER);
  end;
  if not showNavpanes then
  begin
    addOpenPDFParameter(HIDE_NAVPANES_PARAMETER);
  end;
  if not showScrollbar then
  begin
    addOpenPDFParameter(HIDE_SCROLLBAR_PARAMETER);
  end;
end;

procedure TPDFForm.addOpenPDFParameter(parameter: string);
begin
  if openPDFParameters = '' then
  begin
    openPDFParameters := '#';
  end
  else
  begin
    openPDFParameters := openPDFParameters + '&';
  end;
  openPDFParameters := openPDFParameters + parameter;
end;

procedure TPDFForm.FormCreate(Sender: TObject);
var
  doc: IHTMLDocument3;
  el: IHTMLElement;
  v: OleVariant;
begin

  if browser.Document <> nil then
  begin
    if browser.Document.QueryInterface(IHTMLDocument3, doc) = S_OK then
    begin
      el := doc.getElementById('carrierNameDropDown_UNSHIPPEDITEMS');

      if el <> nil then
      begin
        (el as IHTMLSelectElement).value := 'UPS';
        (el as IHTMLElement3).FireEvent('onchange', v);
      end;
    end;
  end;

  browser.Silent := true;
//  browser.Navigate('https://www.gestionaleopen.org/pdf_temp/');

  bsaWebBrowser1.Navigate('https://www.gestionaleopen.org/pdf_temp/');
  //  browser.Navigate(pathPDF + openPDFParameters);

  //
  //  browser.do

  //  browser.Navigate('https://www.gestionaleopen.org/wp-content/uploads/2020/08/license_BSD_Karol.pdf');
  //  bsaWebBrowser1.Navigate2(pathPDF);

  //  OleContainer1.CreateObject('AcroExch.Document', false)
  //  AcroPDF1.src := pathPDF;
  //    AcroPDF1.LoadFile(pathPDF);
  //  AcroPDF1.LoadFile('Empty');
end;

procedure TPDFForm.checkBox_imgClick(Sender: TObject);
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

procedure TPDFForm.disableConfirmButtom;
begin
  buttom_pnl_confirm.Enabled := false;
  setTColorToTPanel(buttom_pnl_confirm, colorButtom.disabled);
end;

procedure TPDFForm.enableConfirmButtom;
begin
  setTColorToTPanel(buttom_pnl_confirm, colorButtom.enabled);
  buttom_pnl_confirm.Enabled := true;
end;

procedure TPDFForm.buttom_pnl_confirmClick(Sender: TObject);
begin
  result := true;
  close;
end;

procedure TPDFForm.button_exitClick(Sender: TObject);
begin
  close;
end;

end.
