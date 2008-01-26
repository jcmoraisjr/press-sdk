(*
  PressObjects, User Model Classes
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressUserModel;

{$I Press.inc}

interface

uses
  PressSubject, PressAttributes, PressUser;

type
  TPressUserGroupReferences = class;

  TPressUser = class(TPressCustomUser)
  private
    FUserName: TPressString;
    FUserId: TPressString;
    FPasswordHash: TPressString;
    FPasswordExpired: TPressBoolean;
    FUserGroups: TPressUserGroupReferences;
    function GetPasswordExpired: Boolean;
    function GetPasswordHash: string;
    function GetUserId: string;
    function GetUserName: string;
    procedure SetPasswordExpired(Value: Boolean);
    procedure SetPasswordHash(const Value: string);
    procedure SetUserId(const Value: string);
    procedure SetUserName(const Value: string);
  protected
    procedure AfterCreate; override;
    function InternalAccessMode(AResourceId: Integer): TPressAccessMode; override;
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property UserGroups: TPressUserGroupReferences read FUserGroups;
  published
    property UserName: string read GetUserName write SetUserName;
    property UserId: string read GetUserId write SetUserId;
    property PasswordHash: string read GetPasswordHash write SetPasswordHash;
    property PasswordExpired: Boolean read GetPasswordExpired write SetPasswordExpired;
  end;

  TPressUserQuery = class(TPressQuery)
  private
    FUserName: TPressString;
    function GetUserName: string;
    procedure SetUserName(const Value: string);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  published
    property UserName: string read GetUserName write SetUserName;
  end;

  TPressUserGroupResourceParts = class;

  TPressUserGroup = class(TPressObject)
  private
    FGroupName: TPressString;
    FGroupResources: TPressUserGroupResourceParts;
    function GetGroupName: string;
    procedure SetGroupName(const Value: string);
  private
    function GetAccessMode(AResourceId: Integer): TPressAccessMode;
    procedure PopulateResources;
    procedure SetAccessMode(AResourceId: Integer; AValue: TPressAccessMode);
  protected
    procedure AfterCreate; override;
    procedure AfterRetrieve; override;
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property AccessMode[AResourceId: Integer]: TPressAccessMode read GetAccessMode write SetAccessMode;
    property GroupResources: TPressUserGroupResourceParts read FGroupResources;
  published
    property GroupName: string read GetGroupName write SetGroupName;
  end;

  TPressUserGroupQuery = class(TPressQuery)
  private
    FGroupName: TPressString;
    function GetGroupName: string;
    procedure SetGroupName(const Value: string);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  published
    property GroupName: string read GetGroupName write SetGroupName;
  end;

  TPressUserGroupReferences = class(TPressReferences)
  private
    function GetObjects(AIndex: Integer): TPressUserGroup;
    procedure SetObjects(AIndex: Integer; const Value: TPressUserGroup);
  public
    function Add(AObject: TPressUserGroup): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressUserGroup);
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressUserGroup read GetObjects write SetObjects; default;
  end;

  TPressUserGroupResource = class(TPressObject)
  private
    FResourceId: TPressEnum;
    FAccessMode: TPressEnum;
    function GetAccessMode: TPressAccessMode;
    function GetResourceId: Integer;
    procedure SetAccessMode(Value: TPressAccessMode);
    procedure SetResourceId(Value: Integer);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
    property ResourceIdAttr: TPressEnum read FResourceId;
  published
    property ResourceId: Integer read GetResourceId write SetResourceId;
    property AccessMode: TPressAccessMode read GetAccessMode write SetAccessMode;
  end;

  TPressUserGroupResourceParts = class(TPressParts)
  private
    function GetObjects(AIndex: Integer): TPressUserGroupResource;
    procedure SetObjects(AIndex: Integer; const Value: TPressUserGroupResource);
  public
    function Add(AObject: TPressUserGroupResource): Integer;
    function IndexOfResourceId(AResourceId: Integer): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressUserGroupResource);
    function ResourceById(AResourceId: Integer): TPressUserGroupResource;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressUserGroupResource read GetObjects write SetObjects; default;
  end;

  TPressLogon = class(TPressObject)
  private
    FUserId: TPressString;
    FPassword: TPressString;
    function GetPassword: string;
    function GetUserId: string;
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
    procedure InternalStore(AStoreMethod: TPressObjectOperation); override;
    property UserId: string read GetUserId;
    property Password: string read GetPassword;
  end;

  TPressChangePassword = class(TPressObject)
  private
    FPassword1: TPressString;
    FPassword2: TPressString;
  private
    FStoreUser: Boolean;
    FUpdatePasswordExpired: Boolean;
    FUser: TPressUser;
  protected
    procedure Init; override;
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
    procedure InternalStore(AStoreMethod: TPressObjectOperation); override;
  public
    property StoreUser: Boolean read FStoreUser write FStoreUser;
    property UpdatePasswordExpired: Boolean read FUpdatePasswordExpired write FUpdatePasswordExpired;
    property User: TPressUser read FUser write FUser;
  end;

  TPressUserData = class(TPressCustomUserData)
  private
    function IsFirstLogon: Boolean;
  protected
    function InternalQueryUser(const AUserId, APassword: string): TPressCustomUser; override;
    function InternalUserClass: TPressUserClass; virtual;
  end;

implementation

uses
  SysUtils, PressConsts;

{ TPressUser }

procedure TPressUser.AfterCreate;
begin
  inherited;
  FPasswordHash.Value := PressUserData.Hash('');
end;

function TPressUser.GetPasswordExpired: Boolean;
begin
  Result := FPasswordExpired.Value;
end;

function TPressUser.GetPasswordHash: string;
begin
  Result := FPasswordHash.Value;
end;

function TPressUser.GetUserId: string;
begin
  Result := FUserId.Value;
end;

function TPressUser.GetUserName: string;
begin
  Result := FUserName.Value;
end;

function TPressUser.InternalAccessMode(
  AResourceId: Integer): TPressAccessMode;
var
  VAccessMode: TPressAccessMode;
  I: Integer;
begin
  if not (UserId = SPressUserAdminId) then
  begin
    Result := Low(TPressAccessMode);
    for I := 0 to Pred(UserGroups.Count) do
    begin
      VAccessMode := UserGroups[I].AccessMode[AResourceId];
      if VAccessMode > Result then
      begin
        Result := VAccessMode;
        if Result = High(TPressAccessMode) then
          Exit;
      end;
    end;
  end else
    Result := High(TPressAccessMode);
end;

function TPressUser.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'UserName') then
    Result := Addr(FUserName)
  else if SameText(AAttributeName, 'UserId') then
    Result := Addr(FUserId)
  else if SameText(AAttributeName, 'PasswordHash') then
    Result := Addr(FPasswordHash)
  else if SameText(AAttributeName, 'PasswordExpired') then
    Result := Addr(FPasswordExpired)
  else if SameText(AAttributeName, 'UserGroups') then
    Result := Addr(FUserGroups)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressUser.InternalMetadataStr: string;
begin
  Result := 'TPressUser PersistentName="TUser" (' +
   'UserName: String(60);' +
   'UserId: String(32);' +
   'PasswordHash: String(32);' +
   'PasswordExpired: Boolean DefaultValue=True;' +
   'UserGroups: TPressUserGroupReferences PersistentName="UserGrp";' +
   ')';
end;

procedure TPressUser.SetPasswordExpired(Value: Boolean);
begin
  FPasswordExpired.Value := Value;
end;

procedure TPressUser.SetPasswordHash(const Value: string);
begin
  FPasswordHash.Value := Value;
end;

procedure TPressUser.SetUserId(const Value: string);
begin
  FUserId.Value := Value;
end;

procedure TPressUser.SetUserName(const Value: string);
begin
  FUserName.Value := Value;
end;

{ TPressUserQuery }

function TPressUserQuery.GetUserName: string;
begin
  Result := FUserName.Value;
end;

function TPressUserQuery.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'UserName') then
    Result := Addr(FUserName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressUserQuery.InternalMetadataStr: string;
begin
  Result := 'TPressUserQuery(TPressUser) (' +
   'UserName: String(60) MatchType=mtContains;' +
   ')';
end;

procedure TPressUserQuery.SetUserName(const Value: string);
begin
  FUserName.Value := Value;
end;

{ TPressUserGroup }

procedure TPressUserGroup.AfterCreate;
begin
  inherited;
  PopulateResources;
end;

procedure TPressUserGroup.AfterRetrieve;
begin
  inherited;
  PopulateResources;
end;

function TPressUserGroup.GetAccessMode(
  AResourceId: Integer): TPressAccessMode;
begin
  Result := GroupResources.ResourceById(AResourceId).AccessMode;
end;

function TPressUserGroup.GetGroupName: string;
begin
  Result := FGroupName.Value;
end;

function TPressUserGroup.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'GroupName') then
    Result := Addr(FGroupName)
  else if SameText(AAttributeName, 'GroupResources') then
    Result := Addr(FGroupResources)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressUserGroup.InternalMetadataStr: string;
begin
  Result := 'TPressUserGroup PersistentName="TUserGrp" (' +
   'GroupName: String(20);' +
   'GroupResources: TPressUserGroupResourceParts PersistentName="GrpRes";' +
   ')';
end;

procedure TPressUserGroup.PopulateResources;
var
  I: Integer;
begin
  for I := 0 to Pred(PressModel.EnumMetadataByName('TPressAppResource').Items.Count) do
    GroupResources.ResourceById(I);
end;

procedure TPressUserGroup.SetAccessMode(
  AResourceId: Integer; AValue: TPressAccessMode);
begin
  GroupResources.ResourceById(AResourceId).AccessMode := AValue;
end;

procedure TPressUserGroup.SetGroupName(const Value: string);
begin
  FGroupName.Value := Value;
end;

{ TPressUserGroupQuery }

function TPressUserGroupQuery.GetGroupName: string;
begin
  Result := FGroupName.Value;
end;

function TPressUserGroupQuery.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'GroupName') then
    Result := Addr(FGroupName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressUserGroupQuery.InternalMetadataStr: string;
begin
  Result := 'TPressUserGroupQuery(TPressUserGroup) (' +
   'GroupName: String(20) MatchType=mtContains;' +
   ')';
end;

procedure TPressUserGroupQuery.SetGroupName(const Value: string);
begin
  FGroupName.Value := Value;
end;

{ TPressUserGroupReferences }

function TPressUserGroupReferences.Add(AObject: TPressUserGroup): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressUserGroupReferences.GetObjects(AIndex: Integer): TPressUserGroup;
begin
  Result := inherited Objects[AIndex] as TPressUserGroup;
end;

procedure TPressUserGroupReferences.Insert(
  AIndex: Integer; AObject: TPressUserGroup);
begin
  inherited Insert(AIndex, AObject);
end;

procedure TPressUserGroupReferences.SetObjects(
  AIndex: Integer; const Value: TPressUserGroup);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPressUserGroupReferences.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressUserGroup;
end;

{ TPressUserGroupResource }

function TPressUserGroupResource.GetAccessMode: TPressAccessMode;
begin
  Result := TPressAccessMode(FAccessMode.Value);
end;

function TPressUserGroupResource.GetResourceId: Integer;
begin
  Result := FResourceId.Value;
end;

function TPressUserGroupResource.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'ResourceId') then
    Result := Addr(FResourceId)
  else if SameText(AAttributeName, 'AccessMode') then
    Result := Addr(FAccessMode)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressUserGroupResource.InternalMetadataStr: string;
begin
  Result := 'TPressUserGroupResource PersistentName="TUserGrpRes" OwnerClass=TPressUserGroup (' +
   'ResourceId: Enum(TPressAppResource);' +
   'AccessMode: Enum(TPressAccessMode) DefaultValue=amInvisible;' +
   ')';
end;

procedure TPressUserGroupResource.SetAccessMode(Value: TPressAccessMode);
begin
  FAccessMode.Value := Ord(Value);
end;

procedure TPressUserGroupResource.SetResourceId(Value: Integer);
begin
  FResourceId.Value := Value;
end;

{ TPressUserGroupResourceParts }

function TPressUserGroupResourceParts.Add(
  AObject: TPressUserGroupResource): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressUserGroupResourceParts.GetObjects(
  AIndex: Integer): TPressUserGroupResource;
begin
  Result := inherited Objects[AIndex] as TPressUserGroupResource;
end;

function TPressUserGroupResourceParts.IndexOfResourceId(
  AResourceId: Integer): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Objects[Result].ResourceIdAttr.SameValue(AResourceId) then
      Exit;
  Result := -1;
end;

procedure TPressUserGroupResourceParts.Insert(
  AIndex: Integer; AObject: TPressUserGroupResource);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressUserGroupResourceParts.ResourceById(
  AResourceId: Integer): TPressUserGroupResource;
var
  VIndex: Integer;
begin
  VIndex := IndexOfResourceId(AResourceId);
  if VIndex = -1 then
  begin
    Result := TPressUserGroupResource.Create;
    Result.ResourceId := AResourceId;
    Add(Result);
  end else
    Result := Objects[VIndex];
end;

procedure TPressUserGroupResourceParts.SetObjects(
  AIndex: Integer; const Value: TPressUserGroupResource);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPressUserGroupResourceParts.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressUserGroupResource;
end;

{ TPressLogon }

function TPressLogon.GetPassword: string;
begin
  Result := FPassword.Value;
end;

function TPressLogon.GetUserId: string;
begin
  Result := FUserId.Value;
end;

function TPressLogon.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'UserId') then
    Result := Addr(FUserId)
  else if SameText(AAttributeName, 'Password') then
    Result := Addr(FPassword)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressLogon.InternalMetadataStr: string;
begin
  Result := 'TPressLogon (' +
   'UserId: String(32);' +
   'Password: String(32);' +
   ')';
end;

procedure TPressLogon.InternalStore(AStoreMethod: TPressObjectOperation);
begin
  if not PressUserData.Logon(FUserId.Value, FPassword.Value) then
    raise EPressUserError.Create(SInvalidLogon);
end;

{ TPressChangePassword }

procedure TPressChangePassword.Init;
begin
  inherited;
  FStoreUser := True;
  FUpdatePasswordExpired := True;
end;

function TPressChangePassword.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Password1') then
    Result := Addr(FPassword1)
  else if SameText(AAttributeName, 'Password2') then
    Result := Addr(FPassword2)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressChangePassword.InternalMetadataStr: string;
begin
  Result := 'TPressChangePassword (' +
   'Password1: String(32);' +
   'Password2: String(32);' +
   ')';
end;

procedure TPressChangePassword.InternalStore(
  AStoreMethod: TPressObjectOperation);
begin
  if Assigned(FUser) then
  begin
    if FPassword1.Value = FPassword2.Value then
    begin
      FUser.PasswordHash := PressUserData.Hash(FPassword1.Value);
      if UpdatePasswordExpired then
        FUser.PasswordExpired := False;
      if StoreUser then
        FUser.Store;
    end else
      raise EPressUserError.Create(SPasswordsDontMatch);
  end;
end;

{ TPressUserData }

function TPressUserData.InternalQueryUser(
  const AUserId, APassword: string): TPressCustomUser;
var
  VList: TPressProxyList;
  VUserClass: TPressUserClass;
begin
  Result := nil;
  if AUserId = '' then
    Exit;
  VUserClass := InternalUserClass;
  VList := DataAccess.OQLQuery(Format(
   'select * from %s where %s = "%s" and %s = "%s"',
   [VUserClass.ClassName, 'UserId', AUserId,
   'PasswordHash', Hash(APassword)]));
  try
    if VList.Count = 1 then
    begin
      Result := VList[0].Instance as TPressCustomUser;
      Result.AddRef;
    end;
  finally
    VList.Free;
  end;
  if not Assigned(Result) and (AUserId = SPressUserAdminId) and
   (APassword = SPressUserAdminId) and IsFirstLogon then
  begin
    Result := VUserClass.Create;
    if Result is TPressUser then
    begin
      TPressUser(Result).UserId := AUserId;
      TPressUser(Result).UserName := AUserId;
    end;
  end;
end;

function TPressUserData.InternalUserClass: TPressUserClass;
begin
  Result := TPressUser;
end;

function TPressUserData.IsFirstLogon: Boolean;
begin
  { TODO : Improve, using count }
  with DataAccess.OQLQuery('select * from ' + InternalUserClass.ClassName) do
  try
    Result := Count = 0;
  finally
    Free;
  end;
end;

initialization
  TPressUser.RegisterClass;
  TPressUserQuery.RegisterClass;
  TPressUserGroup.RegisterClass;
  TPressUserGroupQuery.RegisterClass;
  TPressUserGroupResource.RegisterClass;
  TPressLogon.RegisterClass;
  TPressChangePassword.RegisterClass;
  TPressUserGroupReferences.RegisterAttribute;
  TPressUserGroupResourceParts.RegisterAttribute;
  TPressUserData.RegisterService;

finalization
  TPressUser.UnregisterClass;
  TPressUserQuery.UnregisterClass;
  TPressUserGroup.UnregisterClass;
  TPressUserGroupQuery.UnregisterClass;
  TPressUserGroupResource.UnregisterClass;
  TPressLogon.UnregisterClass;
  TPressChangePassword.UnregisterClass;
  TPressUserGroupReferences.UnregisterAttribute;
  TPressUserGroupResourceParts.UnregisterAttribute;
  TPressUserData.UnregisterService;

end.
