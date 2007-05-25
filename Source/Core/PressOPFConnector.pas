(*
  PressObjects, Persistence Connector Classes
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressOPFConnector;

{$I Press.inc}

interface

uses
  {$IFDEF D6+}Variants,{$ENDIF}
  Contnrs,
  PressClasses,
  PressOPFClasses;

type
  TPressOPFField = class(TObject)
  private
    FFieldType: TPressOPFFieldType;
    FIsNull: Boolean;
    FValue: Variant;
    procedure SetValue(AValue: Variant);
    function GetAsString: string;
  public
    constructor Create(AFieldType: TPressOPFFieldType);
    property AsString: string read GetAsString;
    property FieldType: TPressOPFFieldType read FFieldType;
    property IsNull: Boolean read FIsNull;
    property Value: Variant read FValue write SetValue;
  end;

  TPressOPFDataset = class;

  TPressOPFDataRow = class(TObject)
  private
    FDataset: TPressOPFDataset;
    FFieldList: TObjectList;
    function GetFields(AIndex: Integer): TPressOPFField;
    function GetFieldList: TObjectList;
  protected
    property FieldList: TObjectList read GetFieldList;
  public
    constructor Create(ADataset: TPressOPFDataset);
    destructor Destroy; override;
    function Count: Integer;
    function FieldByName(const AFieldName: string): TPressOPFField;
    property Dataset: TPressOPFDataset read FDataset;
    property Fields[AIndex: Integer]: TPressOPFField read GetFields; default;
  end;

  TPressOPFFieldDef = class(TObject)
  private
    FFieldType: TPressOPFFieldType;
    FName: string;
  public
    property FieldType: TPressOPFFieldType read FFieldType write FFieldType;
    property Name: string read FName write FName;
  end;

  TPressOPFFieldDefIterator = class;

  TPressOPFFieldDefList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressOPFFieldDef;
    procedure SetItems(AIndex: Integer; AValue: TPressOPFFieldDef);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add: TPressOPFFieldDef; overload;
    function Add(AObject: TPressOPFFieldDef): Integer; overload;
    function CreateIterator: TPressOPFFieldDefIterator;
    function Extract(AObject: TPressOPFFieldDef): TPressOPFFieldDef;
    function First: TPressOPFFieldDef;
    function IndexOf(AObject: TPressOPFFieldDef): Integer;
    function IndexOfName(const AFieldName: string): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressOPFFieldDef);
    function Last: TPressOPFFieldDef;
    function Remove(AObject: TPressOPFFieldDef): Integer;
    property Items[AIndex: Integer]: TPressOPFFieldDef read GetItems write SetItems; default;
  end;

  TPressOPFFieldDefIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressOPFFieldDef;
  public
    property CurrentItem: TPressOPFFieldDef read GetCurrentItem;
  end;

  TPressOPFConnector = class;
  TPressOPFConnectorClass = class of TPressOPFConnector;

  TPressOPFDatasetClass = class of TPressOPFDataset;

  TPressOPFDataset = class(TObject)
  private
    FConnector: TPressOPFConnector;
    FFieldDefs: TPressOPFFieldDefList;
    FParams: TPressOPFParamList;
    FRows: TObjectList;
    FSQL: string;
    function GetFieldDefs: TPressOPFFieldDefList;
    function GetParams: TPressOPFParamList;
    function GetRows(AIndex: Integer): TPressOPFDataRow;
    procedure SetSQL(AValue: string);
  protected
    function AddRow: TPressOPFDataRow;
    procedure ClearDataset;
    procedure ClearFields;
    function InternalExecute: Integer; virtual; abstract;
    procedure InternalSQLChanged; virtual;
    property Connector: TPressOPFConnector read FConnector;
  public
    constructor Create(AConnector: TPressOPFConnector);
    destructor Destroy; override;
    function Count: Integer;
    function Execute: Integer;
    property FieldDefs: TPressOPFFieldDefList read GetFieldDefs;
    property Params: TPressOPFParamList read GetParams;
    property SQL: string read FSQL write SetSQL;
    property Rows[AIndex: Integer]: TPressOPFDataRow read GetRows; default;
  end;

  TPressOPFConnector = class(TObject)
  protected
    function GetSupportTransaction: Boolean; virtual;
    procedure InternalCommit; virtual;
    procedure InternalConnect; virtual;
    function InternalDatasetClass: TPressOPFDatasetClass; virtual;
    procedure InternalRollback; virtual;
    procedure InternalStartTransaction; virtual;
    function UnsupportedFeatureError(const AFeatureName: string): EPressOPFError;
  public
    constructor Create; virtual;
    procedure Commit;
    function CreateDataset: TPressOPFDataset;
    procedure Rollback;
    procedure StartTransaction;
    property SupportTransaction: Boolean read GetSupportTransaction;
  end;

implementation

uses
  SysUtils,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressConsts;

{ TPressOPFField }

constructor TPressOPFField.Create(AFieldType: TPressOPFFieldType);
begin
  inherited Create;
  FFieldType := AFieldType;
  FIsNull := True;
end;

function TPressOPFField.GetAsString: string;
begin
  if not IsNull then
    Result := Value
  else
    Result := '';
end;

procedure TPressOPFField.SetValue(AValue: Variant);
begin
  { TODO : Validate }
  FIsNull := VarIsEmpty(AValue) or VarIsNull(AValue);
  FValue := AValue;
end;

{ TPressOPFDataRow }

function TPressOPFDataRow.Count: Integer;
begin
  if Assigned(FFieldList) then
    Result := FFieldList.Count
  else
    Result := 0;
end;

constructor TPressOPFDataRow.Create(ADataset: TPressOPFDataset);
begin
  inherited Create;
  FDataset := ADataset;
end;

destructor TPressOPFDataRow.Destroy;
begin
  FFieldList.Free;
  inherited;
end;

function TPressOPFDataRow.FieldByName(
  const AFieldName: string): TPressOPFField;
var
  VIndex: Integer;
begin
  VIndex := Dataset.FieldDefs.IndexOfName(AFieldName);
  if VIndex >= 0 then
    Result := Fields[VIndex]
  else
    raise EPressOPFError.CreateFmt(SFieldNotFound, [AFieldName]);
end;

function TPressOPFDataRow.GetFieldList: TObjectList;
begin
  if not Assigned(FFieldList) then
    FFieldList := TObjectList.Create(True);
  Result := FFieldList;
end;

function TPressOPFDataRow.GetFields(AIndex: Integer): TPressOPFField;
begin
  Result := FieldList[AIndex] as TPressOPFField;
end;

{ TPressOPFFieldDefList }

function TPressOPFFieldDefList.Add: TPressOPFFieldDef;
begin
  Result := TPressOPFFieldDef.Create;
  Add(Result);
end;

function TPressOPFFieldDefList.Add(AObject: TPressOPFFieldDef): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressOPFFieldDefList.CreateIterator: TPressOPFFieldDefIterator;
begin
  Result := TPressOPFFieldDefIterator.Create(Self);
end;

function TPressOPFFieldDefList.Extract(
  AObject: TPressOPFFieldDef): TPressOPFFieldDef;
begin
  Result := inherited Extract(AObject) as TPressOPFFieldDef;
end;

function TPressOPFFieldDefList.First: TPressOPFFieldDef;
begin
  Result := inherited First as TPressOPFFieldDef;
end;

function TPressOPFFieldDefList.GetItems(
  AIndex: Integer): TPressOPFFieldDef;
begin
  Result := inherited Items[AIndex] as TPressOPFFieldDef;
end;

function TPressOPFFieldDefList.IndexOf(
  AObject: TPressOPFFieldDef): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressOPFFieldDefList.IndexOfName(
  const AFieldName: string): Integer;
begin
  for Result := 0 to Pred(Count) do
    if SameText(Items[Result].Name, AFieldName) then
      Exit;
  Result := -1;
end;

procedure TPressOPFFieldDefList.Insert(AIndex: Integer;
  AObject: TPressOPFFieldDef);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressOPFFieldDefList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressOPFFieldDefList.Last: TPressOPFFieldDef;
begin
  Result := inherited Last as TPressOPFFieldDef;
end;

function TPressOPFFieldDefList.Remove(AObject: TPressOPFFieldDef): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressOPFFieldDefList.SetItems(
  AIndex: Integer; AValue: TPressOPFFieldDef);
begin
  inherited Items[AIndex] := AValue;
end;

{ TPressOPFFieldDefIterator }

function TPressOPFFieldDefIterator.GetCurrentItem: TPressOPFFieldDef;
begin
  Result := inherited CurrentItem as TPressOPFFieldDef;
end;

{ TPressOPFDataset }

function TPressOPFDataset.AddRow: TPressOPFDataRow;
var
  I: Integer;
begin
  if not Assigned(FRows) then
    FRows := TObjectList.Create(True);
  Result := TPressOPFDataRow.Create(Self);
  FRows.Add(Result);
  if Assigned(FFieldDefs) then
    for I := 0 to Pred(FFieldDefs.Count) do
      Result.FieldList.Add(TPressOPFField.Create(FFieldDefs[I].FieldType));  // friend class
end;

procedure TPressOPFDataset.ClearDataset;
begin
  FreeAndNil(FRows);
  FreeAndNil(FParams);
  FreeAndNil(FFieldDefs);
end;

procedure TPressOPFDataset.ClearFields;
begin
  FreeAndNil(FRows);
  FreeAndNil(FFieldDefs);
end;

function TPressOPFDataset.Count: Integer;
begin
  if Assigned(FRows) then
    Result := FRows.Count
  else
    Result := 0;
end;

constructor TPressOPFDataset.Create(AConnector: TPressOPFConnector);
begin
  inherited Create;
  FConnector := AConnector;
end;

destructor TPressOPFDataset.Destroy;
begin
  ClearDataset;
  inherited;
end;

function TPressOPFDataset.Execute: Integer;
{$IFDEF PressLogDAOPersistence}
var
  I: Integer;
{$ENDIF}
begin
  {$IFDEF PressLogDAOPersistence}
    PressLogMsg(Self, 'OPF: ' + FSQL);
    for I := 0 to Pred(Params.Count) do
      PressLogMsg(Self, Format('OPFParam: %s = %s', [
       Params[I].Name, Params[I].AsString]));
  {$ENDIF}
  Result := InternalExecute;
  {$IFDEF PressLogDAOPersistence}
  PressLogMsg(Self, 'OPFResult: ' + InttoStr(Result) + ' row(s) affected');
  {$ENDIF}
end;

function TPressOPFDataset.GetFieldDefs: TPressOPFFieldDefList;
begin
  if not Assigned(FFieldDefs) then
    FFieldDefs := TPressOPFFieldDefList.Create(True);
  Result := FFieldDefs;
end;

function TPressOPFDataset.GetParams: TPressOPFParamList;
begin
  if not Assigned(FParams) then
    FParams := TPressOPFParamList.Create(True);
  Result := FParams;
end;

function TPressOPFDataset.GetRows(AIndex: Integer): TPressOPFDataRow;
begin
  if not Assigned(FRows) then
    FRows := TObjectList.Create(True);
  Result := FRows[AIndex] as TPressOPFDataRow;
end;

procedure TPressOPFDataset.InternalSQLChanged;
begin
end;

procedure TPressOPFDataset.SetSQL(AValue: string);
begin
  ClearDataset;
  FSQL := AValue;
  InternalSQLChanged;
end;

{ TPressOPFConnector }

procedure TPressOPFConnector.Commit;
begin
  {$IFDEF PressLogDAOPersistence}
  PressLogMsg(Self, 'OPF: Commit');
  {$ENDIF}
  InternalCommit;
end;

constructor TPressOPFConnector.Create;
begin
  inherited Create;
end;

function TPressOPFConnector.CreateDataset: TPressOPFDataset;
begin
  Result := InternalDatasetClass.Create(Self);
end;

function TPressOPFConnector.GetSupportTransaction: Boolean;
begin
  raise UnsupportedFeatureError('Transaction support');
end;

procedure TPressOPFConnector.InternalCommit;
begin
  raise UnsupportedFeatureError('Commit transaction');
end;

procedure TPressOPFConnector.InternalConnect;
begin
  raise UnsupportedFeatureError('Connect database');
end;

function TPressOPFConnector.InternalDatasetClass: TPressOPFDatasetClass;
begin
  raise UnsupportedFeatureError('Dataset class');
end;

procedure TPressOPFConnector.InternalRollback;
begin
  raise UnsupportedFeatureError('Rollback transaction');
end;

procedure TPressOPFConnector.InternalStartTransaction;
begin
  raise UnsupportedFeatureError('Start transaction');
end;

procedure TPressOPFConnector.Rollback;
begin
  {$IFDEF PressLogDAOPersistence}
  PressLogMsg(Self, 'OPF: Rollback');
  {$ENDIF}
  InternalRollback;
end;

procedure TPressOPFConnector.StartTransaction;
begin
  InternalConnect;
  {$IFDEF PressLogDAOPersistence}
  PressLogMsg(Self, 'OPF: Start transaction');
  {$ENDIF}
  InternalStartTransaction;
end;

function TPressOPFConnector.UnsupportedFeatureError(
  const AFeatureName: string): EPressOPFError;
begin
  Result := EPressOPFError.CreateFmt(SUnsupportedFeature, [AFeatureName]);
end;

end.
