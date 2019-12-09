-module(bobc_manager_signup_handler).

-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
   	Req = sign_up(Req0),
    {ok, Req, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Returns reply with body = registered if successfully save user in Mnesia,       %%
%%  Reason if not; Possible reasons: already_exists, bad_request, ???               %%
%%%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sign_up(Req0) ->
    HasBody = cowboy_req:has_body(Req0),

    {Login, Password} =
        case cowboy_req:method(Req0) of
            <<"POST">> when HasBody ->
                {ok, PostParams, _Req} = cowboy_req:read_urlencoded_body(Req0),
                Maybe_Login = proplists:get_value(<<"login">>, PostParams),
                Maybe_Password = proplists:get_value(<<"password">>, PostParams),
                {Maybe_Login, Maybe_Password};
            _ ->
                {undefined, undefined}
        end,

    {Code, ResponseBody} =
        case {Login, Password} of
            {_,undefined} ->
                {400, bad_request};
            {undefined,_} ->
                {400, bad_request};
            {Login, Password} ->
                {200, save_new_user(Login, Password)}
        end,
    JsonBody = jsone:encode(ResponseBody),
    cowboy_req:reply(Code,#{<<"content-type">> => <<"text/plain; charset=utf-8">>}, JsonBody, Req0).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  TODO: Returns registered if successfully save user in Mnesia, Reason if not  %%
%%  Possible reasons: already_exists, ???                                                       %%
%%%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save_new_user(_Login, _Password) ->
    registered.