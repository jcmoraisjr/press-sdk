(*
  PressObjects, Picture Attribute Classes
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressPicture;

{$I Press.inc}

interface

uses
  Graphics,
  PressSubject,
  PressAttributes;

type
  TPressGraphicFormat = class(TObject)
  private
    FGraphicClass: TGraphicClass;
    FMatchingBuffer: string;
  protected
    function InternalMatch(const ABuffer: string): Boolean; virtual;
  public
    constructor Create(AGraphicClass: TGraphicClass; const AMatchingBuffer: string);
    function Match(const ABuffer: string): Boolean;
    property GraphicClass: TGraphicClass read FGraphicClass;
  end;

  TPressPicture = class(TPressBlob)
  private
    function CreateGraphic: TGraphic;
    function GetHasPicture: Boolean;
  public
    procedure AssignFromFile(const AFileName: string);
    procedure AssignGraphic(AValue: TGraphic);
    procedure AssignPicture(APicture: TPicture);
    procedure AssignToPicture(APicture: TPicture);
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure ClearPicture;
    property HasPicture: Boolean read GetHasPicture;
  end;

procedure PressRegisterGraphicFormat(AGraphicFormat: TPressGraphicFormat);

implementation

uses
  SysUtils,
  Classes,
  Contnrs,
  PressConsts,
  PressClasses;

var
  _GraphicFormatList: TObjectList;

procedure PressRegisterGraphicFormat(AGraphicFormat: TPressGraphicFormat);
begin
  if not Assigned(_GraphicFormatList) then
    _GraphicFormatList := TObjectList.Create(True);
  _GraphicFormatList.Add(AGraphicFormat);
end;

procedure _InitGraphicFormat;
begin
  PressRegisterGraphicFormat(TPressGraphicFormat.Create(TBitmap, #66#77));
  //PressRegisterGraphicFormat(TPressGraphicFormat.Create(tiff, #73#73#42#0));
  //PressRegisterGraphicFormat(TPressGraphicFormat.Create(tiff, #77#77#42#0));
  //PressRegisterGraphicFormat(TPressGraphicFormat.Create(jpeg, #74#70#73#70, 7));
  //PressRegisterGraphicFormat(TPressGraphicFormat.Create(jpeg, #69#120#105#102, 7));
  //PressRegisterGraphicFormat(TPressGraphicFormat.Create(png, #137#80#78#71#13#10#26#10));
  //PressRegisterGraphicFormat(TPressGraphicFormat.Create(dcx, #177#104#222#58));
  //PressRegisterGraphicFormat(TPressGraphicFormat.Create(pcx, #10));
{$IFDEF BORLAND_CG}
  PressRegisterGraphicFormat(TPressGraphicFormat.Create(TMetafile, #215#205#198#154));
{$ENDIF}
  //PressRegisterGraphicFormat(TPressGraphicFormat.Create(emf, #1#0#0#0));
  //PressRegisterGraphicFormat(TPressGraphicFormat.Create(gif, #71#73#70));
(*
  // TBitmap format with TGraphicHeader header (dbware)
  #01#00#00#01; Pos[5] = StreamLength - 8
  Stream reading starts at 8
*)
end;

{ TPressGraphicFormat }

constructor TPressGraphicFormat.Create(AGraphicClass: TGraphicClass;
  const AMatchingBuffer: string);
begin
  inherited Create;
  FGraphicClass := AGraphicClass;
  FMatchingBuffer := AMatchingBuffer;
end;

function TPressGraphicFormat.InternalMatch(const ABuffer: string): Boolean;
begin
  Result := False;
end;

function TPressGraphicFormat.Match(const ABuffer: string): Boolean;
var
  I: Integer;
begin
  if FMatchingBuffer <> '' then
  begin
    Result := False;
    if Length(ABuffer) >= Length(FMatchingBuffer) then
      for I := 1 to Length(FMatchingBuffer) do
        if ABuffer[I] <> FMatchingBuffer[I] then
          Exit;
    Result := True;
  end else
    Result := InternalMatch(ABuffer);
end;

{ TPressPicture }

procedure TPressPicture.AssignFromFile(const AFileName: string);
var
  VStream: TFileStream;
begin
  VStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Changing;
    Stream.Clear;
    Stream.CopyFrom(VStream, 0);
    ValueAssigned;
  finally
    VStream.Free;
  end;
end;

procedure TPressPicture.AssignGraphic(AValue: TGraphic);
begin
  Changing;
  Stream.Clear;
  if Assigned(AValue) then
    AValue.SaveToStream(Stream);
  ValueAssigned;
end;

procedure TPressPicture.AssignPicture(APicture: TPicture);
begin
  AssignGraphic(APicture.Graphic);
end;

procedure TPressPicture.AssignToPicture(APicture: TPicture);
var
  VGraphic: TGraphic;
begin
  if HasPicture then
  begin
    VGraphic := CreateGraphic;
    Stream.Position := 0;
    try
      VGraphic.LoadFromStream(Stream);
      APicture.Graphic := VGraphic;
    finally
      VGraphic.Free;
    end;
  end else
    APicture.Graphic := nil;
end;

class function TPressPicture.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attPicture;
end;

class function TPressPicture.AttributeName: string;
begin
  if Self = TPressPicture then
    Result := 'Picture'
  else
    Result := ClassName;
end;

procedure TPressPicture.ClearPicture;
begin
  ClearBuffer;
end;

function TPressPicture.CreateGraphic: TGraphic;
const
  CMaxBufferLength = 32;
var
  VBuffer: string;
  VBufferLength: Integer;
  I: Integer;
begin
  if not Assigned(_GraphicFormatList) then
    _InitGraphicFormat;
  Stream.Position := 0;
  SetLength(VBuffer, CMaxBufferLength);
  VBufferLength := Stream.Read(VBuffer[1], CMaxBufferLength);
  SetLength(VBuffer, VBufferLength);
  for I := 0 to Pred(_GraphicFormatList.Count) do
    if (_GraphicFormatList[I] as TPressGraphicFormat).Match(VBuffer) then
    begin
      Result := TPressGraphicFormat(_GraphicFormatList[I]).GraphicClass.Create;
      Exit;
    end;
  raise EPressError.Create(SUnsupportedGraphicFormat);
end;

function TPressPicture.GetHasPicture: Boolean;
begin
  Result := Size > 0;
end;

initialization
  TPressPicture.RegisterAttribute;

finalization
  TPressPicture.UnregisterAttribute;
  _GraphicFormatList.Free;

end.
