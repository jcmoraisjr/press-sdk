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
    FOIDGenerators: TPressOIDGenerators;
    procedure ConnectionManagerConnect(Sender: TObject; var ConnectionDef: TInstantConnectionDef; var Result: Boolean);
    function CreateInstantObject(AObject: TPressObject): TInstantObject;
    procedure GenerateOID(Sender: TObject; const AObject: TInstantObject; var Id: string);
    function GetOIDGenerators: TPressOIDGenerators;
    procedure InstantLog(const AString: string);
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
    property OIDGenerators: TPressOIDGenerators read GetOIDGenerators;
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
  FOIDGenerators.Free;
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
  Id := OIDGenerators.GenerateOID(VObjectClass);
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

function TPressInstantObjectsPersistence.GetOIDGenerators: TPressOIDGenerators;
begin
  if not Assigned(FOIDGenerators) then
    FOIDGenerators := InternalOIDGeneratorsClass.Create;
  Result := FOIDGenerators;
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
    Result := VPressObjectClass.Create;
    try
      Result.PersistentObject := VInstantObject;
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
  if AObject.PersistentObject is TInstantObject then
  begin
    VInstantObject := TInstantObject(AObject.PersistentObject);
    ReadPressObject(AObject, VInstantObject);
  end else
  begin
    VInstantObject := CreateInstantObject(AObject);
    AObject.PersistentObject := VInstantObject;
  end;
  VInstantObject.Store;
  PressAssignPersistentId(AObject, VInstantObject.PersistentId);
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

      //     READ-ME!!
      //
      // If you got a compilation error, move the InstantObjects'
      // TInstantParts.ObjectReference property declaration (line 1067)
      // to the protected area.
      //
      //     READ-ME!!

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
      APressReference.Value.Save;
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
        VProxy.Instance.Save;
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
  TPressInstantObjectsPersistence.RegisterPersistence;

end.
