program lazmqexample;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, lazmqhttp
  { you can add units after this };
var
  Cli: TLazMqHttpClient;
begin
  Cli := TLazMqHttpClient.Create('lazmqdevexc', 'local.libdev.queue', 'local_lazmq_route', 'lazmqdevhost');
  writeln(Cli.Publish('zika'));
  Cli.Free;
end.

