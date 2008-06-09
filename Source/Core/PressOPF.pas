(*
  PressObjects, Core Persistence Classes
  Copyright (C) 2007-2008 Laserpress Ltda.

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
  PressApplication,
  PressSubject,
  PressSession,
  PressOPFConnector,
  PressOPFMapper;

const
  CPressOPFBrokerService = CPressSessionServicesBase + $0003;

type
  TPressOPFBroker = class;

  TPressOPF = class(TPressPersistence)
  private
    FBroker: TPressOPFBroker;
    FConnector: TPressOPFConnector;
    FGeneratorDataset: TPressOPFDataset;
    FMapper: TPressOPFObjectMapper;
    FStatementDataset: TPressOPFDataset;
    function EnsureBroker: TPressOPFBroker;
    function GetConnector: TPressOPFConnector;
    function GetGeneratorDataset: TPressOPFDataset;
    function GetMapper: TPressOPFObjectMapper;
    function GetStatementDataset: TPressOPFDataset;
    procedure SetBroker(AValue: TPressOPFBroker);
  protected
    function CreatePressObject(AClass: TPressObjectClass; ADataset: TPressOPFDataset; ADatasetIndex: Integer): TPressObject;
    procedure DoneService; override;
    procedure Finit; override;
    procedure InternalBulkRetrieve(AProxyList: TPressProxyList; AStartingAt, AItemCount: Integer; AAttributes: TPressSessionAttributes); override;
    procedure InternalCommit; override;
    function InternalDBMSName: string; override;
    procedure InternalDispose(AClass: TPressObjectClass; const AId: string); override;
    function InternalExecuteStatement(const AStatement: string; AParams: TPressParamList): Integer; override;
    function InternalGeneratorClass: TPressGeneratorClass; override;
    function InternalImplementsBulkRetrieve: Boolean; override;
    function InternalImplementsLazyLoading: Boolean; override;
    procedure InternalIsDefaultChanged; override;
    procedure InternalLoad(AObject: TPressObject; AIncludeLazyLoading, ALoadContainers: Boolean); override;
    function InternalOQLQuery(const AOQLStatement: string; AParams: TPressParamList): TPressProxyList; override;
    procedure InternalRefresh(AObject: TPressObject); override;
    function InternalRetrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata; AAttributes: TPressSessionAttributes): TPressObject; override;
    procedure InternalRetrieveAttribute(AAttribute: TPressAttribute); override;
    procedure InternalRollback; override;
    procedure InternalShowConnectionManager; override;
    function InternalSQLProxy(const ASQLStatement: string; AParams: TPressParamList): TPressProxyList; override;
    function InternalSQLQuery(AClass: TPressObjectClass; const ASQLStatement: string; AParams: TPressParamList): TPressProxyList; override;
    procedure InternalStartTransaction; override;
    procedure InternalStore(AObject: TPressObject); override;
    property Broker: TPressOPFBroker read FBroker write SetBroker;
    property Connector: TPressOPFConnector read GetConnector;
    property GeneratorDataset: TPressOPFDataset read GetGeneratorDataset;
    property Mapper: TPressOPFObjectMapper read GetMapper;
    property StatementDataset: TPressOPFDataset read GetStatementDataset;
  public
    function CreateDatabaseStatement: string;
    function CreateDataset: TPressOPFDataset;
  end;

  TPressOPFBrokerClass = class of TPressOPFBroker;

  TPressOPFBroker = class(TPressService)
  private
    FConnector: TPressOPFConnector;
    function GetConnector: TPressOPFConnector;
  protected
    procedure DoneService; override;
    function InternalConnectorClass: TPressOPFConnectorClass; virtual;
    function InternalMapperClass: TPressOPFObjectMapperClass; virtual;
    procedure InternalShowConnectionManager; virtual;
    class function InternalServiceType: TPressServiceType; override;
  public
    function MapperClass: TPressOPFObjectMapperClass;
    procedure ShowConnectionManager;
    property Connector: TPressOPFConnector read GetConnector;
  end;

  TPressOPFConnection = class(TPressServiceComponent)
  private
    FConnector: TPressOPFConnector;
    function GetService: TPressOPF;
  protected
    function InternalBrokerClass: TPressOPFBrokerClass; virtual; abstract;
    function InternalCreateService: TPressService; override;
    property Connector: TPressOPFConnector read FConnector;
  public
    property Service: TPressOPF read GetService;
  end;

  TPressOPFGenerator = class(TPressGenerator)
  private
    FDataset: TPressOPFDataset;
    FMapper: TPressOPFObjectMapper;
  protected
    procedure DoneService; override;
    function InternalGenerateOID(AObjectClass: TPressObjectClass; const AAttributeName: string): string; override;
  end;

function PressOPFService: TPressOPF;

implementation

uses
  SysUtils,
  PressConsts,
  PressAttributes,
  PressOPFClasses,
  PressOPFStorage,
  PressOQL;

type
  TPressObjectFriend = class(TPressObject);

var
  _PressOPFService: TPressOPF;

function PressOPFService: TPressOPF;
begin
  if not Assigned(_PressOPFService) then
  begin
    PressDefaultSession;
    if not Assigned(_PressOPFService) then
      raise EPressOPFError.Create(SUnassignedPersistenceService);
  end;
  Result := _PressOPFService;
end;

{ TPressOPF }

function TPressOPF.CreateDatabaseStatement: string;
begin
  Result := Mapper.CreateDatabaseStatement;
end;

function TPressOPF.CreateDataset: TPressOPFDataset;
begin
  Result := Connector.CreateDataset;
end;

function TPressOPF.CreatePressObject(AClass: TPressObjectClass;
  ADataset: TPressOPFDataset; ADatasetIndex: Integer): TPressObject;
var
  VAttribute: TPressAttribute;
  I: Integer;
begin
  Result := AClass.Create;
  TPressObjectFriend(Result).AddSessionIntf(Self);
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
  FGeneratorDataset.Free;
  FStatementDataset.Free;
  inherited;
end;

function TPressOPF.EnsureBroker: TPressOPFBroker;
begin
  if not Assigned(FBroker) then
  begin
    FBroker :=
     PressApp.Services.DefaultServiceByType(CPressOPFBrokerService) as TPressOPFBroker;
    FBroker.AddRef;
  end;
  Result := FBroker;
end;

procedure TPressOPF.Finit;
begin
  FBroker.Free;
  inherited;
end;

function TPressOPF.GetConnector: TPressOPFConnector;
begin
  if not Assigned(FConnector) then
    FConnector := EnsureBroker.Connector;
  Result := FConnector;
end;

function TPressOPF.GetGeneratorDataset: TPressOPFDataset;
begin
  if not Assigned(FGeneratorDataset) then
    FGeneratorDataset := Connector.CreateDataset;
  Result := FGeneratorDataset;
end;

function TPressOPF.GetMapper: TPressOPFObjectMapper;
begin
  if not Assigned(FMapper) then
    FMapper :=
     EnsureBroker.MapperClass.Create(Self, PressStorageModel(Self), Connector);
  Result := FMapper;
end;

function TPressOPF.GetStatementDataset: TPressOPFDataset;
begin
  if not Assigned(FStatementDataset) then
    FStatementDataset := Connector.CreateDataset;
  Result := FStatementDataset;
end;

procedure TPressOPF.InternalBulkRetrieve(
  AProxyList: TPressProxyList; AStartingAt, AItemCount: Integer;
  AAttributes: TPressSessionAttributes);
begin
  Mapper.BulkRetrieve(AProxyList, AStartingAt, AItemCount, AAttributes);
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

function TPressOPF.InternalExecuteStatement(
  const AStatement: string; AParams: TPressParamList): Integer;
begin
  { TODO : Lock }
  StatementDataset.SQL := AStatement;
  StatementDataset.AssignParams(AParams);
  Result := StatementDataset.Execute;
end;

function TPressOPF.InternalGeneratorClass: TPressGeneratorClass;
begin
  Result := TPressOPFGenerator;
end;

function TPressOPF.InternalImplementsBulkRetrieve: Boolean;
begin
  Result := True;
end;

function TPressOPF.InternalImplementsLazyLoading: Boolean;
begin
  Result := True;
end;

procedure TPressOPF.InternalIsDefaultChanged;
begin
  inherited;
  if IsDefault then
    _PressOPFService := Self
  else
    _PressOPFService := nil;
end;

procedure TPressOPF.InternalLoad(
  AObject: TPressObject; AIncludeLazyLoading, ALoadContainers: Boolean);
var
  VAttribute: TPressAttribute;
begin
  Mapper.Load(AObject, AIncludeLazyLoading);
  with AObject.CreateAttributeIterator do
  try
    BeforeFirstItem;
    while NextItem do
    begin
      VAttribute := CurrentItem;
      if VAttribute is TPressItem then
        TPressItem(VAttribute).Value
      else if VAttribute is TPressItems then
      begin
        if ALoadContainers then
          BulkRetrieve(TPressItems(VAttribute).ProxyList, 0, 50, '');
      end;
    end;
  finally
    Free;
  end;
end;

function TPressOPF.InternalOQLQuery(
  const AOQLStatement: string; AParams: TPressParamList): TPressProxyList;
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
      VDataset.AssignParams(AParams);
      VDataset.Execute;
      Result := TPressProxyList.Create(Self, True, ptShared);
      try
        if VDataset.FieldDefs.Count > 1 then
          for I := 0 to Pred(VDataset.Count) do
          begin
            VDataRow := VDataset[I];
            Result.AddReference(Mapper.StorageModel.ClassNameById(
             VDataRow[1].AsString), VDataRow[0].AsString);
          end
        else
          for I := 0 to Pred(VDataset.Count) do
            Result.AddReference(
             VOQLParser.ObjectClassName, VDataSet[I][0].Value);
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

procedure TPressOPF.InternalRefresh(AObject: TPressObject);
begin
  Mapper.Refresh(AObject);
end;

function TPressOPF.InternalRetrieve(AClass: TPressObjectClass;
  const AId: string; AMetadata: TPressObjectMetadata;
  AAttributes: TPressSessionAttributes): TPressObject;
begin
  Result := Mapper.Retrieve(AClass, AId, AMetadata, AAttributes);
end;

procedure TPressOPF.InternalRetrieveAttribute(AAttribute: TPressAttribute);
begin
  Mapper.RetrieveAttribute(AAttribute);
end;

procedure TPressOPF.InternalRollback;
begin
  Mapper.Rollback;
  Connector.Rollback;
end;

procedure TPressOPF.InternalShowConnectionManager;
begin
  EnsureBroker.ShowConnectionManager;
end;

function TPressOPF.InternalSQLProxy(
  const ASQLStatement: string; AParams: TPressParamList): TPressProxyList;
var
  VDataset: TPressOPFDataset;
  I: Integer;
begin
  VDataset := Connector.CreateDataset;
  try
    Result := TPressProxyList.Create(Self, True, ptShared);
    try
      VDataset.SQL := ASQLStatement;
      VDataset.AssignParams(AParams);
      VDataset.Execute;
      for I := 0 to Pred(VDataset.Count) do
        Result.AddReference(
         VDataset[I][0].AsString, VDataSet[I][1].AsString);
    except
      Result.Free;
      raise;
    end;
  finally
    VDataset.Free;
  end;
end;

function TPressOPF.InternalSQLQuery(AClass: TPressObjectClass;
  const ASQLStatement: string; AParams: TPressParamList): TPressProxyList;
var
  VDataset: TPressOPFDataset;
  VInstance: TPressObject;
  I: Integer;
begin
  VDataset := Connector.CreateDataset;
  try
    Result := TPressProxyList.Create(Self, True, ptShared);
    try
      VDataset.SQL := ASQLStatement;
      VDataset.AssignParams(AParams);
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
  // do not start a db transaction; datasets will do when necessary
  Connector.StartTransactionNotification;
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
    FConnector := nil;
    FreeAndNil(FMapper);
    FBroker.Free;
    FBroker := AValue;
    FBroker.AddRef;
  end;
end;

{ TPressOPFBroker }

procedure TPressOPFBroker.DoneService;
begin
  FConnector.Free;
  inherited;
end;

function TPressOPFBroker.GetConnector: TPressOPFConnector;
begin
  if not Assigned(FConnector) then
    FConnector := InternalConnectorClass.Create;
  Result := FConnector;
end;

function TPressOPFBroker.InternalConnectorClass: TPressOPFConnectorClass;
begin
  Result := TPressOPFConnector;
end;

function TPressOPFBroker.InternalMapperClass: TPressOPFObjectMapperClass;
begin
  Result := TPressOPFObjectMapper;
end;

class function TPressOPFBroker.InternalServiceType: TPressServiceType;
begin
  Result := CPressOPFBrokerService;
end;

procedure TPressOPFBroker.InternalShowConnectionManager;
begin
end;

function TPressOPFBroker.MapperClass: TPressOPFObjectMapperClass;
begin
  Result := InternalMapperClass;
end;

procedure TPressOPFBroker.ShowConnectionManager;
begin
  InternalShowConnectionManager;
end;

{ TPressOPFConnection }

function TPressOPFConnection.GetService: TPressOPF;
begin
  Result := inherited Service as TPressOPF;
end;

function TPressOPFConnection.InternalCreateService: TPressService;
var
  VOPF: TPressOPF;
begin
  VOPF := TPressOPF(PressApp.Services.CreateServiceByBaseClass(TPressOPF));
  VOPF.Broker := InternalBrokerClass.Create;
  FConnector := VOPF.Connector;
  Result := VOPF;
end;

{ TPressOPFGenerator }

procedure TPressOPFGenerator.DoneService;
begin
  FDataset.Free;
  inherited;
end;

function TPressOPFGenerator.InternalGenerateOID(
  AObjectClass: TPressObjectClass; const AAttributeName: string): string;
var
  VOwner: TPressOPF;
  VGenerator: string;
begin
  if not Assigned(FDataset) or not Assigned(FMapper) then
  begin
    if not Assigned(Owner) then
      Exit;
    VOwner := Owner as TPressOPF;
    if not Assigned(FDataset) then
      FDataset := VOwner.Connector.CreateDataset;
    if not Assigned(FMapper) then
      FMapper := VOwner.Mapper;
  end;
  VGenerator := GeneratorName(AObjectClass, AAttributeName);
  if VGenerator <> '' then
    VGenerator := Format(FMapper.SelectGeneratorStatement, [VGenerator]);
  if VGenerator <> '' then
  begin
    FDataset.SQL := VGenerator;
    FDataset.Execute;
    Result := FDataset[0][0].AsString;
  end else
    Result := inherited InternalGenerateOID(AObjectClass, AAttributeName);
end;

initialization
  PressApp.Registry[CPressOPFBrokerService].ServiceTypeName :=
   SPressOPFBrokerServiceName;
  TPressOPF.RegisterService;

finalization
  TPressOPF.UnregisterService;

end.
