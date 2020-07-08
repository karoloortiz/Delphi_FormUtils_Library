unit KLib.Presentation;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, RzLabel,
  RzPanel, dxGDIPlusClasses, PngImage;

const
  TYPE_PRESENTATION_RESOURCE = 'JSON';

type
  TJSONExtraDescription = record
    description: string;
    hint: string;
    function getEmptyRecord: TJSONExtraDescription;
  end;

  TJSONSlide = record
    title: string;
    subTitle: string;
    imgAsResource: boolean;
    imgName: string;
    extraDescription: TJSONExtraDescription;
    function setEmpty: TJSONSlide;
  end;

  TJSONPresentationSchema = record
    mainColorRGB: string;
    textEndButton: string;
    slides: Array of TJSONSlide;
  end;

  TSlide = record
    title: string;
    subTitle: string;
    img: TdxSmartImage;
    extraDescriptionEnabled: boolean;
    extraDescription: string;
    extraDescriptionHintEnabled: boolean;
    extraDescriptionHint: string;
  end;

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
    pnl_extraDescription: TPanel;
    lbl_extraDescription: TRzLabel;
    _spacer_extraDescription_left: TRzSpacer;
    _spacer_extraDescription_right: TRzSpacer;
    img_extraDescription_info: TImage;
    _spacer_extraDescription_upper: TRzSpacer;
    _pnl_extraDescription: TPanel;
    _spacer__extraDescription_left: TRzSpacer;
    pnl_buttons: TPanel;
    pnl_button_back: TPanel;
    _shape_button_back: TShape;
    button_img_back: TImage;
    _pnl_countSlide: TPanel;
    lbl_countSlide: TRzLabel;
    _spacer_extraDescription_bottom: TRzSpacer;
    _pnl_box_button_back: TPanel;
    _pnl_box_button_next: TPanel;
    pnl_button_next: TPanel;
    _shape_button_next: TShape;
    button_img_next: TImage;
    pnl_button_end: TPanel;
    _shape_button_end: TShape;
    lbl_button_end: TRzLabel;
    balloonHint: TBalloonHint;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure button_img_nextClick(Sender: TObject);
    procedure button_img_backClick(Sender: TObject);
    procedure lbl_button_endClick(Sender: TObject);
  private
    resourceJSONName: string;
    JSONPresentationSchema: TJSONPresentationSchema;
    mainColorRGB: string;
    slides: Array of TSlide;
    countSlides: integer;
    currentSlide: integer;
    lastSlide: integer;
    procedure loadNextSlide;
    procedure loadLastSlide;
    procedure loadFirstSlide;
    procedure loadPreviousSlide;
    procedure loadCurrentSlide;
    procedure setCountSlide;
    procedure loadJSONResource;
    procedure createSlides;

    procedure setMainColor;
    procedure setColorButtonNext;
    procedure setColorButtonEnd;
    procedure setWhiteAsSecondColor;
    procedure setVerticalSpacersDimensions;
  public
    constructor Create(AOwner: TComponent; resourceJSONName: string); reintroduce; overload;
  end;

var
  Presentation: TPresentation;

implementation

{$r *.dfm}


uses
  KLib.Graphics, KLib.Utils, System.JSON;

function TJSONExtraDescription.getEmptyRecord: TJSONExtraDescription;
begin
  self.description := '';
  self.hint := '';
  result := self;
end;

function TJSONSlide.setEmpty: TJSONSlide;
begin
  self.title := '';
  self.subTitle := '';
  self.imgAsResource := true;
  self.imgName := '';
  self.extraDescription.getEmptyRecord;
  result := self;
end;

constructor TPresentation.Create(AOwner: TComponent; resourceJSONName: string);
begin
  Self.resourceJSONName := resourceJSONName;
  Create(AOwner);
end;

procedure TPresentation.FormCreate(Sender: TObject);
begin
  setVerticalSpacersDimensions;
  setComponentInMiddlePosition(pnl_buttons);
  loadJSONResource;
  mainColorRGB := JSONPresentationSchema.mainColorRGB;
  lbl_button_end.Caption := JSONPresentationSchema.textEndButton;
  setMainColor;
  setWhiteAsSecondColor;
  createSlides;
  currentSlide := 0;
end;

procedure TPresentation.FormShow(Sender: TObject);
begin
  loadFirstSlide;
end;

procedure TPresentation.loadNextSlide;
begin
  currentSlide := currentSlide + 1;
  pnl_button_back.Visible := true;
  pnl_button_next.Visible := true;
  pnl_button_end.Visible := false;
  if currentSlide <> lastSlide then
  begin
    loadCurrentSlide;
  end
  else
  begin
    loadLastSlide;
  end;
end;

procedure TPresentation.loadPreviousSlide;
begin
  currentSlide := currentSlide - 1;
  pnl_button_back.Visible := true;
  pnl_button_next.Visible := true;
  pnl_button_end.Visible := false;
  if currentSlide <> 0 then
  begin
    loadCurrentSlide;
  end
  else
  begin
    loadFirstSlide;
  end;
end;

procedure TPresentation.loadFirstSlide;
begin
  currentSlide := 0;
  loadCurrentSlide;
  pnl_button_back.Visible := false;
  pnl_button_next.Visible := true;
  pnl_button_end.Visible := false;
end;

procedure TPresentation.loadLastSlide;
begin
  currentSlide := lastSlide;
  loadCurrentSlide;
  pnl_button_back.Visible := true;
  pnl_button_next.Visible := false;
  pnl_button_end.Visible := true;
end;

procedure TPresentation.loadCurrentSlide;
begin
  with slides[currentSlide] do
  begin
    lbl_title.Caption := title;
    lbl_subtitle.Caption := subTitle;
    img_body.Picture.Graphic := img;
    lbl_extraDescription.Visible := extraDescriptionEnabled;
    lbl_extraDescription.Caption := extraDescription;
    _spacer__extraDescription_left.Visible := extraDescriptionHintEnabled;
    img_extraDescription_info.Visible := extraDescriptionHintEnabled;
    img_extraDescription_info.Hint := extraDescriptionHint;
    setCountSlide;
  end;
end;

procedure TPresentation.setCountSlide;
begin
  lbl_countSlide.Caption := #13#10 + IntToStr(currentSlide + 1) + '/' + IntToStr(countSlides);
end;

procedure TPresentation.loadJSONResource;
var
  resourceSchemaAsString: String;
  JSONFile: TBytes;
  JSONMain: TJSONValue;
  _slides: TJSONArray;
  slide: TJSONSlide;
  _slide: TJSONObject;
  _extraDescription: TJSONObject;
  i: integer;
begin
  resourceSchemaAsString := getResourceAsString(resourceJSONName, TYPE_PRESENTATION_RESOURCE);
  JSONFile := TEncoding.ASCII.GetBytes(resourceSchemaAsString);
  JSONMain := TJSONObject.ParseJSONValue(JSONFile, 0);
  if JSONMain <> nil then
  begin
    if not JSONMain.TryGetValue('mainColorRGB', JSONPresentationSchema.mainColorRGB) then
    begin
      raise Exception.Create('mainColorRGB not present in JSON');
    end;
    if not JSONMain.TryGetValue('textEndButton', JSONPresentationSchema.textEndButton) then
    begin
      raise Exception.Create('textEndButton not present in JSON');
    end;
    _slides := JSONMain.GetValue<TJSONArray>('slides');
    SetLength(JSONPresentationSchema.slides, _slides.Count);
    for i := 0 to _slides.Count - 1 do
    begin
      slide.setEmpty;
      _slide := _slides.Items[i] as TJSONObject;
      with slide do
      begin
        if not _slide.TryGetValue('title', title) then
        begin
          raise Exception.Create('title not present in slide ' + IntToStr(i + 1) + ' of JSON');
        end;
        if not _slide.TryGetValue('imgAsResource', imgAsResource) then
        begin
          raise Exception.Create('imgAsResource not present in slide ' + IntToStr(i + 1) + ' of JSON');
        end;
        if not _slide.TryGetValue('imgName', imgName) then
        begin
          raise Exception.Create('imgName not present in slide ' + IntToStr(i + 1) + ' of JSON');
        end;
        _slide.TryGetValue('subTitle', subTitle);
      end;

      if _slide.TryGetValue('extraDescription', _extraDescription) then
      begin
        with slide.extraDescription do
        begin
          _extraDescription.TryGetValue('description', description);
          _extraDescription.TryGetValue('hint', hint);
        end;
      end;
      JSONPresentationSchema.slides[i] := slide;
    end;
  end
  else
  begin
    raise Exception.Create(resourceJSONName + ' is a not valid JSON.');
  end;
end;

procedure TPresentation.button_img_backClick(Sender: TObject);
begin
  loadPreviousSlide;
end;

procedure TPresentation.button_img_nextClick(Sender: TObject);
begin
  loadNextSlide;
end;

procedure TPresentation.lbl_button_endClick(Sender: TObject);
begin
  ShowMessage('Fine');
end;

procedure TPresentation.createSlides;
var
  i: integer;
begin
  countSlides := Length(JSONPresentationSchema.slides);
  lastSlide := countSlides - 1;
  SetLength(slides, countSlides);
  for i := 0 to lastSlide do
  begin
    with slides[i] do
    begin
      title := JSONPresentationSchema.slides[i].title;
      subTitle := JSONPresentationSchema.slides[i].subTitle;

      img := TdxSmartImage.Create;
      if JSONPresentationSchema.slides[i].imgAsResource then
      begin
        img.LoadFromResource(HInstance, pchar(JSONPresentationSchema.slides[i].imgName), pchar('PNG'));
      end
      else
      begin
        img.LoadFromFile(JSONPresentationSchema.slides[i].imgName);
      end;

      extraDescription := JSONPresentationSchema.slides[i].extraDescription.description;
      extraDescriptionHint := JSONPresentationSchema.slides[i].extraDescription.hint;
      if (extraDescription <> '') then
      begin
        extraDescriptionEnabled := true;
      end
      else
      begin
        extraDescriptionEnabled := false;
      end;
      if (extraDescriptionHint <> '') then
      begin
        extraDescriptionHintEnabled := true;
      end
      else
      begin
        extraDescriptionHintEnabled := false;
      end;
    end;
  end;
end;

procedure TPresentation.setMainColor;
var
  _color: Tcolor;
  _RGB: TRGB;
begin
  _RGB.loadFromString(mainColorRGB);
  setTColorToTPanel(pnl_head, _RGB.getTColor);
  setColorButtonNext;
  setColorButtonEnd;
end;

procedure TPresentation.setColorButtonNext;
begin
  _shape_button_next.Brush.Color := getDarkerTColor(pnl_head.Color, 2);
  _shape_button_next.Pen.Color := _shape_button_next.Brush.Color;
end;

procedure TPresentation.setColorButtonEnd;
begin
  _shape_button_end.Brush.Color := getDarkerTColor(pnl_head.Color, 2);
  _shape_button_end.Pen.Color := _shape_button_end.Brush.Color;
end;

procedure TPresentation.setWhiteAsSecondColor;
var
  _color: Tcolor;
begin
  _color := clWhite;
  setTColorToTPanel(pnl_body, _color);
  setTColorToTPanel(pnl_bottom, _color);
  lbl_title.Font.Color := _color;
  lbl_subtitle.Font.Color := _color;
  lbl_button_end.Font.Color := _color;
end;

procedure TPresentation.setVerticalSpacersDimensions;
begin
  _spacer_image_right.Width := _spacer_image_left.Width;
  _spacer_extraDescription_right.Width := _spacer_extraDescription_left.Width;
  _spacer__extraDescription_left.Width := img_extraDescription_info.Width;
end;

end.
