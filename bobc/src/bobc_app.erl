%%%-------------------------------------------------------------------
%% @doc bobc public API
%% @end
%%%-------------------------------------------------------------------

-module(bobc_app).

-behaviour(application).

-export([start/2, stop/1]).
-record(state, {pid_server}).

start(_StartType, _StartArgs) ->
    {ok,Pid_server} = local_back:start_link(),
    {ok, Port} = application:get_env(bobc, port),
    State = #state{pid_server = Pid_server},
    Dispatch = cowboy_router:compile([
            {'_', [
                {"/", bobc_handler, []},
                {"/websocket", websocket_handler, State}
            ]}
        ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, Port}],
        #{env => #{dispatch => Dispatch}}
        ),    

    bobc_sup:start_link().

stop(_State) ->
    ok.

%% internal functions