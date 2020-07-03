unit KLib.Presentation;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, RzLabel,
  RzPanel, dxGDIPlusClasses;

type
  TPresentation = class(TForm)
    lbl_title: TRzLabel;
    pnl_head: TPanel;
    lbl_subtitle: TRzLabel;
    _spacer_head_top: TRzSpacer;
    _spacer_head_titleSubtitle: TRzSpacer;
    _spacer_hed_bottom: TRzSpacer;
    pnl_bottom: TPanel;
    pnl_body: TPanel;
    pnl_image: TPanel;
    _spacer_image_bottom: TRzSpacer;
    _spacer_image_top: TRzSpacer;
    _spacer_image_left: TRzSpacer;
    _spacer_image_right: TRzSpacer;
    img_body: TImage;
    pnl_description: TPanel;
    lbl_description: TRzLabel;
    _spacer_description_left: TRzSpacer;
    _spacer_description_right: TRzSpacer;
    img_description_info: TImage;
    _spacer_description_upper: TRzSpacer;
    _pnl_description: TPanel;
    _spacer__description_left: TRzSpacer;
    pnl_buttons: TPanel;
    _pnl_button_back: TPanel;
    _shape_button_back: TShape;
    button_img_back: TImage;
    _pnl_button_next: TPanel;
    _pnl_countSlide: TPanel;
    lbl_countSlide: TRzLabel;
    _shape_button_next: TShape;
    button_img_next: TImage;
    _spacer_decription_bottom: TRzSpacer;
    procedure FormCreate(Sender: TObject);
  private
    procedure setSpacersDimensions;
  public
    { Public declarations }
  end;

var
  Presentation: TPresentation;

implementation

{$r *.dfm}


uses
  KLib.Graphics;

procedure TPresentation.FormCreate(Sender: TObject);
begin
  setSpacersDimensions;
  setComponentInMiddlePosition(pnl_buttons);
end;

procedure TPresentation.setSpacersDimensions;
begin
  _spacer_image_bottom.Height := _spacer_image_top.Height;
  _spacer_image_right.Width := _spacer_image_left.Width;

  _spacer_decription_bottom.Height := _spacer_description_upper.Height;
  _spacer_description_right.Width := _spacer_description_left.Width;

  _spacer__description_left.Width := img_description_info.Width;
end;

end.
