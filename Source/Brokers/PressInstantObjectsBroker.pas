(*
  PressObjects, InstantObjects Persistence Broker
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressInstantObjectsBroker;

{.$DEFINE IO2.1}
{$I Press.inc}

interface

uses
  Db,
  PressSubject,
  PressPersistence,
  InstantConnectionManager,
  InstantConnectionManagerFormUnit,
  InstantPersistence;

type
  TPressInstantObjectsPersistence = class(TPressThirdPartyPersistence)
  private
    FConnectionManager: TInstantConnectionManager;
    FConnector: TInstantConnector;
    procedure ConnectionManagerConnect(Sender: TObject; var ConnectionDef: TInstantConnectionDef; var Result: Boolean);
    function CreateInstantObject(AObject: TPressObject): TInstantObject;
    function CreatePressObject(AClass: TPressObjectClass; ADataSet: TDataSet): TPressObject;
    procedure InstantGenerateOID(Sender: TObject; const AObject: TInstantObject; var Id: string);
    procedure InstantLog(const AString: string);
    { TODO : Use streaming to copy an InstantObject to a PressObject and vice-versa }
    procedure ReadInstantObject(AInstantObject: TInstantObject; APressObject: TPressObject);
    procedure ReadPressObject(APressObject: TPressObject; AInstantObject: TInstantObject);
  protected
    function GetIdentifierQuotes: string; override;
    function GetStrQuote: Char; override;
    procedure InitService; override;
    procedure InternalCommit; override;
    procedure InternalShowConnectionManager; override;
    procedure InternalDispose(AClass: TPressObjectClass; const AId: string); override;
    procedure InternalExecuteStatement(const AStatement: string); override;
    function InternalOQLQuery(const AOQLStatement: string): TPressProxyList; override;
    function InternalRetrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata): TPressObject; override;
    function InternalRetrieveProxyList(AQuery: TPressQuery): TPressProxyList; override;
    function InternalSQLProxy(const ASQLStatement: string): TPressProxyList; override;
    function InternalSQLQuery(AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList; override;
    procedure InternalRollback; override;
    procedure InternalStartTransaction; override;
    procedure InternalStore(AObject: TPressObject); override;
    property Connector: TInstantConnector read FConnector;
  public
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils,
  PressClasses,
  PressConsts,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressAttributes,
  {$IFDEF IO2.1}InstantBrokers,{$ENDIF}
  InstantClasses;

type
  TPressInstantSQLQueryFriend = class(TInstantSQLQuery);
  TPressInstantPartsFriend = class(TInstantParts);
  TPressInstantReferencesFriend = class(TInstantReferences);

function DefaultConnector: TInstantConnector;
begin
  Result := InstantDefaultConnector;
  if not Assigned(Result) then
    raise EPressError.Create(SUnassignedPersistenceConnector);
end;

{ TPressInstantObjectsPersistence }

procedure TPressInstantObjectsPersistence.ConnectionManagerConnect(Sender: TObject;
  var ConnectionDef: TInstantConnectionDef; var Result: Boolean);
begin
  FConnector.Free;
  FConnector := ConnectionDef.CreateConnector(nil);
  FConnector.OnGenerateId := InstantGenerateOID;
  FConnector.IsDefault := True;
  Result := True;
end;

function TPressInstantObjectsPersistence.CreateInstantObject(AObject: TPressObject): TInstantObject;
var
  VInstantObjectClass: TInstantObjectClass;
begin
  VInstantObjectClass := InstantFindClass(AObject.PersistentName);
  if (AObject.IsPersistent) then
    Result := VInstantObjectClass.Retrieve(AObject.PersistentId, True)
  else
    Result := VInstantObjectClass.Create;
  try
    ReadPressObject(AObject, Result);
  except
    Result.Free;
    raise;
  end;
end;

function TPressInstantObjectsPersistence.CreatePressObject(
  AClass: TPressObjectClass; ADataSet: TDataSet): TPressObject;
var
  VAttribute: TPressAttribute;
  I: Integer;
begin
  Result := AClass.Create(Self);
  try
    for I := 0 to Pred(ADataSet.FieldCount) do
    begin
      VAttribute := Result.FindAttribute(ADataSet.FieldDefs[I].Name);
      if Assigned(VAttribute) then
        VAttribute.AsVariant := ADataSet.Fields[I].AsVariant;
    end;
  except
    Result.Free;
    raise;
  end;
end;

destructor TPressInstantObjectsPersistence.Destroy;
begin
  FConnectionManager.Free;
  FConnector.Free;
  inherited;
end;

function TPressInstantObjectsPersistence.GetIdentifierQuotes: string;
var
  VInstantBroker: TInstantBroker;
begin
  VInstantBroker := DefaultConnector.Broker;
  if VInstantBroker is TInstantCustomRelationalBroker then
    Result := TInstantCustomRelationalBroker(VInstantBroker).SQLDelimiters
  else
    Result := '';
end;

function TPressInstantObjectsPersistence.GetStrQuote: Char;
var
  VInstantBroker: TInstantBroker;
begin
  VInstantBroker := DefaultConnector.Broker;
  if VInstantBroker is TInstantCustomRelationalBroker then
    Result := TInstantCustomRelationalBroker(VInstantBroker).SQLQuote
  else
    Result := '"';
end;

procedure TPressInstantObjectsPersistence.InitService;
begin
  inherited;
  InstantLogProc := InstantLog;
  FConnectionManager := TInstantConnectionManager.Create(nil);
  with FConnectionManager do
  begin
    OnConnect := ConnectionManagerConnect;
    VisibleActions :=
     [atNew, atEdit, atDelete, atRename, atConnect, atBuild, atEvolve, atOpen];
    FileFormat := sfXML;
    Caption := SConnectionManagerCaption;
    FileName := ChangeFileExt(ParamStr(0), '.xml');
    LoadConnectionDefs;
    if ConnectionDefs.Count = 1 then
      ConnectByName(ConnectionDefs[0].Name)
    else
      Execute;
  end;
end;

procedure TPressInstantObjectsPersistence.InstantGenerateOID(
  Sender: TObject; const AObject: TInstantObject; var Id: string);
var
  VObjectClass: TPressObjectClass;
begin
  if Assigned(AObject) then
    VObjectClass := PressModel.ClassByPersistentName(AObject.ClassName)
  else
    VObjectClass := nil;
  Id := GenerateOID(VObjectClass);
end;

procedure TPressInstantObjectsPersistence.InstantLog(const AString: string);
begin
  {$IFDEF PressLogDAOPersistence}PressLogMsg(Self, 'Instant: ' + AString);{$ENDIF}
end;

procedure TPressInstantObjectsPersistence.InternalCommit;
begin
  Connector.CommitTransaction;
end;

procedure TPressInstantObjectsPersistence.InternalDispose(
  AClass: TPressObjectClass; const AId: string);
var
  VInstantObject: TInstantObject;
begin
  VInstantObject := InstantFindClass(
   AClass.ClassMetadata.PersistentName).Retrieve(AId, False);
  if Assigned(VInstantObject) then
    try
      VInstantObject.Dispose;
    finally
      VInstantObject.Free;
    end;
end;

procedure TPressInstantObjectsPersistence.InternalExecuteStatement(
  const AStatement: string);
begin
  (Connector.Broker as TInstantCustomRelationalBroker).Execute(AStatement);
end;

function TPressInstantObjectsPersistence.InternalOQLQuery(
  const AOQLStatement: string): TPressProxyList;
var
  VInstantQuery: TInstantQuery;
  I: Integer;
begin
  VInstantQuery := DefaultConnector.CreateQuery;
  try
    Result := TPressProxyList.Create(True, ptShared);
    try
      VInstantQuery.Command := AOQLStatement;
      VInstantQuery.Open;
      if VInstantQuery is TInstantSQLQuery then
        for I := 0 to Pred(VInstantQuery.ObjectCount) do
          with TPressInstantSQLQueryFriend(VInstantQuery).ObjectReferenceList.RefItems[I] do
            Result.AddReference(ObjectClassName, ObjectId, Self)
      else
        { TODO : Implement }
        // for I := 0 to Pred(VQuery.ObjectCount) do
        //   Result.Add(CreateReference(CreatePressObject(VQuery.Objects[I])));
        ;
    except
      Result.Free;
      raise;
    end;
  finally
    VInstantQuery.Free;
  end;
end;

function TPressInstantObjectsPersistence.InternalRetrieve(
  AClass: TPressObjectClass; const AId: string;
  AMetadata: TPressObjectMetadata): TPressObject;
var
  VInstantObject: TInstantObject;
begin
  VInstantObject := InstantFindClass(
   AClass.ClassMetadata.PersistentName).Retrieve(AId, False);
  if Assigned(VInstantObject) then
  begin
    Result := AClass.Create(Self, AMetadata);
    try
      PersistentObject[Result] := VInstantObject;
      ReadInstantObject(VInstantObject, Result);
    except
      Result.Free;
      raise;
    end;
  end else
    Result := nil;
end;

function TPressInstantObjectsPersistence.InternalRetrieveProxyList(
  AQuery: TPressQuery): TPressProxyList;

  function SelectPart: string;
  begin
    Result := 'SELECT ' + AQuery.FieldNamesClause;
  end;

  function FromPart: string;
  begin
    Result := AQuery.FromClause;
    if Result <> '' then
      if (AQuery.Style = qsOQL) and AQuery.Metadata.IncludeSubClasses then
        Result := ' FROM ANY ' + Result
      else
        Result := ' FROM ' + Result;
  end;

  function WherePart: string;
  begin
    Result := AQuery.WhereClause;
    if Result <> '' then
      Result := ' WHERE ' + Result;
  end;

  function GroupByPart: string;
  begin
    Result := AQuery.GroupByClause;
    if Result <> '' then
      Result := ' GROUP BY ' + Result;
  end;

  function OrderByPart: string;
  begin
    Result := AQuery.OrderByClause;
    if Result <> '' then
      Result := ' ORDER BY ' + Result;
  end;

var
  VQueryStr: string;
begin
  VQueryStr := SelectPart + FromPart + WherePart + GroupByPart + OrderByPart;
  {$IFDEF PressLogDAOPersistence}PressLogMsg(Self, 'Querying "' +  VQueryStr + '"');{$ENDIF}
  case AQuery.Style of
    qsOQL: Result := OQLQuery(VQueryStr);
    qsReference: Result := SQLProxy(VQueryStr);
    else {qsCustom} Result := SQLQuery(AQuery.Metadata.ItemObjectClass, VQueryStr);
  end;
end;

procedure TPressInstantObjectsPersistence.InternalRollback;
begin
  Connector.RollbackTransaction;
end;

procedure TPressInstantObjectsPersistence.InternalShowConnectionManager;
begin
  if Assigned(FConnectionManager) then
    FConnectionManager.Execute;
end;

function TPressInstantObjectsPersistence.InternalSQLProxy(
  const ASQLStatement: string): TPressProxyList;
var
  VBroker: TInstantSQLBroker;
  VDataSet: TDataSet;
begin
  VBroker := DefaultConnector.Broker as TInstantSQLBroker;
  VDataSet := VBroker.AcquireDataSet(ASQLStatement);
  try
    Result := TPressProxyList.Create(True, ptShared);
    try
      VDataSet.Open;
      while not VDataSet.Eof do
      begin
        Result.AddReference(
         VDataSet.Fields[0].AsString, VDataSet.Fields[1].AsString, Self);
        VDataSet.Next;
      end;
    except
      Result.Free;
      raise;
    end;
  finally
    VBroker.ReleaseDataSet(VDataSet);
  end;
end;

function TPressInstantObjectsPersistence.InternalSQLQuery(
  AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList;
var
  VBroker: TInstantSQLBroker;
  VDataSet: TDataSet;
  VInstance: TPressObject;
begin
  VBroker := DefaultConnector.Broker as TInstantSQLBroker;
  VDataSet := VBroker.AcquireDataSet(ASQLStatement);
  try
    Result := TPressProxyList.Create(True, ptShared);
    try
      VDataSet.Open;
      while not VDataSet.Eof do
      begin
        VInstance := CreatePressObject(AClass, VDataSet);
        Result.AddInstance(VInstance);
        VInstance.Release;
        VDataSet.Next;
      end;
    except
      Result.Free;
      raise;
    end;
  finally
    VBroker.ReleaseDataSet(VDataSet);
  end;
end;

procedure TPressInstantObjectsPersistence.InternalStartTransaction;
begin
  Connector.StartTransaction;
end;

procedure TPressInstantObjectsPersistence.InternalStore(AObject: TPressObject);
var
  VPersistentObject: TObject;
  VInstantObject: TInstantObject;
begin
  VPersistentObject := PersistentObject[AObject];
  if VPersistentObject is TInstantObject then
  begin
    VInstantObject := TInstantObject(VPersistentObject);
    ReadPressObject(AObject, VInstantObject);
  end else
  begin
    VInstantObject := CreateInstantObject(AObject);
    PersistentObject[AObject] := VInstantObject;
  end;
  VInstantObject.Store;
  if AObject.Id = '' then
    AObject.Id := VInstantObject.Id;
end;

procedure TPressInstantObjectsPersistence.ReadInstantObject(
  AInstantObject: TInstantObject; APressObject: TPressObject);

  procedure ReadInstantReference(AInstantReference: TInstantReference;
    APressReference: TPressReference);
  var
    VObject: TPressObject;
  begin
    if (AInstantReference.ObjectClassName <> '') and (AInstantReference.ObjectId <> '') then
    begin
      APressReference.AssignReference(
       AInstantReference.ObjectClassName, AInstantReference.ObjectId);
    end else if AInstantReference.HasValue then
    begin
      VObject := PressModel.
       ClassByPersistentName(AInstantReference.Value.ClassName).Create(Self);
      ReadInstantObject(AInstantReference.Value, VObject);
      try
        APressReference.Value := VObject;
      except
        VObject.Free;
        raise;
      end;
      VObject.Release;
    end else
      APressReference.Value := nil;
  end;

  procedure ReadInstantParts(AInstantParts: TInstantParts; APressParts: TPressParts);
  var
    VObject: TPressObject;
    VReference: TInstantObjectReference;
    I: Integer;
  begin
    APressParts.Clear;
    for I := 0 to Pred(AInstantParts.Count) do
    begin

      //     READ-ME!!
      //
      // If you got a compilation error, move the InstantObjects'
      // TInstantParts.ObjectReference property declaration (line 1067)
      // to the protected area.
      //
      // You can also move to InstantObjects 2.1 where this issue was
      // fixed.
      //
      //     READ-ME!!

      VReference :=
       TPressInstantPartsFriend(AInstantParts).ObjectReferences[I];

      if (VReference.ObjectClassName <> '') and (VReference.ObjectId <> '') then
      begin
        APressParts.AddReference(
         VReference.ObjectClassName, VReference.ObjectId, Self);
      end else
      begin
        VObject := PressModel.
         ClassByPersistentName(AInstantParts[I].ClassName).Create(Self);
        ReadInstantObject(AInstantParts[I], VObject);
        try
          APressParts.Add(VObject);
        except
          VObject.Free;
          raise;
        end;
      end;
    end;
  end;

  procedure ReadInstantReferences(AInstantReferences: TInstantReferences;
    APressReferences: TPressReferences);
  var
    VObject: TPressObject;
    VReference: TInstantObjectReference;
    I: Integer;
  begin
    APressReferences.Clear;
    for I := 0 to Pred(AInstantReferences.Count) do
    begin
      VReference := AInstantReferences.RefItems[I];
      if (VReference.ObjectClassName <> '') and (VReference.ObjectId <> '') then
      begin
        APressReferences.AddReference(
         VReference.ObjectClassName, VReference.ObjectId, Self);
      end else if VReference.HasInstance then
      begin
        VObject := PressModel.
         ClassByPersistentName(VReference.Instance.ClassName).Create(Self);
        ReadInstantObject(VReference.Instance, VObject);
        try
          APressReferences.Add(VObject);
        except
          VObject.Free;
          raise;
        end;
        VObject.Release;
      end;
    end;
  end;

var
  VPressAttr: TPressAttribute;
  VInstantAttr: TInstantAttribute;
  I: Integer;
begin
  APressObject.DisableChanges;
  try
    APressObject.Id := AInstantObject.Id;
    PressAssignPersistentId(APressObject, AInstantObject.PersistentId);
    for I := 0 to Pred(APressObject.AttributeCount) do
    begin
      VPressAttr := APressObject.Attributes[I];
      if (VPressAttr.Name = SPressIdString) or
       not VPressAttr.Metadata.IsPersistent then
        Continue;
      VInstantAttr := AInstantObject.AttributeByName(VPressAttr.PersistentName);
      case VPressAttr.AttributeBaseType of
        attString, attMemo, attBinary, attPicture:
          VPressAttr.AsString := VInstantAttr.AsString;
        attInteger, attEnum:
          VPressAttr.AsInteger := VInstantAttr.AsInteger;
        attFloat:
          VPressAttr.AsFloat := VInstantAttr.AsFloat;
        attCurrency:
          VPressAttr.AsCurrency := VInstantAttr.AsCurrency;
        attBoolean:
          VPressAttr.AsBoolean := VInstantAttr.AsBoolean;
        attDate, attTime, attDateTime:
          VPressAttr.AsDateTime := VInstantAttr.AsDateTime;
        attPart:
          ReadInstantObject(TInstantPart(VInstantAttr).Value, TPressPart(VPressAttr).Value);
        attReference:
          ReadInstantReference(TInstantReference(VInstantAttr), TPressReference(VPressAttr));
        attParts:
          ReadInstantParts(TInstantParts(VInstantAttr), TPressParts(VPressAttr));
        attReferences:
          ReadInstantReferences(TInstantReferences(VInstantAttr), TPressReferences(VPressAttr));
        else
          raise EPressError.CreateFmt(SUnsupportedAttribute,
           [APressObject.ClassName, VPressAttr.Name]);
      end;
    end;
  finally
    APressObject.EnableChanges;
  end;
end;

procedure TPressInstantObjectsPersistence.ReadPressObject(
  APressObject: TPressObject; AInstantObject: TInstantObject);

  procedure ReadPressReference(APressReference: TPressReference;
    AInstantReference: TInstantReference);
  begin
    if APressReference.HasInstance and
     not APressReference.Value.IsPersistent then
      APressReference.Value.Store;
    if (APressReference.ObjectClassName <> '') and
     (APressReference.ObjectId <> '') then
      AInstantReference.ReferenceObject(
       APressReference.ObjectClassName, APressReference.ObjectId)
    else
      AInstantReference.Value := nil;
  end;

  procedure ReadPressParts(APressParts: TPressParts; AInstantParts: TInstantParts);
  var
    VObject: TInstantObject;
    I: Integer;
  begin
    { TODO : Optimize (Unmodified, Modified, Inserted, Deleted) }
    AInstantParts.Clear;
    for I := 0 to Pred(APressParts.Count) do
    begin
      VObject := InstantFindClass(APressParts[I].PersistentName).Create;
      try
        AInstantParts.Add(VObject);
      except
        VObject.Free;
        raise;
      end;
      ReadPressObject(APressParts[I], VObject);
    end;
  end;

  procedure ReadPressReferences(APressReferences: TPressReferences;
    AInstantReferences: TInstantReferences);
  var
    VObjectReference: TInstantObjectReference;
    VProxy: TPressProxy;
    I: Integer;
  begin
    AInstantReferences.Clear;
    for I := 0 to Pred(APressReferences.Count) do
    begin
      VProxy := APressReferences.Proxies[I];
      if VProxy.HasInstance and not VProxy.Instance.IsPersistent then
        VProxy.Instance.Store;
      if (VProxy.ObjectClassName <> '') and (VProxy.ObjectId <> '') then
      begin
        VObjectReference := TPressInstantReferencesFriend(AInstantReferences).
         ObjectReferenceList.Add;
        VObjectReference.
         ReferenceObject(VProxy.ObjectClassName, VProxy.ObjectId);
      end;
    end;
  end;

var
  VPressAttr: TPressAttribute;
  VInstantAttr: TInstantAttribute;
  I: Integer;
begin
  AInstantObject.Id := APressObject.Id;
  for I := 0 to Pred(APressObject.AttributeCount) do
  begin
    VPressAttr := APressObject.Attributes[I];
    if (VPressAttr.Name = SPressIdString) or
     not VPressAttr.Metadata.IsPersistent or (APressObject.IsPersistent and
     not APressObject.IsOwned and not VPressAttr.IsChanged) then
      Continue;
    VInstantAttr := AInstantObject.AttributeByName(VPressAttr.PersistentName);
    case VPressAttr.AttributeBaseType of
      attString, attMemo, attBinary, attPicture:
        VInstantAttr.AsString := VPressAttr.AsString;
      attInteger, attEnum:
        VInstantAttr.AsInteger := VPressAttr.AsInteger;
      attFloat:
        VInstantAttr.AsFloat := VPressAttr.AsFloat;
      attCurrency:
        VInstantAttr.AsCurrency := VPressAttr.AsCurrency;
      attBoolean:
        VInstantAttr.AsBoolean := VPressAttr.AsBoolean;
      attDate, attDateTime, attTime:
        VInstantAttr.AsDateTime := VPressAttr.AsDateTime;
      attPart:
        ReadPressObject(TPressPart(VPressAttr).Value, TInstantPart(VInstantAttr).Value);
      attReference:
        ReadPressReference(TPressReference(VPressAttr), TInstantReference(VInstantAttr));
      attParts:
        ReadPressParts(TPressParts(VPressAttr), TInstantParts(VInstantAttr));
      attReferences:
        ReadPressReferences(TPressReferences(VPressAttr), TInstantReferences(VInstantAttr));
      else
        raise EPressError.CreateFmt(SUnsupportedAttribute,
         [APressObject.ClassName, VPressAttr.Name]);
    end;
  end;
end;

initialization
  TPressInstantObjectsPersistence.RegisterService;

end.
