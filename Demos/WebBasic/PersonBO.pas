unit PersonBO;

{$mode objfpc}{$H+}

interface

uses
  PressSubject,
  PressAttributes;

type

  { TPerson }

  TPerson = class(TPressObject)
    _Name: TPressString;
  private
    function GetName: string;
    procedure SetName(AValue: string);
  protected
    class function InternalMetadataStr: string; override;
  published
    property Name: string read GetName write SetName;
  end;

implementation

{ TPerson }

function TPerson.GetName: string;
begin
  Result := _Name.Value;
end;

procedure TPerson.SetName(AValue: string);
begin
  _Name.Value := AValue;
end;

class function TPerson.InternalMetadataStr: string;
begin
  Result := 'TPerson IsPersistent PersistentName="Person" (' +
   'Name: String(60) PersistentName="PersonName";' +
   ')';
end;

initialization
  TPerson.RegisterClass;

finalization
  TPerson.UnregisterClass;

end.

