(*
  PressObjects, MVP-Factory Classes
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

unit PressMVPFactory;

interface

{$I Press.inc}

uses
  Controls,
  Contnrs,
  Forms,
  PressApplication,
  PressClasses,
  PressSubject,
  PressMVP,
  PressMVPView,
  PressMVPPresenter;

type
  TPressMVPRegisteredForm = class(TObject)
  private
    FFormClass: TFormClass;
    FFormPresenterType: TPressMVPFormPresenterType;
    FObjectClass: TPressObjectClass;
    FPresenterClass: TPressMVPFormPresenterClass;
  public
    constructor Create(APresenterClass: TPressMVPFormPresenterClass; AObjectClass: TPressObjectClass; AFormClass: TFormClass; AFormPresenterType: TPressMVPFormPresenterType);
    property FormClass: TFormClass read FFormClass;
    property FormPresenterType: TPressMVPFormPresenterType read FFormPresenterType;
    property ObjectClass: TPressObjectClass read FObjectClass;
    property PresenterClass: TPressMVPFormPresenterClass read FPresenterClass;
  end;

  TPressMVPRegisteredFormIterator = class;

  TPressMVPRegisteredFormList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressMVPRegisteredForm;
    procedure SetItems(AIndex: Integer; const Value: TPressMVPRegisteredForm);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressMVPRegisteredForm): Integer;
    function CreateIterator: TPressMVPRegisteredFormIterator;
    function IndexOf(AObject: TPressMVPRegisteredForm): Integer;
    function IndexOfObjectClass(AObjectClass: TPressObjectClass; AFormPresenterType: TPressMVPFormPresenterType): Integer;
    function IndexOfPresenterClass(APresenterClass: TPressMVPFormPresenterClass): Integer;
    function IndexOfQueryItemObject(AObjectClass: TPressObjectClass; AFormPresenterType: TPressMVPFormPresenterType): Integer;
    procedure Insert(Index: Integer; AObject: TPressMVPRegisteredForm);
    function Remove(AObject: TPressMVPRegisteredForm): Integer;
    property Items[AIndex: Integer]: TPressMVPRegisteredForm read GetItems write SetItems; default;
  end;

  TPressMVPRegisteredFormIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPRegisteredForm;
  public
    property CurrentItem: TPressMVPRegisteredForm read GetCurrentItem;
  end;

  TPressMVPFactory = class(TPressService)
  { TODO : Refactor }
  private
    FInteractors: TClassList;
    FModels: TClassList;
    FPresenters: TClassList;
    FViews: TClassList;
    FForms: TPressMVPRegisteredFormList;
    function ChooseConcreteClass(ATargetClass, ACandidateClass1, ACandidateClass2: TClass): Integer;
    function ExistSubClasses(AClasses: TClassList; AClass: TClass): Boolean;
    procedure RemoveSuperClasses(AClasses: TClassList; AClass: TClass);
  protected
    class function InternalServiceType: TPressServiceType; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function MVPInteractorFactory(APresenter: TPressMVPPresenter): TPressMVPInteractorClasses;
    function MVPModelFactory(AParent: TPressMVPModel; ASubject: TPressSubject): TPressMVPModel;
    function MVPPresenterFactory(AParent: TPressMVPFormPresenter; AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter;
    function MVPViewFactory(AControl: TControl; AOwnsControl: Boolean = False): TPressMVPView;
    procedure RegisterInteractor(AInteractorClass: TPressMVPInteractorClass);
    procedure RegisterForm(APresenterClass: TPressMVPFormPresenterClass; AObjectClass: TPressObjectClass; AFormClass: TFormClass; AFormPresenterType: TPressMVPFormPresenterType);
    procedure RegisterModel(AModelClass: TPressMVPModelClass);
    procedure RegisterPresenter(APresenterClass: TPressMVPPresenterClass);
    procedure RegisterView(AViewClass: TPressMVPViewClass);
    property Forms: TPressMVPRegisteredFormList read FForms;
  end;

function PressDefaultMVPFactory: TPressMVPFactory;

implementation

uses
  PressConsts,
  PressQuery;

function PressDefaultMVPFactory: TPressMVPFactory;
begin
  with PressApp.Registry[stMVPFactory] do
  begin
    if not HasDefaultService then
      RegisterService(TPressMVPFactory, False);
    Result := DefaultService as TPressMVPFactory;
  end;
end;

{ TPressMVPRegisteredForm }

constructor TPressMVPRegisteredForm.Create(
  APresenterClass: TPressMVPFormPresenterClass;
  AObjectClass: TPressObjectClass; AFormClass: TFormClass;
  AFormPresenterType: TPressMVPFormPresenterType);
begin
  inherited Create;
  FPresenterClass := APresenterClass;
  FObjectClass := AObjectClass;
  FFormClass := AFormClass;
  FFormPresenterType := AFormPresenterType;
end;

{ TPressMVPRegisteredFormList }

function TPressMVPRegisteredFormList.Add(
  AObject: TPressMVPRegisteredForm): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressMVPRegisteredFormList.CreateIterator: TPressMVPRegisteredFormIterator;
begin
  Result := TPressMVPRegisteredFormIterator.Create(Self);
end;

function TPressMVPRegisteredFormList.GetItems(
  AIndex: Integer): TPressMVPRegisteredForm;
begin
  Result := inherited Items[AIndex] as TPressMVPRegisteredForm;
end;

function TPressMVPRegisteredFormList.IndexOf(
  AObject: TPressMVPRegisteredForm): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressMVPRegisteredFormList.IndexOfObjectClass(
  AObjectClass: TPressObjectClass;
  AFormPresenterType: TPressMVPFormPresenterType): Integer;
begin
  for Result := 0 to Pred(Count) do
    with Items[Result] do
      if (ObjectClass = AObjectClass) and
       (FormPresenterType in [AFormPresenterType, fpIncludePresent]) then
        Exit;
  { TODO : Notify ambiguous presenter class }
  Result := -1;
end;

function TPressMVPRegisteredFormList.IndexOfPresenterClass(
  APresenterClass: TPressMVPFormPresenterClass): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Items[Result].PresenterClass = APresenterClass then
      Exit;
  Result := -1;
end;

function TPressMVPRegisteredFormList.IndexOfQueryItemObject(
  AObjectClass: TPressObjectClass;
  AFormPresenterType: TPressMVPFormPresenterType): Integer;

  function Match(ARegForm: TPressMVPRegisteredForm): Boolean;
  begin
    Result := Assigned(ARegForm.ObjectClass) and
     (ARegForm.ObjectClass.InheritsFrom(TPressQuery)) and
     (ARegForm.FormPresenterType in [AFormPresenterType, fpIncludePresent]) and
     (TPressQueryClass(ARegForm.ObjectClass).ClassMetadata.ItemObjectClass =
      AObjectClass);
  end;

begin
  for Result := 0 to Pred(Count) do
    if Match(Items[Result]) then
      Exit;
  Result := -1;
end;

procedure TPressMVPRegisteredFormList.Insert(Index: Integer;
  AObject: TPressMVPRegisteredForm);
begin
  inherited Insert(Index, AObject);
end;

function TPressMVPRegisteredFormList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressMVPRegisteredFormList.Remove(
  AObject: TPressMVPRegisteredForm): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressMVPRegisteredFormList.SetItems(AIndex: Integer;
  const Value: TPressMVPRegisteredForm);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressMVPRegisteredFormIterator }

function TPressMVPRegisteredFormIterator.GetCurrentItem: TPressMVPRegisteredForm;
begin
  Result := inherited CurrentItem as TPressMVPRegisteredForm;
end;

{ TPressMVPFactory }

function TPressMVPFactory.ChooseConcreteClass(
  ATargetClass, ACandidateClass1, ACandidateClass2: TClass): Integer;

  function InheritanceLevel(AClass: TClass): Integer;
  begin
    Result := 0;
    while Assigned(AClass) do
    begin
      Inc(Result);
      AClass := AClass.ClassParent;
    end;
  end;

var
  VLevel1, VLevel2: Integer;
begin
  { TODO : Return a class or a boolean instead an Integer }
  if not Assigned(ATargetClass) then
    raise EPressMVPError.Create(SUnassignedTargetClass)
  else if not Assigned(ACandidateClass1) and not Assigned(ACandidateClass2) then
    raise EPressMVPError.Create(SUnassignedCandidateClasses)
  else if Assigned(ACandidateClass1) and not ATargetClass.InheritsFrom(ACandidateClass1) then
    raise EPressMVPError.CreateFmt(SNonRelatedClasses,
     [ATargetClass.ClassName, ACandidateClass1.ClassName])
  else if Assigned(ACandidateClass2) and not ATargetClass.InheritsFrom(ACandidateClass2) then
    raise EPressMVPError.CreateFmt(SNonRelatedClasses,
     [ATargetClass.ClassName, ACandidateClass2.ClassName])
  else if not Assigned(ACandidateClass1) then
    Result := 2
  else if not Assigned(ACandidateClass2) then
    Result := 1
  else
  begin
    VLevel1 := InheritanceLevel(ACandidateClass1);
    VLevel2 := InheritanceLevel(ACandidateClass2);
    if VLevel1 > VLevel2 then
      Result := 1
    else if VLevel2 > VLevel1 then
      Result := 2
    else
      raise EPressMVPError.CreateFmt(SAmbiguousConcreteClass,
       [ACandidateClass1.ClassName, ACandidateClass2.ClassName,
       ATargetClass.ClassName]);
  end;
end;

constructor TPressMVPFactory.Create;
begin
  inherited Create;
  FForms := TPressMVPRegisteredFormList.Create(True);
  FInteractors := TClassList.Create;
  FModels := TClassList.Create;
  FPresenters := TClassList.Create;
  FViews := TClassList.Create;
end;

destructor TPressMVPFactory.Destroy;
begin
  FInteractors.Free;
  FModels.Free;
  FPresenters.Free;
  FViews.Free;
  FForms.Free;
  inherited;
end;

function TPressMVPFactory.ExistSubClasses(
  AClasses: TClassList; AClass: TClass): Boolean;
var
  I: Integer;
begin
  for I := 0 to Pred(AClasses.Count) do
  begin
    Result := AClasses[I].InheritsFrom(AClass);
    if Result then
      Exit;
  end;
  Result := False;
end;

class function TPressMVPFactory.InternalServiceType: TPressServiceType;
begin
  Result := stMVPFactory;
end;

function TPressMVPFactory.MVPInteractorFactory(
  APresenter: TPressMVPPresenter): TPressMVPInteractorClasses;
var
  VInteractorClass: TPressMVPInteractorClass;
  VClasses: TClassList;
  I: Integer;
begin
  VClasses := TClassList.Create;
  try
    for I := 0 to Pred(FInteractors.Count) do
    begin
      VInteractorClass := TPressMVPInteractorClass(FInteractors[I]);
      if VInteractorClass.Apply(APresenter) and not
       ExistSubClasses(VClasses, VInteractorClass) then
      begin
        RemoveSuperClasses(VClasses, VInteractorClass);
        VClasses.Add(VInteractorClass);
      end;
    end;
    SetLength(Result, VClasses.Count);
    for I := 0 to Pred(VClasses.Count) do
      Result[I] := TPressMVPInteractorClass(VClasses[I]);
  finally
    VClasses.Free;
  end;
end;

function TPressMVPFactory.MVPModelFactory(
  AParent: TPressMVPModel; ASubject: TPressSubject): TPressMVPModel;
var
  VModelClass, VCandidateClass: TPressMVPModelClass;
  I: Integer;
begin
  if Assigned(ASubject) then
  begin
    VCandidateClass := nil;
    for I := 0 to Pred(FModels.Count) do
    begin
      VModelClass := TPressMVPModelClass(FModels[I]);
      if ASubject.InheritsFrom(VModelClass.Apply) and
       (not Assigned(VCandidateClass) or (ChooseConcreteClass(
       ASubject.ClassType, VCandidateClass.Apply, VModelClass.Apply) = 2)) then
        VCandidateClass := VModelClass;
    end;
    if not Assigned(VCandidateClass) then
      raise EPressMVPError.CreateFmt(SUnsupportedObject,
       [TPressMVPModel.ClassName, ASubject.ClassName]);
  end else
    raise EPressMVPError.Create(SUnassignedSubject);
  Result := VCandidateClass.Create(AParent, ASubject);
end;

function TPressMVPFactory.MVPPresenterFactory(
  AParent: TPressMVPFormPresenter;
  AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter;
var
  VPresenterClass, VCandidateClass: TPressMVPPresenterClass;
  I: Integer;
begin
  VCandidateClass := nil;
  for I := 0 to Pred(FPresenters.Count) do
  begin
    VPresenterClass := TPressMVPPresenterClass(FPresenters[I]);
    if VPresenterClass.Apply(AModel, AView) then
    begin
      if Assigned(VCandidateClass) then
        raise EPressMVPError.CreateFmt(SAmbiguousConcreteClass,
         [VCandidateClass.ClassName, VPresenterClass.ClassName,
         TPressMVPPresenter.ClassName, AModel.ClassName + ', ' + AView.ClassName]);
      VCandidateClass := VPresenterClass;
    end;
  end;
  if not Assigned(VCandidateClass) then
    raise EPressMVPError.CreateFmt(SUnsupportedObject,
     [TPressMVPPresenter.ClassName, AModel.ClassName + ', ' + AView.ClassName]);
  Result := VCandidateClass.Create(AParent, AModel, AView);
end;

function TPressMVPFactory.MVPViewFactory(AControl: TControl;
  AOwnsControl: Boolean): TPressMVPView;
var
  VViewClass, VCandidateClass: TPressMVPViewClass;
  I: Integer;
begin
  VCandidateClass := nil;
  for I := 0 to Pred(FViews.Count) do
  begin
    VViewClass := TPressMVPViewClass(FViews[I]);
    if VViewClass.Apply(AControl) then
    begin
      if Assigned(VCandidateClass) then
        raise EPressMVPError.CreateFmt(SAmbiguousConcreteClass,
         [VCandidateClass.ClassName, VViewClass.ClassName,
         AControl.ClassName, AControl.Name]);
      VCandidateClass := VViewClass;
    end;
  end;
  if not Assigned(VCandidateClass) then
    raise EPressMVPError.CreateFmt(SUnsupportedControl,
     [AControl.ClassName, AControl.Name]);
  Result := VCandidateClass.Create(AControl, AOwnsControl);
end;

procedure TPressMVPFactory.RegisterForm(
  APresenterClass: TPressMVPFormPresenterClass;
  AObjectClass: TPressObjectClass; AFormClass: TFormClass;
  AFormPresenterType: TPressMVPFormPresenterType);
begin
  Forms.Add(TPressMVPRegisteredForm.Create(
   APresenterClass, AObjectClass, AFormClass, AFormPresenterType));
end;

procedure TPressMVPFactory.RegisterInteractor(
  AInteractorClass: TPressMVPInteractorClass);
begin
  FInteractors.Add(AInteractorClass);
end;

procedure TPressMVPFactory.RegisterModel(AModelClass: TPressMVPModelClass);
begin
  FModels.Add(AModelClass);
end;

procedure TPressMVPFactory.RegisterPresenter(
  APresenterClass: TPressMVPPresenterClass);
begin
  FPresenters.Add(APresenterClass);
end;

procedure TPressMVPFactory.RegisterView(AViewClass: TPressMVPViewClass);
begin
  FViews.Add(AViewClass);
end;

procedure TPressMVPFactory.RemoveSuperClasses(
  AClasses: TClassList; AClass: TClass);
var
  I: Integer;
begin
  for I := Pred(AClasses.Count) downto 0 do
    if AClass.InheritsFrom(AClasses[I]) then
      AClasses.Delete(I);
end;

end.