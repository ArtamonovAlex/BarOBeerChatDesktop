%%%-------------------------------------------------------------------
%% @doc bobc public API
%% @end
%%%-------------------------------------------------------------------

-module(bobc_app).

-behaviour(application).

-export([start/2, stop/1]).
-record(state, {pid_server}).

start(_StartType, _StartArgs) ->
    {ok, Port} = application:get_env(bobc, port),
    {ok, User} = application:get_env(bobc, user),
    {ok, Back} = application:get_env(bobc, back),
    {ok,Pid_server} = local_back:start_link(Back, User),
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