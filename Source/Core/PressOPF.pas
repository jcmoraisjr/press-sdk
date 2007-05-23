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
  PressApplication,
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
    procedure DoneService; override;
    procedure InternalCommit; override;
    procedure InternalDispose(AClass: TPressObjectClass; const AId: string); override;
    function InternalExecuteStatement(const AStatement: string): Integer; override;
    procedure InternalIsDefaultChanged; override;
    function InternalOQLQuery(const AOQLStatement: string): TPressProxyList; override;
    function InternalRetrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata): TPressObject; override;
    function InternalRetrieveProxyList(AQuery: TPressQuery): TPressProxyList; override;
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

  procedure PopulateProxyList(
    AList: TPressProxyList; ADataset: TPressOPFDataset);
  var
    VDataRow: TPressOPFDataRow;
    I: Integer;
  begin
    for I := 0 to Pred(ADataset.Count) do
    begin
      VDataRow := ADataset[I];
      AList.AddReference(VDataRow[1].Value, VDataRow[0].Value, Self);
    end;
  end;

var
  VOQLParser: TPressOQLSelectStatement;
  VOQLReader: TPressOQLReader;
  VDataset: TPressOPFDataset;
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
        PopulateProxyList(Result, VDataset);
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

function TPressOPF.InternalRetrieveProxyList(
  AQuery: TPressQuery): TPressProxyList;
var
  VQuery: string;
begin
  VQuery := AQuery.WhereClause;
  if VQuery <> '' then
    VQuery := ' where ' + VQuery;
  VQuery := 'select * from ' + AQuery.FromClause + VQuery;
  Result := OQLQuery(VQuery);
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
begin
  { TODO : Implement }
  Result := nil;
end;

function TPressOPF.InternalSQLQuery(AClass: TPressObjectClass;
  const ASQLStatement: string): TPressProxyList;
begin
  { TODO : Implement }
  Result := nil;
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
