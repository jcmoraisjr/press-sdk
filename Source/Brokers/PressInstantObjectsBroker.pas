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

{.$DEFINE IO21}
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
    function AcquireInstantDataSet(const AStatement: string; AParams: TPressParamList): TDataSet;
    procedure ConnectionManagerConnect(Sender: TObject; var ConnectionDef: TInstantConnectionDef; var Result: Boolean);
    function CreateDBParams(AParams: TPressParamList): TParams;
    function CreateInstantObject(AObject: TPressObject): TInstantObject;
    function CreatePressObject(AClass: TPressObjectClass; ADataSet: TDataSet): TPressObject;
    procedure InstantGenerateOID(Sender: TObject; const AObject: TInstantObject; var Id: string);
    procedure InstantLog(const AString: string);
    function PressParamToDBParam(AParamType: TPressAttributeBaseType): TFieldType;
    { TODO : Use streaming to copy an InstantObject to a PressObject and vice-versa }
    procedure ReadInstantObject(AInstantObject: TInstantObject; APressObject: TPressObject);
    procedure ReadPressObject(APressObject: TPressObject; AInstantObject: TInstantObject);
    procedure ReleaseInstantDataSet(ADataSet: TDataSet);
  protected
    procedure Finit; override;
    procedure InitService; override;
    procedure InternalCommit; override;
    function InternalDBMSName: string; override;
    procedure InternalShowConnectionManager; override;
    procedure InternalDispose(AClass: TPressObjectClass; const AId: string); override;
    function InternalExecuteStatement(const AStatement: string; AParams: TPressParamList): Integer; override;
    function InternalOQLQuery(const AOQLStatement: string; AParams: TPressParamList): TPressProxyList; override;
    procedure InternalRefresh(AObject: TPressObject); override;
    function InternalRetrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata): TPressObject; override;
    function InternalSQLProxy(const ASQLStatement: string; AParams: TPressParamList): TPressProxyList; override;
    function InternalSQLQuery(AClass: TPressObjectClass; const ASQLStatement: string; AParams: TPressParamList): TPressProxyList; override;
    procedure InternalRollback; override;
    procedure InternalStartTransaction; override;
    procedure InternalStore(AObject: TPressObject); override;
    property Connector: TInstantConnector read FConnector;
  end;

implementation

uses
  SysUtils,
  TypInfo,
  PressClasses,
  PressConsts,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressAttributes,
  {$IFDEF IO21}InstantBrokers,{$ENDIF}
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

function TPressInstantObjectsPersistence.AcquireInstantDataSet(
  const AStatement: string; AParams: TPressParamList): TDataSet;
var
  VParams: TParams;
begin
  VParams := CreateDBParams(AParams);
  try
    Result := (DefaultConnector.Broker as TInstantSQLBroker).AcquireDataSet(
     AStatement, VParams);
  finally
    VParams.Free;
  end;
end;

procedure TPressInstantObjectsPersistence.ConnectionManagerConnect(Sender: TObject;
  var ConnectionDef: TInstantConnectionDef; var Result: Boolean);
begin
  FConnector.Free;
  FConnector := ConnectionDef.CreateConnector(nil);
  FConnector.OnGenerateId := InstantGenerateOID;
  FConnector.IsDefault := True;
  Result := True;
end;

function TPressInstantObjectsPersistence.CreateDBParams(
  AParams: TPressParamList): TParams;
var
  VParam: TPressParam;
  I: Integer;
begin
  if Assigned(AParams) and (AParams.Count > 0) then
  begin
    Result := TParams.Create;
    try
      for I := 0 to Pred(AParams.Count) do
      begin
        VParam := AParams[I];
        Result.CreateParam(PressParamToDBParam(VParam.ParamType),
         VParam.Name, ptInput).Value := VParam.Value;
      end;
    except
      FreeAndNil(Result);
      raise;
    end;
  end else
    Result := nil;
end;

function TPressInstantObjectsPersistence.CreateInstantObject(
  AObject: TPressObject): TInstantObject;
var
  VInstantObjectClass: TInstantObjectClass;
begin
  VInstantObjectClass := InstantFindClass(AObject.ClassName);
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
  Result := CreateObject(AClass, nil);
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

procedure TPressInstantObjectsPersistence.Finit;
begin
  FConnectionManager.Free;
  FConnector.Free;
  inherited;
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
    VObjectClass := PressModel.ClassByName(AObject.ClassName)
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

function TPressInstantObjectsPersistence.InternalDBMSName: string;
begin
  (Connector.Broker as TInstantCustomRelationalBroker).DBMSName;
end;

procedure TPressInstantObjectsPersistence.InternalDispose(
  AClass: TPressObjectClass; const AId: string);
var
  VMetadata: TPressObjectMetadata;
  VInstantObject: TInstantObject;
begin
  VMetadata := AClass.ClassMetadata;
  VInstantObject := InstantFindClass(
    VMetadata.ObjectClassName).Retrieve(AId, False);
  if Assigned(VInstantObject) then
    try
      VInstantObject.Dispose;
    finally
      VInstantObject.Free;
    end;
end;

function TPressInstantObjectsPersistence.InternalExecuteStatement(
  const AStatement: string; AParams: TPressParamList): Integer;
var
  VParams: TParams;
begin
  VParams := CreateDBParams(AParams);
  try
    Result := (Connector.Broker as TInstantCustomRelationalBroker).Execute(
     AStatement, VParams);
  finally
    VParams.Free;
  end;
end;

function TPressInstantObjectsPersistence.InternalOQLQuery(
  const AOQLStatement: string; AParams: TPressParamList): TPressProxyList;
var
  VInstantQuery: TInstantQuery;
  VParams: TParams;
  I: Integer;
begin
  VInstantQuery := DefaultConnector.CreateQuery;
  try
    Result := TPressProxyList.Create(True, ptShared);
    try
      VInstantQuery.Command := AOQLStatement;
      VParams := CreateDBParams(AParams);
      if Assigned(VParams) then
      begin
        try
          VInstantQuery.Params := VParams;
        finally
          FreeAndNil(VParams);
        end;
      end;
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

procedure TPressInstantObjectsPersistence.InternalRefresh(
  AObject: TPressObject);
var
  VPersistentObject: TObject;
  VInstantObject: TInstantObject;
begin
  VPersistentObject := PersistentObject[AObject];
  if VPersistentObject is TInstantObject then
    VInstantObject := TInstantObject(VPersistentObject)
  else
    raise EPressError.CreateFmt(SInstanceNotFound,
     [AObject.ClassName, AObject.PersistentId]);
  VInstantObject.Refresh;
  ReadInstantObject(VInstantObject, AObject);
end;

function TPressInstantObjectsPersistence.InternalRetrieve(
  AClass: TPressObjectClass; const AId: string;
  AMetadata: TPressObjectMetadata): TPressObject;
var
  VMetadata: TPressObjectMetadata;
  VInstantObject: TInstantObject;
begin
  VMetadata := AClass.ClassMetadata;
  VInstantObject := InstantFindClass(
   VMetadata.ObjectClassName).Retrieve(AId, False);
  if Assigned(VInstantObject) then
  begin
    Result := CreateObject(AClass, AMetadata);
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
  const ASQLStatement: string; AParams: TPressParamList): TPressProxyList;
var
  VDataSet: TDataSet;
begin
  VDataSet := AcquireInstantDataSet(ASQLStatement, AParams);
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
    ReleaseInstantDataSet(VDataSet);
  end;
end;

function TPressInstantObjectsPersistence.InternalSQLQuery(
  AClass: TPressObjectClass; const ASQLStatement: string;
  AParams: TPressParamList): TPressProxyList;
var
  VDataSet: TDataSet;
  VInstance: TPressObject;
begin
  VDataSet := AcquireInstantDataSet(ASQLStatement, AParams);
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
    ReleaseInstantDataSet(VDataSet);
  end;
end;

procedure TPressInstantObjectsPersistence.InternalStartTransaction;
begin
  Connector.Connect;
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

function TPressInstantObjectsPersistence.PressParamToDBParam(
  AParamType: TPressAttributeBaseType): TFieldType;
const
  CFieldType: array[TPressAttributeBaseType] of TFieldType = (
   ftUnknown,    // attUnknown
   ftString,     // attString
   ftInteger,    // attInteger
   ftFloat,      // attFloat
   ftCurrency,   // attCurrency
   ftSmallint,   // attEnum
   ftBoolean,    // attBoolean
   ftDateTime,   // attDate
   ftDateTime,   // attTime
   ftDateTime,   // attDateTime
   ftUnknown,    // attVariant
   ftMemo,       // attMemo
   ftBlob,       // attBinary
   ftBlob,       // attPicture
   ftUnknown,    // attPart
   ftUnknown,    // attReference
   ftUnknown,    // attParts
   ftUnknown);   // attReferences
begin
  Result := CFieldType[AParamType];
  if Result = ftUnknown then
    raise EPressError.CreateFmt(SUnsupportedAttributeType, [
     GetEnumName(TypeInfo(TPressAttributeBaseType), Ord(AParamType))]);
end;

procedure TPressInstantObjectsPersistence.ReadInstantObject(
  AInstantObject: TInstantObject; APressObject: TPressObject);

  procedure ReadInstantPart(AInstantPart: TInstantPart; APressPart: TPressPart);
  begin
    if APressPart.Proxy.IsEmpty then
      APressPart.Value := CreateObject(APressPart.ObjectClass, nil);
    ReadInstantObject(AInstantPart.Value, APressPart.Value);
  end;

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
       ClassByName(AInstantReference.Value.ClassName).Create(Self);
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
         ClassByName(AInstantParts[I].ClassName).Create(Self);
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
         ClassByName(VReference.Instance.ClassName).Create(Self);
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
      VInstantAttr := AInstantObject.AttributeByName(VPressAttr.Name);
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
          ReadInstantPart(TInstantPart(VInstantAttr), TPressPart(VPressAttr));
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
    if APressReference.Proxy.HasInstance and
     not APressReference.Value.IsPersistent then
      APressReference.Value.Store;
    if (APressReference.Proxy.ObjectClassName <> '') and
     (APressReference.Proxy.ObjectId <> '') then
      AInstantReference.ReferenceObject(
       APressReference.Proxy.ObjectClassName, APressReference.Proxy.ObjectId)
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
      VObject := InstantFindClass(APressParts[I].ClassName).Create;
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
    VInstantAttr := AInstantObject.AttributeByName(VPressAttr.Name);
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

procedure TPressInstantObjectsPersistence.ReleaseInstantDataSet(
  ADataSet: TDataSet);
begin
  (DefaultConnector.Broker as TInstantSQLBroker).ReleaseDataSet(ADataSet);
end;

initialization
  TPressInstantObjectsPersistence.RegisterService;

finalization
  TPressInstantObjectsPersistence.UnregisterService;

end.
