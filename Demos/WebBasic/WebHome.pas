unit WebHome;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs,
  PressWebHandler;

type

  { TWebIndexRequestHandler }

  TWebIndexRequestHandler = class(TInterfacedObject, IPressWebRequestHandler)
  protected
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse);
  end;

  { TWebHomeRequestHandler }

  TWebHomeRequestHandler = class(TInterfacedObject, IPressWebRequestHandler)
  protected
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse);
  end;

implementation

{ TWebIndexRequestHandler }

procedure TWebIndexRequestHandler.HandleRequest(ARequest: TRequest;
  AResponse: TResponse);
begin
  AResponse.Contents.Add('<a href="WebBasic/">Go Home</a><br/>');
end;

{ TWebHomeRequestHandler }

procedure TWebHomeRequestHandler.HandleRequest(ARequest: TRequest;
  AResponse: TResponse);
begin
  AResponse.Contents.Add('<a href="hello">Hello</a><br/>');
  AResponse.Contents.Add('<a href="info">Info</a><br/>');
end;

initialization
  TPressWebHandler.DefaultService.RegisterRequestHandler('', TWebIndexRequestHandler.Create);
  TPressWebHandler.DefaultService.RegisterRequestHandler('/', TWebHomeRequestHandler.Create);

end.

