(*
  PressObjects, Lazarus Component Library (LCL) Broker
  Copyright (C) 2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressLCLBroker;

{$I Press.inc}

interface

uses
  Forms,
  PressMVPPresenter;

procedure PressLCLForm(APresenter: TPressMVPFormPresenterClass; AForm: TFormClass);

implementation

uses
  PressXCLBroker;

procedure PressLCLForm(
  APresenter: TPressMVPFormPresenterClass; AForm: TFormClass);
begin
  PressXCLForm(APresenter, AForm);
end;

end.
