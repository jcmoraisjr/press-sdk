(*
  PressObjects, InstantObjects Persistence Broker
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

unit PressInstantObjectsBroker;

interface

{$I Press.inc}

uses
  PressSubject,
  PressQuery,
  PressPersistence,
  InstantConnectionManager,
  InstantConnectionManagerFormUnit,
  InstantPersistence;

type
  TPressInstantObjectsPersistence = class(TPressPersistenceBroker)
  private
    FConnectionManager: TInstantConnectionManager;
    FConnector: TInstantConnector;
    FOIDGenerator: TPressOIDGenerator;
    procedure ConnectionManagerConnect(Sender: TObject; var ConnectionDef: TInstantConnectionDef; var Result: Boolean);
    function CreateInstantObject(AObject: TPressObject): TInstantObject;
    procedure GenerateOID(Sender: TObject; const AObject: TInstantObject; var Id: string);
    procedure InstantLog(const AString: string);
    function GetOIDGenerator: TPressOIDGenerator;
    { TODO : Use streaming to copy an InstantObject to a PressObject and vice-versa }
    procedure ReadInstantObject(AInstantObject: TInstantObject; APressObject: TPressObject);
    procedure ReadPressObject(APressObject: TPressObject; AInstantObject: TInstantObject);
  protected
    function GetIdentifierQuotes: string; override;
    function GetStrQuote: Char; override;
    procedure InitPersistenceBroker; override;
    procedure InternalConnect; override;
    procedure InternalDispose(AObject: TPressObject); override;
    function InternalRetrieve(const AClass, AId: string): TPressObject; override;
    function InternalRetrieveProxyList(AQuery: TPressQuery): TPressProxyList; override;
    procedure InternalStore(AObject: TPressObject); override;
    property OIDGenerator: TPressOIDGenerator read GetOIDGenerator;
  public
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils,
  PressClasses,
  PressConsts,
  {$IFDEF PressLog}PressLog,{$ENDIF}
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
  FConnector.OnGenerateId := GenerateOID;
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

destructor TPressInstantObjectsPersistence.Destroy;
begin
  FOIDGenerator.Free;
  FConnectionManager.Free;
  FConnector.Free;
  inherited;
end;

procedure TPressInstantObjectsPersistence.GenerateOID(
  Sender: TObject; const AObject: TInstantObject; var Id: string);
var
  VObjectClass: TPressObjectClass;
begin
  if Assigned(AObject) then
    VObjectClass := PressObjectClassByPersistentName(AObject.ClassName)
  else
    VObjectClass := nil;
  Id := OIDGenerator.GenerateOID(VObjectClass);
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

function TPressInstantObjectsPersistence.GetOIDGenerator: TPressOIDGenerator;
begin
  if not Assigned(FOIDGenerator) then
    FOIDGenerator := InternalOIDGeneratorClass.Create;
  Result := FOIDGenerator;
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

procedure TPressInstantObjectsPersistence.InitPersistenceBroker;
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

procedure TPressInstantObjectsPersistence.InstantLog(const AString: string);
begin
  {$IFDEF PressLogOPFPersistence}PressLogMsg(Self, 'Instant: ' + AString);{$ENDIF}
end;

procedure TPressInstantObjectsPersistence.InternalConnect;
begin
  if Assigned(FConnectionManager) then
    FConnectionManager.Execute;
end;

procedure TPressInstantObjectsPersistence.InternalDispose(AObject: TPressObject);
var
  VInstantObject: TInstantObject;
begin
  if AObject.IsPersistent then
  begin
    VInstantObject := CreateInstantObject(AObject);
    try
      VInstantObject.Dispose;
    finally
      VInstantObject.Free;
    end;
  end;
end;

function TPressInstantObjectsPersistence.InternalRetrieve(const AClass, AId: string): TPressObject;
var
  VPressObjectClass: TPressObjectClass;
  VInstantObject: TInstantObject;
begin
  VPressObjectClass := PressObjectClassByName(AClass);
  VInstantObject := InstantFindClass(
   VPressObjectClass.ClassMetadata.PersistentName).Retrieve(AId, False);
  if Assigned(VInstantObject) then
  begin
    try
      Result := VPressObjectClass.Create;
      try
        ReadInstantObject(VInstantObject, Result);
      except
        Result.Free;
        raise;
      end;
    finally
      VInstantObject.Free;
    end;
  end else
    Result := nil;
end;

function TPressInstantObjectsPersistence.InternalRetrieveProxyList(
  AQuery: TPressQuery): TPressProxyList;
var
  VInstantQuery: TInstantQuery;
  VQueryStr: string;
  WhereClause: string;
  OrderByClause: string;
  I: Integer;
begin
  VInstantQuery := DefaultConnector.CreateQuery;
  try
    Result := TPressProxyList.Create(True, ptShared);
    try
      VQueryStr := 'SELECT * FROM ';
      if AQuery.Metadata.IncludeSubClasses then
        VQueryStr := VQueryStr + 'ANY ';
      VQueryStr := VQueryStr + AQuery.Metadata.ItemObjectClassName;
      WhereClause := AQuery.WhereClause;
      OrderByClause := AQuery.OrderByClause;
      if WhereClause <> '' then
        VQueryStr := VQueryStr + ' WHERE ' + WhereClause;
      if OrderByClause <> '' then
        VQueryStr := VQueryStr + ' ORDER BY ' + OrderByClause;
      {$IFDEF PressLogOPF}PressLogMsg(Self, 'Querying "' +  VQueryStr + '"');{$ENDIF}
      VInstantQuery.Command := VQueryStr;
      VInstantQuery.Open;
      if VInstantQuery is TInstantSQLQuery then
        for I := 0 to Pred(VInstantQuery.ObjectCount) do
          with TPressInstantSQLQueryFriend(VInstantQuery).ObjectReferenceList.RefItems[I] do
            Result.AddReference(ObjectClassName, ObjectId)
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

procedure TPressInstantObjectsPersistence.InternalStore(AObject: TPressObject);
var
  VInstantObject: TInstantObject;
begin
  VInstantObject := CreateInstantObject(AObject);
  try
    VInstantObject.Store;
    PressAssignPersistentId(AObject, VInstantObject.PersistentId);
  finally
    VInstantObject.Free;
  end;
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
      VObject :=
       PressObjectClassByPersistentName(AInstantReference.Value.ClassName).Create;
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
      VReference :=
       TPressInstantPartsFriend(AInstantParts).ObjectReferences[I];
      if (VReference.ObjectClassName <> '') and (VReference.ObjectId <> '') then
      begin
        APressParts.AddReference(
         VReference.ObjectClassName, VReference.ObjectId);
      end else
      begin
        VObject :=
         PressObjectClassByPersistentName(AInstantParts[I].ClassName).Create;
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
         VReference.ObjectClassName, VReference.ObjectId);
      end else if VReference.HasInstance then
      begin
        VObject :=
         PressObjectClassByPersistentName(VReference.Instance.ClassName).Create;
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
      if VPressAttr.Name = SPressIdString then
        Continue;
      VInstantAttr := AInstantObject.AttributeByName(VPressAttr.PersistentName);
      case VPressAttr.AttributeBaseType of
        attString, attMemo, attPicture:
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
  var
    VObject: TInstantObject;
  begin
    if (APressReference.ObjectClassName <> '') and (APressReference.ObjectId <> '') then
    begin
      AInstantReference.ReferenceObject(
       APressReference.ObjectClassName, APressReference.ObjectId);
    end else if APressReference.HasInstance then
    begin
      VObject := InstantFindClass(APressReference.Value.PersistentName).Create;
      try
        AInstantReference.Value := VObject;
      except
        VObject.Free;
        raise;
      end;
      VObject.Release;
      ReadPressObject(APressReference.Value, VObject);
    end else
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
    VObject: TInstantObject;
    VProxy: TPressProxy;
    I: Integer;
  begin
    AInstantReferences.Clear;
    for I := 0 to Pred(APressReferences.Count) do
    begin
      VProxy := APressReferences.Proxies[I];
      if (VProxy.ObjectClassName <> '') and
       (VProxy.ObjectId <> '') then
      begin

        { TODO : use try / except to avoid orphaned references }
        TPressInstantReferencesFriend(AInstantReferences).ObjectReferenceList.
         Add.ReferenceObject(VProxy.ObjectClassName, VProxy.ObjectId);

      end else if VProxy.HasInstance then
      begin
        { TODO : Test to avoid AV }
        VObject := InstantFindClass(VProxy.Instance.PersistentName).Create;
        try
          AInstantReferences.Add(VObject);
        except
          VObject.Free;
          raise;
        end;
        VObject.Release;
        ReadPressObject(VProxy.Instance, VObject);
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
     (not APressObject.IsOwned and not VPressAttr.IsChanged) then
      Continue;
    VInstantAttr := AInstantObject.AttributeByName(VPressAttr.PersistentName);
    case VPressAttr.AttributeBaseType of
      attString, attMemo, attPicture:
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
  TPressInstantObjectsPersistence.RegisterPersistence;

end.
