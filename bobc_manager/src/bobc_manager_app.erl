%%%-------------------------------------------------------------------
%% @doc bobc_manager public API
%% @end
%%%-------------------------------------------------------------------

-module(bobc_manager_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    {ok, Port} = application:get_env(bobc_manager, port),
    Dispatch = cowboy_router:compile([
            {'_', [
                %%POST - params: [Login, Password] - reply: {ok, registered} / {error, Reason}
                {"/signup", bobc_manager_signup_handler, []},
                %%POST - params: [Login, Password] - reply: {ok, signed_in} / {error, Reason}
                {"/signin", bobc_manager_signin_handler, []},
                %%GET - params: Chat_id - reply: [UserAddress, UserAddress, ...]; UserAddress = {IP, Port}; IP = {int,int,int,int}; Port = int
                {"/connect/:chat_id", bobc_manager_connect_handler, []},
                %%GET = params: _ - reply: {ok, Chat_id} / {error, Reason}
                {"/create", bobc_manager_create_handler, []}
            ]}
        ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, Port}],
        #{env => #{dispatch => Dispatch}}
        ),    

    bobc_manager_sup:start_link().

stop(_State) ->
    ok.

%% internal functions