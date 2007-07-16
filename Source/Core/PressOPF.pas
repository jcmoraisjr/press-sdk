(*
  PressObjects, Core Persistence Class
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressOPF;

{$I Press.inc}

interface

uses
  PressSubject,
  PressPersistence,
  PressOPFBroker,
  PressOPFConnector,
  PressOPFMapper;

type
  TPressOPF = class(TPressPersistence)
  private
    FBroker: TPressOPFBroker;
    FConnector: TPressOPFConnector;
    FMapper: TPressOPFObjectMapper;
    FStatementDataset: TPressOPFDataset;
    function GetConnector: TPressOPFConnector;
    function GetMapper: TPressOPFObjectMapper;
    function GetStatementDataset: TPressOPFDataset;
    procedure SetBroker(AValue: TPressOPFBroker);
  protected
    function CreatePressObject(AClass: TPressObjectClass; ADataset: TPressOPFDataset; ADatasetIndex: Integer): TPressObject;
    procedure DoneService; override;
    procedure InternalCommit; override;
    function InternalDBMSName: string; override;
    procedure InternalDispose(AClass: TPressObjectClass; const AId: string); override;
    function InternalExecuteStatement(const AStatement: string): Integer; override;
    procedure InternalIsDefaultChanged; override;
    function InternalOQLQuery(const AOQLStatement: string): TPressProxyList; override;
    function InternalRetrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata): TPressObject; override;
    procedure InternalRollback; override;
    procedure InternalShowConnectionManager; override;
    function InternalSQLProxy(const ASQLStatement: string): TPressProxyList; override;
    function InternalSQLQuery(AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList; override;
    procedure InternalStartTransaction; override;
    procedure InternalStore(AObject: TPressObject); override;
    property StatementDataset: TPressOPFDataset read GetStatementDataset;
  public
    function EnsureBroker: TPressOPFBroker;
    property Broker: TPressOPFBroker read FBroker write SetBroker;
    property Connector: TPressOPFConnector read GetConnector;
    property Mapper: TPressOPFObjectMapper read GetMapper;
  end;

function PressOPFService: TPressOPF;

implementation

uses
  SysUtils,
  PressApplication,
  PressConsts,
  PressOPFClasses,
  PressOQL;

var
  _PressOPFService: TPressOPF;

function PressOPFService: TPressOPF;
begin
  if not Assigned(_PressOPFService) then
  begin
    PressDefaultDAO;
    if not Assigned(_PressOPFService) then
      raise EPressOPFError.Create(SUnassignedPersistenceService);
  end;
  Result := _PressOPFService;
end;

{ TPressOPF }

function TPressOPF.CreatePressObject(AClass: TPressObjectClass;
  ADataset: TPressOPFDataset; ADatasetIndex: Integer): TPressObject;
var
  VAttribute: TPressAttribute;
  I: Integer;
begin
  Result := AClass.Create(Self);
  try
    for I := 0 to Pred(ADataset.FieldDefs.Count) do
    begin
      VAttribute := Result.FindAttribute(ADataset.FieldDefs[I].Name);
      if Assigned(VAttribute) then
        VAttribute.AsVariant := ADataset[ADatasetIndex][I].Value;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TPressOPF.DoneService;
begin
  FMapper.Free;
  FStatementDataset.Free;
  inherited;
end;

function TPressOPF.EnsureBroker: TPressOPFBroker;
begin
  if not Assigned(FBroker) then
    FBroker :=
     PressApp.DefaultService(CPressOPFBrokerService) as TPressOPFBroker;
  Result := FBroker;
end;

function TPressOPF.GetConnector: TPressOPFConnector;
begin
  if not Assigned(FConnector) then
    FConnector := EnsureBroker.Connector;
  Result := FConnector;
end;

function TPressOPF.GetMapper: TPressOPFObjectMapper;
begin
  if not Assigned(FMapper) then
    FMapper :=
     EnsureBroker.MapperClass.Create(Self, PressStorageModel, Connector);
  Result := FMapper;
end;

function TPressOPF.GetStatementDataset: TPressOPFDataset;
begin
  if not Assigned(FStatementDataset) then
    FStatementDataset := Connector.CreateDataset;
  Result := FStatementDataset;
end;

procedure TPressOPF.InternalCommit;
begin
  Connector.Commit;
end;

function TPressOPF.InternalDBMSName: string;
begin
  Result := Connector.DBMSName;
end;

procedure TPressOPF.InternalDispose(AClass: TPressObjectClass;
  const AId: string);
begin
  Mapper.Dispose(AClass, AId);
end;

function TPressOPF.InternalExecuteStatement(const AStatement: string): Integer;
begin
  StatementDataset.SQL := AStatement;
  Result := StatementDataset.Execute;
end;

procedure TPressOPF.InternalIsDefaultChanged;
begin
  inherited;
  if IsDefault then
    _PressOPFService := Self
  else
    _PressOPFService := nil;
end;

function TPressOPF.InternalOQLQuery(
  const AOQLStatement: string): TPressProxyList;
var
  VOQLParser: TPressOQLSelectStatement;
  VOQLReader: TPressOQLReader;
  VDataset: TPressOPFDataset;
  VDataRow: TPressOPFDataRow;
  I: Integer;
begin
  VOQLReader := TPressOQLReader.Create(AOQLStatement);
  VOQLParser := TPressOQLSelectStatement.Create(nil, PressModel);
  try
    VOQLParser.Read(VOQLReader);
    VDataset := Connector.CreateDataset;
    try
      VDataset.SQL := VOQLParser.AsSQL;
      VDataset.Execute;
      Result := TPressProxyList.Create(True, ptShared);
      try
        if VDataset.FieldDefs.Count > 1 then
          for I := 0 to Pred(VDataset.Count) do
          begin
            VDataRow := VDataset[I];
            Result.AddReference(Mapper.StorageModel.ClassNameById(
             VDataRow[1].AsString), VDataRow[0].AsString, Self);
          end
        else
          for I := 0 to Pred(VDataset.Count) do
            Result.AddReference(
             VOQLParser.ObjectClassName, VDataSet[I][0].Value, Self);
      except
        FreeAndNil(Result);
        raise;
      end;
    finally
      VDataset.Free;
    end;
  finally
    VOQLParser.Free;
    VOQLReader.Free;
  end;
end;

function TPressOPF.InternalRetrieve(AClass: TPressObjectClass;
  const AId: string; AMetadata: TPressObjectMetadata): TPressObject;
begin
  Result := Mapper.Retrieve(AClass, AId, AMetadata);
end;

procedure TPressOPF.InternalRollback;
begin
  Connector.Rollback;
end;

procedure TPressOPF.InternalShowConnectionManager;
begin
  EnsureBroker.ShowConnectionManager;
end;

function TPressOPF.InternalSQLProxy(
  const ASQLStatement: string): TPressProxyList;
var
  VDataset: TPressOPFDataset;
  I: Integer;
begin
  VDataset := Connector.CreateDataset;
  try
    Result := TPressProxyList.Create(True, ptShared);
    try
      VDataset.SQL := ASQLStatement;
      VDataset.Execute;
      for I := 0 to Pred(VDataset.Count) do
        Result.AddReference(
         VDataset[I][0].AsString, VDataSet[I][1].AsString, Self);
    except
      Result.Free;
      raise;
    end;
  finally
    VDataset.Free;
  end;
end;

function TPressOPF.InternalSQLQuery(AClass: TPressObjectClass;
  const ASQLStatement: string): TPressProxyList;
var
  VDataset: TPressOPFDataset;
  VInstance: TPressObject;
  I: Integer;
begin
  VDataset := Connector.CreateDataset;
  try
    Result := TPressProxyList.Create(True, ptShared);
    try
      VDataset.SQL := ASQLStatement;
      VDataset.Execute;
      for I := 0 to Pred(VDataset.Count) do
      begin
        VInstance := CreatePressObject(AClass, VDataset, I);
        Result.AddInstance(VInstance);
        VInstance.Release;
      end;
    except
      Result.Free;
      raise;
    end;
  finally
    VDataset.Free;
  end;
end;

procedure TPressOPF.InternalStartTransaction;
begin
  Connector.StartTransaction;
end;

procedure TPressOPF.InternalStore(AObject: TPressObject);
begin
  Mapper.Store(AObject);
end;

procedure TPressOPF.SetBroker(AValue: TPressOPFBroker);
begin
  if FBroker <> AValue then
  begin
    if Cache.HasObject then
      raise EPressOPFError.Create(SCannotChangeOPFBroker);
    FreeAndNil(FMapper);
    FBroker := AValue;
  end;
end;

initialization
  TPressOPF.RegisterService;

end.
