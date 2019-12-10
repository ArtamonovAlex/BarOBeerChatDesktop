-module(websocket_handler).

-behavior(cowboy_websocket).

-export([init/2, websocket_handle/2, websocket_info/2, websocket_init/1]).
-record(state, {pid_server}).



init(Req, State) ->
  {cowboy_websocket, Req, State}.

websocket_init(State) ->
	PidServer = State#state.pid_server,
  {ok, Msgs} = gen_server:call(PidServer, {websocket_init, self()}),
   Reply = [{text, jsone:encode(Msg)}|| Msg<- Msgs],
  	{Reply, State}.

websocket_handle({text, Msg}, State) ->
  io:format("Got: ~p~n", [Msg]),
  PidServer = State#state.pid_server,
  gen_server:cast(PidServer,{forward, Msg}),
  {[], State};

websocket_handle(_Data, State) ->
  {[], State}.

websocket_info({send, Msg}, State) ->
  Reply = [{text, jsone:encode(Msg)}],
  {Reply, State};

websocket_info(_Info, State) ->
  {[], State}.