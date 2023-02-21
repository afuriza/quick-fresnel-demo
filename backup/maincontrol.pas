unit MainControl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, SynHighlighterCss, SynHighlighterJScript, SynEdit, Fresnel.Controls,
  Fresnel.DOM, Fresnel.Layouter, Fresnel.LCLControls, BESEN, BESENNativeObject,
  BESENTypes, BESENValue, BESENObject, BESENUtils, BESENErrors, BESENConstants,
  fgl;

type

  { Elements Collection }

  TElementObject = class(TBESENNativeObject)
  private
    ElementComponent: TComponent;
  protected
    procedure ConstructObject(const ThisArgument: TBESENValue;
      Arguments: PPBESENValues; CountArguments: integer); override;
    procedure InitializeObject; override;
    procedure FinalizeObject; override;
  public
    constructor Create(AInstance: TObject; APrototype: TBESENObject = nil;
      AHasPrototypeProperty: longbool = False); override;
    destructor Destroy; override;
  published
    procedure setStyle(const ThisArgument: TBESENValue; Arguments:PPBESENValues;
      CountArguments: integer; var ResultValue: TBESENValue);
    procedure setCaption(const ThisArgument: TBESENValue; Arguments:PPBESENValues;
      CountArguments: integer; var ResultValue: TBESENValue);
  end;


  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    PageControl1: TPageControl;
    Panel1: TPanel;
    pnPreview: TPanel;
    Splitter1: TSplitter;
    SynCssSyn1: TSynCssSyn;
    seBESENFresnel: TSynEdit;
    seCSSFresnel: TSynEdit;
    SynJScriptSyn1: TSynJScriptSyn;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure seCSSFresnelChange(Sender: TObject);
  private
    Fresnel1: TFresnelLCLControl;
    ViewPort: TFresnelViewport;
    Layouter: TSimpleFresnelLayouter;
  public

  end;

var
  frmMain: TfrmMain;
  Instance:TBESEN;
  Compatibility: longword;
  indx: integer;

implementation

{$R *.lfm}

{ Elements Collection }

constructor TElementObject.Create(AInstance: TObject; APrototype: TBESENObject = nil;
  AHasPrototypeProperty: longbool = False);
begin
  inherited Create(AInstance, APrototype, AHasPrototypeProperty);
  ElementComponent := nil;
end;

destructor TElementObject.Destroy;
begin
  BesenFreeAndNil(ElementComponent);
  inherited Destroy;
end;

procedure TElementObject.ConstructObject(const ThisArgument: TBESENValue;
  Arguments: PPBESENValues; CountArguments: integer);

var
  CurrentElementClass: string;
  CurrentElementParent: TBESENObject;
  i: integer;
begin
  inherited ConstructObject(ThisArgument, Arguments, CountArguments);

  if CountArguments < 1 then
  begin
    raise EBESENError.Create('Error', 'Too few arguments');
  end
  else
  begin
    CurrentElementClass := LowerCase(TBESEN(Instance).ToStr(Arguments^[0]^));
    if CurrentElementClass = 'body' then
    begin
      ElementComponent := TFresnelBody.Create(nil);
      TFresnelBody(ElementComponent).Parent := frmMain.ViewPort;

      {
        ObjectName doesn't even give the object name.
        > var myDiv = new Element("Div");
        Should gave me myDiv in object name.
        Function? I think that should be a object type, I guess.
      }
      //ElementComponent.Name := ObjectName;
      ElementComponent.Name := 'el'+indx.ToString;
    end
    else if CurrentElementClass = 'div' then
    begin
      if CountArguments < 2 then
      begin
        raise EBESENError.Create('Error', 'Too few arguments');
      end
      else
      begin
        CurrentElementParent := TBESEN(Instance).ToObj(Arguments^[1]^);
        ElementComponent := TFresnelDiv.Create(nil);
        TFresnelDiv(ElementComponent).Parent :=
          TFresnelElement(TElementObject(CurrentElementParent).ElementComponent);

        ElementComponent.Name := 'el'+indx.ToString;
      end;
    end
    else if CurrentElementClass = 'span' then
    begin
      if CountArguments < 2 then
      begin
        raise EBESENError.Create('Error', 'Too few arguments');
      end
      else
      begin
        CurrentElementParent := TBESEN(Instance).ToObj(Arguments^[1]^);
        ElementComponent := TFresnelSpan.Create(nil);
        TFresnelSpan(ElementComponent).Parent :=
          TFresnelElement(TElementObject(CurrentElementParent).ElementComponent);

        ElementComponent.Name := 'el'+indx.ToString;
      end;
    end
    else if CurrentElementClass = 'span' then
    begin
      if CountArguments < 2 then
      begin
        raise EBESENError.Create('Error', 'Too few arguments');
      end
      else
      begin
        CurrentElementParent := TBESEN(Instance).ToObj(Arguments^[1]^);
        ElementComponent := TFresnelSpan.Create(nil);
        TFresnelSpan(ElementComponent).Parent :=
          TFresnelElement(TElementObject(CurrentElementParent).ElementComponent);

        ElementComponent.Name := 'el'+indx.ToString;
      end;
    end
    else if CurrentElementClass = 'label' then
    begin
      if CountArguments < 2 then
      begin
        raise EBESENError.Create('Error', 'Too few arguments');
      end
      else
      begin
        CurrentElementParent := TBESEN(Instance).ToObj(Arguments^[1]^);
        ElementComponent := TFresnelLabel.Create(nil);
        TFresnelLabel(ElementComponent).Parent :=
          TFresnelElement(TElementObject(CurrentElementParent).ElementComponent);

        ElementComponent.Name := 'el'+indx.ToString;
      end;
    end;
  end;
  CurrentElementClass := '';
  CurrentElementParent :=  nil;
  indx := indx+1;
end;

procedure TElementObject.setStyle(const ThisArgument: TBESENValue; Arguments:PPBESENValues;
  CountArguments: integer; var ResultValue: TBESENValue);
begin
  if CountArguments < 1 then
    raise EBESENError.Create('Error', 'Too few arguments')
  else
    TFresnelElement(ElementComponent).Style := TBESEN(Instance).ToStr(Arguments^[0]^);
end;

procedure TElementObject.setCaption(const ThisArgument: TBESENValue; Arguments:PPBESENValues;
  CountArguments: integer; var ResultValue: TBESENValue);
begin
  if CountArguments < 1 then
    raise EBESENError.Create('Error', 'Too few arguments')
  else
    TFresnelLabel(ElementComponent).Caption := TBESEN(Instance).ToStr(Arguments^[0]^);
end;

procedure TElementObject.InitializeObject;
begin
  inherited InitializeObject;
  ElementComponent := nil;
end;

procedure TElementObject.FinalizeObject;
begin
  BesenFreeAndNil(ElementComponent);
  inherited FinalizeObject;
end;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Fresnel1 := TFresnelLCLControl.Create(Self);
  Fresnel1.Name := 'Fresnel1';
  Fresnel1.Align := alClient;
  Fresnel1.Parent := pnPreview;
  ViewPort := Fresnel1.Viewport;
  Layouter := Fresnel1.Layouter;
  Viewport.Stylesheet.Text := 'div { padding: 2px; border: 3px; margin: 6px; }';
end;

procedure TfrmMain.seCSSFresnelChange(Sender: TObject);
begin

end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  ViewPort.Stylesheet.Text := seCSSFresnel.Lines.Text;
  if Instance <> nil then
    FreeAndNil(Instance);
  { always break on second creation }
  Instance := TBESEN.Create(Compatibility);
  TBESEN(Instance).RegisterNativeObject('Element', TElementObject);

  TBESEN(Instance).Execute(seBESENFresnel.Lines.Text);
  TBESEN(Instance).GarbageCollector.CollectAll;
end;

initialization

  Compatibility := COMPAT_JS;

finalization

  if Instance <> nil then
    TBESEN(Instance).Destroy;

end.
