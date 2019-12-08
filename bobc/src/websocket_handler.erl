-module(websocket_handler).

-behavior(cowboy_websocket).

-export([init/2, websocket_handle/2, websocket_info/2, websocket_init/1]).
-record(state, {pid_server}).



init(Req, State) ->
  {cowboy_websocket, Req, State}.

websocket_init(State) ->
	PidServer = State#state.pid_server,
  	gen_server:cast(PidServer, {websocket, self()}),
  	{[{text, <<"Hello!">>}], State}.

websocket_handle({text, Msg}, State) ->
  io:format("Got: ~p~n", [Msg]),
  {[], State};

websocket_handle(_Data, State) ->
  {[], State}.

websocket_info({send, Msg}, State) ->
  {[{text, Msg}], State};

websocket_info(_Info, State) ->
  {[], State}.