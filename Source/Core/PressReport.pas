(*
  PressObjects, Report Classes
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*)

unit PressReport;

{$I Press.inc}

interface

uses
  Classes,
  Contnrs,
  PressApplication,
  PressClasses,
  PressSubject,
  PressQuery;

type
  TPressReportNeedValueEvent = procedure(
   const ADataSetName, AFieldName: string; var AValue: Variant;
   AForceData: Boolean) of object;

  TPressReportDataSet = class;

  TPressReport = class(TPressService)
  private
    FOnNeedValue: TPressReportNeedValueEvent;
  protected
    procedure InternalCreateFields(ADataSet: TPressReportDataSet; AFields: TStrings); virtual;
    function InternalCreateReportDataSet(const AName: string): TPressReportDataSet; virtual; abstract;
    procedure InternalDesignReport; virtual;
    procedure InternalExecuteReport; virtual; abstract;
    procedure InternalLoadFromStream(AStream: TStream); virtual; abstract;
    procedure InternalSaveToStream(AStream: TStream); virtual; abstract;
    class function InternalServiceType: TPressServiceType; override;
  public
    procedure CreateFields(ADataSet: TPressReportDataSet; AFields: TStrings);
    function CreateReportDataSet(const AName: string): TPressReportDataSet;
    procedure Design;
    procedure Execute;
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    property OnNeedValue: TPressReportNeedValueEvent read FOnNeedValue write FOnNeedValue;
  end;

  TPressReportDataSource = class;

  TPressReportDataSet = class(TObject)
  private
    FName: string;
    FOwner: TPressReportDataSource;
  protected
    function InternalCurrentIndex: Integer; virtual; abstract;
  public
    constructor Create(const AName: string);
    function CheckEof: Boolean;
    function CurrentIndex: Integer;
    property Name: string read FName;
  end;

  TPressReportDataSource = class(TObject)
  private
    FDataSet: TPressReportDataSet;
    FFields: TStrings;
    FParent: TPressReportDataSource;
    function GetName: string;
  protected
    function InternalCheckEof: Boolean; virtual; abstract;
    function InternalCurrentItem: TPressObject; virtual; abstract;
    property DataSet: TPressReportDataSet read FDataSet;
    property Parent: TPressReportDataSource read FParent;
  public
    constructor Create(ADataSet: TPressReportDataSet; AParent: TPressReportDataSource);
    destructor Destroy; override;
    function CheckEof: Boolean;
    procedure CreateField(const AFieldName: string);
    function CurrentItem: TPressObject;
    property Fields: TStrings read FFields;
    property Name: string read GetName;
  end;

  TPressReportDataSourceIterator = class;

  TPressReportDataSourceList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressReportDataSource;
    procedure SetItems(AIndex: Integer; Value: TPressReportDataSource);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressReportDataSource): Integer;
    function CreateIterator: TPressReportDataSourceIterator;
    function Extract(AObject: TPressReportDataSource): TPressReportDataSource;
    function IndexOf(AObject: TPressReportDataSource): Integer;
    function IndexOfDataSetName(const ADataSetName: string): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressReportDataSource);
    function Remove(AObject: TPressReportDataSource): Integer;
    property Items[AIndex: Integer]: TPressReportDataSource read GetItems write SetItems; default;
  end;

  TPressReportDataSourceIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressReportDataSource;
  public
    property CurrentItem: TPressReportDataSource read GetCurrentItem;
  end;

  TPressReportObjectDataSource = class(TPressReportDataSource)
  private
    FObject: TPressObject;
  protected
    function InternalCheckEof: Boolean; override;
    function InternalCurrentItem: TPressObject; override;
  public
    constructor Create(ADataSet: TPressReportDataSet; AObject: TPressObject);
    destructor Destroy; override;
  end;

  TPressReportItemsDataSource = class(TPressReportDataSource)
  private
    FItems: TPressItems;
    FItemsName: string;
    function GetItems: TPressItems;
  protected
    function InternalCheckEof: Boolean; override;
    function InternalCurrentItem: TPressObject; override;
    property Items: TPressItems read GetItems;
  public
    constructor Create(ADataSet: TPressReportDataSet; const AItemsName: string; AParent: TPressReportDataSource);
  end;

  TPressReportGroup = class;

  TPressReportData = class(TPressService)
  protected
    function InternalFindReportGroup(const AObjectClassName: string): TPressReportGroup; virtual; abstract;
    class function InternalServiceType: TPressServiceType; override;
  public
    function FindReportGroup(const AObjectClassName: string): TPressReportGroup;
  end;

  TPressReportGroup = class(TPressObject)
  private
    FBusinessObj: TObject;
  protected
    function InternalCreateReportItemIterator: TPressProxyIterator; virtual; abstract;
  public
    function CreateReportItemIterator: TPressProxyIterator;
    property BusinessObj: TObject read FBusinessObj write FBusinessObj;
  end;

  TPressReportGroupItem = class(TPressObject)
  private
    FDataSources: TPressReportDataSourceList;
    FReport: TPressReport;
    function GetBusinessObj: TObject;
    function GetDataSources: TPressReportDataSourceList;
    function GetReport: TPressReport;
    procedure LoadFields;
    procedure LoadMetadatas;
    procedure LoadReport;
    procedure ReportNeedValue(const ADataSetName, AFieldName: string; var AValue: Variant; AForceData: Boolean);
    procedure SaveReport;
  protected
    procedure Finalize; override;
    function GetReportCaption: string; virtual;
    procedure GetReportData(AStream: TStream); virtual;
    function GetReportVisible: Boolean; virtual;
    procedure SetReportData(AStream: TStream); virtual;
    property BusinessObj: TObject read GetBusinessObj;
    property DataSources: TPressReportDataSourceList read GetDataSources;
    property Report: TPressReport read GetReport;
  public
    procedure Design;
    procedure Execute;
    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToFile(const AFileName: string);
    procedure SaveToStream(AStream: TStream);
    property ReportCaption: string read GetReportCaption;
    property ReportVisible: Boolean read GetReportVisible;
  end;

function PressReportData: TPressReportData;

implementation

uses
  SysUtils,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressConsts;

{ Global routines }

function PressReportData: TPressReportData;
begin
  Result := PressApp.DefaultService(stReportData) as TPressReportData;
end;

{ TPressReport }

procedure TPressReport.CreateFields(ADataSet: TPressReportDataSet; AFields: TStrings);
begin
  InternalCreateFields(ADataSet, AFields);
end;

function TPressReport.CreateReportDataSet(const AName: string): TPressReportDataSet;
begin
  Result := InternalCreateReportDataSet(AName);
end;

procedure TPressReport.Design;
begin
  InternalDesignReport;
end;

procedure TPressReport.Execute;
begin
  InternalExecuteReport;
end;

procedure TPressReport.InternalCreateFields(
  ADataSet: TPressReportDataSet; AFields: TStrings);
begin
end;

procedure TPressReport.InternalDesignReport;
begin
end;

class function TPressReport.InternalServiceType: TPressServiceType;
begin
  Result := stReport;
end;

procedure TPressReport.LoadFromStream(AStream: TStream);
begin
  InternalLoadFromStream(AStream);
end;

procedure TPressReport.SaveToStream(AStream: TStream);
begin
  InternalSaveToStream(AStream);
end;

{ TPressReportDataSet }

function TPressReportDataSet.CheckEof: Boolean;
begin
  if Assigned(FOwner) then
    Result := FOwner.CheckEof
  else
    Result := True;
end;

constructor TPressReportDataSet.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
end;

function TPressReportDataSet.CurrentIndex: Integer;
begin
  Result := InternalCurrentIndex;
end;

{ TPressReportDataSource }

function TPressReportDataSource.CheckEof: Boolean;
begin
  Result := InternalCheckEof;
end;

constructor TPressReportDataSource.Create(
  ADataSet: TPressReportDataSet; AParent: TPressReportDataSource);
begin
  inherited Create;
  FDataSet := ADataSet;
  FDataSet.FOwner := Self;  // friend class
  FParent := AParent;
  FFields := TStringList.Create;
end;

procedure TPressReportDataSource.CreateField(const AFieldName: string);
begin
  FFields.Add(AFieldName);
end;

function TPressReportDataSource.CurrentItem: TPressObject;
begin
  Result := InternalCurrentItem;
end;

destructor TPressReportDataSource.Destroy;
begin
  FDataSet.Free;
  FFields.Free;
  inherited;
end;

function TPressReportDataSource.GetName: string;
begin
  Result := FDataSet.Name;
end;

{ TPressReportDataSourceList }

function TPressReportDataSourceList.Add(
  AObject: TPressReportDataSource): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressReportDataSourceList.CreateIterator: TPressReportDataSourceIterator;
begin
  Result := TPressReportDataSourceIterator.Create(Self);
end;

function TPressReportDataSourceList.Extract(
  AObject: TPressReportDataSource): TPressReportDataSource;
begin
  Result := inherited Extract(AObject) as TPressReportDataSource;
end;

function TPressReportDataSourceList.GetItems(
  AIndex: Integer): TPressReportDataSource;
begin
  Result := inherited Items[AIndex] as TPressReportDataSource;
end;

function TPressReportDataSourceList.IndexOf(
  AObject: TPressReportDataSource): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressReportDataSourceList.IndexOfDataSetName(
  const ADataSetName: string): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Items[Result].DataSet.Name = ADataSetName then
      Exit;
  Result := -1;
end;

procedure TPressReportDataSourceList.Insert(
  AIndex: Integer; AObject: TPressReportDataSource);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressReportDataSourceList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressReportDataSourceList.Remove(
  AObject: TPressReportDataSource): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressReportDataSourceList.SetItems(
  AIndex: Integer; Value: TPressReportDataSource);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressReportDataSourceIterator }

function TPressReportDataSourceIterator.GetCurrentItem: TPressReportDataSource;
begin
  Result := inherited CurrentItem as TPressReportDataSource;
end;

{ TPressReportObjectDataSource }

constructor TPressReportObjectDataSource.Create(
  ADataSet: TPressReportDataSet; AObject: TPressObject);
begin
  inherited Create(ADataSet, nil);
  FObject := AObject;
  FObject.AddRef;
end;

destructor TPressReportObjectDataSource.Destroy;
begin
  FObject.Free;
  inherited;
end;

function TPressReportObjectDataSource.InternalCheckEof: Boolean;
begin
  Result := DataSet.CurrentIndex > 0;
end;

function TPressReportObjectDataSource.InternalCurrentItem: TPressObject;
begin
  Result := FObject;
end;

{ TPressReportItemsDataSource }

constructor TPressReportItemsDataSource.Create(
  ADataSet: TPressReportDataSet;
  const AItemsName: string; AParent: TPressReportDataSource);
begin
  inherited Create(ADataSet, AParent);
  FItemsName := AItemsName;
end;

function TPressReportItemsDataSource.GetItems: TPressItems;
begin
  if Assigned(Parent) and
   (not Assigned(FItems) or (Parent.CurrentItem <> FItems.Owner)) then
    FItems := Parent.CurrentItem.AttributeByName(FItemsName) as TPressItems;
  if not Assigned(FItems) then
    raise EPressError.CreateFmt(SAttributeNotFound, ['', FItemsName]);
  Result := FItems;
end;

function TPressReportItemsDataSource.InternalCheckEof: Boolean;
begin
  Result := DataSet.CurrentIndex >= Items.Count;
end;

function TPressReportItemsDataSource.InternalCurrentItem: TPressObject;
begin
  Result := Items[DataSet.CurrentIndex];
end;

{ TPressReportData }

function TPressReportData.FindReportGroup(
  const AObjectClassName: string): TPressReportGroup;
begin
  Result := InternalFindReportGroup(AObjectClassName);
end;

class function TPressReportData.InternalServiceType: TPressServiceType;
begin
  Result := stReportData;
end;

{ TPressReportGroup }

function TPressReportGroup.CreateReportItemIterator: TPressProxyIterator;
begin
  Result := InternalCreateReportItemIterator;
end;

{ TPressReportGroupItem }

procedure TPressReportGroupItem.Design;
begin
  Report.Design;
  SaveReport;
end;

procedure TPressReportGroupItem.Execute;
begin
  Report.Execute;
end;

procedure TPressReportGroupItem.Finalize;
begin
  FReport.Free;
  FDataSources.Free;
  inherited;
end;

function TPressReportGroupItem.GetBusinessObj: TObject;
begin
  if Owner is TPressReportGroup then
    Result := TPressReportGroup(Owner).BusinessObj
  else
    Result := nil;
end;

function TPressReportGroupItem.GetDataSources: TPressReportDataSourceList;
begin
  if not Assigned(FDataSources) then
    FDataSources := TPressReportDataSourceList.Create(True);
  Result := FDataSources;
end;

function TPressReportGroupItem.GetReport: TPressReport;
begin
  if not Assigned(FReport) then
  begin
    FReport := PressApp.CreateDefaultService(stReport) as TPressReport;
    FReport.OnNeedValue := ReportNeedValue;
    LoadReport;
    LoadMetadatas;
    LoadFields;
  end;
  Result := FReport;
end;

function TPressReportGroupItem.GetReportCaption: string;
begin
  Result := ClassName;
end;

procedure TPressReportGroupItem.GetReportData(AStream: TStream);
begin
end;

function TPressReportGroupItem.GetReportVisible: Boolean;
begin
  Result := True;
end;

procedure TPressReportGroupItem.LoadFields;
begin
  with DataSources.CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
      with CurrentItem do
        Report.CreateFields(DataSet, Fields);
  finally
    Free;
  end;
end;

procedure TPressReportGroupItem.LoadFromFile(const AFileName: string);
var
  VStream: TFileStream;
begin
  VStream := TFileStream.Create(AFileName, fmOpenRead + fmShareDenyWrite);
  try
    LoadFromStream(VStream);
  finally
    VStream.Free;
  end;
end;

procedure TPressReportGroupItem.LoadFromStream(AStream: TStream);
begin
  Report.LoadFromStream(AStream);
  SetReportData(AStream);
end;

procedure TPressReportGroupItem.LoadMetadatas;

  function CreateDataSet(const ADataSetName: string): TPressReportDataSet;
  begin
    Result := Report.CreateReportDataSet(ADataSetName);
  end;

  function CreateDataSource(
   const ADataSetName: string;
   AObject: TPressObject): TPressReportDataSource; overload;
  begin
    Result := TPressReportObjectDataSource.Create(
     CreateDataSet(ADataSetName), AObject);
    DataSources.Add(Result);
  end;

  function CreateDataSource(
    const ADataSetName, AItemsName: string;
    AParent: TPressReportDataSource): TPressReportDataSource; overload;
  begin
    Result := TPressReportItemsDataSource.Create(
     CreateDataSet(ADataSetName), AItemsName, AParent);
    DataSources.Add(Result);
  end;

  procedure LoadPressMetadata(
    AObjectClass: TPressObjectClass;
    ACurrentDataSource: TPressReportDataSource;
    const ADataSetPath, AAttributePath: string);

    procedure ReadAttributeMetadata(AMetadata: TPressAttributeMetadata);
    var
      VDataSource: TPressReportDataSource;
      VDataSetName: string;
    begin
      {$IFDEF Press-LogReport}
      PressLogMsg(Self, 'Reading '+ AMetadata.Owner.ObjectClass.ClassName +'('+
       AMetadata.Name +')');
      {$ENDIF}
      if Assigned(AMetadata.AttributeClass) then
      begin
        if AMetadata.AttributeClass.InheritsFrom(TPressValue) then
          ACurrentDataSource.CreateField(AAttributePath + AMetadata.Name)
        else if AMetadata.AttributeClass.InheritsFrom(TPressItem) then
          LoadPressMetadata(
           AMetadata.ObjectClass,
           ACurrentDataSource,
           ADataSetPath + SPressAttributeSeparator + AMetadata.Name,
           AAttributePath + AMetadata.Name + SPressAttributeSeparator)
        else if AMetadata.AttributeClass.InheritsFrom(TPressItems) then
        begin
          if AObjectClass.InheritsFrom(TPressQuery) and
           (AMetadata.Name = SPressQueryItemsString) then
            VDataSetName := AMetadata.ObjectClassName
          else
            VDataSetName :=
             ADataSetPath + SPressAttributeSeparator + AMetadata.Name;
          VDataSource :=
           CreateDataSource(VDataSetName, AMetadata.Name, ACurrentDataSource);
          LoadPressMetadata(
           AMetadata.ObjectClass, VDataSource, VDataSetName, '');
        end;
      end;
    end;

  begin
    {$IFDEF PressLogReport}
    PressLogMsg(Self, 'Loading ' + AObjectClass.ClassName + ' - DataSource: ' + 
     ACurrentDataSource.Name + ' - Paths: ' +
     ADataSetPath + '//' + AAttributePath );
    {$ENDIF}
    if not Assigned(AObjectClass) then
      Exit;
    with AObjectClass.ClassMap.CreateIterator do
    { TODO : Fix loop with circular references }
    try
      BeforeFirstItem;
      while NextItem do
        ReadAttributeMetadata(CurrentItem);
    finally
      Free;
    end;
  end;

var
  VBusinessObj: TObject;
begin
  VBusinessObj := BusinessObj;
  if not Assigned(VBusinessObj) then
    Exit;
  if VBusinessObj is TPressObject then
    LoadPressMetadata(
     TPressObjectClass(VBusinessObj.ClassType),
     CreateDataSource(VBusinessObj.ClassName, TPressObject(VBusinessObj)),
     VBusinessObj.ClassName, '');
  { TODO : else if BO has RTTI then read published fields }
end;

procedure TPressReportGroupItem.LoadReport;
var
  VStream: TStream;
begin
  VStream := TMemoryStream.Create;
  try
    GetReportData(VStream);
    Report.LoadFromStream(VStream);
  finally
    VStream.Free;
  end;
end;

procedure TPressReportGroupItem.ReportNeedValue(
  const ADataSetName, AFieldName: string; var AValue: Variant;
  AForceData: Boolean);
type
  TSuffixType = (stNative, stFormated);
var
  VAttribute: TPressAttribute;
  VIndex, VPos: Integer;
  VFieldName, VSuffix: string;
  VSuffixType: TSuffixType;
begin
  VIndex := DataSources.IndexOfDataSetName(ADataSetName);
  if VIndex <> -1 then
  begin
    VPos := LastDelimiter('.', AFieldName);
    VSuffix := Copy(AFieldName, VPos + 1, Length(AFieldName) - VPos);
    if SameText(VSuffix, SPressReportNativeValueSuffix) then
      VSuffixType := stNative
    else if SameText(VSuffix, SPressReportDisplayTextSuffix) then
      VSuffixType := stFormated
    else
    begin
      VSuffix := '';
      VSuffixType := stNative;
      VPos := Length(AFieldName) + 1;
    end;
    VFieldName := Copy(AFieldName, 1, VPos - 1);
    VAttribute :=
     DataSources[VIndex].CurrentItem.FindPathAttribute(VFieldName, False);
    if Assigned(VAttribute) then
    begin
      case VSuffixType of
        stNative: AValue := VAttribute.AsVariant;
        stFormated: AValue := VAttribute.DisplayText;
      end;
    end else
      AValue := '';
  end else if AForceData then
    AValue := SPressReportErrorMsg;
end;

procedure TPressReportGroupItem.SaveReport;
var
  VStream: TStream;
begin
  VStream := TMemoryStream.Create;
  try
    Report.SaveToStream(VStream);
    SetReportData(VStream);
  finally
    VStream.Free;
  end;
end;

procedure TPressReportGroupItem.SaveToFile(const AFileName: string);
var
  VStream: TFileStream;
begin
  VStream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(VStream);
  finally
    VStream.Free;
  end;
end;

procedure TPressReportGroupItem.SaveToStream(AStream: TStream);
begin
  GetReportData(AStream);
end;

procedure TPressReportGroupItem.SetReportData(AStream: TStream);
begin
end;

end.
