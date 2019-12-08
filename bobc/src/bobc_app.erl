%%%-------------------------------------------------------------------
%% @doc bobc public API
%% @end
%%%-------------------------------------------------------------------

-module(bobc_app).

-behaviour(application).

-export([start/2, stop/1]).
-record(state, {pid_server}).

start(_StartType, _StartArgs) ->
    {ok, Internal} = application:get_env(bobc, internal),
    {ok, Remote} = application:get_env(bobc, remote),
    {ok, External} = application:get_env(bobc, external),
    {ok, Pid_server} = local_back:start_link(External, Remote),
    State = #state{pid_server = Pid_server},
    Dispatch = cowboy_router:compile([
            {'_', [
                {"/", bobc_handler, []},
                {"/websocket", websocket_handler, State}
            ]}
        ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, Internal}],
        #{env => #{dispatch => Dispatch}}
        ),    

    bobc_sup:start_link().

stop(_State) ->
    ok.

%% internal functions