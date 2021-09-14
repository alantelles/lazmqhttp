unit LazMqHttp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TPayloadEncoding = (peString, peBase64);

  TLazMqHttpClient = class
    private
      FExchange: string;
      FQueue: string;
      FRoutingKey: string;
      FVhost: string;
    public
      property Exchange: string read FExchange write FExchange;
      property Queue: string read FQueue write FQueue;
      property RoutingKey: string read FRoutingKey write FRoutingKey;
      property VHost: string read FVhost write FVhost;
      constructor Create(AExchange: string; AQueue: string; ARoutingKey: string; AVhost: string);
      function Publish(Payload: string; PayloadEncodingIsString: boolean=True): boolean;
  end;


implementation

uses fphttpclient, StrUtils;

constructor TLazMqHttpClient.Create(AExchange: string; AQueue: string; ARoutingKey: string; AVhost: string);
begin
  FExchange := AExchange;
  FQueue := AQueue;
  FRoutingKey := ARoutingKey;
  FVhost := AVhost;
end;

function TLazMqHttpClient.Publish(Payload: string; PayloadEncodingIsString: boolean=True): boolean;
var
  HttpClient: TFpHttpClient;
  StrStream: TStringStream;
  Response, FullPayload: string;
  PayloadAsString: string = 'base64';
begin
  HttpClient := TFPHttpClient.Create(nil);
  HttpClient.UserName := 'guest';
  HttpClient.Password := 'guest';
  if PayloadencodingIsString then
    PayloadAsString := 'string';
  FullPayload := '{"properties": {}, "routing_key": "' + FRoutingKey + '", "payload": "' + ReplaceStr(Payload, '"', '\"') + '", "payload_encoding" : "' + PayloadAsString + '"}';
  StrStream := TStringStream.Create(FullPayload);
  HttpClient.RequestBody := StrStream;
  HttpClient.AddHeader('Content-Type', 'application/json');
  Response := HttpClient.Post('http://localhost:15672/api/exchanges/' + FVhost + '/' + FExchange + '/publish');
  if Response = '{"routed":true}' then
    Result := True
  else
    Result := False;
end;

end.

