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
    public
      property Exchange: string read FExchange write FExchange;
      property Queue: string read FQueue write FQueue;
      property RoutingKey: string read FRoutingKey write FRoutingKey;
      constructor Create(AExchange: string; AQueue: string; ARoutingKey: string);
      function Publish(Payload: string; PayloadEncoding: TPayloadEncoding): boolean;
  end;


implementation

uses fphttpclient;

constructor TLazMqHttpClient.Create(AExchange: string; AQueue: string; ARoutingKey: string);
begin
  FExchange := AExchange;
  FQueue := AQueue;
  FRoutingKey := ARoutingKey;
end;

function TLazMqHttpClient.Publish(Payload: string; PayloadEncoding: TPayloadEncoding): boolean;
begin
  Result := False;
end;

end.

