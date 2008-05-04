(*
  PressObjects, Report Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressReport;

{$I Press.inc}

interface

uses
  Classes,
  PressApplication,
  PressClasses,
  PressSubject,
  PressAttributes;

const
  CPressReportDataService = CPressReportServicesBase + $0001;
  CPressReportService     = CPressReportServicesBase + $0002;

type
  TPressReportNeedValueEvent = procedure(
   const ADataSetName, AFieldName: string; var AValue: Variant;
   AForceData: Boolean) of object;

  TPressReportNeedUpdateFields = procedure of object;

  TPressReportDataSet = class;

  TPressReport = class(TPressService)
  private
    FOnNeedValue: TPressReportNeedValueEvent;
    FOnNeedUpdateFields: TPressReportNeedUpdateFields;
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
    procedure UpdateFields;
    property OnNeedValue: TPressReportNeedValueEvent read FOnNeedValue write FOnNeedValue;
    property OnNeedUpdateFields: TPressReportNeedUpdateFields read FOnNeedUpdateFields write FOnNeedUpdateFields;
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
  public
    constructor Create(ADataSet: TPressReportDataSet; AParent: TPressReportDataSource);
    destructor Destroy; override;
    function CheckEof: Boolean;
    procedure CreateField(const AFieldName: string);
    function CurrentItem: TPressObject;
    property DataSet: TPressReportDataSet read FDataSet;
    property Fields: TStrings read FFields;
    property Name: string read GetName;
    property Parent: TPressReportDataSource read FParent;
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

  TPressReportGroupClass = class of TPressCustomReportGroup;

  TPressCustomReportGroup = class(TPressObject)
  private
    FBusinessObj: TObject;
  protected
    function InternalCreateReportItemIterator: TPressItemsIterator; virtual; abstract;
  public
    function CreateReportItemIterator: TPressItemsIterator;
    class function ObjectClassAttributeName: string; virtual; abstract;
    property BusinessObj: TObject read FBusinessObj write FBusinessObj;
  end;

  TPressCustomReportItem = class(TPressObject)
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
    procedure Finit; override;
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

  TPressCustomReportData = class(TPressService)
  private
    FReportGroups: TStrings;
  protected
    procedure Finit; override;
    function InternalReportGroupClass: TPressReportGroupClass; virtual; abstract;
    class function InternalServiceType: TPressServiceType; override;
  public
    function ReportGroupByClassName(ADataAccess: IPressSession; const AObjectClassName: string): TPressCustomReportGroup;
  end;

function PressDefaultReportDataService: TPressCustomReportData;

implementation

uses
  SysUtils,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressConsts;

function PressDefaultReportDataService: TPressCustomReportData;
begin
  Result := PressApp.DefaultService(CPressReportDataService) as TPressCustomReportData;
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
  Result := CPressReportService;
end;

procedure TPressReport.LoadFromStream(AStream: TStream);
begin
  InternalLoadFromStream(AStream);
end;

procedure TPressReport.SaveToStream(AStream: TStream);
begin
  InternalSaveToStream(AStream);
end;

procedure TPressReport.UpdateFields;
begin
  if Assigned(FOnNeedUpdateFields) then
    FOnNeedUpdateFields;
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

{ TPressReportGroup }

function TPressCustomReportGroup.CreateReportItemIterator: TPressItemsIterator;
begin
  Result := InternalCreateReportItemIterator;
end;

{ TPressReportItem }

procedure TPressCustomReportItem.Design;
begin
  Report.Design;
  SaveReport;
end;

procedure TPressCustomReportItem.Execute;
begin
  Report.Execute;
end;

procedure TPressCustomReportItem.Finit;
begin
  FReport.Free;
  FDataSources.Free;
  inherited;
end;

function TPressCustomReportItem.GetBusinessObj: TObject;
begin
  if Owner is TPressCustomReportGroup then
    Result := TPressCustomReportGroup(Owner).BusinessObj
  else
    Result := nil;
end;

function TPressCustomReportItem.GetDataSources: TPressReportDataSourceList;
begin
  if not Assigned(FDataSources) then
    FDataSources := TPressReportDataSourceList.Create(True);
  Result := FDataSources;
end;

function TPressCustomReportItem.GetReport: TPressReport;
begin
  if not Assigned(FReport) then
  begin
    FReport :=
     PressApp.CreateDefaultService(CPressReportService) as TPressReport;
    FReport.AddRef;
    FReport.OnNeedValue := {$IFDEF FPC}@{$ENDIF}ReportNeedValue;
    FReport.OnNeedUpdateFields := {$IFDEF FPC}@{$ENDIF}LoadFields;
    LoadReport;
    LoadMetadatas;
    LoadFields;
  end;
  Result := FReport;
end;

function TPressCustomReportItem.GetReportCaption: string;
begin
  Result := ClassName;
end;

procedure TPressCustomReportItem.GetReportData(AStream: TStream);
begin
end;

function TPressCustomReportItem.GetReportVisible: Boolean;
begin
  Result := True;
end;

procedure TPressCustomReportItem.LoadFields;
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

procedure TPressCustomReportItem.LoadFromFile(const AFileName: string);
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

procedure TPressCustomReportItem.LoadFromStream(AStream: TStream);
begin
  Report.LoadFromStream(AStream);
  SaveReport;
end;

procedure TPressCustomReportItem.LoadMetadatas;

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
      {$IFDEF PressLogReport}
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
          begin
            VDataSetName :=
             ADataSetPath + SPressAttributeSeparator + AMetadata.Name;
            ACurrentDataSource.CreateField(AAttributePath + AMetadata.Name);
          end;
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

procedure TPressCustomReportItem.LoadReport;
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

procedure TPressCustomReportItem.ReportNeedValue(
  const ADataSetName, AFieldName: string; var AValue: Variant;
  AForceData: Boolean);
var
  VIndex: Integer;
begin
  VIndex := DataSources.IndexOfDataSetName(ADataSetName);
  if VIndex <> -1 then
    AValue := DataSources[VIndex].CurrentItem.Expression(AFieldName)
  else if AForceData then
    AValue := SPressReportErrorMsg;
end;

procedure TPressCustomReportItem.SaveReport;
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

procedure TPressCustomReportItem.SaveToFile(const AFileName: string);
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

procedure TPressCustomReportItem.SaveToStream(AStream: TStream);
begin
  GetReportData(AStream);
end;

procedure TPressCustomReportItem.SetReportData(AStream: TStream);
begin
end;

{ TPressReportData }

procedure TPressCustomReportData.Finit;
var
  I: Integer;
begin
  inherited;
  if Assigned(FReportGroups) then
  begin
    for I := 0 to Pred(FReportGroups.Count) do
      FReportGroups.Objects[I].Free;
    FReportGroups.Free;
  end;
end;

class function TPressCustomReportData.InternalServiceType: TPressServiceType;
begin
  Result := CPressReportDataService;
end;

function TPressCustomReportData.ReportGroupByClassName(ADataAccess: IPressSession;
  const AObjectClassName: string): TPressCustomReportGroup;

  function CreateReportList: TStringList;
  begin
    Result := TStringList.Create;
    try
      Result.Sorted := True;
      Result.Duplicates := dupError;
    except
      FreeAndNil(Result);
      raise;
    end;
  end;

  function CreateReportGroup: TPressCustomReportGroup;
  var
    VReportClass: TPressReportGroupClass;
    VList: TPressProxyList;
  begin
    VReportClass := InternalReportGroupClass;
    VList := ADataAccess.OQLQuery(Format('select * from %s where %s = "%s"', [
     VReportClass.ClassName,
     VReportClass.ObjectClassAttributeName,
     AObjectClassName]));
    try
      if VList.Count > 0 then
      begin
        Result := VList[0].Instance as TPressCustomReportGroup;
        Result.AddRef;
        Result.Load(True, True);
      end else
      begin
        Result := VReportClass.Create;
        Result.AttributeByName(
         VReportClass.ObjectClassAttributeName).AsString := AObjectClassName;
        Result.Store;
      end;
    finally
      VList.Free;
    end;
  end;

var
  VIndex: Integer;
begin
  if not Assigned(FReportGroups) then
    FReportGroups := CreateReportList;
  VIndex := FReportGroups.IndexOf(AObjectClassName);
  if VIndex = -1 then
  begin
    ADataAccess.StartTransaction;
    try
      Result := CreateReportGroup;
      ADataAccess.Commit;
    except
      ADataAccess.Rollback;
      raise;
    end;
    FReportGroups.AddObject(AObjectClassName, Result);
  end else
    Result := TPressCustomReportGroup(FReportGroups.Objects[VIndex]);
end;

initialization
  TPressCustomReportGroup.RegisterClass;
  TPressCustomReportItem.RegisterClass;

finalization
  TPressCustomReportGroup.UnregisterClass;
  TPressCustomReportItem.UnregisterClass;

end.
