unit WebHelloWorld;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs,
  PressWebHandler;

type

  { THelloWorldRequestHandler }

  THelloWorldRequestHandler = class(TInterfacedObject, IPressWebRequestHandler)
  protected
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse);
  end;

implementation

{ THelloWorldRequestHandler }

procedure THelloWorldRequestHandler.HandleRequest(ARequest: TRequest; AResponse: TResponse);
begin
  AResponse.Contents.Add('Hello World!');
end;

initialization
  TPressWebHandler.DefaultService.RegisterRequestHandler('/hello', THelloWorldRequestHandler.Create);

end.

