(*
  PressObjects, Report Model Classes
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressReportModel;

{$I Press.inc}

interface

uses
  Classes,
  PressSubject,
  PressAttributes,
  PressReport;

type
  TPressReportGroup = class(TPressCustomReportGroup)
  private
    FObjectClassName: TPressPlainString;
    FReports: TPressParts;
    function GetObjectClassName: string;
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    function InternalCreateReportItemIterator: TPressItemsIterator; override;
    class function InternalMetadataStr: string; override;
  public
    class function ObjectClassAttributeName: string; override;
    property ObjectClassName: string read GetObjectClassName;
  end;

  TPressReportItem = class(TPressCustomReportItem)
  private
    FCaption: TPressAnsiString;
    FVisible: TPressBoolean;
    FReportMetadata: TPressBinary;
  protected
    function GetReportCaption: string; override;
    procedure GetReportData(AStream: TStream); override;
    function GetReportVisible: Boolean; override;
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
    procedure SetReportData(AStream: TStream); override;
  end;

  TPressReportData = class(TPressCustomReportData)
  protected
    function InternalReportGroupClass: TPressReportGroupClass; override;
  end;

implementation

uses
  SysUtils,
  PressConsts;

{ TPressReportGroup }

function TPressReportGroup.GetObjectClassName: string;
begin
  Result := FObjectClassName.Value;
end;

function TPressReportGroup.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, ObjectClassAttributeName) then
    Result := Addr(FObjectClassName)
  else if SameText(AAttributeName, 'Reports') then
    Result := Addr(FReports)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

function TPressReportGroup.InternalCreateReportItemIterator: TPressItemsIterator;
begin
  Result := FReports.CreateIterator;
end;

class function TPressReportGroup.InternalMetadataStr: string;
begin
  Result := 'TPressReportGroup PersistentName="TRepGrp" ('+
   'ObjectClassName: PlainString(32);' +
   'Reports: Parts(TPressReportItem))';
end;

class function TPressReportGroup.ObjectClassAttributeName: string;
begin
  Result := 'ObjectClassName';
end;

{ TPressReportItem }

function TPressReportItem.GetReportCaption: string;
begin
  Result := FCaption.Value;
end;

procedure TPressReportItem.GetReportData(AStream: TStream);
begin
  FReportMetadata.SaveToStream(AStream);
end;

function TPressReportItem.GetReportVisible: Boolean;
begin
  Result := FVisible.Value;
end;

function TPressReportItem.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Caption') then
    Result := Addr(FCaption)
  else if SameText(AAttributeName, 'Visible') then
    Result := Addr(FVisible)
  else if SameText(AAttributeName, 'ReportMetadata') then
    Result := Addr(FReportMetadata)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressReportItem.InternalMetadataStr: string;
begin
  Result := 'TPressReportItem PersistentName="TRepItem" (' +
   'Caption: AnsiString(40);' +
   'Visible: Boolean DefaultValue=True;' +
   'ReportMetadata: Binary)';
end;

procedure TPressReportItem.SetReportData(AStream: TStream);
begin
  FReportMetadata.LoadFromStream(AStream);
end;

{ TPressReportData }

function TPressReportData.InternalReportGroupClass: TPressReportGroupClass;
begin
  Result := TPressReportGroup;
end;

initialization
  TPressReportGroup.RegisterClass;
  TPressReportItem.RegisterClass;
  TPressReportData.RegisterService;

finalization
  TPressReportGroup.UnregisterClass;
  TPressReportItem.UnregisterClass;
  TPressReportData.UnregisterService;

end.
