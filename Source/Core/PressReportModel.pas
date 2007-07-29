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
  TPressDefaultReportGroup = class(TPressReportGroup)
  private
    FObjectClassName: TPressString;
    FReports: TPressParts;
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    function InternalCreateReportItemIterator: TPressItemsIterator; override;
    class function InternalMetadataStr: string; override;
  public
    class function ObjectClassAttributeName: string; override;
  end;

  TPressDefaultReportItem = class(TPressReportItem)
  private
    FCaption: TPressString;
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

  TPressDefaultReportData = class(TPressReportData)
  protected
    function InternalReportGroupClass: TPressReportGroupClass; override;
  end;

implementation

uses
  SysUtils,
  PressConsts;

{ TPressDefaultReportGroup }

function TPressDefaultReportGroup.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, ObjectClassAttributeName) then
    Result := Addr(FObjectClassName)
  else if SameText(AAttributeName, 'Reports') then
    Result := Addr(FReports)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

function TPressDefaultReportGroup.InternalCreateReportItemIterator: TPressItemsIterator;
begin
  Result := FReports.CreateIterator;
end;

class function TPressDefaultReportGroup.InternalMetadataStr: string;
begin
  Result := 'TPressDefaultReportGroup PersistentName="TRepGrp" ('+
   'ObjectClassName: String(32);' +
   'Reports: Parts(TPressDefaultReportItem))';
end;

class function TPressDefaultReportGroup.ObjectClassAttributeName: string;
begin
  Result := 'ObjectClassName';
end;

{ TPressDefaultReportItem }

function TPressDefaultReportItem.GetReportCaption: string;
begin
  Result := FCaption.Value;
end;

procedure TPressDefaultReportItem.GetReportData(AStream: TStream);
begin
  FReportMetadata.SaveToStream(AStream);
end;

function TPressDefaultReportItem.GetReportVisible: Boolean;
begin
  Result := FVisible.Value;
end;

function TPressDefaultReportItem.InternalAttributeAddress(
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

class function TPressDefaultReportItem.InternalMetadataStr: string;
begin
  Result := 'TPressDefaultReportItem PersistentName="TRepItem" (' +
   'Caption: String(40);' +
   'Visible: Boolean DefaultValue=True;' +
   'ReportMetadata: Binary)';
end;

procedure TPressDefaultReportItem.SetReportData(AStream: TStream);
begin
  FReportMetadata.LoadFromStream(AStream);
end;

{ TPressDefaultReportData }

function TPressDefaultReportData.InternalReportGroupClass: TPressReportGroupClass;
begin
  Result := TPressDefaultReportGroup;
end;

initialization
  TPressDefaultReportGroup.RegisterClass;
  TPressDefaultReportItem.RegisterClass;
  TPressDefaultReportData.RegisterService;

finalization
  TPressDefaultReportGroup.UnregisterClass;
  TPressDefaultReportItem.UnregisterClass;
  TPressDefaultReportData.UnregisterService;

end.
