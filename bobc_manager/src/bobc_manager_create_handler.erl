-module(bobc_manager_create_handler).

-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    Body =
        case create_chat_room() of
            {error, Reason} ->
                #{status => error, reason => Reason};
            {ok, ChatId} ->
                #{status => ok, chat_id => list_to_binary(ChatId)}
        end,
    Req = cowboy_req:reply(200,
        #{<<"content-type">> => <<"text/plain; charset=utf-8">>},
        jsone:encode(Body),
        Req0),
    {ok, Req, State}.


create_chat_room() ->
    {ok, "testroom"}.