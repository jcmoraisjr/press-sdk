(*
  PressObjects, MVP-Factory Class
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

uses
  Controls,
  Contnrs,
  PressApplication,
  PressSubject,
  PressMVP,
  PressMVPView,
  PressMVPPresenter;

type
  TPressMVPFactory = class(TPressService)
  { TODO : Refactor }
  private
    FInteractors: TClassList;
    FModels: TClassList;
    FPresenters: TClassList;
    FViews: TClassList;
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
    procedure RegisterModel(AModelClass: TPressMVPModelClass);
    procedure RegisterPresenter(APresenterClass: TPressMVPPresenterClass);
    procedure RegisterView(AViewClass: TPressMVPViewClass);
  end;

function PressDefaultMVPFactory: TPressMVPFactory;

implementation

uses
  PressConsts;

{ TPressMVPFactory }

function PressDefaultMVPFactory: TPressMVPFactory;
begin
  with PressApp.Registry[stMVPFactory] do
  begin
    if not HasDefaultService then
      RegisterService(TPressMVPFactory, False);
    Result := DefaultService as TPressMVPFactory;
  end;
end;

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
