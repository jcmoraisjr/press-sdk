(*
  PressObjects, FastReport Broker
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressFastReportBroker;

{$I Press.inc}

interface

uses
  Classes, FR_Class, FR_DSet, FR_Desgn, PressReport;

type
  TPressFRReport = class(TPressReport)
  private
    FOwner: TComponent;
    FReport: TfrReport;
    procedure ReportGetValue(const ParName: String; var ParValue: Variant);
  protected
    procedure InternalCreateFields(ADataSet: TPressReportDataSet; AFields: TStrings); override;
    function InternalCreateReportDataSet(const AName: string): TPressReportDataSet; override;
    procedure InternalDesignReport; override;
    procedure InternalExecuteReport; override;
    procedure InternalLoadFromStream(AStream: TStream); override;
    procedure InternalSaveToStream(AStream: TStream); override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

  TPressFRReportDataSet = class(TPressReportDataSet)
  private
    FDataSet: TfrDataSet;
    procedure ReportCheckEof(Sender: TObject; var Eof: Boolean);
  protected
    function InternalCurrentIndex: Integer; override;
  public
    constructor Create(AOwner: TComponent; const AName: string);
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils, Forms, PressConsts;

{ TPressFRReport }

constructor TPressFRReport.Create;
begin
  inherited Create;
  FOwner := TForm.Create(nil);
  FReport := TfrReport.Create(FOwner);
  FReport.OnGetValue := ReportGetValue;
end;

destructor TPressFRReport.Destroy;
begin
  while FOwner.ComponentCount > 0 do
    FOwner.RemoveComponent(FOwner.Components[0]);
  FReport.Free;
  FOwner.Free;
  inherited;
end;

procedure TPressFRReport.InternalCreateFields(
  ADataSet: TPressReportDataSet; AFields: TStrings);
var
  I: Integer;
  VVarName: string;
begin
  FReport.Variables.Add(ADataSet.Name);
  for I := 0 to Pred(AFields.Count) do
  begin
    VVarName := ADataSet.Name + SPressDataSeparator + AFields[I];
    FReport.Variables.Add(' ' + VVarName);
    FReport.Values.Items[FReport.Values.AddValue] := VVarName;
  end;
end;

function TPressFRReport.InternalCreateReportDataSet(
  const AName: string): TPressReportDataSet;
begin
  Result := TPressFRReportDataSet.Create(FOwner, AName);
end;

procedure TPressFRReport.InternalDesignReport;
begin
  FReport.DesignReport;
end;

procedure TPressFRReport.InternalExecuteReport;
begin
  FReport.ShowReport;
end;

procedure TPressFRReport.InternalLoadFromStream(AStream: TStream);
begin
  if AStream.Size > 0 then
  begin
    AStream.Position := 0;
    FReport.LoadFromStream(AStream);
  end;
end;

procedure TPressFRReport.InternalSaveToStream(AStream: TStream);
begin
  FReport.SaveToStream(AStream);
end;

procedure TPressFRReport.ReportGetValue(
  const ParName: string; var ParValue: Variant);
var
  VDataSetName, VFieldName: string;
  VPos: Integer;
begin
  if Assigned(OnNeedValue) then
  begin
    VPos := Pos(SPressDataSeparator, ParName);
    if VPos > 0 then
    begin
      VDataSetName := Copy(ParName, 1, VPos - 1);
      VFieldName := Copy(ParName, VPos + 1, Length(ParName));
    end else
    begin
      VDataSetName := '';
      VFieldName := ParName;
    end;
    OnNeedValue(VDataSetName, VFieldName, ParValue, False);
  end;
end;

{ TPressFRReportDataSet }

constructor TPressFRReportDataSet.Create(
  AOwner: TComponent; const AName: string);
begin
  inherited Create(AName);
  FDataSet := TfrDataSet.Create(AOwner);
  FDataSet.Name := StringReplace(
   AName, SPressAttributeSeparator, SPressIdentifierSeparator, [rfReplaceAll]);
  FDataSet.OnCheckEOF := ReportCheckEof;
end;

destructor TPressFRReportDataSet.Destroy;
begin
  FDataSet.Free;
  inherited;
end;

function TPressFRReportDataSet.InternalCurrentIndex: Integer;
begin
  Result := FDataSet.RecNo;
end;

procedure TPressFRReportDataSet.ReportCheckEof(
  Sender: TObject; var Eof: Boolean);
begin
  Eof := CheckEof;
end;

initialization
  TPressFRReport.RegisterService;

end.