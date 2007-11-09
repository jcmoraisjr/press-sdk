(*
  PressObjects, English Translation Class
  Copyright (C) 2007 Joao Morais, Steven Mitchell

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMessages_en;

{$I Press.inc}

interface

uses
  PressApplication;

type
  TPressMessages_en = class(TPressMessages)
  protected
    procedure InternalIsDefaultChanged; override;
  end;

implementation

uses
  PressConsts;

resourcestring
  {$I PressMessages_en.inc}

{ TPressMessages_en }

procedure TPressMessages_en.InternalIsDefaultChanged;
begin
  if IsDefault then
  begin
    {$I PressMessages.inc}
  end;
  inherited;
end;

initialization
  TPressMessages_en.RegisterService;

end.
